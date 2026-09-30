import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../providers/providers.dart';
import '../core/validation/app_validators.dart';

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
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
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
            backgroundColor: const Color(0xFF0D6EFD),
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

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingTicket != null;
    final units = ref.watch(unitProvider);
    final theme = Theme.of(context);

    // Find current unit's areas if available
    final isDark = theme.brightness == Brightness.dark;

    final currentUnitId = units.any((u) => u.id == _selectedUnitId)
        ? _selectedUnitId
        : (units.any((u) => u.name == _selectedUnit)
            ? units.firstWhere((u) => u.name == _selectedUnit).id
            : (units.isNotEmpty ? units.first.id : null));

    final currentUnit = units.firstWhere(
      (u) => u.id == currentUnitId,
      orElse: () =>
          units.isNotEmpty ? units.first : Unit(id: 'u1', name: _selectedUnit.isNotEmpty ? _selectedUnit : 'Unit 1'),
    );
    final availableAreas = currentUnit.maintenanceAreas.isNotEmpty
        ? currentUnit.maintenanceAreas
        : _defaultAreas;

    return Scaffold(
      appBar: AppBar(
        title: Text(
            isEditing ? 'Edit Maintenance Issue' : 'Log Maintenance Issue'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Banner
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D6EFD).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: const Color(0xFF0D6EFD).withValues(alpha: 0.2)),
                  ),
                  child: const Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Color(0xFF0D6EFD),
                        child:
                            Icon(Icons.handyman_rounded, color: Colors.white),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Log Maintenance Issue',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: Color(0xFF0D6EFD)),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Specify affected unit areas and details to begin repair workflow.',
                              style:
                                  TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Assigned Unit Selection
                const Text('Assigned Unit',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  isExpanded: true,
                  initialValue: currentUnitId,
                  dropdownColor:
                      isDark ? const Color(0xFF1E293B) : Colors.white,
                  style: TextStyle(
                    color: isDark ? Colors.white : const Color(0xFF1E293B),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  items: units
                      .map((u) => DropdownMenuItem(
                            value: u.id,
                            child: Text(
                              '${u.name} ${u.tenantName != null && u.tenantName!.isNotEmpty ? "(${u.tenantName})" : "(Vacant)"}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF1E293B),
                                fontSize: 14,
                              ),
                            ),
                          ))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) {
                      final matched = units.firstWhere((u) => u.id == val,
                          orElse: () => currentUnit);
                      setState(() {
                        _selectedUnitId = matched.id;
                        _selectedUnit = matched.name;
                        _tenantName = matched.tenantName ?? 'Unoccupied';
                        _selectedTenantId = matched.tenantId;
                        _selectedAreas.clear();
                      });
                    }
                  },
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: isDark
                        ? const Color(0xFF0F172A)
                        : const Color(0xFFF8FAFC),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 14),
                  ),
                ),
                const SizedBox(height: 20),

                // Issue Title
                const Text('Issue Name / Title',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _titleCtrl,
                  validator: (val) =>
                      AppValidators.requiredText(val, label: 'issue title'),
                  decoration: const InputDecoration(
                    hintText: 'e.g. Bathroom Faucet Dripping',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),

                // Affected Areas Selector
                const Text('Affected Areas / Location',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 4),
                const Text('Select all places where the issue is occurring:',
                    style: TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: availableAreas.map((area) {
                    final isSelected = _selectedAreas.contains(area);
                    return FilterChip(
                      label: Text(
                        area,
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : (isDark
                                  ? Colors.white
                                  : const Color(0xFF1E293B)),
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: const Color(0xFF0D6EFD),
                      backgroundColor: isDark
                          ? const Color(0xFF1E293B)
                          : const Color(0xFFF1F5F9),
                      checkmarkColor: Colors.white,
                      side: BorderSide(
                        color: isSelected
                            ? const Color(0xFF0D6EFD)
                            : (isDark
                                ? const Color(0xFF334155)
                                : const Color(0xFFCBD5E1)),
                      ),
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
                const SizedBox(height: 20),

                // When issue started (optional)
                const Text('When did the issue start? (Optional)',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 8),
                InkWell(
                  onTap: _selectStartDate,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            _issueStartedAt != null
                                ? DateFormat('MMMM dd, yyyy')
                                    .format(_issueStartedAt!)
                                : 'Select start date (Optional)',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: _issueStartedAt != null
                                  ? theme.textTheme.bodyMedium?.color
                                  : Colors.grey,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.calendar_today_rounded, size: 18),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Description
                const Text('Description',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _descCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'Provide details about what needs attention...',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),

                // Optional Photo
                const Text('Issue Photo (Optional)',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 8),
                InkWell(
                  onTap: _pickImage,
                  child: Container(
                    height: 120,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: _photoFile != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(File(_photoFile!.path),
                                fit: BoxFit.cover),
                          )
                        : const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_a_photo_outlined,
                                  color: Color(0xFF0D6EFD)),
                              SizedBox(height: 4),
                              Text('Attach Photo Evidence',
                                  style: TextStyle(
                                      fontSize: 12, color: Color(0xFF0D6EFD))),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 30),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D6EFD),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.check_circle_rounded),
                    label: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        _isSaving
                            ? 'SAVING...'
                            : (isEditing
                                ? 'UPDATE TICKET'
                                : 'CREATE MAINTENANCE TICKET'),
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ),
                    onPressed: _isSaving
                        ? null
                        : () async {
                            if (!(_formKey.currentState?.validate() ?? false)) {
                              return;
                            }
                            setState(() => _isSaving = true);

                            final newTicket = isEditing
                                ? widget.existingTicket!.copyWith(
                                    title: _titleCtrl.text.trim(),
                                    description: _descCtrl.text.trim(),
                                    unitNumber: _selectedUnit,
                                    unitId: _selectedUnitId ?? currentUnit.id,
                                    tenantName: _tenantName,
                                    tenantId: _selectedTenantId ??
                                        currentUnit.tenantId,
                                    affectedAreas: _selectedAreas,
                                    issueStartedAt: _issueStartedAt,
                                    photoPath: _photoFile?.path ??
                                        widget.existingTicket?.photoPath,
                                  )
                                : Ticket(
                                    id: 'tk_${DateTime.now().millisecondsSinceEpoch}',
                                    title: _titleCtrl.text.trim(),
                                    description: _descCtrl.text.trim(),
                                    unitNumber: _selectedUnit,
                                    unitId: _selectedUnitId ?? currentUnit.id,
                                    tenantName: _tenantName,
                                    tenantId: _selectedTenantId ??
                                        currentUnit.tenantId,
                                    affectedAreas: _selectedAreas,
                                    issueStartedAt: _issueStartedAt,
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
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: const Color(0xFF10B981),
                                  content: Text(isEditing
                                      ? 'Maintenance ticket updated!'
                                      : 'Maintenance ticket for $_selectedUnit created!'),
                                ),
                              );
                            }
                          },
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).padding.bottom + 28),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
