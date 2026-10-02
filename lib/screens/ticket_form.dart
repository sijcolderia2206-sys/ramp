import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../core/theme/ramp_theme.dart';
import '../core/validation/app_validators.dart';
import '../core/widgets/bouncing_interactive.dart';
import '../core/widgets/ramp_text_field.dart';
import '../providers/providers.dart';

class TicketFormScreen extends ConsumerStatefulWidget {
  final Ticket? existingTicket;
  const TicketFormScreen({super.key, this.existingTicket});

  @override
  ConsumerState<TicketFormScreen> createState() => _TicketFormScreenState();
}

class _TicketFormScreenState extends ConsumerState<TicketFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleCtrl;
  late TextEditingController _descCtrl;

  String _selectedUnit = 'Unit 1';
  String _tenantName = 'Juan Dela Cruz';
  String? _selectedUnitId;
  String? _selectedTenantId;

  String _selectedPriority = 'Med';
  String _selectedCategory = 'General';

  List<String> _selectedAreas = [];
  DateTime? _issueStartedAt;
  XFile? _photoFile;
  bool _isSaving = false;

  final List<String> _defaultAreas = const [
    'Bathroom',
    'Bedroom',
    'Indoor Area',
    'Outdoor Area',
  ];

  final List<String> _categories = const [
    'General',
    'Plumbing',
    'Electrical',
    'Appliance',
    'Carpentry',
    'HVAC',
  ];

  final List<String> _priorities = const [
    'Low',
    'Med',
    'High',
    'Emergency',
  ];

  @override
  void initState() {
    super.initState();
    final t = widget.existingTicket;
    _titleCtrl = TextEditingController(text: t?.title ?? '');
    _descCtrl = TextEditingController(text: t?.description ?? '');

    if (t != null) {
      _selectedUnit = t.unitNumber;
      _tenantName = t.tenantName;
      _selectedUnitId = t.unitId;
      _selectedTenantId = t.tenantId;
      _selectedAreas = List<String>.from(t.affectedAreas);
      _issueStartedAt = t.issueStartedAt;
      if (t.priority.isNotEmpty) _selectedPriority = t.priority;
      if (t.category.isNotEmpty) _selectedCategory = t.category;
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<bool> _confirmLeave() async {
    return await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('Leave maintenance form?'),
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

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? picked = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );
      if (picked != null) {
        setState(() {
          _photoFile = picked;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Image selection error: ${e.toString().split("\n").first}'),
            backgroundColor: RampColors.primary,
          ),
        );
      }
    }
  }

  Future<void> _selectStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _issueStartedAt ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _issueStartedAt = picked;
      });
    }
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
    final isEditing = widget.existingTicket != null;
    final units = ref.watch(unitProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
        color: isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
      ),
    );

    final formTheme = theme.copyWith(
      inputDecorationTheme: theme.inputDecorationTheme.copyWith(
        filled: true,
        fillColor: isDark ? const Color(0xFF172033) : const Color(0xFFF8FAFC),
        border: border,
        enabledBorder: border,
        focusedBorder: border.copyWith(
          borderSide: const BorderSide(color: RampColors.primary, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      ),
    );

    final currentUnitId = units.any((u) => u.id == _selectedUnitId)
        ? _selectedUnitId
        : (units.any((u) => u.name == _selectedUnit)
            ? units.firstWhere((u) => u.name == _selectedUnit).id
            : (units.isNotEmpty ? units.first.id : null));

    final currentUnit = units.firstWhere(
      (u) => u.id == currentUnitId,
      orElse: () => units.isNotEmpty
          ? units.first
          : Unit(
              id: 'u1',
              name: _selectedUnit.isNotEmpty ? _selectedUnit : 'Unit 1'),
    );

    final availableAreas = currentUnit.maintenanceAreas.isNotEmpty
        ? currentUnit.maintenanceAreas
        : _defaultAreas;

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
            isEditing ? 'Edit Maintenance Issue' : 'Log Maintenance Issue',
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
                            color: RampColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: RampColors.primary.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              const CircleAvatar(
                                backgroundColor: RampColors.primary,
                                child: Icon(
                                  Icons.handyman_rounded,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Log Maintenance Ticket',
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
                                      'Specify affected unit areas and details to begin repair workflow.',
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

                        // Section 1: Unit & Issue Info
                        _section(
                          'Unit & Issue Details',
                          Icons.home_work_outlined,
                          [
                            DropdownButtonFormField<String>(
                              isExpanded: true,
                              initialValue: currentUnitId,
                              decoration: const InputDecoration(
                                labelText: 'Assigned Unit',
                                prefixIcon: Icon(Icons.meeting_room_outlined),
                              ),
                              items: units
                                  .map((u) => DropdownMenuItem(
                                        value: u.id,
                                        child: Text(
                                          '${u.name} ${u.tenantName != null && u.tenantName!.isNotEmpty ? "(${u.tenantName})" : "(Vacant)"}',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ))
                                  .toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  final matched = units.firstWhere(
                                      (u) => u.id == val,
                                      orElse: () => currentUnit);
                                  setState(() {
                                    _selectedUnitId = matched.id;
                                    _selectedUnit = matched.name;
                                    _tenantName =
                                        matched.tenantName ?? 'Unoccupied';
                                    _selectedTenantId = matched.tenantId;
                                    _selectedAreas.clear();
                                  });
                                }
                              },
                            ),
                            const SizedBox(height: 12),
                            RampTextField(
                              controller: _titleCtrl,
                              label: 'Issue Name / Title',
                              hintText: 'e.g. Bathroom Faucet Dripping',
                              validator: (val) => AppValidators.requiredText(
                                  val,
                                  label: 'issue title'),
                            ),
                            const SizedBox(height: 12),
                            DropdownButtonFormField<String>(
                              isExpanded: true,
                              initialValue: _categories.contains(_selectedCategory)
                                  ? _selectedCategory
                                  : 'General',
                              decoration: const InputDecoration(
                                labelText: 'Category',
                                prefixIcon: Icon(Icons.category_outlined),
                              ),
                              items: _categories
                                  .map((cat) => DropdownMenuItem(
                                        value: cat,
                                        child: Text(cat),
                                      ))
                                  .toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() => _selectedCategory = val);
                                }
                              },
                            ),
                            const SizedBox(height: 14),
                            Text(
                              'Priority Level',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                fontSize: 13.5,
                                color: isDark ? Colors.white : RampColors.slate,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: _priorities.map((p) {
                                final isSel = _selectedPriority == p;
                                Color chipColor = RampColors.primary;
                                if (p == 'Emergency' || p == 'High') {
                                  chipColor = RampColors.danger;
                                } else if (p == 'Med') {
                                  chipColor = RampColors.warning;
                                } else {
                                  chipColor = RampColors.success;
                                }

                                return ChoiceChip(
                                  label: Text(
                                    p,
                                    style: TextStyle(
                                      color: isSel
                                          ? Colors.white
                                          : (isDark
                                              ? Colors.white
                                              : RampColors.slate),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12.5,
                                    ),
                                  ),
                                  selected: isSel,
                                  selectedColor: chipColor,
                                  backgroundColor: isDark
                                      ? const Color(0xFF172033)
                                      : const Color(0xFFF1F5F9),
                                  checkmarkColor: Colors.white,
                                  onSelected: (_) =>
                                      setState(() => _selectedPriority = p),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Section 2: Affected Areas & Timeline
                        _section(
                          'Location & Timeline',
                          Icons.location_on_outlined,
                          [
                            Text(
                              'Select Affected Areas',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                fontSize: 13.5,
                                color: isDark ? Colors.white : RampColors.slate,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: availableAreas.map((area) {
                                final isSelected =
                                    _selectedAreas.contains(area);
                                return FilterChip(
                                  label: Text(
                                    area,
                                    style: GoogleFonts.poppins(
                                      color: isSelected
                                          ? Colors.white
                                          : (isDark
                                              ? Colors.white
                                              : RampColors.slate),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                  selected: isSelected,
                                  selectedColor: RampColors.primary,
                                  backgroundColor: isDark
                                      ? const Color(0xFF0F172A)
                                      : RampColors.background,
                                  checkmarkColor: Colors.white,
                                  onSelected: (selected) {
                                    setState(() {
                                      if (selected) {
                                        _selectedAreas.add(area);
                                      } else {
                                        _selectedAreas.remove(area);
                                      }
                                    });
                                  },
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 16),
                            InkWell(
                              onTap: _selectStartDate,
                              borderRadius: BorderRadius.circular(12),
                              child: InputDecorator(
                                decoration: const InputDecoration(
                                  labelText: 'When did the issue start?',
                                  suffixIcon:
                                      Icon(Icons.calendar_today_outlined),
                                ),
                                child: Text(
                                  _issueStartedAt != null
                                      ? DateFormat('MMMM dd, yyyy')
                                          .format(_issueStartedAt!)
                                      : 'Select start date (Optional)',
                                  style: TextStyle(
                                    color: _issueStartedAt != null
                                        ? (isDark
                                            ? Colors.white
                                            : RampColors.slate)
                                        : Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Section 3: Description & Evidence
                        _section(
                          'Description & Photo Evidence',
                          Icons.notes_rounded,
                          [
                            RampTextField(
                              controller: _descCtrl,
                              label: 'Description',
                              hintText:
                                  'Provide details about what needs attention...',
                              maxLines: 3,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Photo Evidence (Optional)',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                fontSize: 13.5,
                                color: isDark ? Colors.white : RampColors.slate,
                              ),
                            ),
                            const SizedBox(height: 8),
                            InkWell(
                              onTap: _pickImage,
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                height: 120,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? const Color(0xFF172033)
                                      : const Color(0xFFF8FAFC),
                                  border: Border.all(
                                    color: isDark
                                        ? const Color(0xFF475569)
                                        : const Color(0xFFCBD5E1),
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: _photoFile != null
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Image.file(
                                          File(_photoFile!.path),
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    : Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Icon(
                                            Icons.add_a_photo_outlined,
                                            color: RampColors.primary,
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            'Attach Photo Evidence',
                                            style: GoogleFonts.poppins(
                                              fontSize: 12.5,
                                              fontWeight: FontWeight.w600,
                                              color: RampColors.primary,
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 28),

                        // Submit Button
                        BouncePillButton(
                          text: _isSaving
                              ? 'SAVING...'
                              : (isEditing
                                  ? 'UPDATE TICKET'
                                  : 'CREATE MAINTENANCE TICKET'),
                          icon: Icons.check_circle_rounded,
                          backgroundColor: RampColors.primary,
                          onPressed: _isSaving
                              ? null
                              : () async {
                                  if (!(_formKey.currentState?.validate() ??
                                      false)) {
                                    return;
                                  }
                                  setState(() => _isSaving = true);

                                  final newTicket = isEditing
                                      ? widget.existingTicket!.copyWith(
                                          title: _titleCtrl.text.trim(),
                                          description: _descCtrl.text.trim(),
                                          unitNumber: _selectedUnit,
                                          unitId:
                                              _selectedUnitId ?? currentUnit.id,
                                          tenantName: _tenantName,
                                          tenantId: _selectedTenantId ??
                                              currentUnit.tenantId,
                                          affectedAreas: _selectedAreas,
                                          issueStartedAt: _issueStartedAt,
                                          priority: _selectedPriority,
                                          category: _selectedCategory,
                                          photoPath: _photoFile?.path ??
                                              widget.existingTicket?.photoPath,
                                        )
                                      : Ticket(
                                          id: 'tk_${DateTime.now().millisecondsSinceEpoch}',
                                          title: _titleCtrl.text.trim(),
                                          description: _descCtrl.text.trim(),
                                          unitNumber: _selectedUnit,
                                          unitId:
                                              _selectedUnitId ?? currentUnit.id,
                                          tenantName: _tenantName,
                                          tenantId: _selectedTenantId ??
                                              currentUnit.tenantId,
                                          affectedAreas: _selectedAreas,
                                          issueStartedAt: _issueStartedAt,
                                          priority: _selectedPriority,
                                          category: _selectedCategory,
                                          photoPath: _photoFile?.path,
                                          status: 'Schedule Visit',
                                        );

                                  if (isEditing) {
                                    ref
                                        .read(ticketProvider.notifier)
                                        .updateTicket(newTicket);
                                  } else {
                                    ref
                                        .read(ticketProvider.notifier)
                                        .addTicket(newTicket);
                                  }

                                  if (mounted) {
                                    Navigator.pop(context, true);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        backgroundColor: RampColors.success,
                                        behavior: SnackBarBehavior.floating,
                                        content: Text(isEditing
                                            ? 'Maintenance ticket updated!'
                                            : 'Maintenance ticket for $_selectedUnit created!'),
                                      ),
                                    );
                                  }
                                },
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
