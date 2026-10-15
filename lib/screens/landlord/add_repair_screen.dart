// lib/screens/landlord/add_repair_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../widgets/dashed_border_container.dart';
import '../../models/unit_model.dart';
import '../../models/maintenance_ticket_model.dart';
import '../../core/db_result.dart';

import '../../providers/landlord_providers.dart';
import '../../providers/tenant_providers.dart';
import '../../core/validators.dart';

// =============================================================================
// 1. REUSABLE NEUMORPHIC (SOFT UI) STYLES & WIDGETS
// =============================================================================

class NeumorphicStyle {
  static const Color baseColor = Color(0xFFE0E5EC);
  static const Color darkShadow = Color(0xFFA3B1C6);
  static const Color lightShadow = Colors.white;
  static const Color primaryBlue = Color(0xFF0052CC);
  static const Color textDark = Color(0xFF0F172A);
  static const Color textMuted = Color(0xFF64748B);
  static const Color errorRed = Color(0xFFDC2626);
  static const Color successGreen = Color(0xFF16A34A);

  static BoxDecoration convex({double borderRadius = 16.0}) {
    return BoxDecoration(
      color: baseColor,
      borderRadius: BorderRadius.circular(borderRadius),
      boxShadow: const [
        BoxShadow(
          color: lightShadow,
          offset: Offset(-4, -4),
          blurRadius: 8,
        ),
        BoxShadow(
          color: darkShadow,
          offset: Offset(4, 4),
          blurRadius: 8,
        ),
      ],
    );
  }

  static BoxDecoration inset({double borderRadius = 14.0}) {
    return BoxDecoration(
      color: baseColor,
      borderRadius: BorderRadius.circular(borderRadius),
      boxShadow: const [
        BoxShadow(
          color: darkShadow,
          offset: Offset(2, 2),
          blurRadius: 4,
          spreadRadius: 1,
        ),
        BoxShadow(
          color: lightShadow,
          offset: Offset(-2, -2),
          blurRadius: 4,
          spreadRadius: 1,
        ),
      ],
    );
  }
}

class _NeumorphicConvexCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _NeumorphicConvexCard({
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20.0),
      padding: const EdgeInsets.all(20.0),
      decoration: NeumorphicStyle.convex(borderRadius: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: NeumorphicStyle.textMuted,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _NeumorphicInsetInput extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? hintText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final Widget? prefix;
  final bool isRequired;
  final int maxLines;

  const _NeumorphicInsetInput({
    required this.label,
    required this.controller,
    this.hintText,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.prefix,
    this.isRequired = false,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return FormField<String>(
      validator: (stateVal) {
        final val = controller.text;
        return validator?.call(val);
      },
      initialValue: controller.text,
      builder: (formFieldState) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 6),
              child: Row(
                children: [
                  Flexible(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: NeumorphicStyle.textDark,
                      ),
                    ),
                  ),
                  if (isRequired)
                    const Text(
                      ' *',
                      style: TextStyle(
                        color: NeumorphicStyle.errorRed,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            ),
            Container(
              decoration: NeumorphicStyle.inset(borderRadius: 14.0),
              padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 2.0),
              child: Row(
                children: [
                  if (prefix != null) ...[
                    prefix!,
                    const SizedBox(width: 8),
                  ],
                  Expanded(
                    child: TextFormField(
                      controller: controller,
                      keyboardType: keyboardType,
                      maxLines: maxLines,
                      style: const TextStyle(
                        fontSize: 14,
                        color: NeumorphicStyle.textDark,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: InputDecoration(
                        hintText: hintText,
                        hintStyle: const TextStyle(
                          color: NeumorphicStyle.textMuted,
                          fontSize: 13,
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        focusedErrorBorder: InputBorder.none,
                        fillColor: Colors.transparent,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onChanged: (val) {
                        formFieldState.didChange(val);
                      },
                    ),
                  ),
                ],
              ),
            ),
            if (formFieldState.hasError)
              Padding(
                padding: const EdgeInsets.only(left: 8, top: 4),
                child: Text(
                  formFieldState.errorText ?? '',
                  style: const TextStyle(
                    color: NeumorphicStyle.errorRed,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _NeumorphicInsetDropdown<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final bool enabled;

  const _NeumorphicInsetDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: enabled ? NeumorphicStyle.textDark : NeumorphicStyle.textMuted,
            ),
          ),
        ),
        Opacity(
          opacity: enabled ? 1.0 : 0.6,
          child: Container(
            decoration: NeumorphicStyle.inset(borderRadius: 14.0),
            padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 2.0),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<T>(
                value: value,
                items: items,
                onChanged: enabled ? onChanged : null,
                isExpanded: true,
                dropdownColor: NeumorphicStyle.baseColor,
                icon: const Icon(Icons.arrow_drop_down, color: NeumorphicStyle.primaryBlue),
                style: const TextStyle(
                  fontSize: 14,
                  color: NeumorphicStyle.textDark,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// 2. MAIN SCREEN WIDGET WITH NEUMORPHIC 4-CARD FORM
// =============================================================================

class AddRepairScreen extends ConsumerStatefulWidget {
  final MaintenanceTicket? ticketToEdit;

  const AddRepairScreen({super.key, this.ticketToEdit});

  @override
  ConsumerState<AddRepairScreen> createState() => _AddRepairScreenState();
}

class _AddRepairScreenState extends ConsumerState<AddRepairScreen> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _laborCostCtrl = TextEditingController();
  final _materialsCostCtrl = TextEditingController();
  final _technicianNameCtrl = TextEditingController();
  final _technicianPhoneCtrl = TextEditingController();

  String? _selectedUnitId;
  String _selectedArea = 'Indoor Area';
  String _priority = 'Medium'; // Emergency, Medium, Low
  String _vendorCategory = 'General Maintenance';
  bool _isTenantChargeable = false;

  DateTime _visitDate = DateTime.now().add(const Duration(days: 1));
  String _visitTimeSlot = 'Morning (9:00 AM - 12:00 PM)';

  File? _evidenceFile;
  bool _isVideoEvidence = false;
  bool _isSubmitting = false;
  double _calculatedTotalCost = 0.0;

  @override
  void initState() {
    super.initState();
    _laborCostCtrl.addListener(_recalculateTotalCost);
    _materialsCostCtrl.addListener(_recalculateTotalCost);

    if (widget.ticketToEdit != null) {
      final t = widget.ticketToEdit!;
      _titleCtrl.text = t.title;
      _descCtrl.text = t.description;
      _laborCostCtrl.text = t.laborCost > 0 ? t.laborCost.toStringAsFixed(2) : '';
      _materialsCostCtrl.text = t.materialsCost > 0 ? t.materialsCost.toStringAsFixed(2) : '';
      _technicianNameCtrl.text = t.repairer ?? '';
      _technicianPhoneCtrl.text = t.repairerPhone ?? '';
      _selectedUnitId = t.unitId;
      _selectedArea = t.unitArea;
      _priority = t.priority;
      _vendorCategory = t.vendorCategory;
      _isTenantChargeable = t.isTenantChargeable;
      _visitDate = t.visitDate ?? t.createdAt;
      _visitTimeSlot = t.visitTimeSlot ?? 'Morning (9:00 AM - 12:00 PM)';
      _calculatedTotalCost = t.totalCost;
    }
  }

  @override
  void dispose() {
    _laborCostCtrl.removeListener(_recalculateTotalCost);
    _materialsCostCtrl.removeListener(_recalculateTotalCost);
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _laborCostCtrl.dispose();
    _materialsCostCtrl.dispose();
    _technicianNameCtrl.dispose();
    _technicianPhoneCtrl.dispose();
    super.dispose();
  }

  void _recalculateTotalCost() {
    final labor = double.tryParse(_laborCostCtrl.text.trim()) ?? 0.0;
    final materials = double.tryParse(_materialsCostCtrl.text.trim()) ?? 0.0;
    setState(() {
      _calculatedTotalCost = labor + materials;
    });
  }

  // Pick Photo or Video with strict 10MB Size Limit Enforcement
  Future<void> _pickEvidenceFile(ImageSource source, bool isVideo) async {
    final XFile? file = isVideo
        ? await _picker.pickVideo(source: source)
        : await _picker.pickImage(source: source);

    if (file != null) {
      final f = File(file.path);
      final bytes = await f.length();
      final sizeInMB = bytes / (1024 * 1024);

      if (sizeInMB > 10.0) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('File exceeds 10MB limit (${sizeInMB.toStringAsFixed(1)} MB).'),
              backgroundColor: NeumorphicStyle.errorRed,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
        return;
      }

      setState(() {
        _evidenceFile = f;
        _isVideoEvidence = isVideo;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${isVideo ? "Video" : "Photo"} attached (${sizeInMB.toStringAsFixed(1)} MB).'),
            backgroundColor: NeumorphicStyle.successGreen,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  void _showMediaPickerOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: NeumorphicStyle.baseColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library, color: NeumorphicStyle.primaryBlue),
                title: const Text('Pick Photo Evidence (Max 10MB)'),
                onTap: () {
                  Navigator.pop(context);
                  _pickEvidenceFile(ImageSource.gallery, false);
                },
              ),
              ListTile(
                leading: const Icon(Icons.video_library, color: NeumorphicStyle.primaryBlue),
                title: const Text('Pick Video Evidence (Max 10MB)'),
                onTap: () {
                  Navigator.pop(context);
                  _pickEvidenceFile(ImageSource.gallery, true);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _selectVisitDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _visitDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      helpText: 'Select Visit Date',
    );
    if (picked != null) {
      setState(() => _visitDate = picked);
    }
  }

  Future<void> _addRepairTicket() async {
    FocusScope.of(context).unfocus();

    if (_formKey.currentState != null && !_formKey.currentState!.validate()) {
      return;
    }

    final title = _titleCtrl.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter repair issue title.'),
          backgroundColor: NeumorphicStyle.errorRed,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: NeumorphicStyle.baseColor,
        title: const Text('Confirm Add Repair Ticket', style: TextStyle(fontWeight: FontWeight.bold, color: NeumorphicStyle.textDark)),
        content: Text('Are you sure you want to log a $_priority priority repair ticket for "$title"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: NeumorphicStyle.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: NeumorphicStyle.primaryBlue),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirm', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isSubmitting = true);

    final units = ref.read(unitsProvider);
    final selectedUnit = units.firstWhere(
      (u) => u.id == _selectedUnitId,
      orElse: () => units.isNotEmpty
          ? units.first
          : RentalUnit(id: '', title: '', unitNumber: '', monthlyRent: 0),
    );

    final now = DateTime.now();
    final slaDueDate = MaintenanceTicket.calculateSlaDueDate(_priority, now);
    final laborCost = double.tryParse(_laborCostCtrl.text.trim()) ?? 0.0;
    final materialsCost = double.tryParse(_materialsCostCtrl.text.trim()) ?? 0.0;
    final description = _descCtrl.text.trim();

    String? photoUrl;
    if (_evidenceFile != null) {
      photoUrl = await uploadToRampMedia(XFile(_evidenceFile!.path), 'maintenance');
    }

    final isEditing = widget.ticketToEdit != null;
    final ticketId = isEditing ? widget.ticketToEdit!.id : 'm_${now.millisecondsSinceEpoch}';

    final targetTicket = MaintenanceTicket(
      id: ticketId,
      unitId: selectedUnit.id,
      unitNumber: selectedUnit.unitNumber,
      tenantId: selectedUnit.tenantId ?? (isEditing ? widget.ticketToEdit!.tenantId : null),
      tenantName: selectedUnit.tenantName ?? (isEditing ? widget.ticketToEdit!.tenantName : 'Landlord Admin'),
      title: title,
      description: description.isEmpty ? 'Scheduled maintenance repair' : description,
      unitArea: _selectedArea,
      priority: _priority,
      vendorCategory: _vendorCategory,
      stage: isEditing ? widget.ticketToEdit!.stage : 'Schedule Visit',
      visitDate: _visitDate,
      visitTimeSlot: _visitTimeSlot,
      estimatedCost: laborCost + materialsCost,
      laborCost: laborCost,
      materialsCost: materialsCost,
      repairer: _technicianNameCtrl.text.trim().isEmpty ? null : _technicianNameCtrl.text.trim(),
      repairerPhone: _technicianPhoneCtrl.text.trim().isEmpty ? null : _technicianPhoneCtrl.text.trim(),
      isTenantChargeable: _isTenantChargeable,
      photoBefore: photoUrl ?? (isEditing ? widget.ticketToEdit!.photoBefore : _evidenceFile?.path),
      photoAfter: isEditing ? widget.ticketToEdit!.photoAfter : null,
      completionSummary: isEditing ? widget.ticketToEdit!.completionSummary : null,
      rating: isEditing ? widget.ticketToEdit!.rating : null,
      tenantFeedback: isEditing ? widget.ticketToEdit!.tenantFeedback : null,
      slaDueDate: isEditing ? widget.ticketToEdit!.slaDueDate : slaDueDate,
      createdAt: isEditing ? widget.ticketToEdit!.createdAt : now,
    );

    DbResult res;
    if (isEditing) {
      res = await ref.read(maintenanceTicketsProvider.notifier).updateTicket(targetTicket);
    } else {
      res = await ref.read(maintenanceTicketsProvider.notifier).addTicket(targetTicket);
    }

    if (mounted) {
      setState(() => _isSubmitting = false);
      if (res.isOfflineQueued) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Offline Mode: Repair ticket "$title" saved locally & queued for sync.'),
            backgroundColor: Colors.amber.shade800,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        context.pop();
      } else if (res.isSuccess) {
        ref.read(notificationsProvider.notifier).addNotification(
              'Repair Ticket Scheduled',
              'Added $_priority priority repair for Unit ${selectedUnit.unitNumber}: $title',
              'maintenance',
            );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Repair Ticket Scheduled for Unit ${selectedUnit.unitNumber}!'),
            backgroundColor: NeumorphicStyle.successGreen,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        context.pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save repair ticket: ${res.errorMessage ?? "Database write rejected."}'),
            backgroundColor: NeumorphicStyle.errorRed,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final units = ref.watch(unitsProvider);
    if (_selectedUnitId == null && units.isNotEmpty) {
      _selectedUnitId = units.first.id;
    }

    final selectedUnitObj = units.firstWhere(
      (u) => u.id == _selectedUnitId,
      orElse: () => units.isNotEmpty ? units.first : RentalUnit(id: '', title: '', unitNumber: '', monthlyRent: 0),
    );

    final availableAreas = (selectedUnitObj.maintenanceAreas.isNotEmpty
            ? selectedUnitObj.maintenanceAreas
            : const ['Bathroom', 'Bedroom', 'Kitchen', 'Living Area', 'Indoor Area', 'Outdoor Area'])
        .toSet()
        .toList();

    if (!availableAreas.contains(_selectedArea)) {
      _selectedArea = availableAreas.first;
    }

    return Scaffold(
      backgroundColor: NeumorphicStyle.baseColor,
      appBar: AppBar(
        backgroundColor: NeumorphicStyle.baseColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: NeumorphicStyle.textDark, size: 20),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Add Repair Ticket',
          style: TextStyle(
            color: NeumorphicStyle.textDark,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // CARD 1: AFFECTED PROPERTY & ROOM AREA
                _NeumorphicConvexCard(
                  title: 'AFFECTED PROPERTY & ROOM',
                  child: Column(
                    children: [
                      _NeumorphicInsetDropdown<String>(
                        label: 'Affected Rental Unit',
                        value: units.isNotEmpty ? _selectedUnitId : null,
                        items: units.isEmpty
                            ? [const DropdownMenuItem(value: null, child: Text('No Units Available'))]
                            : units.map((u) {
                                return DropdownMenuItem(
                                  value: u.id,
                                  child: Text('Unit ${u.unitNumber} - ${u.title}'),
                                );
                              }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              _selectedUnitId = val;
                              if (selectedUnitObj.maintenanceAreas.isNotEmpty) {
                                _selectedArea = selectedUnitObj.maintenanceAreas.first;
                              }
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      _NeumorphicInsetDropdown<String>(
                        label: 'Affected Area / Room',
                        value: _selectedArea,
                        enabled: units.isNotEmpty && _selectedUnitId != null,
                        items: availableAreas
                            .map((area) => DropdownMenuItem(value: area, child: Text(area)))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedArea = val);
                        },
                      ),
                    ],
                  ),
                ),

                // CARD 2: ISSUE DETAILS & SLA TARGET PRIORITY
                _NeumorphicConvexCard(
                  title: 'ISSUE DETAILS & SLA PRIORITY',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _NeumorphicInsetInput(
                        label: 'Repair Title',
                        controller: _titleCtrl,
                        hintText: 'e.g. Aircon Error E4 / Pipe Leak',
                        isRequired: true,
                        prefix: const Icon(Icons.build_outlined, size: 20, color: NeumorphicStyle.primaryBlue),
                        validator: (val) => FormValidators.name(val, 'Repair Title', minLength: 3, maxLength: 100),
                      ),
                      const SizedBox(height: 16),
                      _NeumorphicInsetInput(
                        label: 'Detailed Description',
                        controller: _descCtrl,
                        hintText: 'Provide complete details regarding the damage...',
                        maxLines: 4,
                        prefix: const Icon(Icons.description_outlined, size: 20, color: NeumorphicStyle.primaryBlue),
                        validator: (val) => FormValidators.textLength(val, 'Description', minLength: 5, maxLength: 500, isRequired: false),
                      ),
                      const SizedBox(height: 16),
                      _NeumorphicInsetDropdown<String>(
                        label: 'Specialty Category',
                        value: _vendorCategory,
                        items: const [
                          DropdownMenuItem(value: 'Plumbing / Water Supply', child: Text('Plumbing / Water Supply')),
                          DropdownMenuItem(value: 'Electrical & Power', child: Text('Electrical & Power')),
                          DropdownMenuItem(value: 'HVAC / Air Conditioning', child: Text('HVAC / Air Conditioning')),
                          DropdownMenuItem(value: 'Carpentry & Structure', child: Text('Carpentry & Structure')),
                          DropdownMenuItem(value: 'General Maintenance', child: Text('General Maintenance')),
                        ],
                        onChanged: (val) {
                          if (val != null) setState(() => _vendorCategory = val);
                        },
                      ),
                      const SizedBox(height: 16),
                      const Padding(
                        padding: EdgeInsets.only(left: 4, bottom: 8),
                        child: Text(
                          'SLA Target Priority',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: NeumorphicStyle.textDark),
                        ),
                      ),
                      Row(
                        children: [
                          _buildPriorityToggle('Emergency', '24h SLA', NeumorphicStyle.errorRed),
                          const SizedBox(width: 8),
                          _buildPriorityToggle('Medium', '3 Days SLA', NeumorphicStyle.primaryBlue),
                          const SizedBox(width: 8),
                          _buildPriorityToggle('Low', '7 Days SLA', NeumorphicStyle.successGreen),
                        ],
                      ),
                    ],
                  ),
                ),

                // CARD 3: TECHNICIAN DISPATCH & SCHEDULE
                _NeumorphicConvexCard(
                  title: 'TECHNICIAN DISPATCH & SCHEDULE',
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _NeumorphicInsetInput(
                              label: 'Technician / Vendor',
                              controller: _technicianNameCtrl,
                              hintText: 'e.g. Apex Plumbing Co.',
                              prefix: const Icon(Icons.engineering_outlined, size: 20, color: NeumorphicStyle.primaryBlue),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _NeumorphicInsetInput(
                              label: 'Contact Phone',
                              controller: _technicianPhoneCtrl,
                              hintText: '09171234567',
                              keyboardType: TextInputType.phone,
                              prefix: const Icon(Icons.phone_outlined, size: 20, color: NeumorphicStyle.primaryBlue),
                              validator: (val) => FormValidators.phone(val, isRequired: false),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      GestureDetector(
                        onTap: _selectVisitDate,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: NeumorphicStyle.inset(borderRadius: 14),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.calendar_month, color: NeumorphicStyle.primaryBlue, size: 20),
                                  const SizedBox(width: 10),
                                  Text(
                                    'Visit Date: ${DateFormat.yMMMMd().format(_visitDate)}',
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: NeumorphicStyle.textDark, fontSize: 13),
                                  ),
                                ],
                              ),
                              const Icon(Icons.arrow_drop_down, color: NeumorphicStyle.primaryBlue),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _NeumorphicInsetDropdown<String>(
                        label: 'Visit Time Window',
                        value: _visitTimeSlot,
                        items: const [
                          DropdownMenuItem(value: 'Morning (9:00 AM - 12:00 PM)', child: Text('Morning (9:00 AM - 12:00 PM)')),
                          DropdownMenuItem(value: 'Afternoon (1:00 PM - 5:00 PM)', child: Text('Afternoon (1:00 PM - 5:00 PM)')),
                        ],
                        onChanged: (val) {
                          if (val != null) setState(() => _visitTimeSlot = val);
                        },
                      ),
                      const SizedBox(height: 16),
                      DashedBorderContainer(
                        onTap: _showMediaPickerOptions,
                        height: 100,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _evidenceFile == null ? Icons.add_a_photo_outlined : (_isVideoEvidence ? Icons.videocam : Icons.photo),
                              color: NeumorphicStyle.primaryBlue,
                              size: 32,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _evidenceFile == null
                                  ? 'Upload Photo/Video Evidence (Max 10MB)'
                                  : 'Attached: ${_evidenceFile!.path.split('/').last}',
                              style: const TextStyle(fontSize: 13, color: NeumorphicStyle.textMuted, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // CARD 4: COST BREAKDOWN & EXPENSE ALLOCATION
                _NeumorphicConvexCard(
                  title: 'ITEMIZED COST BREAKDOWN',
                  child: Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(left: 4, bottom: 8),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Responsible Expense Party',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: NeumorphicStyle.textDark),
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _isTenantChargeable = false),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: !_isTenantChargeable
                                    ? NeumorphicStyle.inset(borderRadius: 14)
                                    : NeumorphicStyle.convex(borderRadius: 14),
                                alignment: Alignment.center,
                                child: Text(
                                  'Landlord Expense',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: !_isTenantChargeable ? FontWeight.bold : FontWeight.w500,
                                    color: !_isTenantChargeable ? NeumorphicStyle.primaryBlue : NeumorphicStyle.textMuted,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _isTenantChargeable = true),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: _isTenantChargeable
                                    ? NeumorphicStyle.inset(borderRadius: 14)
                                    : NeumorphicStyle.convex(borderRadius: 14),
                                alignment: Alignment.center,
                                child: Text(
                                  'Tenant Chargeable',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: _isTenantChargeable ? FontWeight.bold : FontWeight.w500,
                                    color: _isTenantChargeable ? NeumorphicStyle.primaryBlue : NeumorphicStyle.textMuted,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _NeumorphicInsetInput(
                              label: 'Labor Fee (PHP)',
                              controller: _laborCostCtrl,
                              hintText: '0',
                              keyboardType: TextInputType.number,
                              prefix: const Text('₱', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: NeumorphicStyle.primaryBlue)),
                              validator: (val) => FormValidators.number(val, 'Labor Fee', isRequired: false, allowZero: true),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _NeumorphicInsetInput(
                              label: 'Materials / Parts (PHP)',
                              controller: _materialsCostCtrl,
                              hintText: '0',
                              keyboardType: TextInputType.number,
                              prefix: const Text('₱', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: NeumorphicStyle.primaryBlue)),
                              validator: (val) => FormValidators.number(val, 'Materials Fee', isRequired: false, allowZero: true),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Prominent Read-Only Total Cost Display
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: NeumorphicStyle.inset(borderRadius: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total Estimated Cost:',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: NeumorphicStyle.textDark),
                            ),
                            Text(
                              '₱${_calculatedTotalCost.toStringAsFixed(2)}',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: NeumorphicStyle.primaryBlue),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // SUBMIT BUTTON
                GestureDetector(
                  onTap: _isSubmitting ? null : _addRepairTicket,
                  child: Container(
                    width: double.infinity,
                    height: 52,
                    decoration: NeumorphicStyle.convex(borderRadius: 18).copyWith(
                      color: NeumorphicStyle.primaryBlue,
                    ),
                    alignment: Alignment.center,
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Text(
                            'Add Repair Ticket',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityToggle(String priorityKey, String slaText, Color accentColor) {
    final isActive = _priority == priorityKey;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _priority = priorityKey),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: isActive
              ? NeumorphicStyle.inset(borderRadius: 14)
              : NeumorphicStyle.convex(borderRadius: 14),
          child: Column(
            children: [
              Text(
                priorityKey,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                  color: isActive ? accentColor : NeumorphicStyle.textDark,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                slaText,
                style: TextStyle(
                  fontSize: 10,
                  color: isActive ? accentColor : NeumorphicStyle.textMuted,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
