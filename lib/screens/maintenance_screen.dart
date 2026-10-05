import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../providers/providers.dart';
import '../core/widgets/core_widgets.dart';
import '../core/widgets/clay_container.dart';
import '../core/navigation/custom_page_transitions.dart';
import '../core/theme/ramp_theme.dart';
import '../core/services/reminder_launcher_service.dart';
import '../core/utils/toast_service.dart';
import 'ticket_form.dart';

class MaintenanceScreen extends ConsumerStatefulWidget {
  const MaintenanceScreen({super.key});

  @override
  ConsumerState<MaintenanceScreen> createState() => _MaintenanceScreenState();
}

class _MaintenanceScreenState extends ConsumerState<MaintenanceScreen> {
  final Set<String> _expandedTicketIds = <String>{};
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';
  String _sortOption = 'Newest';

  final List<String> _filters = [
    'All',
    'Schedule Visit',
    'Estimate',
    'Schedule Repair',
    'Completed'
  ];
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) setState(() => _isLoading = false);
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  static final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'en_PH',
    symbol: '₱',
    decimalDigits: 2,
  );

  // --- STAGE 1: SCHEDULE VISIT DIALOG ---
  void _showScheduleVisitSheet(BuildContext context, Ticket ticket) {
    DateTime selectedDate =
        ticket.visitScheduledAt ?? DateTime.now().add(const Duration(days: 1));
    String timeSlot = ticket.visitTimeWindow.isNotEmpty
        ? ticket.visitTimeWindow
        : 'Morning (8 AM - 12 PM)';
    TimeOfDay? exactTime;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final bottomInset = MediaQuery.of(context).viewInsets.bottom +
                MediaQuery.of(context).padding.bottom +
                28;
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: bottomInset,
              ),
              child: SafeArea(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Schedule Visit',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () => Navigator.pop(sheetContext)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                          'Select inspection visit date and time window for ${ticket.unitNumber}:',
                          style: const TextStyle(
                              fontSize: 13, color: Colors.grey)),
                      const SizedBox(height: 16),

                      // Date Selector
                      ListTile(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: Colors.grey.shade300)),
                        leading: const Icon(Icons.calendar_month_rounded,
                            color: RampColors.primary),
                        title: Text(
                            'Visit Date: ${DateFormat('EEE, MMM dd, yyyy').format(selectedDate)}'),
                        trailing:
                            const Icon(Icons.edit_calendar_rounded, size: 18),
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime.now(),
                            lastDate:
                                DateTime.now().add(const Duration(days: 90)),
                          );
                          if (picked != null) {
                            setSheetState(() => selectedDate = picked);
                          }
                        },
                      ),
                      const SizedBox(height: 16),

                      // Time Window Selector
                      const Text('Time Slot:',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 13)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: [
                          'Morning (8 AM - 12 PM)',
                          'Afternoon (12 PM - 5 PM)',
                          'Evening (5 PM - 8 PM)'
                        ].map((slot) {
                          final isSelected = timeSlot == slot;
                          final isDark =
                              Theme.of(context).brightness == Brightness.dark;
                          return ChoiceChip(
                            label: Text(
                              slot,
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : (isDark
                                        ? Colors.white
                                        : const Color(0xFF1E293B)),
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                            selected: isSelected,
                            selectedColor: RampColors.primary,
                            backgroundColor: isDark
                                ? const Color(0xFF1E293B)
                                : const Color(0xFFF1F5F9),
                            checkmarkColor: Colors.white,
                            side: BorderSide(
                              color: isSelected
                                  ? RampColors.primary
                                  : (isDark
                                      ? const Color(0xFF334155)
                                      : const Color(0xFFCBD5E1)),
                            ),
                            onSelected: (_) =>
                                setSheetState(() => timeSlot = slot),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 12),

                      // Optional Custom Time Picker
                      OutlinedButton.icon(
                        icon: const Icon(Icons.access_time_rounded, size: 16),
                        label: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(exactTime != null
                              ? 'Exact Time: ${exactTime!.format(context)}'
                              : 'Set Exact Time (Optional)'),
                        ),
                        onPressed: () async {
                          final picked = await showTimePicker(
                              context: context, initialTime: TimeOfDay.now());
                          if (picked != null) {
                            setSheetState(() => exactTime = picked);
                          }
                        },
                      ),
                      const SizedBox(height: 20),

                      // Action Buttons: Send Reminder & Confirm
                      Row(
                        children: [
                          if (ticket.tenantId?.isNotEmpty == true)
                            Expanded(
                              child: OutlinedButton.icon(
                                icon: const Icon(Icons.content_copy_rounded,
                                    size: 16),
                                label: const FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text('Send Reminder')),
                                onPressed: () async {
                                  final timeStr = exactTime != null
                                      ? exactTime!.format(context)
                                      : timeSlot;
                                  final notifier =
                                      ref.read(ticketProvider.notifier);
                                  notifier.scheduleTicketVisit(
                                      ticket.id, selectedDate, timeStr);
                                  notifier
                                      .prepareTicketVisitReminder(ticket.id);
                                  final reminderText =
                                      'Hi ${ticket.tenantName}, a maintenance inspection visit for ${ticket.unitNumber} (${ticket.title}) is scheduled on ${DateFormat("MMM dd, yyyy").format(selectedDate)} during $timeStr. Please reply to confirm availability!';
                                  final tenantMatch = ref
                                      .read(tenantProvider)
                                      .where((t) =>
                                          t.id == ticket.tenantId ||
                                          t.name.toLowerCase() ==
                                              ticket.tenantName.toLowerCase())
                                      .firstOrNull;
                                  await ReminderLauncherService.launchSms(
                                      phone: tenantMatch?.phone ?? '',
                                      message: reminderText);
                                  if (!context.mounted) return;
                                  ToastService.showInfo(
                                      'Visit reminder template ready & dispatched!');
                                },
                              ),
                            ),
                          if (ticket.tenantId?.isNotEmpty == true)
                            const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: RampColors.primary,
                                  foregroundColor: Colors.white),
                              icon: const Icon(Icons.check_rounded, size: 16),
                              label: const FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text('Mark Visit Scheduled')),
                              onPressed: () {
                                final formattedSlot = exactTime != null
                                    ? exactTime!.format(context)
                                    : timeSlot;
                                ref
                                    .read(ticketProvider.notifier)
                                    .scheduleTicketVisit(
                                        ticket.id, selectedDate, formattedSlot);
                                Navigator.pop(sheetContext);
                                ToastService.showSuccess(
                                    'Inspection visit scheduled for ${ticket.unitNumber}!');
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      if (ticket.visitScheduledAt != null)
                        SizedBox(
                          width: double.infinity,
                          child: TextButton.icon(
                            icon: const Icon(Icons.task_alt_rounded,
                                color: RampColors.success, size: 18),
                            label: const Text(
                                'Visit Completed -> Move to Estimate',
                                style: TextStyle(
                                    color: RampColors.success,
                                    fontWeight: FontWeight.bold)),
                            onPressed: () {
                              final moved = ref
                                  .read(ticketProvider.notifier)
                                  .markTicketVisitDone(ticket.id);
                              if (!moved) return;
                              final updated = ref
                                  .read(ticketProvider)
                                  .firstWhere((item) => item.id == ticket.id);
                              Navigator.pop(sheetContext);
                              _showEstimateSheet(context, updated);
                            },
                          ),
                        ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // --- STAGE 2: ESTIMATE SHEET ---
  void _showEstimateSheet(BuildContext context, Ticket ticket) {
    final amountCtrl = TextEditingController(
        text: ticket.estimatedCost > 0
            ? ticket.estimatedCost.toStringAsFixed(2)
            : '');
    final partsCtrl =
        TextEditingController(text: ticket.replacementItems.join(', '));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (sheetContext) {
        final bottomInset = MediaQuery.of(context).viewInsets.bottom +
            MediaQuery.of(context).padding.bottom +
            28;
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: bottomInset,
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Repair Estimate',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(sheetContext)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                      'Enter money needed for repair and replacement parts for ${ticket.unitNumber}:',
                      style: const TextStyle(fontSize: 13, color: Colors.grey)),
                  const SizedBox(height: 16),

                  // Amount Field
                  TextFormField(
                    controller: amountCtrl,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Estimated Repair Cost (₱)',
                      prefixText: '₱ ',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Replaced Items / Parts Field
                  TextFormField(
                    controller: partsCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Items / Parts to be Replaced',
                      hintText: 'e.g. Faucet, Water Pipe, PVC Joint',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: RampColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.info_outline_rounded,
                            color: RampColors.primary, size: 20),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Saving this estimate logs a Maintenance entry in the unit\'s payment ledger history.',
                            style: TextStyle(
                                fontSize: 11, color: RampColors.primary),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Submit Estimate Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: RampColors.primary,
                          foregroundColor: Colors.white),
                      icon: const Icon(Icons.save_rounded),
                      label: const FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'Save Estimate & Proceed to Repair Schedule',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      onPressed: () {
                        final parsedAmount =
                            double.tryParse(amountCtrl.text.trim()) ?? 0.0;
                        final partsList = partsCtrl.text
                            .split(',')
                            .map((e) => e.trim())
                            .where((e) => e.isNotEmpty)
                            .toList();

                        final saved = ref
                            .read(ticketProvider.notifier)
                            .submitTicketEstimate(
                                ticket.id, parsedAmount, partsList);
                        if (!saved) {
                          ToastService.showError(
                              'Enter an estimate above zero and at least one repair or replacement item.');
                          return;
                        }
                        Navigator.pop(sheetContext);

                        ToastService.showSuccess(
                            'Estimate saved! Added ₱${parsedAmount.toStringAsFixed(2)} to ${ticket.unitNumber}\'s ledger.');
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // --- STAGE 3: SCHEDULE REPAIR SHEET ---
  void _showScheduleRepairSheet(BuildContext context, Ticket ticket) {
    DateTime repairDate =
        ticket.repairScheduledAt ?? DateTime.now().add(const Duration(days: 1));
    String timeSlot = ticket.repairTimeWindow.isNotEmpty
        ? ticket.repairTimeWindow
        : 'Morning (8 AM - 12 PM)';
    TimeOfDay? exactTime;
    final contractorCtrl = TextEditingController(
        text: ticket.repairer.isNotEmpty
            ? ticket.repairer
            : 'Alex Rivera (Plumbing & HVAC)');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final bottomInset = MediaQuery.of(context).viewInsets.bottom +
                MediaQuery.of(context).padding.bottom +
                28;
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: bottomInset,
              ),
              child: SafeArea(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Schedule Repair Work',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () => Navigator.pop(sheetContext)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                          'Select repair date, time window, and contractor for ${ticket.unitNumber}:',
                          style: const TextStyle(
                              fontSize: 13, color: Colors.grey)),
                      const SizedBox(height: 16),

                      // Repair Date
                      ListTile(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: Colors.grey.shade300)),
                        leading: const Icon(Icons.build_circle_rounded,
                            color: RampColors.primary),
                        title: Text(
                            'Repair Date: ${DateFormat('EEE, MMM dd, yyyy').format(repairDate)}'),
                        trailing:
                            const Icon(Icons.edit_calendar_rounded, size: 18),
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: repairDate,
                            firstDate: DateTime.now(),
                            lastDate:
                                DateTime.now().add(const Duration(days: 90)),
                          );
                          if (picked != null) {
                            setSheetState(() => repairDate = picked);
                          }
                        },
                      ),
                      const SizedBox(height: 16),

                      // Time Slot
                      const Text('Time Slot:',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 13)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: [
                          'Morning (8 AM - 12 PM)',
                          'Afternoon (12 PM - 5 PM)',
                          'Evening (5 PM - 8 PM)'
                        ].map((slot) {
                          final isSelected = timeSlot == slot;
                          final isDark =
                              Theme.of(context).brightness == Brightness.dark;
                          return ChoiceChip(
                            label: Text(
                              slot,
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : (isDark
                                        ? Colors.white
                                        : const Color(0xFF1E293B)),
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                            selected: isSelected,
                            selectedColor: RampColors.primary,
                            backgroundColor: isDark
                                ? const Color(0xFF1E293B)
                                : const Color(0xFFF1F5F9),
                            checkmarkColor: Colors.white,
                            side: BorderSide(
                              color: isSelected
                                  ? RampColors.primary
                                  : (isDark
                                      ? const Color(0xFF334155)
                                      : const Color(0xFFCBD5E1)),
                            ),
                            onSelected: (_) =>
                                setSheetState(() => timeSlot = slot),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 12),

                      // Custom Time Picker
                      OutlinedButton.icon(
                        icon: const Icon(Icons.access_time_rounded, size: 16),
                        label: Text(exactTime != null
                            ? 'Exact Time: ${exactTime!.format(context)}'
                            : 'Set Exact Time (Optional)'),
                        onPressed: () async {
                          final picked = await showTimePicker(
                              context: context, initialTime: TimeOfDay.now());
                          if (picked != null) {
                            setSheetState(() => exactTime = picked);
                          }
                        },
                      ),
                      const SizedBox(height: 16),

                      // Contractor / Handyman Field
                      TextFormField(
                        controller: contractorCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Assigned Repairer / Contractor',
                          hintText: 'e.g. Alex Rivera',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Action Buttons: Send Reminder & Save Schedule
                      Row(
                        children: [
                          if (ticket.tenantId?.isNotEmpty == true)
                            Expanded(
                              child: OutlinedButton.icon(
                                icon: const Icon(Icons.content_copy_rounded,
                                    size: 16),
                                label: const FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text('Send Reminder')),
                                onPressed: () async {
                                  final timeStr = exactTime != null
                                      ? exactTime!.format(context)
                                      : timeSlot;
                                  final repairer = contractorCtrl.text.trim();
                                  final notifier =
                                      ref.read(ticketProvider.notifier);
                                  final scheduled =
                                      notifier.scheduleTicketRepair(ticket.id,
                                          repairDate, timeStr, repairer);
                                  if (!scheduled) return;
                                  notifier
                                      .prepareTicketRepairReminder(ticket.id);
                                  final reminderText =
                                      'Hi ${ticket.tenantName}, repair work for ${ticket.unitNumber} (${ticket.title}) is scheduled on ${DateFormat("MMM dd, yyyy").format(repairDate)} ($timeStr) by ${contractorCtrl.text.trim()}. Thank you for your cooperation!';
                                  final tenantMatch = ref
                                      .read(tenantProvider)
                                      .where((t) =>
                                          t.id == ticket.tenantId ||
                                          t.name.toLowerCase() ==
                                              ticket.tenantName.toLowerCase())
                                      .firstOrNull;
                                  await ReminderLauncherService.launchSms(
                                      phone: tenantMatch?.phone ?? '',
                                      message: reminderText);
                                  if (!context.mounted) return;
                                  ToastService.showInfo(
                                      'Repair reminder template ready & dispatched!');
                                },
                              ),
                            ),
                          if (ticket.tenantId?.isNotEmpty == true)
                            const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: RampColors.primary,
                                  foregroundColor: Colors.white),
                              icon: const Icon(Icons.check_rounded, size: 16),
                              label: const FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text('Save Schedule')),
                              onPressed: () {
                                final formattedSlot = exactTime != null
                                    ? exactTime!.format(context)
                                    : timeSlot;
                                final saved = ref
                                    .read(ticketProvider.notifier)
                                    .scheduleTicketRepair(
                                      ticket.id,
                                      repairDate,
                                      formattedSlot,
                                      contractorCtrl.text.trim(),
                                    );
                                if (!saved) {
                                  ToastService.showError(
                                      'Choose a repair time and enter who will perform the repair.');
                                  return;
                                }
                                Navigator.pop(sheetContext);
                                ToastService.showSuccess(
                                    'Repair scheduled for ${ticket.unitNumber}!');
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      if (ticket.repairScheduledAt != null)
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: RampColors.success,
                                foregroundColor: Colors.white),
                            icon: const Icon(Icons.task_alt_rounded),
                            label: const FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text('Mark Repair Fully Completed',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                            ),
                            onPressed: () {
                              _showCompletionSummarySheet(context, ticket);
                            },
                          ),
                        ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // --- STAGE 4: COMPLETION SUMMARY SHEET ---
  void _showCompletionSummarySheet(BuildContext context, Ticket ticket) {
    final notesCtrl = TextEditingController(text: ticket.completionSummary);
    XFile? completionPhoto;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final bottomInset = MediaQuery.of(context).viewInsets.bottom +
                MediaQuery.of(context).padding.bottom +
                28;
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: bottomInset,
              ),
              child: SafeArea(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Complete Repair Ticket',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () => Navigator.pop(sheetContext)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                          'Final completion summary and optional photo for ${ticket.unitNumber}:',
                          style: const TextStyle(
                              fontSize: 13, color: Colors.grey)),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: notesCtrl,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Completion Notes & Work Done',
                          hintText:
                              'e.g. Replaced leaking PVC pipe and tested water flow.',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Completion Photo
                      InkWell(
                        onTap: () async {
                          final picker = ImagePicker();
                          final picked = await picker.pickImage(
                              source: ImageSource.gallery,
                              maxWidth: 1024,
                              maxHeight: 1024);
                          if (picked != null) {
                            setSheetState(() => completionPhoto = picked);
                          }
                        },
                        child: Container(
                          height: 100,
                          width: double.infinity,
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(12)),
                          child: completionPhoto != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.file(File(completionPhoto!.path),
                                      fit: BoxFit.cover))
                              : const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add_a_photo_outlined,
                                        color: RampColors.success),
                                    SizedBox(height: 4),
                                    Text('Attach Final Photo (Optional)',
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: RampColors.success)),
                                  ],
                                ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: RampColors.success,
                              foregroundColor: Colors.white),
                          icon: const Icon(Icons.check_circle_rounded),
                          label: const FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text('MARK TICKET COMPLETED & CLOSE',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                          onPressed: () {
                            final completed = ref
                                .read(ticketProvider.notifier)
                                .markTicketCompleted(
                                  ticket.id,
                                  completionPhoto: completionPhoto?.path,
                                  summary: notesCtrl.text.trim(),
                                );
                            if (!completed) {
                              ToastService.showError(
                                  'Add a completion summary before closing the repair.');
                              return;
                            }
                            Navigator.pop(sheetContext);
                            ToastService.showSuccess(
                                'Ticket for ${ticket.unitNumber} marked fully completed!');
                          },
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showSavedCompletionSummary(BuildContext context, Ticket ticket) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Repair Completed'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(ticket.completionSummary),
            if (ticket.photoAfter != null && ticket.photoAfter!.isNotEmpty) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  File(ticket.photoAfter!),
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.image_not_supported_outlined),
                    title: Text('Completion photo is unavailable.'),
                  ),
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('CLOSE'),
          ),
        ],
      ),
    );
  }

  void _showTimelineModal(BuildContext context, Ticket ticket) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AnimatedRepairProgressTimelineSheet(ticket: ticket),
    );
  }

  void _openTicketForm({Ticket? existingTicket}) {
    Navigator.of(context, rootNavigator: true).push(
      SlideUpFadeRoute(
        page: TicketFormScreen(existingTicket: existingTicket),
      ),
    );
  }

  Color _getStatusDotColor(Ticket ticket) {
    if (ticket.status == 'Completed' ||
        ticket.status == 'Closed' ||
        ticket.status.toLowerCase() == 'resolved') {
      return RampColors.success;
    }
    if (ticket.priority.toLowerCase() == 'urgent' ||
        ticket.priority.toLowerCase() == 'emergency') {
      return RampColors.danger;
    }
    if (ticket.priority.toLowerCase() == 'high') {
      return RampColors.warning;
    }
    return RampColors.primary;
  }

  void _confirmDeleteTicket(BuildContext context, Ticket ticket) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Repair Ticket?'),
        content: Text(
            'Are you sure you want to delete "${ticket.title}" for ${ticket.unitNumber}? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('CANCEL'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: RampColors.danger),
            onPressed: () {
              Navigator.pop(dialogContext);
              ref.read(ticketProvider.notifier).deleteTicket(ticket.id);
              ToastService.showInfo('Deleted repair ticket for ${ticket.unitNumber}.');
            },
            child: const Text('DELETE'),
          ),
        ],
      ),
    );
  }

  Widget _buildTicketCard(Ticket ticket) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final foreground = theme.colorScheme.onSurface;
    final muted = theme.colorScheme.onSurfaceVariant;
    final completed = ticket.status == 'Completed' || ticket.status == 'Closed';
    final isExpanded = _expandedTicketIds.contains(ticket.id);
    final statusColor = _getStatusDotColor(ticket);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE0E5EC),
        borderRadius: BorderRadius.circular(16),
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
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => setState(() {
          if (isExpanded) {
            _expandedTicketIds.remove(ticket.id);
          } else {
            _expandedTicketIds.add(ticket.id);
          }
        }),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Single Colored Dot on the Left Side
                  Container(
                    width: 10,
                    height: 10,
                    margin: const EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      color: statusColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      ticket.title.replaceAll(RegExp(r'^Ticket:\s*', caseSensitive: false), ''),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: foreground,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  PopupMenuButton<String>(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: Icon(Icons.more_vert_rounded, size: 20, color: muted),
                    tooltip: 'Ticket Actions',
                    onSelected: (val) {
                      if (val == 'edit') {
                        _openTicketForm(existingTicket: ticket);
                      } else if (val == 'timeline') {
                        _showTimelineModal(context, ticket);
                      } else if (val == 'delete') {
                        _confirmDeleteTicket(context, ticket);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit_outlined, size: 18),
                            SizedBox(width: 8),
                            Text('Edit Ticket'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'timeline',
                        child: Row(
                          children: [
                            Icon(Icons.history_rounded, size: 18),
                            SizedBox(width: 8),
                            Text('View Timeline'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline_rounded,
                                size: 18, color: RampColors.danger),
                            SizedBox(width: 8),
                            Text('Delete Ticket',
                                style: TextStyle(color: RampColors.danger)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 4),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 180),
                    child:
                        Icon(Icons.keyboard_arrow_down_rounded, color: muted),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.only(left: 20.0),
                child: Text(
                  '${ticket.unitNumber} \u2022 ${ticket.tenantName}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 12,
                    color: muted,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 12),

              // Stage Status Pill, Priority Badge & Areas
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: completed
                          ? const Color(0xFF059669).withValues(alpha: 0.15)
                          : theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      ticket.status,
                      style: TextStyle(
                        fontSize: 11,
                        color: completed
                            ? const Color(0xFF059669)
                            : theme.colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: (ticket.priority.toLowerCase() == 'high' ||
                              ticket.priority.toLowerCase() == 'urgent' ||
                              ticket.priority.toLowerCase() == 'emergency')
                          ? const Color(0xFFEF4444).withValues(alpha: 0.15)
                          : const Color(0xFFF59E0B).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Priority: ${ticket.priority}',
                      style: TextStyle(
                        fontSize: 11,
                        color: (ticket.priority.toLowerCase() == 'high' ||
                                ticket.priority.toLowerCase() == 'urgent' ||
                                ticket.priority.toLowerCase() == 'emergency')
                            ? const Color(0xFFEF4444)
                            : const Color(0xFFD97706),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (completed && ticket.rating > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEAB308).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star_rounded,
                              size: 14, color: Color(0xFFEAB308)),
                          const SizedBox(width: 4),
                          Text(
                            'Rating: ${ticket.rating}/5',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFFA16207),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (ticket.affectedAreas.isNotEmpty)
                    ...ticket.affectedAreas.map((area) => Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            area,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontSize: 11,
                              color: muted,
                            ),
                          ),
                        )),
                ],
              ),

              if (isExpanded) ...[
                const SizedBox(height: 14),
                if (ticket.description.isNotEmpty) ...[
                  Text(ticket.description,
                      style: GoogleFonts.poppins(fontSize: 13, color: muted)),
                  const SizedBox(height: 12),
                ],

                // Workflow Step Callouts
                if (ticket.visitScheduledAt != null) ...[
                  Row(
                    children: [
                      const Icon(Icons.event_available_rounded,
                          size: 16, color: RampColors.primary),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                            'Visit Scheduled: ${DateFormat("MMM dd, yyyy").format(ticket.visitScheduledAt!)} (${ticket.visitTimeWindow})',
                            style: GoogleFonts.poppins(
                                fontSize: 12, fontWeight: FontWeight.w500)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  if (ticket.visitReminderSent)
                    Text('Tenant visit reminder prepared',
                        style: GoogleFonts.poppins(
                            fontSize: 11, color: RampColors.success)),
                ],
                if (ticket.replacementItems.isNotEmpty ||
                    ticket.estimatedCost > 0) ...[
                  Row(
                    children: [
                      const Icon(Icons.build_circle_outlined,
                          size: 16, color: RampColors.warning),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                            'Estimate: ${_currencyFormat.format(ticket.estimatedCost)} (${ticket.replacementItems.join(", ")})',
                            style: GoogleFonts.poppins(
                                fontSize: 12, fontWeight: FontWeight.w500)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  if (ticket.repairReminderSent)
                    Text('Tenant repair reminder prepared',
                        style: GoogleFonts.poppins(
                            fontSize: 11, color: RampColors.success)),
                ],
                if (ticket.isCompletedStage &&
                    ticket.completionSummary.isNotEmpty) ...[
                  Text('Completed: ${ticket.completionSummary}',
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                          fontSize: 12, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 6),
                ],
                if (ticket.repairScheduledAt != null) ...[
                  Row(
                    children: [
                      const Icon(Icons.handyman_rounded,
                          size: 16, color: RampColors.success),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                            'Repair Date: ${DateFormat("MMM dd, yyyy").format(ticket.repairScheduledAt!)} by ${ticket.repairer}',
                            style: GoogleFonts.poppins(
                                fontSize: 12, fontWeight: FontWeight.w500)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                ],

                const Divider(height: 20),

                // Progressive Stage Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showTimelineModal(context, ticket),
                        icon: const Icon(Icons.history_rounded, size: 16),
                        label: const FittedBox(
                            fit: BoxFit.scaleDown, child: Text('Timeline')),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Progressive Action Button based on current stage
                    if (ticket.isScheduleVisitStage)
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: RampColors.primary,
                              foregroundColor: Colors.white),
                          icon: const Icon(Icons.calendar_month_rounded,
                              size: 16),
                          label: const FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text('Schedule Visit')),
                          onPressed: () =>
                              _showScheduleVisitSheet(context, ticket),
                        ),
                      )
                    else if (ticket.isEstimateStage)
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: RampColors.warning,
                              foregroundColor: Colors.white),
                          icon:
                              const Icon(Icons.attach_money_rounded, size: 16),
                          label: const FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text('Set Estimate')),
                          onPressed: () => _showEstimateSheet(context, ticket),
                        ),
                      )
                    else if (ticket.isScheduleRepairStage)
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: RampColors.primary,
                              foregroundColor: Colors.white),
                          icon: const Icon(Icons.build_rounded, size: 16),
                          label: const FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text('Schedule Repair')),
                          onPressed: () =>
                              _showScheduleRepairSheet(context, ticket),
                        ),
                      )
                    else if (ticket.isCompletedStage)
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.check_circle_outline_rounded,
                              size: 16, color: RampColors.success),
                          label: const FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text('Summary',
                                style: TextStyle(color: RampColors.success)),
                          ),
                          onPressed: () =>
                              _showSavedCompletionSummary(context, ticket),
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final allTickets = ref.watch(ticketProvider);
    final activeFilter = ref.watch(ticketFilterProvider);

    List<Ticket> displayTickets = allTickets;
    if (activeFilter != 'All') {
      displayTickets = allTickets.where((t) {
        final st = t.status.toLowerCase();
        final af = activeFilter.toLowerCase();
        if (af == 'schedule visit') {
          return st == 'schedule visit' || st == 'pending';
        }
        if (af == 'estimate') return st == 'estimate';
        if (af == 'schedule repair') {
          return st == 'schedule repair' || st == 'in progress';
        }
        if (af == 'completed') return st == 'completed' || st == 'closed';
        return st == af;
      }).toList();
    }

    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.trim().toLowerCase();
      displayTickets = displayTickets.where((t) {
        final title = t.title.toLowerCase();
        final unit = t.unitNumber.toLowerCase();
        final tenant = t.tenantName.toLowerCase();
        final category = t.category.toLowerCase();
        final desc = t.description.toLowerCase();
        final status = t.status.toLowerCase();
        final priority = t.priority.toLowerCase();
        final repairer = t.repairer.toLowerCase();
        final id = t.id.toLowerCase();

        return title.contains(q) ||
            unit.contains(q) ||
            tenant.contains(q) ||
            category.contains(q) ||
            desc.contains(q) ||
            status.contains(q) ||
            priority.contains(q) ||
            repairer.contains(q) ||
            id.contains(q) ||
            t.affectedAreas.any((area) => area.toLowerCase().contains(q)) ||
            t.replacementItems.any((item) => item.toLowerCase().contains(q));
      }).toList();
    }

    displayTickets = List.from(displayTickets);
    if (_sortOption == 'Newest') {
      displayTickets.sort((a, b) => b.effectiveDate.compareTo(a.effectiveDate));
    } else if (_sortOption == 'Oldest') {
      displayTickets.sort((a, b) => a.effectiveDate.compareTo(b.effectiveDate));
    } else if (_sortOption == 'Priority High-First') {
      final priorityRank = {'Emergency': 4, 'High': 3, 'Med': 2, 'Low': 1};
      displayTickets.sort((a, b) => (priorityRank[b.priority] ?? 0)
          .compareTo(priorityRank[a.priority] ?? 0));
    } else if (_sortOption == 'Title A-Z') {
      displayTickets.sort(
          (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
    }

    return Scaffold(
      backgroundColor: isDark
          ? Theme.of(context).scaffoldBackgroundColor
          : RampColors.background,
      appBar: AppBar(
        title: Text('Repairs',
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : RampColors.slate)),
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort, color: RampColors.primary),
            tooltip: 'Sort Repairs',
            onSelected: (val) => setState(() => _sortOption = val),
            itemBuilder: (context) => [
              'Newest',
              'Oldest',
              'Priority High-First',
              'Title A-Z',
            ]
                .map((opt) => PopupMenuItem<String>(
                      value: opt,
                      child: Text('Sort by $opt'),
                    ))
                .toList(),
          ),
        ],
      ),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: RefreshIndicator(
              onRefresh: () async {
                setState(() {
                  _hasError = false;
                  _isLoading = true;
                });
                await Future<void>.delayed(const Duration(milliseconds: 300));
                if (mounted) setState(() => _isLoading = false);
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics()),
                padding: const EdgeInsets.only(
                    left: 16.0, right: 16.0, top: 12.0, bottom: 100.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Search Bar
                    TextField(
                      controller: _searchCtrl,
                      style: GoogleFonts.poppins(
                        color: isDark ? Colors.white : RampColors.slate,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Search issue, unit, tenant, or area...',
                        hintStyle: GoogleFonts.poppins(
                          color: isDark
                              ? const Color(0xFF94A3B8)
                              : RampColors.mutedText,
                        ),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide(
                                color: isDark
                                    ? const Color(0xFF334155)
                                    : RampColors.border)),
                        prefixIcon:
                            const Icon(Icons.search, color: RampColors.primary),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear_rounded, size: 18),
                                onPressed: () {
                                  _searchCtrl.clear();
                                  setState(() => _searchQuery = '');
                                },
                              )
                            : null,
                      ),
                      onChanged: (val) => setState(() => _searchQuery = val),
                    ),
                    if (_searchQuery.trim().isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.filter_list_rounded,
                              size: 14, color: RampColors.primary),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Showing ${displayTickets.length} ${displayTickets.length == 1 ? 'ticket' : 'tickets'} matching "${_searchQuery.trim()}"',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: RampColors.primary,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              _searchCtrl.clear();
                              setState(() => _searchQuery = '');
                            },
                            child: Text(
                              'Clear',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: RampColors.primary,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 16),

                    // Status Filter Chips
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: _filters.map((f) {
                          final isSelected = activeFilter == f;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: FilterChip(
                              visualDensity: VisualDensity.compact,
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              label: Text(
                                f,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: isSelected
                                          ? Theme.of(context)
                                              .colorScheme
                                              .onPrimary
                                          : Theme.of(context)
                                              .colorScheme
                                              .onSurface,
                                    ),
                              ),
                              selected: isSelected,
                              onSelected: (_) {
                                ref.read(ticketFilterProvider.notifier).state =
                                    f;
                              },
                              selectedColor:
                                  Theme.of(context).colorScheme.primary,
                              backgroundColor:
                                  Theme.of(context).colorScheme.surface,
                              checkmarkColor:
                                  Theme.of(context).colorScheme.onPrimary,
                              side: BorderSide(
                                color: Theme.of(context)
                                    .colorScheme
                                    .outlineVariant,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '${displayTickets.length} ${displayTickets.length == 1 ? 'ticket' : 'tickets'}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 16),

                    if (_isLoading)
                      const ShimmerList(
                          itemCount: 4, height: 120, padding: EdgeInsets.zero)
                    else if (_hasError)
                      ErrorStateWidget(
                        message: 'Failed to load maintenance tickets.',
                        onRetry: () {
                          setState(() {
                            _hasError = false;
                            _isLoading = true;
                          });
                          Future.delayed(const Duration(milliseconds: 300), () {
                            if (mounted) setState(() => _isLoading = false);
                          });
                        },
                      )
                    else if (displayTickets.isEmpty)
                      EmptyStateWidget(
                        icon: Icons.build_circle_outlined,
                        title: _searchQuery.isNotEmpty || activeFilter != 'All'
                            ? 'No Repairs Match Filters'
                            : 'No Repairs Found',
                        message: _searchQuery.isNotEmpty
                            ? 'No maintenance tickets match "$_searchQuery". Try clearing your search or resetting filters.'
                            : 'No maintenance tickets match the selected status filter.',
                        buttonText:
                            _searchQuery.isNotEmpty || activeFilter != 'All'
                                ? 'Reset Filters & Search'
                                : 'Report Issue',
                        buttonIcon:
                            _searchQuery.isNotEmpty || activeFilter != 'All'
                                ? Icons.refresh_rounded
                                : Icons.add,
                        onButtonPressed: () {
                          if (_searchQuery.isNotEmpty ||
                              activeFilter != 'All') {
                            _searchCtrl.clear();
                            setState(() => _searchQuery = '');
                            ref.read(ticketFilterProvider.notifier).state =
                                'All';
                          } else {
                            _openTicketForm();
                          }
                        },
                      )
                    else
                      Column(
                        children: List.generate(displayTickets.length, (index) {
                          final ticket = displayTickets[index];
                          return StaggeredListItem(
                            index: index,
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: _buildTicketCard(ticket),
                            ),
                          );
                        }),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton.extended(
        heroTag: null,
        onPressed: () => _openTicketForm(),
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Log Ticket',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

typedef MaintenanceTicketScreen = MaintenanceScreen;

/// Repair Progress Timeline Bottom Sheet with dynamic progress fill,
/// milestone step indicators, and staggered timeline history.
class AnimatedRepairProgressTimelineSheet extends StatefulWidget {
  final Ticket ticket;

  const AnimatedRepairProgressTimelineSheet({
    super.key,
    required this.ticket,
  });

  @override
  State<AnimatedRepairProgressTimelineSheet> createState() =>
      _AnimatedRepairProgressTimelineSheetState();
}

class _AnimatedRepairProgressTimelineSheetState
    extends State<AnimatedRepairProgressTimelineSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _entranceController;
  late Animation<double> _progressAnimation;

  double get _targetProgress {
    final status = widget.ticket.status.toLowerCase();
    if (status == 'completed' || status == 'closed') return 1.0;
    if (widget.ticket.isScheduleRepairStage) return 0.75;
    if (widget.ticket.isEstimateStage) return 0.50;
    return 0.25;
  }

  int get _currentStageIndex {
    final status = widget.ticket.status.toLowerCase();
    if (status == 'completed' || status == 'closed') return 3;
    if (widget.ticket.isScheduleRepairStage) return 2;
    if (widget.ticket.isEstimateStage) return 1;
    return 0;
  }

  String get _stageSummary {
    final status = widget.ticket.status.toLowerCase();
    if (status == 'completed' || status == 'closed') {
      return 'Stage 4 of 4: Completed & Closed';
    }
    if (widget.ticket.isScheduleRepairStage) {
      return 'Stage 3 of 4: Repair Scheduled / In Progress';
    }
    if (widget.ticket.isEstimateStage) {
      return 'Stage 2 of 4: Cost Estimate Set';
    }
    return 'Stage 1 of 4: Visit Scheduled';
  }

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: _targetProgress,
    ).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: Curves.easeOutCubic,
      ),
    );

    _entranceController.forward();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = RampColors.primary;
    final completedColor = RampColors.success;
    final surfaceBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final cardBg = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final borderClr = isDark ? const Color(0xFF334155) : RampColors.border;

    final steps = [
      {'title': 'Visit', 'icon': Icons.calendar_month_rounded},
      {'title': 'Estimate', 'icon': Icons.attach_money_rounded},
      {'title': 'Repair', 'icon': Icons.build_rounded},
      {'title': 'Complete', 'icon': Icons.check_circle_rounded},
    ];

    return Container(
      height: MediaQuery.of(context).size.height * 0.72,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE0E5EC),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
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
        children: [
          // Drag Handle
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 12),

          // Modal Title Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: primaryColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.insights_rounded,
                          color: primaryColor,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Repair Progress Timeline',
                              style: GoogleFonts.poppins(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : RampColors.slate,
                              ),
                            ),
                            Text(
                              '${widget.ticket.unitNumber} • ${widget.ticket.title}',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: isDark
                                    ? const Color(0xFF94A3B8)
                                    : RampColors.mutedText,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          Divider(height: 20, color: borderClr),

          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- 1. ANIMATED PROGRESS BAR BANNER CARD ---
                  AnimatedBuilder(
                    animation: _progressAnimation,
                    builder: (context, child) {
                      final progressVal = _progressAnimation.value;
                      final percentDisplay = (progressVal * 100).toInt();

                      return Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE0E5EC),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: borderClr, width: 1),
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Overall Progress',
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: isDark
                                            ? const Color(0xFF94A3B8)
                                            : RampColors.mutedText,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      _stageSummary,
                                      style: GoogleFonts.poppins(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: isDark
                                            ? Colors.white
                                            : RampColors.slate,
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: (progressVal == 1.0
                                            ? completedColor
                                            : primaryColor)
                                        .withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    '$percentDisplay%',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      color: progressVal == 1.0
                                          ? completedColor
                                          : primaryColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // ANIMATED PROGRESS TRACKER
                            LayoutBuilder(
                              builder: (context, constraints) {
                                final totalWidth = constraints.maxWidth;
                                final filledWidth = (totalWidth * progressVal)
                                    .clamp(0.0, totalWidth);

                                return Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    // Background Track
                                    Container(
                                      height: 12,
                                      width: totalWidth,
                                      decoration: BoxDecoration(
                                        color: isDark
                                            ? const Color(0xFF334155)
                                            : const Color(0xFFE2E8F0),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),

                                    // Animated Gradient Fill
                                    AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 50),
                                      height: 12,
                                      width: filledWidth,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        gradient: LinearGradient(
                                          colors: [
                                            primaryColor,
                                            progressVal == 1.0
                                                ? completedColor
                                                : const Color(0xFF00D2FF),
                                          ],
                                        ),
                                      ),
                                    ),

                                    // Indicator Leading Dot
                                    if (filledWidth > 10 &&
                                        filledWidth < totalWidth)
                                      Positioned(
                                        left: (filledWidth - 8)
                                            .clamp(0.0, totalWidth - 16),
                                        top: -2,
                                        child: Container(
                                          width: 16,
                                          height: 16,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.white,
                                            border: Border.all(
                                              color: primaryColor,
                                              width: 3,
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 20),

                  // --- 2. STEPPER MILESTONES ROW ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(steps.length, (idx) {
                      final isPassed = idx < _currentStageIndex;
                      final isCurrent = idx == _currentStageIndex;

                      final stepBg = isPassed
                          ? completedColor
                          : (isCurrent ? primaryColor : borderClr);
                      final stepFg = (isPassed || isCurrent)
                          ? Colors.white
                          : (isDark
                              ? const Color(0xFF64748B)
                              : const Color(0xFF94A3B8));

                      return Expanded(
                        child: Column(
                          children: [
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: stepBg,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                isPassed
                                    ? Icons.check_rounded
                                    : (steps[idx]['icon'] as IconData),
                                color: stepFg,
                                size: 18,
                              ),
                            ),
                            const SizedBox(height: 6),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                steps[idx]['title'] as String,
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  fontWeight: isCurrent || isPassed
                                      ? FontWeight.bold
                                      : FontWeight.w500,
                                  color: isCurrent
                                      ? primaryColor
                                      : (isPassed
                                          ? (isDark
                                              ? Colors.white
                                              : RampColors.slate)
                                          : (isDark
                                              ? const Color(0xFF64748B)
                                              : RampColors.mutedText)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ),

                  const SizedBox(height: 24),

                  // --- 3. AUDIT LOG HISTORY TITLE ---
                  Text(
                    'Audit Log & Activity History',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : RampColors.slate,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // --- 4. STAGGERED ANIMATED HISTORY LIST ---
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: widget.ticket.statusHistory.length,
                    itemBuilder: (context, index) {
                      final item = widget.ticket.statusHistory[index];
                      final isLast =
                          index == widget.ticket.statusHistory.length - 1;

                      return TweenAnimationBuilder<double>(
                        duration: Duration(milliseconds: 400 + (index * 100)),
                        curve: Curves.easeOutQuad,
                        tween: Tween<double>(begin: 0.0, end: 1.0),
                        builder: (context, animValue, child) {
                          return Transform.translate(
                            offset: Offset(0, 20 * (1.0 - animValue)),
                            child: Opacity(
                              opacity: animValue,
                              child: child,
                            ),
                          );
                        },
                        child: IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Timeline Node & Line
                              Column(
                                children: [
                                  Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      color: index == 0
                                          ? primaryColor.withValues(alpha: 0.15)
                                          : (isDark
                                              ? const Color(0xFF334155)
                                              : const Color(0xFFE2E8F0)),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: index == 0
                                            ? primaryColor
                                            : (isDark
                                                ? const Color(0xFF64748B)
                                                : const Color(0xFFCBD5E1)),
                                        width: 2,
                                      ),
                                    ),
                                    child: Icon(
                                      index == 0
                                          ? Icons.radio_button_checked_rounded
                                          : Icons.check_rounded,
                                      color: index == 0
                                          ? primaryColor
                                          : (isDark
                                              ? const Color(0xFF94A3B8)
                                              : const Color(0xFF64748B)),
                                      size: 12,
                                    ),
                                  ),
                                  if (!isLast)
                                    Expanded(
                                      child: Container(
                                        width: 2,
                                        margin: const EdgeInsets.symmetric(
                                            vertical: 4),
                                        color: isDark
                                            ? const Color(0xFF334155)
                                            : const Color(0xFFE2E8F0),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(width: 14),

                              // Content Card
                              Expanded(
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 16),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE0E5EC),
                                    borderRadius: BorderRadius.circular(14),
                                    border:
                                        Border.all(color: borderClr, width: 1),
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              item.status,
                                              style: GoogleFonts.poppins(
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                                color: isDark
                                                    ? Colors.white
                                                    : RampColors.slate,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            item.formattedTime,
                                            style: GoogleFonts.poppins(
                                              fontSize: 11,
                                              color: isDark
                                                  ? const Color(0xFF94A3B8)
                                                  : RampColors.mutedText,
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (item.note != null &&
                                          item.note!.isNotEmpty) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          item.note!,
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            color: isDark
                                                ? const Color(0xFFCBD5E1)
                                                : const Color(0xFF475569),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
