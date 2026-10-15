// lib/screens/tenant/maintenance_repairs_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../theme.dart';
import '../../models/maintenance_ticket_model.dart';
import '../../models/tenant_model.dart';
import '../../models/unit_model.dart';
import '../../widgets/neumorphic_widgets.dart';
import '../../widgets/dashed_border_container.dart';
import '../../providers/tenant_providers.dart';
import '../../providers/landlord_providers.dart';
import '../../core/validators.dart';

class MaintenanceRepairsScreen extends ConsumerStatefulWidget {
  const MaintenanceRepairsScreen({super.key});

  @override
  ConsumerState<MaintenanceRepairsScreen> createState() => _MaintenanceRepairsScreenState();
}

class _MaintenanceRepairsScreenState extends ConsumerState<MaintenanceRepairsScreen> {
  void _openCreateTicketModal(BuildContext context, TenantRecord tenant, RentalUnit unit) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFFE0E5EC),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return _CreateTicketModal(tenant: tenant, unit: unit);
      },
    );
  }

  void _showRatingDialog(BuildContext context, MaintenanceTicket ticket) {
    int selectedRating = ticket.rating ?? 5;
    final feedbackController = TextEditingController(text: ticket.tenantFeedback ?? '');

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFFE0E5EC),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Text(
                'Rate Service Quality',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: RampTheme.textPrimary),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'How was the repair resolution for "${ticket.title}"?',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 13, color: RampTheme.textSecondary),
                    ),
                    const SizedBox(height: 16),

                    // Neumorphic 5-Star Rating Widget
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        final star = index + 1;
                        return GestureDetector(
                          onTap: () {
                            setDialogState(() => selectedRating = star);
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            padding: const EdgeInsets.all(6),
                            decoration: NeumorphicDecoration.convex(
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              star <= selectedRating ? Icons.star_rounded : Icons.star_outline_rounded,
                              color: star <= selectedRating ? Colors.amber : RampTheme.textSecondary,
                              size: 28,
                            ),
                          ),
                        );
                      }),
                    ),

                    const SizedBox(height: 20),

                    // Rating Feedback Input Field
                    NeumorphicTextField(
                      controller: feedbackController,
                      label: 'Rating Feedback / Review',
                      hintText: 'Share details about the repair service...',
                      maxLines: 3,
                      prefixIcon: Icons.rate_review_outlined,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: RampTheme.primaryBlue,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () async {
                    await ref.read(maintenanceTicketsProvider.notifier).rateTicket(
                          ticket.id,
                          selectedRating,
                          feedbackController.text.trim(),
                        );
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Thank you for rating the service!'),
                          backgroundColor: RampTheme.successGreen,
                        ),
                      );
                    }
                  },
                  child: const Text('Submit Rating', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final tenant = ref.watch(currentTenantProvider);
    final unit = ref.watch(currentTenantUnitProvider);
    final myTickets = ref.watch(tenantTicketsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFE0E5EC),
      floatingActionButton: NeumorphicContainer(
        shape: BoxShape.circle,
        width: 58,
        height: 58,
        onTap: (tenant == null || unit == null)
            ? null
            : () => _openCreateTicketModal(context, tenant, unit),
        child: const Center(
          child: Icon(
            Icons.add,
            color: RampTheme.primaryBlue,
            size: 30,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(RampTheme.spacing20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Screen Header
              const Text(
                'MAINTENANCE & REPAIRS',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                  color: RampTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Ticket History',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: RampTheme.textPrimary,
                    ),
                  ),
                  NeumorphicPill(
                    text: '${myTickets.length} Total',
                    textColor: RampTheme.primaryBlue,
                  ),
                ],
              ),
              const SizedBox(height: RampTheme.spacing16),

              // Tickets List
              Expanded(
                child: myTickets.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            NeumorphicContainer(
                              shape: BoxShape.circle,
                              width: 80,
                              height: 80,
                              child: const Icon(
                                Icons.build_circle_outlined,
                                size: 40,
                                color: RampTheme.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'No maintenance requests logged.',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: RampTheme.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Tap the "+" button below to submit a repair request.',
                              style: TextStyle(
                                fontSize: 12,
                                color: RampTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        itemCount: myTickets.length,
                        itemBuilder: (context, index) {
                          final ticket = myTickets[index];
                          return _buildTicketCard(context, ticket);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRealtimeStageStepper(String currentStage) {
    final stages = ['Schedule Visit', 'Estimate', 'Schedule Repair', 'Completed'];

    int currentIndex = 0;
    if (currentStage.toLowerCase().contains('estimate')) {
      currentIndex = 1;
    } else if (currentStage.toLowerCase().contains('repair')) {
      currentIndex = 2;
    } else if (currentStage.toLowerCase().contains('completed') || currentStage.toLowerCase().contains('resolved')) {
      currentIndex = 3;
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: RampTheme.scaffoldBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: RampTheme.dividerColor.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Live Repair Pipeline:',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: RampTheme.textSecondary),
              ),
              Text(
                'Stage ${currentIndex + 1} of 4',
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: RampTheme.primaryBlue),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: List.generate(4, (index) {
              final isPassed = index <= currentIndex;
              final isCurrent = index == currentIndex;

              return Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: isCurrent ? 20 : 14,
                            height: isCurrent ? 20 : 14,
                            decoration: BoxDecoration(
                              color: isPassed ? RampTheme.successGreen : RampTheme.dividerColor,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isPassed ? Icons.check : Icons.circle,
                              size: isCurrent ? 12 : 8,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            stages[index].split(' ').last,
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: isPassed ? FontWeight.bold : FontWeight.normal,
                              color: isPassed ? RampTheme.textPrimary : RampTheme.textSecondary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    if (index < 3)
                      Expanded(
                        child: Container(
                          height: 2,
                          color: index < currentIndex ? RampTheme.successGreen : RampTheme.dividerColor,
                        ),
                      ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildTicketCard(BuildContext context, MaintenanceTicket ticket) {
    final isCompleted = ticket.stage == 'Completed' || ticket.stage == 'Resolved';
    final formattedDate = DateFormat('MMM d, yyyy • h:mm a').format(ticket.createdAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: NeumorphicContainer(
        borderRadius: 20.0,
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title & Status Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ticket.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: RampTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Category: ${ticket.unitArea} • Priority: ${ticket.priority}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: RampTheme.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),

                // Recessed Neumorphic Badge for Status
                NeumorphicPill(
                  text: isCompleted ? 'Completed' : ticket.stage,
                  textColor: isCompleted ? RampTheme.successGreen : RampTheme.primaryBlue,
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Live 4-Stage SLA Repair Stepper
            _buildRealtimeStageStepper(ticket.stage),

            const SizedBox(height: 6),

            // Date
            Row(
              children: [
                const Icon(Icons.calendar_today_rounded, size: 12, color: RampTheme.textSecondary),
                const SizedBox(width: 6),
                Text(
                  formattedDate,
                  style: const TextStyle(fontSize: 11, color: RampTheme.textSecondary),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Description
            if (ticket.description.isNotEmpty) ...[
              Text(
                ticket.description,
                style: const TextStyle(
                  fontSize: 13,
                  color: RampTheme.textPrimary,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Before & After Photo Preview Comparison
            if (ticket.photoAfter != null && ticket.photoAfter!.isNotEmpty) ...[
              Row(
                children: [
                  if (ticket.photoBefore != null && ticket.photoBefore!.isNotEmpty)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Before Repair', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: RampTheme.textSecondary)),
                          const SizedBox(height: 4),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              ticket.photoBefore!,
                              height: 100,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => File(ticket.photoBefore!).existsSync()
                                  ? Image.file(File(ticket.photoBefore!), height: 100, fit: BoxFit.cover)
                                  : Container(height: 100, color: Colors.grey.shade300, child: const Icon(Icons.broken_image)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (ticket.photoBefore != null && ticket.photoBefore!.isNotEmpty) const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('After Repair', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: RampTheme.successGreen)),
                        const SizedBox(height: 4),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            ticket.photoAfter!,
                            height: 100,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => File(ticket.photoAfter!).existsSync()
                                ? Image.file(File(ticket.photoAfter!), height: 100, fit: BoxFit.cover)
                                : Container(height: 100, color: Colors.grey.shade300, child: const Icon(Icons.broken_image)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ] else if (ticket.photoBefore != null && ticket.photoBefore!.isNotEmpty) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  ticket.photoBefore!,
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    if (File(ticket.photoBefore!).existsSync()) {
                      return Image.file(File(ticket.photoBefore!), height: 120, fit: BoxFit.cover);
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Service Rating Section (Revealed when ticket status == 'Completed')
            if (isCompleted) ...[
              const Divider(height: 1),
              const SizedBox(height: 12),

              NeumorphicContainer(
                isInset: true,
                borderRadius: 14,
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.check_circle_outline_rounded, color: RampTheme.successGreen, size: 18),
                            SizedBox(width: 6),
                            Text(
                              'Service Completed',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: RampTheme.successGreen),
                            ),
                          ],
                        ),
                        if (ticket.rating != null)
                          Row(
                            children: List.generate(
                              5,
                              (index) => Icon(
                                index < ticket.rating! ? Icons.star_rounded : Icons.star_outline_rounded,
                                color: index < ticket.rating! ? Colors.amber : RampTheme.textSecondary,
                                size: 16,
                              ),
                            ),
                          ),
                      ],
                    ),

                    if (ticket.tenantFeedback != null && ticket.tenantFeedback!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Feedback: "${ticket.tenantFeedback}"',
                        style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: RampTheme.textPrimary),
                      ),
                    ],

                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: NeumorphicButton(
                        label: ticket.rating == null ? 'Rate Service Quality' : 'Update Rating & Feedback',
                        icon: Icons.star_rate_rounded,
                        height: 40,
                        backgroundColor: NeumorphicDecoration.baseColor,
                        textColor: RampTheme.primaryBlue,
                        onPressed: () => _showRatingDialog(context, ticket),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// SUBMIT REPAIR REQUEST FAB BOTTOM SHEET MODAL
// ============================================================================
class _CreateTicketModal extends ConsumerStatefulWidget {
  final TenantRecord tenant;
  final RentalUnit unit;

  const _CreateTicketModal({
    required this.tenant,
    required this.unit,
  });

  @override
  ConsumerState<_CreateTicketModal> createState() => _CreateTicketModalState();
}

class _CreateTicketModalState extends ConsumerState<_CreateTicketModal> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  String _category = 'Plumbing'; // Dropdown options: Plumbing, Electrical, General, Aircon, Carpentry
  String _priority = 'Med'; // Segmented control options: Low, Med, High
  XFile? _photoFile;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    try {
      final XFile? file = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (file != null) {
        setState(() => _photoFile = file);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking photo: $e')),
        );
      }
    }
  }

  Future<void> _submitTicket() async {
    if (!_formKey.currentState!.validate()) return;

    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    setState(() => _isSubmitting = true);

    try {
      String? photoUrl;
      if (_photoFile != null) {
        photoUrl = await uploadToRampMedia(_photoFile!, 'ticket_photos');
      }

      String fullPriority = _priority == 'High'
          ? 'Emergency'
          : _priority == 'Med'
              ? 'Medium'
              : 'Low';

      final now = DateTime.now();
      final slaDueDate = MaintenanceTicket.calculateSlaDueDate(fullPriority, now);

      final ticket = MaintenanceTicket(
        id: 'ticket_${now.millisecondsSinceEpoch}',
        unitId: widget.unit.id,
        unitNumber: widget.unit.unitNumber,
        tenantId: widget.tenant.id,
        tenantName: widget.tenant.name,
        title: title,
        description: _descController.text.trim(),
        unitArea: _category,
        priority: fullPriority,
        stage: 'Pending',
        photoBefore: photoUrl,
        slaDueDate: slaDueDate,
        createdAt: now,
      );

      await ref.read(maintenanceTicketsProvider.notifier).addTicket(ticket);
      ref.read(notificationsProvider.notifier).addNotification(
            'New Repair Ticket',
            '${widget.tenant.name} reported issue: $title ($fullPriority)',
            'maintenance',
          );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: RampTheme.successGreen,
            content: Text('Repair request submitted successfully!'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: RampTheme.errorRed,
            content: Text('Failed to submit repair request: $e'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Submit Repair Request',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: RampTheme.textPrimary,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: RampTheme.textSecondary),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 12),

              // 1. Title (inset text)
              NeumorphicTextField(
                controller: _titleController,
                label: 'Title *',
                hintText: 'e.g. Water leak under kitchen sink',
                prefixIcon: Icons.build_outlined,
                validator: (val) => FormValidators.name(val, 'Title', minLength: 3, maxLength: 100),
              ),

              const SizedBox(height: 16),

              // 2. Category Dropdown
              NeumorphicDropdown<String>(
                label: 'Category *',
                value: _category,
                prefixIcon: Icons.category_outlined,
                items: const [
                  DropdownMenuItem(value: 'Plumbing', child: Text('Plumbing')),
                  DropdownMenuItem(value: 'Electrical', child: Text('Electrical')),
                  DropdownMenuItem(value: 'General', child: Text('General')),
                  DropdownMenuItem(value: 'Aircon', child: Text('Aircon')),
                  DropdownMenuItem(value: 'Carpentry', child: Text('Carpentry')),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _category = val);
                },
              ),

              const SizedBox(height: 16),

              // 3. Priority Segmented Control (Low, Med, High)
              const Padding(
                padding: EdgeInsets.only(left: 4, bottom: 6),
                child: Text(
                  'Priority *',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: RampTheme.textPrimary),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: NeumorphicFilterChip(
                      label: 'Low',
                      isSelected: _priority == 'Low',
                      onTap: () => setState(() => _priority = 'Low'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: NeumorphicFilterChip(
                      label: 'Med',
                      isSelected: _priority == 'Med',
                      onTap: () => setState(() => _priority = 'Med'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: NeumorphicFilterChip(
                      label: 'High',
                      isSelected: _priority == 'High',
                      onTap: () => setState(() => _priority = 'High'),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // 4. Description (multiline text)
              NeumorphicTextField(
                controller: _descController,
                label: 'Description',
                hintText: 'Describe the issue in detail...',
                maxLines: 3,
                prefixIcon: Icons.notes_outlined,
                validator: (val) => FormValidators.textLength(val, 'Description', minLength: 5, maxLength: 500, isRequired: false),
              ),

              const SizedBox(height: 16),

              // 5. Photo Attachment
              const Padding(
                padding: EdgeInsets.only(left: 4, bottom: 6),
                child: Text(
                  'Photo Attachment',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: RampTheme.textPrimary),
                ),
              ),

              if (_photoFile == null)
                DashedBorderContainer(
                  height: 110,
                  onTap: _pickPhoto,
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_a_photo_outlined, color: RampTheme.primaryBlue, size: 22),
                      SizedBox(width: 8),
                      Text(
                        'Tap to attach issue photo',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: RampTheme.textPrimary),
                      ),
                    ],
                  ),
                )
              else
                NeumorphicContainer(
                  isInset: true,
                  borderRadius: 14,
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(
                          File(_photoFile!.path),
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _photoFile!.name,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: RampTheme.errorRed, size: 20),
                        onPressed: () => setState(() => _photoFile = null),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 24),

              // Submit Button
              NeumorphicButton(
                label: _isSubmitting ? 'Submitting...' : 'Submit Repair Request',
                icon: Icons.send_rounded,
                isLoading: _isSubmitting,
                onPressed: _isSubmitting ? null : _submitTicket,
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
