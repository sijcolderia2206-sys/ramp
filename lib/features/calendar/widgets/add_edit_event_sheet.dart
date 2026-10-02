// lib/features/calendar/widgets/add_edit_event_sheet.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/state/ramp_state.dart';
import '../../../core/services/persistence_queue.dart';

class AddEditEventSheet extends ConsumerStatefulWidget {
  const AddEditEventSheet({
    super.key,
    this.existingEvent,
    this.initialDate,
  });

  final AppEvent? existingEvent;
  final DateTime? initialDate;

  @override
  ConsumerState<AddEditEventSheet> createState() => _AddEditEventSheetState();
}

class _AddEditEventSheetState extends ConsumerState<AddEditEventSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descController;

  late DateTime _selectedDate;
  TimeOfDay _selectedTime = TimeOfDay.now();

  String _selectedType = 'custom';
  String _selectedPriority = 'medium';
  String? _selectedUnitId;
  String? _selectedTenantId;

  final List<Map<String, String>> _eventTypes = [
    {'value': 'rent', 'label': 'Rent Due Reminder'},
    {'value': 'maintenance', 'label': 'Maintenance Visit'},
    {'value': 'inspection', 'label': 'Property Inspection'},
    {'value': 'meter_reading', 'label': 'Submeter Reading'},
    {'value': 'meeting', 'label': 'Tenant Meeting'},
    {'value': 'custom', 'label': 'General Custom Event'},
  ];

  @override
  void initState() {
    super.initState();
    final event = widget.existingEvent;
    _titleController = TextEditingController(text: event?.title ?? '');
    _descController = TextEditingController(text: event?.description ?? '');

    _selectedDate = event?.date ?? widget.initialDate ?? DateTime.now();
    if (event != null) {
      _selectedTime = TimeOfDay.fromDateTime(event.date);
      _selectedType = event.type;
      _selectedPriority = event.priority;
      _selectedUnitId = event.unitId;
      _selectedTenantId = event.tenantId;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _saveEvent() {
    if (!_formKey.currentState!.validate()) return;

    final eventDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    final isEdit = widget.existingEvent != null;
    final eventId = widget.existingEvent?.id ??
        'evt_${DateTime.now().millisecondsSinceEpoch}';

    final units = ref.read(unitProvider);
    final selectedUnit =
        units.where((u) => u.id == _selectedUnitId).firstOrNull;

    final newEvent = AppEvent(
      id: eventId,
      title: _titleController.text.trim(),
      date: eventDateTime,
      type: _selectedType,
      unitId: _selectedUnitId,
      tenantId: _selectedTenantId,
      unitNumber: selectedUnit?.name,
      description: _descController.text.trim(),
      priority: _selectedPriority,
      isCompleted: widget.existingEvent?.isCompleted ?? false,
    );

    if (isEdit) {
      ref.read(eventProvider.notifier).updateEvent(newEvent);
    } else {
      ref.read(eventProvider.notifier).addEvent(newEvent);
    }

    // Register offline persistence action
    PersistenceQueue.instance.enqueueUpsert(
      'events',
      newEvent.id,
      newEvent.toJson(),
    );

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isEdit
            ? 'Event updated successfully.'
            : 'Event scheduled successfully.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final units = ref.watch(unitProvider);
    final tenants = ref.watch(tenantProvider);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 12,
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Drag Handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF34383C)
                          : const Color(0xFFCBD5E1),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Header Bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.existingEvent != null
                          ? 'Edit Schedule Event'
                          : 'Schedule New Event',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest
                            .withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.close_rounded, size: 20),
                        onPressed: () => Navigator.pop(context),
                        tooltip: 'Close',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Event Title
                TextFormField(
                  controller: _titleController,
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600, fontSize: 14),
                  decoration: InputDecoration(
                    labelText: 'Event Title *',
                    hintText: 'e.g., Unit 101 Disinfection',
                    filled: true,
                    fillColor: isDark
                        ? const Color(0xFF1E2022)
                        : const Color(0xFFF8F9FA),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                          color: theme.colorScheme.primary, width: 1.5),
                    ),
                    prefixIcon: Icon(Icons.edit_note_rounded,
                        color: theme.colorScheme.primary),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Please enter event title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Event Type Dropdown
                DropdownButtonFormField<String>(
                  initialValue: _selectedType,
                  style: GoogleFonts.poppins(
                      fontSize: 14, color: theme.colorScheme.onSurface),
                  decoration: InputDecoration(
                    labelText: 'Event Category',
                    filled: true,
                    fillColor: isDark
                        ? const Color(0xFF1E2022)
                        : const Color(0xFFF8F9FA),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                          color: theme.colorScheme.primary, width: 1.5),
                    ),
                    prefixIcon: Icon(Icons.category_rounded,
                        color: theme.colorScheme.primary),
                  ),
                  icon: const Icon(Icons.keyboard_arrow_down_rounded),
                  items: _eventTypes.map((type) {
                    return DropdownMenuItem<String>(
                      value: type['value'],
                      child: Text(type['label']!),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedType = val);
                  },
                ),
                const SizedBox(height: 16),

                // Date & Time pickers
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: _pickDate,
                        borderRadius: BorderRadius.circular(16),
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'Date',
                            filled: true,
                            fillColor: isDark
                                ? const Color(0xFF1E2022)
                                : const Color(0xFFF8F9FA),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                            prefixIcon: Icon(Icons.calendar_month_rounded,
                                color: theme.colorScheme.primary),
                          ),
                          child: Text(
                            DateFormat('MMM d, yyyy').format(_selectedDate),
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600, fontSize: 13),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: InkWell(
                        onTap: _pickTime,
                        borderRadius: BorderRadius.circular(16),
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'Time',
                            filled: true,
                            fillColor: isDark
                                ? const Color(0xFF1E2022)
                                : const Color(0xFFF8F9FA),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                            prefixIcon: Icon(Icons.access_time_rounded,
                                color: theme.colorScheme.primary),
                          ),
                          child: Text(
                            _selectedTime.format(context),
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600, fontSize: 13),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Priority Selection
                DropdownButtonFormField<String>(
                  initialValue: _selectedPriority,
                  style: GoogleFonts.poppins(
                      fontSize: 14, color: theme.colorScheme.onSurface),
                  decoration: InputDecoration(
                    labelText: 'Priority Level',
                    filled: true,
                    fillColor: isDark
                        ? const Color(0xFF1E2022)
                        : const Color(0xFFF8F9FA),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: Icon(Icons.flag_rounded,
                        color: theme.colorScheme.primary),
                  ),
                  icon: const Icon(Icons.keyboard_arrow_down_rounded),
                  items: const [
                    DropdownMenuItem(value: 'low', child: Text('Low Priority')),
                    DropdownMenuItem(
                        value: 'medium', child: Text('Medium Priority')),
                    DropdownMenuItem(
                        value: 'high', child: Text('High Priority')),
                    DropdownMenuItem(value: 'urgent', child: Text('Urgent')),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedPriority = val);
                  },
                ),
                const SizedBox(height: 16),

                // Optional Unit Selector
                DropdownButtonFormField<String?>(
                  initialValue: _selectedUnitId,
                  style: GoogleFonts.poppins(
                      fontSize: 14, color: theme.colorScheme.onSurface),
                  decoration: InputDecoration(
                    labelText: 'Associated Unit (Optional)',
                    filled: true,
                    fillColor: isDark
                        ? const Color(0xFF1E2022)
                        : const Color(0xFFF8F9FA),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: Icon(Icons.apartment_rounded,
                        color: theme.colorScheme.primary),
                  ),
                  icon: const Icon(Icons.keyboard_arrow_down_rounded),
                  items: [
                    const DropdownMenuItem<String?>(
                      value: null,
                      child: Text('None / General Property'),
                    ),
                    ...units.map((u) => DropdownMenuItem<String?>(
                          value: u.id,
                          child: Text('${u.name} (${u.status})'),
                        )),
                  ],
                  onChanged: (val) {
                    setState(() => _selectedUnitId = val);
                  },
                ),
                const SizedBox(height: 16),

                // Optional Tenant Selector
                DropdownButtonFormField<String?>(
                  initialValue: _selectedTenantId,
                  style: GoogleFonts.poppins(
                      fontSize: 14, color: theme.colorScheme.onSurface),
                  decoration: InputDecoration(
                    labelText: 'Associated Tenant (Optional)',
                    filled: true,
                    fillColor: isDark
                        ? const Color(0xFF1E2022)
                        : const Color(0xFFF8F9FA),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: Icon(Icons.person_outline_rounded,
                        color: theme.colorScheme.primary),
                  ),
                  icon: const Icon(Icons.keyboard_arrow_down_rounded),
                  items: [
                    const DropdownMenuItem<String?>(
                      value: null,
                      child: Text('None'),
                    ),
                    ...tenants
                        .where((t) => !t.isArchived)
                        .map((t) => DropdownMenuItem<String?>(
                              value: t.id,
                              child: Text('${t.name} (${t.unitNumber})'),
                            )),
                  ],
                  onChanged: (val) {
                    setState(() => _selectedTenantId = val);
                  },
                ),
                const SizedBox(height: 16),

                // Notes / Description
                TextFormField(
                  controller: _descController,
                  maxLines: 3,
                  style: GoogleFonts.poppins(
                      fontSize: 14, color: theme.colorScheme.onSurface),
                  decoration: InputDecoration(
                    labelText: 'Description & Notes (Optional)',
                    hintText:
                        'Add details, contact instructions, or access codes...',
                    filled: true,
                    fillColor: isDark
                        ? const Color(0xFF1E2022)
                        : const Color(0xFFF8F9FA),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                          color: theme.colorScheme.primary, width: 1.5),
                    ),
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 24),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton(
                    onPressed: _saveEvent,
                    style: FilledButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: Text(
                      widget.existingEvent != null
                          ? 'SAVE CHANGES'
                          : 'SCHEDULE EVENT',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        letterSpacing: 0.5,
                      ),
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
}
