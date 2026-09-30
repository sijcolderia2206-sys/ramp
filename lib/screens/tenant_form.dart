import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../core/theme/ramp_theme.dart';
import '../core/validation/app_validators.dart';
import '../providers/providers.dart';

class TenantFormScreen extends ConsumerStatefulWidget {
  final Tenant? existingTenant;

  const TenantFormScreen({super.key, this.existingTenant});

  @override
  ConsumerState<TenantFormScreen> createState() => _TenantFormScreenState();
}

class _TenantFormScreenState extends ConsumerState<TenantFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _addressCtrl;
  late final TextEditingController _referralCtrl;
  late final TextEditingController _messengerCtrl;
  late final TextEditingController _unitCtrl;
  late final TextEditingController _rentCtrl;
  late final TextEditingController _balanceCtrl;
  String? _selectedUnitId;
  late DateTime _leaseStart;
  late DateTime _leaseEnd;
  late DateTime _dueDate;
  bool _isSaving = false;

  bool get _isEditing => widget.existingTenant != null;

  DateTime get _minimumTenantDate {
    final now = DateTime.now();
    return DateTime(now.year, 1, 1);
  }

  @override
  void initState() {
    super.initState();
    final tenant = widget.existingTenant;
    _nameCtrl = TextEditingController(text: tenant?.name ?? '');
    _phoneCtrl = TextEditingController(text: tenant?.phone ?? '');
    _addressCtrl = TextEditingController(text: tenant?.address ?? '');
    _referralCtrl = TextEditingController(text: tenant?.referral ?? '');
    _messengerCtrl = TextEditingController(text: tenant?.messengerHandle ?? '');
    _unitCtrl = TextEditingController(text: tenant?.unitNumber ?? '');
    _selectedUnitId = tenant?.unitId.isNotEmpty == true ? tenant!.unitId : null;
    _rentCtrl =
        TextEditingController(text: tenant?.monthlyRent.toString() ?? '');
    _balanceCtrl =
        TextEditingController(text: tenant?.balance.toString() ?? '0');
    _leaseStart = tenant?.leaseStart.isBefore(_minimumTenantDate) == true
        ? _minimumTenantDate
        : (tenant?.leaseStart ?? DateTime.now());
    _leaseEnd = tenant?.leaseEnd.isBefore(_minimumTenantDate) == true
        ? _minimumTenantDate.add(const Duration(days: 365))
        : (tenant?.leaseEnd ?? DateTime.now().add(const Duration(days: 365)));
    _dueDate = tenant?.dueDate.isBefore(_minimumTenantDate) == true
        ? _minimumTenantDate
        : (tenant?.dueDate ?? DateTime.now().add(const Duration(days: 5)));
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _referralCtrl.dispose();
    _messengerCtrl.dispose();
    _unitCtrl.dispose();
    _rentCtrl.dispose();
    _balanceCtrl.dispose();
    super.dispose();
  }

  Future<bool> _confirmLeave() async {
    return await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('Leave tenant form?'),
            content: const Text(
                'Any information entered on this page will be discarded.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('KEEP EDITING'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: const Text('LEAVE'),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _pickDate(
      String label, DateTime current, ValueChanged<DateTime> onSelected) async {
    final picked = await showDatePicker(
      context: context,
      initialDate:
          current.isBefore(_minimumTenantDate) ? _minimumTenantDate : current,
      firstDate: _minimumTenantDate,
      lastDate: DateTime(2100),
      helpText: label,
    );
    if (picked != null && mounted) setState(() => onSelected(picked));
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final name = _nameCtrl.text.trim();
    final units = ref.read(unitProvider);
    final selectedUnit =
        units.where((unit) => unit.id == _selectedUnitId).firstOrNull;
    final rent = double.tryParse(_rentCtrl.text.trim()) ?? 0;
    final balance = double.tryParse(_balanceCtrl.text.trim()) ?? 0;

    if (rent < 0 || balance < 0) {
      _showError('Rent and balance must be valid non-negative amounts.');
      return;
    }
    if (_isEditing &&
        selectedUnit != null &&
        (_leaseStart.isBefore(_minimumTenantDate) ||
            _leaseEnd.isBefore(_minimumTenantDate) ||
            _dueDate.isBefore(_minimumTenantDate))) {
      _showError(
          'Lease and rent due dates must be within this year or a future year.');
      return;
    }
    if (_isEditing && selectedUnit != null && _leaseEnd.isBefore(_leaseStart)) {
      _showError('Lease end date must be after the lease start date.');
      return;
    }

    setState(() => _isSaving = true);
    final tenant = Tenant(
      id: widget.existingTenant?.id ??
          't_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      email: '',
      phone: _phoneCtrl.text.trim(),
      address: _addressCtrl.text.trim(),
      referral: _referralCtrl.text.trim(),
      messengerHandle: _messengerCtrl.text.trim(),
      reminderCount: widget.existingTenant?.reminderCount ?? 0,
      unitId: _isEditing ? (selectedUnit?.id ?? '') : '',
      unitNumber: _isEditing
          ? (selectedUnit?.unitNumber ?? 'Unassigned')
          : 'Unassigned',
      monthlyRent: _isEditing && selectedUnit != null ? rent : 0,
      balance: _isEditing && selectedUnit != null ? balance : 0,
      leaseStart: _leaseStart,
      leaseEnd: _leaseEnd,
      dueDate: _dueDate,
      status: selectedUnit == null ? 'Unassigned' : 'Active',
      isArchived: widget.existingTenant?.isArchived ?? false,
      avatarUrl: widget.existingTenant?.avatarUrl,
    );

    if (_isEditing) {
      final previousUnitId = widget.existingTenant!.unitId;
      ref.read(tenantProvider.notifier).updateTenant(tenant);
      if (previousUnitId.isNotEmpty && previousUnitId != selectedUnit?.id) {
        ref.read(unitProvider.notifier).markVacant(previousUnitId);
      }
      if (selectedUnit != null) {
        ref.read(unitProvider.notifier).updateUnit(selectedUnit.copyWith(
              status: 'Occupied',
              tenantId: tenant.id,
              tenantName: tenant.name,
            ));
      }
    } else {
      ref.read(tenantProvider.notifier).addTenant(tenant);
    }
    if (!mounted) return;
    Navigator.pop(context, true);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: RampColors.danger,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _section(String title, IconData icon, List<Widget> children) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: RampColors.primary),
              const SizedBox(width: 10),
              Text(title,
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 15)),
            ],
          ),
          const SizedBox(height: 18),
          ...children,
        ],
      ),
    );
  }

  Widget _field(String label, TextEditingController controller,
      {TextInputType? keyboardType,
      int maxLines = 1,
      String? Function(String?)? validator}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      inputFormatters: keyboardType == TextInputType.phone
          ? [FilteringTextInputFormatter.allow(RegExp(r'[0-9+() -]'))]
          : null,
      decoration: InputDecoration(labelText: label),
    );
  }

  Widget _dateField(String label, DateTime date, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: const Icon(Icons.calendar_today_outlined),
        ),
        child: Text(DateFormat('MMM d, yyyy').format(date)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
          color: isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1)),
    );
    final formTheme = theme.copyWith(
      inputDecorationTheme: theme.inputDecorationTheme.copyWith(
        filled: true,
        fillColor: isDark ? const Color(0xFF172033) : const Color(0xFFF8FAFC),
        border: border,
        enabledBorder: border,
        focusedBorder: border.copyWith(
            borderSide: const BorderSide(color: RampColors.primary, width: 2)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      ),
    );
    final units = ref.watch(unitProvider);
    final availableUnits = units
        .where((unit) =>
            unit.isVacant ||
            (_isEditing && unit.id == widget.existingTenant?.unitId))
        .toList();

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final shouldLeave = await _confirmLeave();
        if (shouldLeave && context.mounted) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
              _isEditing ? 'Edit Tenant Profile' : 'Register New Tenant',
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600, fontSize: 17)),
        ),
        body: Theme(
          data: formTheme,
          child: SafeArea(
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 680),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: RampColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                                color:
                                    RampColors.primary.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: RampColors.primary,
                                child: Icon(
                                  _isEditing
                                      ? Icons.edit_note_rounded
                                      : Icons.person_add_alt_1_rounded,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _isEditing
                                      ? 'Update tenant details and lease information.'
                                      : 'Create an unassigned tenant profile now. Unit, lease, and billing details can be added from the profile later.',
                                  style: TextStyle(
                                      color: isDark
                                          ? const Color(0xFFCBD5E1)
                                          : const Color(0xFF475569),
                                      height: 1.5),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        _section('Tenant Information', Icons.person_outline, [
                          _field('Full Name', _nameCtrl,
                              validator: (value) => AppValidators.personName(
                                  value,
                                  label: 'tenant name')),
                          const SizedBox(height: 16),
                          _field('Home Address', _addressCtrl,
                              maxLines: 2,
                              validator: (value) =>
                                  value == null || value.trim().isEmpty
                                      ? 'Enter the tenant address.'
                                      : null),
                          const SizedBox(height: 16),
                          _field('Phone Number (SMS)', _phoneCtrl,
                              keyboardType: TextInputType.phone,
                              validator: AppValidators.philippinePhone),
                          const SizedBox(height: 16),
                          _field('Facebook / Messenger Username (optional)', _messengerCtrl),
                          const SizedBox(height: 16),
                          _field('Referral (optional)', _referralCtrl),
                        ]),
                        if (_isEditing) ...[
                          const SizedBox(height: 20),
                          _section('Unit & Billing', Icons.apartment_outlined, [
                            DropdownButtonFormField<String>(
                              initialValue: availableUnits
                                      .any((unit) => unit.id == _selectedUnitId)
                                  ? _selectedUnitId
                                  : null,
                              decoration: const InputDecoration(
                                  labelText: 'Assigned Unit (optional)',
                                  hintText: 'Leave empty to keep unassigned'),
                              items: availableUnits
                                  .map((unit) => DropdownMenuItem(
                                        value: unit.id,
                                        child: Text(
                                            '${unit.name} • ${unit.formattedRent}'),
                                      ))
                                  .toList(),
                              onChanged: (value) =>
                                  setState(() => _selectedUnitId = value),
                            ),
                            if (availableUnits.isEmpty) ...[
                              const SizedBox(height: 8),
                              const Text(
                                'No vacant units are available. Add or mark a unit vacant first.',
                                style: TextStyle(color: RampColors.danger),
                              ),
                            ],
                            const SizedBox(height: 16),
                            _field('Monthly Rent (₱)', _rentCtrl,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                        decimal: true),
                                validator: (value) => _selectedUnitId == null
                                    ? null
                                    : AppValidators.amount(value,
                                        label: 'monthly rent')),
                            const SizedBox(height: 16),
                            _field('Outstanding Balance (₱)', _balanceCtrl,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                        decimal: true),
                                validator: (value) => _selectedUnitId == null
                                    ? null
                                    : AppValidators.amount(value,
                                        label: 'outstanding balance',
                                        allowZero: true)),
                          ]),
                          const SizedBox(height: 20),
                          _section(
                              'Lease Schedule', Icons.event_note_outlined, [
                            _dateField(
                                'Lease Start',
                                _leaseStart,
                                () => _pickDate('Lease start date', _leaseStart,
                                    (value) => _leaseStart = value)),
                            const SizedBox(height: 16),
                            _dateField(
                                'Lease End',
                                _leaseEnd,
                                () => _pickDate('Lease end date', _leaseEnd,
                                    (value) => _leaseEnd = value)),
                            const SizedBox(height: 16),
                            _dateField(
                                'Rent Due Date',
                                _dueDate,
                                () => _pickDate('Rent due date', _dueDate,
                                    (value) => _dueDate = value)),
                          ]),
                        ],
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: FilledButton.icon(
                            onPressed: _isSaving ? null : _save,
                            icon: _isSaving
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2, color: Colors.white))
                                : const Icon(Icons.save_rounded),
                            label: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(_isEditing
                                  ? 'SAVE TENANT CHANGES'
                                  : 'CREATE UNASSIGNED PROFILE'),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
