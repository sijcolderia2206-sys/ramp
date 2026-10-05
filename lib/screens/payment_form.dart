// lib/screens/payment_form.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../core/navigation/custom_page_transitions.dart';
import '../core/theme/ramp_theme.dart';
import '../core/utils/toast_service.dart';
import '../core/widgets/bouncing_interactive.dart';
import '../core/widgets/clay_container.dart';
import '../core/widgets/ramp_text_field.dart';
import '../providers/providers.dart';

class PaymentFormScreen extends ConsumerStatefulWidget {
  final Tenant? initialTenant;

  const PaymentFormScreen({super.key, this.initialTenant});

  @override
  ConsumerState<PaymentFormScreen> createState() => _PaymentFormScreenState();
}

class _PaymentFormScreenState extends ConsumerState<PaymentFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _monthCtrl;
  late final TextEditingController _amountCtrl;
  late final TextEditingController _refCtrl;
  late final TextEditingController _baseRentCtrl;
  late final TextEditingController _waterCtrl;
  late final TextEditingController _electricCtrl;
  late final TextEditingController _lateFeeCtrl;

  static const _paymentMethods = ['GCash', 'Maya', 'Bank Transfer', 'Cash'];
  String _selectedMethod = 'GCash';
  Tenant? _selectedTenant;
  bool _isSaving = false;

  final _currencyFormat = NumberFormat.currency(
    locale: 'en_PH',
    symbol: '₱',
    decimalDigits: 2,
  );

  @override
  void initState() {
    super.initState();
    _monthCtrl = TextEditingController(
      text: DateFormat('MMMM yyyy').format(DateTime.now()),
    );
    _refCtrl = TextEditingController();
    _baseRentCtrl = TextEditingController();
    _waterCtrl = TextEditingController(text: '0.00');
    _electricCtrl = TextEditingController(text: '0.00');
    _lateFeeCtrl = TextEditingController(text: '0.00');
    _amountCtrl = TextEditingController();

    final allTenants = ref.read(tenantProvider);
    _selectedTenant = widget.initialTenant ??
        allTenants.where((t) => !t.isArchived).firstOrNull ??
        allTenants.firstOrNull;

    if (_selectedTenant != null) {
      _applyTenantCharges(_selectedTenant!);
    }
  }

  @override
  void dispose() {
    _monthCtrl.dispose();
    _amountCtrl.dispose();
    _refCtrl.dispose();
    _baseRentCtrl.dispose();
    _waterCtrl.dispose();
    _electricCtrl.dispose();
    _lateFeeCtrl.dispose();
    super.dispose();
  }

  static String _formatAmount(double? amount) {
    final double v = amount ?? 0.0;
    return v.toStringAsFixed(2);
  }

  void _applyTenantCharges(Tenant selected) {
    final unit = ref
        .read(unitProvider)
        .where((item) => item.id == selected.unitId)
        .firstOrNull;
    final rates = ref.read(utilityRateProvider);

    double water = 0.0;
    if (unit != null && unit.waterUtilityEnabled) {
      water = unit.waterUsage * unit.effectiveWaterRate(rates.waterRate);
    }

    double electricity = 0.0;
    if (unit != null && unit.electricityUtilityEnabled) {
      electricity = unit.electricUsage *
          unit.effectiveElectricityRate(rates.electricityRate);
    }

    double lateFee = 0.0;
    if (selected.isLate) {
      lateFee = unit?.lateFee ?? ref.read(lateFeeAmountProvider);
    }

    final double baseRent = selected.monthlyRent;

    _baseRentCtrl.text = _formatAmount(baseRent);
    _waterCtrl.text = _formatAmount(water);
    _electricCtrl.text = _formatAmount(electricity);
    _lateFeeCtrl.text = _formatAmount(lateFee);
    _recalculateTotal();
  }

  void _recalculateTotal() {
    final baseRent = double.tryParse(_baseRentCtrl.text.trim()) ?? 0.0;
    final water = double.tryParse(_waterCtrl.text.trim()) ?? 0.0;
    final electric = double.tryParse(_electricCtrl.text.trim()) ?? 0.0;
    final lateFee = double.tryParse(_lateFeeCtrl.text.trim()) ?? 0.0;

    _amountCtrl.text = _formatAmount(baseRent + water + electric + lateFee);
  }

  Future<bool> _confirmLeave() async {
    return await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('Leave payment form?'),
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

  Future<void> _savePayment() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final month = _monthCtrl.text.trim().isEmpty
        ? DateFormat('MMM yyyy').format(DateTime.now())
        : _monthCtrl.text.trim();
    final refNum = _refCtrl.text.trim().isEmpty
        ? 'REF-${DateTime.now().millisecondsSinceEpoch.toString().substring(6)}'
        : _refCtrl.text.trim();

    final baseRent = double.tryParse(_baseRentCtrl.text.trim()) ?? 0.0;
    final water = double.tryParse(_waterCtrl.text.trim()) ?? 0.0;
    final electric = double.tryParse(_electricCtrl.text.trim()) ?? 0.0;
    final lateFee = double.tryParse(_lateFeeCtrl.text.trim()) ?? 0.0;
    final totalPaid = double.tryParse(_amountCtrl.text.trim()) ??
        (baseRent + water + electric + lateFee);

    if (totalPaid <= 0) {
      ToastService.showError('Please enter a valid amount paid.');
      return;
    }

    final confirmed = await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('Record this payment?'),
            content: Text(
                'Add payment of ${_currencyFormat.format(totalPaid)} to ${_selectedTenant?.name ?? "tenant"} and recalculate balance?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('CANCEL'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: const Text('CONFIRM'),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirmed || !mounted) return;

    setState(() => _isSaving = true);

    final tenantUnit = _selectedTenant == null
        ? null
        : ref
            .read(unitProvider)
            .where((unit) => unit.id == _selectedTenant!.unitId)
            .firstOrNull;

    final newPayment = PaymentData(
      month: month,
      amount: totalPaid,
      method: _selectedMethod,
      paymentMethod: _selectedMethod,
      date: DateTime.now(),
      paymentDate: DateTime.now(),
      status: 'Paid',
      referenceNumber: refNum,
      unitId: _selectedTenant?.unitId ?? tenantUnit?.id ?? 'u1',
      unitNumber:
          _selectedTenant?.unitNumber ?? tenantUnit?.unitNumber ?? 'Unit 1',
      tenantId: _selectedTenant?.id ?? '',
      tenantName: _selectedTenant?.name ?? 'Tenant',
      baseRent: baseRent > 0 ? baseRent : totalPaid,
      waterBill: water,
      electricBill: electric,
      lateFee: lateFee,
    );

    ref.read(paymentProvider.notifier).addPayment(newPayment);

    if (!mounted) return;

    Navigator.pop(context, true);
    ToastService.showSuccess('Payment for $month recorded successfully! Ref: $refNum');
  }

  Widget _section(String title, IconData icon, List<Widget> children) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE0E5EC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withValues(alpha: 0.5) : const Color(0xFFA3B1C6).withValues(alpha: 0.6),
            blurRadius: 10,
            offset: const Offset(5, 5),
          ),
          BoxShadow(
            color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white.withValues(alpha: 0.8),
            blurRadius: 10,
            offset: const Offset(-5, -5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: RampColors.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          ...children,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final allTenants = ref.watch(tenantProvider);

    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
        color: isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
      ),
    );

    final formTheme = theme.copyWith(
      inputDecorationTheme: theme.inputDecorationTheme.copyWith(
        filled: true,
        fillColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFE0E5EC),
        border: border,
        enabledBorder: border,
        focusedBorder: border.copyWith(
          borderSide: const BorderSide(color: RampColors.primary, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      ),
    );

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
        backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFE0E5EC),
        appBar: AppBar(
          backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFE0E5EC),
          title: Text(
            'Record Payment',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 17,
            ),
          ),
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
                        // Header Banner
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE0E5EC),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: RampColors.primary.withValues(alpha: 0.3),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: isDark ? Colors.black.withValues(alpha: 0.5) : const Color(0xFFA3B1C6).withValues(alpha: 0.6),
                                blurRadius: 10,
                                offset: const Offset(5, 5),
                              ),
                              BoxShadow(
                                color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white.withValues(alpha: 0.8),
                                blurRadius: 10,
                                offset: const Offset(-5, -5),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              const CircleAvatar(
                                backgroundColor: RampColors.primary,
                                child: Icon(
                                  Icons.payments_rounded,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Record Rental Payment',
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                        color: isDark
                                            ? Colors.white
                                            : RampColors.slate,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Log tenant rent, utility charges, and payment details to update balance.',
                                      style: TextStyle(
                                        color: isDark
                                            ? const Color(0xFFCBD5E1)
                                            : const Color(0xFF475569),
                                        fontSize: 12.5,
                                        height: 1.4,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Section 1: Tenant & Unit
                        _section(
                          'Tenant & Unit Selection',
                          Icons.person_outline_rounded,
                          [
                            if (widget.initialTenant == null &&
                                allTenants.isNotEmpty) ...[
                              DropdownButtonFormField<String>(
                                isExpanded: true,
                                initialValue: _selectedTenant?.id,
                                decoration: const InputDecoration(
                                  labelText: 'Select Tenant and Unit',
                                  prefixIcon:
                                      Icon(Icons.person_outline_rounded),
                                ),
                                items: allTenants
                                    .map((item) => DropdownMenuItem(
                                          value: item.id,
                                          child: Text(
                                            '${item.name} • ${item.unitNumber}${item.isFormer ? ' (Former)' : ''}',
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ))
                                    .toList(),
                                onChanged: (tenantId) {
                                  setState(() {
                                    _selectedTenant = allTenants
                                        .where((item) => item.id == tenantId)
                                        .firstOrNull;
                                    if (_selectedTenant != null) {
                                      _applyTenantCharges(_selectedTenant!);
                                    }
                                  });
                                },
                              ),
                              const SizedBox(height: 12),
                            ],
                            if (_selectedTenant != null) ...[
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE0E5EC),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isDark
                                        ? const Color(0xFF334155)
                                        : RampColors.primary
                                            .withValues(alpha: 0.2),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: isDark ? Colors.black.withValues(alpha: 0.5) : const Color(0xFFA3B1C6).withValues(alpha: 0.6),
                                      blurRadius: 10,
                                      offset: const Offset(5, 5),
                                    ),
                                    BoxShadow(
                                      color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white.withValues(alpha: 0.8),
                                      blurRadius: 10,
                                      offset: const Offset(-5, -5),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _selectedTenant!.name,
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                        color: isDark
                                            ? Colors.white
                                            : RampColors.slate,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${_selectedTenant!.unitNumber} • Current Balance: ${_currencyFormat.format(_selectedTenant!.balance)}',
                                      style: GoogleFonts.poppins(
                                        fontSize: 13,
                                        color: isDark
                                            ? const Color(0xFF94A3B8)
                                            : RampColors.mutedText,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Section 2: Payment Breakdown
                        _section(
                          'Payment Breakdown & Period',
                          Icons.receipt_long_rounded,
                          [
                            RampTextField(
                              controller: _monthCtrl,
                              label: 'Payment Month',
                              hintText: 'e.g. October 2024',
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: RampTextField(
                                    controller: _baseRentCtrl,
                                    label: 'Base Rent (₱)',
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                            decimal: true),
                                    onChanged: (_) => _recalculateTotal(),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: RampTextField(
                                    controller: _waterCtrl,
                                    label: 'Water Bill (₱)',
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                            decimal: true),
                                    onChanged: (_) => _recalculateTotal(),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: RampTextField(
                                    controller: _electricCtrl,
                                    label: 'Electric Bill (₱)',
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                            decimal: true),
                                    onChanged: (_) => _recalculateTotal(),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: RampTextField(
                                    controller: _lateFeeCtrl,
                                    label: 'Late Fee (₱)',
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                            decimal: true),
                                    onChanged: (_) => _recalculateTotal(),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            RampTextField(
                              controller: _amountCtrl,
                              label: 'Total Amount Paid (₱)',
                              hintText: 'Enter total amount received',
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Section 3: Payment Method & Reference
                        _section(
                          'Method & Reference',
                          Icons.credit_card_rounded,
                          [
                            Text(
                              'Payment Method',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: isDark ? Colors.white : RampColors.slate,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: _paymentMethods.map((method) {
                                final isSelected = _selectedMethod == method;
                                return ChoiceChip(
                                  label: Text(
                                    method,
                                    style: GoogleFonts.poppins(
                                      color: isSelected
                                          ? Colors.white
                                          : (isDark
                                              ? Colors.white
                                              : RampColors.slate),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  selected: isSelected,
                                  selectedColor: RampColors.primary,
                                  backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFE0E5EC),
                                  onSelected: (selected) {
                                    if (selected) {
                                      setState(() => _selectedMethod = method);
                                    }
                                  },
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 16),
                            RampTextField(
                              controller: _refCtrl,
                              label: 'Reference Number / Txn ID',
                              hintText: 'e.g. GC-198273645',
                            ),
                          ],
                        ),
                        const SizedBox(height: 28),

                        // Submit Button
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: isDark ? Colors.black.withValues(alpha: 0.5) : const Color(0xFFA3B1C6).withValues(alpha: 0.6),
                                blurRadius: 10,
                                offset: const Offset(5, 5),
                              ),
                              BoxShadow(
                                color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white.withValues(alpha: 0.8),
                                blurRadius: 10,
                                offset: const Offset(-5, -5),
                              ),
                            ],
                          ),
                          child: BouncePillButton(
                            text: _isSaving ? 'RECORDING...' : 'RECORD PAYMENT',
                            icon: Icons.check_circle_rounded,
                            backgroundColor: RampColors.success,
                            onPressed: _isSaving ? null : _savePayment,
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

/// Helper function to open PaymentFormScreen with standard SlideUpFadeRoute transition
void showRecordPaymentSheet(
  BuildContext context,
  WidgetRef ref, {
  Tenant? initialTenant,
}) {
  final allTenants = ref.read(tenantProvider);
  if (allTenants.isEmpty) {
    ToastService.showWarning('Create a tenant profile before recording a payment.');
    return;
  }
  Navigator.of(context, rootNavigator: true).push(
    SlideUpFadeRoute(
      page: PaymentFormScreen(initialTenant: initialTenant),
    ),
  );
}
