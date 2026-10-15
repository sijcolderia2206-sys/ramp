// lib/screens/landlord/maintenance_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../theme.dart';
import '../../models/maintenance_ticket_model.dart';
import '../../providers/landlord_providers.dart';
import '../../widgets/neumorphic_widgets.dart';
import '../../core/validators.dart';
import 'add_repair_screen.dart';

class LandlordMaintenanceScreen extends ConsumerWidget {
  const LandlordMaintenanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: RampTheme.scaffoldBackground,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12.0),
            // Header Title
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Maintenance & Repairs',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: RampTheme.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 12.0),
            // Inset Search Bar
            const _TicketSearchBar(),
            const SizedBox(height: 12.0),
            // Filter Chips Row
            const _TicketFilterRow(),
            const SizedBox(height: 12.0),
            // Ticket List
            const Expanded(child: _TicketListView()),
          ],
        ),
      ),
      floatingActionButton: _AddTicketFab(),
    );
  }
}

class _TicketSearchBar extends ConsumerWidget {
  const _TicketSearchBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = ref.watch(ticketSearchQueryProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: NeumorphicSearchBar(
        hintText: 'Search by unit #, issue title, category, or contractor...',
        initialValue: query,
        onChanged: (val) {
          ref.read(ticketSearchQueryProvider.notifier).updateQuery(val);
        },
        onClear: () {
          ref.read(ticketSearchQueryProvider.notifier).clear();
        },
      ),
    );
  }
}

class _TicketFilterRow extends ConsumerWidget {
  const _TicketFilterRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeFilter = ref.watch(ticketFilterProvider);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          NeumorphicFilterChip(
            label: 'Pending',
            isSelected: activeFilter == TicketStatus.pending,
            onTap: () => ref.read(ticketFilterProvider.notifier).updateFilter(TicketStatus.pending),
          ),
          const SizedBox(width: 10.0),
          NeumorphicFilterChip(
            label: 'In Progress',
            isSelected: activeFilter == TicketStatus.inProgress,
            onTap: () => ref.read(ticketFilterProvider.notifier).updateFilter(TicketStatus.inProgress),
          ),
          const SizedBox(width: 10.0),
          NeumorphicFilterChip(
            label: 'Resolved',
            isSelected: activeFilter == TicketStatus.resolved,
            onTap: () => ref.read(ticketFilterProvider.notifier).updateFilter(TicketStatus.resolved),
          ),
          const SizedBox(width: 10.0),
          NeumorphicFilterChip(
            label: 'All Tickets',
            isSelected: activeFilter == TicketStatus.all,
            onTap: () => ref.read(ticketFilterProvider.notifier).updateFilter(TicketStatus.all),
          ),
        ],
      ),
    );
  }
}

class _TicketListView extends ConsumerWidget {
  const _TicketListView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tickets = ref.watch(filteredTicketsProvider);

    if (tickets.isEmpty) {
      return const _EmptyTicketState();
    }

    return ListView.separated(
      padding: const EdgeInsets.only(
        left: 16.0,
        right: 16.0,
        top: 8.0,
        bottom: 80.0,
      ),
      itemCount: tickets.length,
      separatorBuilder: (_, __) => const SizedBox(height: 14.0),
      itemBuilder: (context, index) {
        return _TicketSlidableCard(ticket: tickets[index]);
      },
    );
  }
}

class _TicketSlidableCard extends ConsumerWidget {
  final MaintenanceTicket ticket;

  const _TicketSlidableCard({required this.ticket});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Color priorityColor;
    switch (ticket.priority.toLowerCase()) {
      case 'emergency':
      case 'urgent':
      case 'high':
        priorityColor = RampTheme.errorRed;
        break;
      case 'medium':
      case 'med':
        priorityColor = RampTheme.warningYellow;
        break;
      case 'low':
      default:
        priorityColor = RampTheme.successGreen;
        break;
    }

    final isCompleted = ticket.stage == 'Completed' || ticket.stage == 'Resolved';
    
    // Determine SLA Badge Color
    Color slaColor = RampTheme.successGreen;
    if (ticket.isOverdue) {
      slaColor = RampTheme.errorRed;
    } else if (ticket.priority.toLowerCase() == 'emergency') {
      slaColor = RampTheme.warningYellow;
    }

    return Slidable(
      key: ValueKey(ticket.id),
      startActionPane: ActionPane(
        motion: const BehindMotion(),
        children: [
          SlidableAction(
            onPressed: (ctx) {
              _showTriageModal(context, ref, ticket);
            },
            backgroundColor: RampTheme.primaryBlue,
            foregroundColor: Colors.white,
            icon: Icons.tune_rounded,
            label: 'Manage SLA',
            borderRadius: const BorderRadius.horizontal(left: Radius.circular(18)),
          ),
        ],
      ),
      child: NeumorphicContainer(
        borderRadius: 18.0,
        onTap: () => _showTriageModal(context, ref, ticket),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Leading Thumbnail or Fallback Icon
                  NeumorphicContainer(
                    borderRadius: 14.0,
                    width: 52,
                    height: 52,
                    child: ticket.imageUrl != null && ticket.imageUrl!.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(14.0),
                            child: Image.network(
                              ticket.imageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) {
                                if (File(ticket.imageUrl!).existsSync()) {
                                  return Image.file(File(ticket.imageUrl!), fit: BoxFit.cover);
                                }
                                return const Icon(Icons.build_rounded, color: RampTheme.primaryBlue);
                              },
                            ),
                          )
                        : const Icon(Icons.build_rounded, color: RampTheme.primaryBlue, size: 24),
                  ),
                  const SizedBox(width: 14.0),

                  // Issue Title & Unit
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                ticket.issueTitle,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: RampTheme.textPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (ticket.repairCost > 0) ...[
                              const SizedBox(width: 8.0),
                              Text(
                                formatCurrency(ticket.repairCost),
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: RampTheme.primaryBlue,
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4.0),
                        Text(
                          'Unit ${ticket.unitNumber} • ${ticket.category}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: RampTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12.0),

              // Badges & SLA Countdown
              Wrap(
                spacing: 8.0,
                runSpacing: 6.0,
                children: [
                  NeumorphicPill(
                    text: ticket.priority,
                    textColor: priorityColor,
                  ),
                  NeumorphicPill(
                    text: 'Stage: ${ticket.stage}',
                    textColor: isCompleted ? RampTheme.successGreen : RampTheme.primaryBlue,
                  ),
                  NeumorphicPill(
                    text: ticket.slaRemainingText,
                    textColor: slaColor,
                    icon: Icons.timer_outlined,
                  ),
                  if (ticket.isSlaBreached)
                    const NeumorphicPill(
                      text: 'SLA Breached',
                      textColor: RampTheme.errorRed,
                      icon: Icons.error_outline_rounded,
                    ),
                  if (ticket.isTenantChargeable)
                    const NeumorphicPill(
                      text: 'Tenant Chargeable',
                      textColor: RampTheme.warningYellow,
                      icon: Icons.receipt_long,
                    ),
                  if (ticket.repairer != null && ticket.repairer!.isNotEmpty)
                    NeumorphicPill(
                      text: ticket.repairer!,
                      textColor: RampTheme.textSecondary,
                      icon: Icons.person_outline,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTriageModal(BuildContext context, WidgetRef ref, MaintenanceTicket ticket) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: RampTheme.scaffoldBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
      ),
      builder: (context) => _TriageModalSheet(ticket: ticket),
    );
  }
}

class _TriageModalSheet extends ConsumerStatefulWidget {
  final MaintenanceTicket ticket;

  const _TriageModalSheet({required this.ticket});

  @override
  ConsumerState<_TriageModalSheet> createState() => _TriageModalSheetState();
}

class _TriageModalSheetState extends ConsumerState<_TriageModalSheet> {
  late String _activeStage;

  // Stage 1 - Visit
  late DateTime _visitDate;
  late String _visitTimeSlot;

  // Stage 2 - Estimate
  late TextEditingController _costController;
  late TextEditingController _itemsController;
  late bool _isTenantChargeable;

  // Stage 3 - Schedule Repair / Dispatch
  late TextEditingController _repairerNameCtrl;
  late TextEditingController _repairerPhoneCtrl;
  late DateTime _repairDate;
  late String _repairTimeSlot;

  // Stage 4 - Completion
  late TextEditingController _completionSummaryCtrl;
  File? _photoAfterFile;

  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _activeStage = widget.ticket.stage;
    if (_activeStage == 'Pending') _activeStage = 'Schedule Visit';

    _visitDate = widget.ticket.visitDate ?? DateTime.now().add(const Duration(days: 1));
    _visitTimeSlot = widget.ticket.visitTimeSlot ?? 'Morning (9:00 AM - 12:00 PM)';

    _costController = TextEditingController(
      text: widget.ticket.estimatedCost > 0 ? widget.ticket.estimatedCost.toStringAsFixed(2) : '',
    );
    _itemsController = TextEditingController(
      text: widget.ticket.replacementItems.join(', '),
    );
    _isTenantChargeable = widget.ticket.isTenantChargeable;

    _repairerNameCtrl = TextEditingController(text: widget.ticket.repairer ?? '');
    _repairerPhoneCtrl = TextEditingController(text: widget.ticket.repairerPhone ?? '');
    _repairDate = widget.ticket.repairDate ?? DateTime.now().add(const Duration(days: 2));
    _repairTimeSlot = widget.ticket.repairTimeSlot ?? 'Afternoon (1:00 PM - 5:00 PM)';

    _completionSummaryCtrl = TextEditingController(text: widget.ticket.completionSummary ?? '');
  }

  @override
  void dispose() {
    _costController.dispose();
    _itemsController.dispose();
    _repairerNameCtrl.dispose();
    _repairerPhoneCtrl.dispose();
    _completionSummaryCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickAfterPhoto() async {
    final file = await _picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      setState(() => _photoAfterFile = File(file.path));
    }
  }

  Future<void> _saveCurrentStage() async {
    setState(() => _isLoading = true);

    try {
      final notifier = ref.read(maintenanceTicketsProvider.notifier);

      if (_activeStage == 'Schedule Visit') {
        await notifier.updateStageVisit(
          widget.ticket.id,
          _visitDate,
          _visitTimeSlot,
        );
      } else if (_activeStage == 'Estimate') {
        final costErr = FormValidators.number(_costController.text, 'Estimated Cost', isRequired: true, allowZero: false);
        if (costErr != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(costErr), backgroundColor: RampTheme.errorRed),
          );
          return;
        }
        final cost = double.parse(_costController.text.trim());
        final items = _itemsController.text
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();

        await notifier.updateStageEstimate(
          widget.ticket.id,
          cost,
          items,
          isTenantChargeable: _isTenantChargeable,
        );
      } else if (_activeStage == 'Schedule Repair') {
        if (_repairerPhoneCtrl.text.trim().isNotEmpty) {
          final phoneErr = FormValidators.phone(_repairerPhoneCtrl.text, isRequired: false);
          if (phoneErr != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(phoneErr), backgroundColor: RampTheme.errorRed),
            );
            return;
          }
        }
        await notifier.updateStageRepair(
          widget.ticket.id,
          _repairerNameCtrl.text.trim().isEmpty ? 'Contractor Dispatched' : _repairerNameCtrl.text.trim(),
          _repairDate,
          _repairTimeSlot,
          repairerPhone: _repairerPhoneCtrl.text.trim(),
        );
      } else if (_activeStage == 'Completed') {
        await notifier.updateStageComplete(
          widget.ticket.id,
          completionSummary: _completionSummaryCtrl.text.trim().isEmpty
              ? 'Repair completed successfully.'
              : _completionSummaryCtrl.text.trim(),
          photoAfter: _photoAfterFile?.path,
        );
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Updated maintenance ticket for Unit ${widget.ticket.unitNumber}'),
            backgroundColor: RampTheme.successGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating ticket: $e'), backgroundColor: RampTheme.errorRed),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 20.0,
          right: 20.0,
          top: 16.0,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20.0,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Drag Handle
              Center(
                child: NeumorphicContainer(
                  isInset: true,
                  width: 44.0,
                  height: 5.0,
                  borderRadius: 2.5,
                  child: const SizedBox.shrink(),
                ),
              ),
              const SizedBox(height: 16.0),

              // Title Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.ticket.issueTitle,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: RampTheme.textPrimary),
                        ),
                        Text(
                          'Unit ${widget.ticket.unitNumber} • Priority: ${widget.ticket.priority}',
                          style: const TextStyle(fontSize: 12, color: RampTheme.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  NeumorphicPill(
                    text: widget.ticket.slaRemainingText,
                    textColor: widget.ticket.isOverdue ? RampTheme.errorRed : RampTheme.primaryBlue,
                    icon: Icons.timer_outlined,
                  ),
                ],
              ),

              const SizedBox(height: 16.0),

              // 4-Stage Stepper Buttons
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildStageChip('1. Visit', 'Schedule Visit'),
                    const SizedBox(width: 6),
                    _buildStageChip('2. Estimate', 'Estimate'),
                    const SizedBox(width: 6),
                    _buildStageChip('3. Repair', 'Schedule Repair'),
                    const SizedBox(width: 6),
                    _buildStageChip('4. Complete', 'Completed'),
                  ],
                ),
              ),

              const Divider(height: 28),

              // Stage Specific Form Elements
              if (_activeStage == 'Schedule Visit' || _activeStage == 'Pending') ...[
                const Text('Stage 1 — Schedule Inspection Visit', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 12),
                ListTile(
                  tileColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  leading: const Icon(Icons.calendar_today, color: RampTheme.primaryBlue),
                  title: const Text('Target Inspection Date', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                  subtitle: Text(DateFormat('EEEE, MMM d, yyyy').format(_visitDate), style: const TextStyle(fontSize: 12)),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _visitDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 30)),
                    );
                    if (picked != null) setState(() => _visitDate = picked);
                  },
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  initialValue: _visitTimeSlot,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Time Slot Window', prefixIcon: Icon(Icons.access_time)),
                  items: const [
                    DropdownMenuItem(
                      value: 'Morning (9:00 AM - 12:00 PM)',
                      child: Text('Morning (9:00 AM - 12:00 PM)', overflow: TextOverflow.ellipsis),
                    ),
                    DropdownMenuItem(
                      value: 'Afternoon (1:00 PM - 5:00 PM)',
                      child: Text('Afternoon (1:00 PM - 5:00 PM)', overflow: TextOverflow.ellipsis),
                    ),
                    DropdownMenuItem(
                      value: 'Evening (5:00 PM - 8:00 PM)',
                      child: Text('Evening (5:00 PM - 8:00 PM)', overflow: TextOverflow.ellipsis),
                    ),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => _visitTimeSlot = val);
                  },
                ),
              ] else if (_activeStage == 'Estimate') ...[
                const Text('Stage 2 — Inspection Findings & Cost Estimate', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 12),
                NeumorphicTextField(
                  controller: _costController,
                  label: 'Estimated Cost (PHP)',
                  hintText: 'e.g. 2500.00',
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  prefixIcon: Icons.payments_outlined,
                ),
                const SizedBox(height: 12),
                NeumorphicTextField(
                  controller: _itemsController,
                  label: 'Itemized Replacement Items',
                  hintText: 'e.g. PVC pipe, Silicone sealant, Valve',
                  prefixIcon: Icons.inventory_2_outlined,
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  activeThumbColor: RampTheme.primaryBlue,
                  title: const Text('Tenant Chargeable Repair', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                  subtitle: const Text('Automatically flags invoice for tenant reimbursement', style: TextStyle(fontSize: 11)),
                  value: _isTenantChargeable,
                  onChanged: (val) => setState(() => _isTenantChargeable = val),
                ),
              ] else if (_activeStage == 'Schedule Repair') ...[
                const Text('Stage 3 — Contractor & Dispatch Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 12),
                NeumorphicTextField(
                  controller: _repairerNameCtrl,
                  label: 'Assigned Contractor / Specialist',
                  hintText: 'e.g. Master Plumber Alex',
                  prefixIcon: Icons.badge_outlined,
                ),
                const SizedBox(height: 12),
                NeumorphicTextField(
                  controller: _repairerPhoneCtrl,
                  label: 'Contractor Phone Number',
                  hintText: 'e.g. +63 917 123 4567',
                  keyboardType: TextInputType.phone,
                  prefixIcon: Icons.phone_outlined,
                ),
                const SizedBox(height: 12),
                ListTile(
                  tileColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  leading: const Icon(Icons.build_circle_outlined, color: RampTheme.primaryBlue),
                  title: const Text('Target Repair Date', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                  subtitle: Text(DateFormat('EEEE, MMM d, yyyy').format(_repairDate), style: const TextStyle(fontSize: 12)),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _repairDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 30)),
                    );
                    if (picked != null) setState(() => _repairDate = picked);
                  },
                ),
              ] else if (_activeStage == 'Completed') ...[
                const Text('Stage 4 — Final Repair Completion', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 12),
                NeumorphicTextField(
                  controller: _completionSummaryCtrl,
                  label: 'Work Completed Summary',
                  hintText: 'Describe repair work performed...',
                  maxLines: 2,
                  prefixIcon: Icons.check_circle_outline,
                ),
                const SizedBox(height: 12),
                ListTile(
                  tileColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  leading: const Icon(Icons.add_a_photo_outlined, color: RampTheme.primaryBlue),
                  title: Text(_photoAfterFile == null ? 'Attach Completion Photo (After)' : 'Photo Attached!'),
                  subtitle: Text(_photoAfterFile?.path ?? 'Tap to pick image from gallery'),
                  onTap: _pickAfterPhoto,
                ),
              ],

              const SizedBox(height: 24.0),

              // Save / Advance Button
              NeumorphicButton(
                label: 'Save & Advance Stage',
                icon: Icons.check_circle_outline,
                isLoading: _isLoading,
                onPressed: _saveCurrentStage,
              ),
              const SizedBox(height: 12.0),

              // Edit Repair Ticket Button
              NeumorphicButton(
                label: 'Edit Ticket Details',
                icon: Icons.edit_outlined,
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => AddRepairScreen(ticketToEdit: widget.ticket),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStageChip(String label, String stageKey) {
    final isSelected = _activeStage == stageKey || (stageKey == 'Schedule Visit' && _activeStage == 'Pending');
    return GestureDetector(
      onTap: () => setState(() => _activeStage = stageKey),
      child: NeumorphicPill(
        text: label,
        textColor: isSelected ? Colors.white : RampTheme.textSecondary,
        backgroundColor: isSelected ? RampTheme.primaryBlue : null,
      ),
    );
  }
}

class _AddTicketFab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/add-repair'),
      child: NeumorphicContainer(
        borderRadius: 28.0,
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
        backgroundColor: RampTheme.primaryBlue,
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add_task, color: Colors.white, size: 20),
            SizedBox(width: 8.0),
            Text(
              'New Ticket',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyTicketState extends StatelessWidget {
  const _EmptyTicketState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            NeumorphicContainer(
              shape: BoxShape.circle,
              padding: const EdgeInsets.all(24.0),
              child: const Icon(
                Icons.check_circle_outline,
                size: 48,
                color: RampTheme.successGreen,
              ),
            ),
            const SizedBox(height: 20.0),
            const Text(
              'No Tickets Found',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: RampTheme.textPrimary),
            ),
            const SizedBox(height: 8.0),
            const Text(
              'All maintenance requests for this filter are up to date.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: RampTheme.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
