// lib/features/calendar/widgets/event_card.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/ramp_theme.dart';
import '../../../core/state/ramp_state.dart';
import '../../../screens/payments_screen.dart';
import '../../../screens/tenant_profile.dart';
import '../../../screens/ticket_form.dart';
import '../../../screens/unit_detail.dart';
import 'add_edit_event_sheet.dart';

class RampCalendarEventCard extends ConsumerWidget {
  const RampCalendarEventCard({
    super.key,
    required this.event,
    this.onCloseSheet,
  });

  final AppEvent event;
  final VoidCallback? onCloseSheet;

  Color _priorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'urgent':
        return const Color(0xFFEF4444);
      case 'high':
        return const Color(0xFFF97316);
      case 'medium':
        return const Color(0xFFEAB308);
      case 'low':
      default:
        return const Color(0xFF10B981);
    }
  }

  void _navigateTo(BuildContext context, WidgetRef ref, String route, {Tenant? tenant, Ticket? ticket}) {
    if (onCloseSheet != null) {
      onCloseSheet!();
    } else if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (route == '/payments/new') {
        Navigator.of(context, rootNavigator: true).push(
          MaterialPageRoute(builder: (_) => PaymentsScreen(initialTenant: tenant)),
        );
      } else if (route == '/maintenance/new') {
        Navigator.of(context, rootNavigator: true).push(
          MaterialPageRoute(builder: (_) => const TicketFormScreen()),
        );
      } else if (route == '/maintenance') {
        if (ticket != null) {
          Navigator.of(context, rootNavigator: true).push(
            MaterialPageRoute(builder: (_) => TicketFormScreen(existingTicket: ticket)),
          );
        } else {
          ref.read(bottomNavIndexProvider.notifier).state = 2;
        }
      } else if (route == '/tenants') {
        if (tenant != null) {
          Navigator.of(context, rootNavigator: true).push(
            MaterialPageRoute(builder: (_) => TenantProfileScreen(tenantId: tenant.id)),
          );
        } else {
          ref.read(bottomNavIndexProvider.notifier).state = 3;
        }
      } else if (route.startsWith('/units/')) {
        final unitId = route.substring('/units/'.length);
        Navigator.of(context, rootNavigator: true).push(
          MaterialPageRoute(builder: (_) => UnitDetailScreen(unitId: unitId)),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final categoryColor = event.categoryColor;
    final isOverdue = event.isOverdue;
    final isCompleted = event.isCompleted;

    final tenants = ref.watch(tenantProvider);
    final tickets = ref.watch(ticketProvider);
    final units = ref.watch(unitProvider);

    final tenant = event.tenantId != null
        ? tenants.where((t) => t.id == event.tenantId).firstOrNull
        : null;
    final ticket = event.ticketId != null
        ? tickets.where((t) => t.id == event.ticketId).firstOrNull
        : null;
    final unit = event.unitId != null
        ? units.where((u) => u.id == event.unitId).firstOrNull
        : null;

    final isCustomEvent = !event.id.startsWith('rent_') &&
        !event.id.startsWith('ticket_') &&
        !event.id.startsWith('lease_');

    return RampCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.zero,
      borderRadius: 20,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 10,
          offset: const Offset(0, 4),
        )
      ],
      borderColor: isOverdue
          ? Colors.red.withValues(alpha: 0.4)
          : Colors.transparent,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Category Color Left Bar Indicator
              Container(
                width: 6,
                color: isOverdue ? Colors.red : categoryColor,
              ),

              Expanded(
                child: Theme(
                  data: theme.copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    tilePadding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                    childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    leading: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: isCompleted ? Colors.green.withValues(alpha: 0.15) : categoryColor.withValues(alpha: isDark ? 0.2 : 0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        isCompleted
                            ? Icons.check_circle_rounded
                            : isOverdue
                                ? Icons.warning_amber_rounded
                                : event.type.contains('rent')
                                    ? Icons.payments_rounded
                                    : event.type.contains('maintenance')
                                        ? Icons.handyman_rounded
                                        : event.type.contains('inspection')
                                            ? Icons.fact_check_rounded
                                            : event.type.contains('lease')
                                                ? Icons.description_rounded
                                                : Icons.event_rounded,
                        color: isCompleted
                            ? Colors.green
                            : isOverdue
                                ? Colors.red
                                : categoryColor,
                        size: 22,
                      ),
                    ),
                    title: Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              event.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                                fontSize: 14,
                                decoration: isCompleted ? TextDecoration.lineThrough : null,
                                color: isCompleted
                                    ? theme.colorScheme.onSurfaceVariant
                                    : theme.colorScheme.onSurface,
                              ),
                            ),
                          ),
                          // Priority Badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            margin: const EdgeInsets.only(left: 8),
                            decoration: BoxDecoration(
                              color: _priorityColor(event.priority).withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: _priorityColor(event.priority).withValues(alpha: 0.3),
                              ),
                            ),
                            child: Text(
                              event.priority.toUpperCase(),
                              style: GoogleFonts.poppins(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: _priorityColor(event.priority),
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    subtitle: Row(
                      children: [
                        Icon(
                          Icons.schedule_rounded,
                          size: 13,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          DateFormat('EEEE • MMM d, yyyy').format(event.date),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                            fontSize: 11,
                          ),
                        ),
                        if (isOverdue) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'OVERDUE',
                              style: GoogleFonts.poppins(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    children: [
                      if (event.description != null && event.description!.isNotEmpty) ...[
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF1E2022) : const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.info_outline_rounded, size: 16, color: theme.colorScheme.onSurfaceVariant),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    event.description!,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurface,
                                      fontSize: 12,
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                      ],

                      // Action buttons
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            // 1. Copy Reminder Action
                            _EventActionButton(
                              icon: Icons.content_copy_rounded,
                              label: 'Copy Reminder',
                              onPressed: () {
                                final text = 'Reminder: ${event.title} scheduled for ${DateFormat('MMMM d, yyyy').format(event.date)}. ${event.description ?? ''}';
                                Clipboard.setData(ClipboardData(text: text));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Reminder copied to clipboard.')),
                                );
                              },
                              color: theme.colorScheme.onSurfaceVariant,
                            ),

                            // 2. Quick Pay for Rent
                            if (event.type.contains('rent') && tenant != null)
                              _EventActionButton(
                                icon: Icons.add_card_rounded,
                                label: 'Receive Payment',
                                onPressed: () => _navigateTo(context, ref, '/payments/new', tenant: tenant),
                                color: Colors.green,
                              ),

                            // 3. View Tenant
                            if (tenant != null)
                              _EventActionButton(
                                icon: Icons.person_outline_rounded,
                                label: 'Tenant Profile',
                                onPressed: () => _navigateTo(context, ref, '/tenants', tenant: tenant),
                                color: theme.colorScheme.primary,
                              ),

                            // 4. View Ticket
                            if (ticket != null)
                              _EventActionButton(
                                icon: Icons.build_outlined,
                                label: 'Open Ticket',
                                onPressed: () => _navigateTo(context, ref, '/maintenance', ticket: ticket),
                                color: const Color(0xFFF59E0B),
                              ),

                            // 5. View Unit
                            if (unit != null)
                              _EventActionButton(
                                icon: Icons.apartment_rounded,
                                label: 'Unit Details',
                                onPressed: () => _navigateTo(context, ref, '/units/${unit.id}'),
                                color: const Color(0xFF0EA5E9),
                              ),

                            // 6. Custom Event: Toggle Complete
                            if (isCustomEvent)
                              _EventActionButton(
                                icon: isCompleted ? Icons.undo_rounded : Icons.check_circle_outline_rounded,
                                label: isCompleted ? 'Reopen' : 'Complete',
                                onPressed: () {
                                  ref.read(eventProvider.notifier).toggleEventCompleted(event.id);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(isCompleted ? 'Event marked incomplete' : 'Event marked completed!'),
                                    ),
                                  );
                                },
                                color: isCompleted ? theme.colorScheme.onSurfaceVariant : Colors.green,
                              ),

                            // 7. Custom Event: Edit
                            if (isCustomEvent)
                              _EventActionButton(
                                icon: Icons.edit_outlined,
                                label: 'Edit',
                                onPressed: () {
                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    backgroundColor: isDark ? theme.colorScheme.surface : Colors.white,
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                                    ),
                                    builder: (_) => AddEditEventSheet(existingEvent: event),
                                  );
                                },
                                color: theme.colorScheme.primary,
                              ),

                            // 8. Custom Event: Delete
                            if (isCustomEvent)
                              _EventActionButton(
                                icon: Icons.delete_outline_rounded,
                                label: 'Delete',
                                color: Colors.red,
                                onPressed: () async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (dialogCtx) => AlertDialog(
                                      title: const Text('Delete Event'),
                                      content: Text('Are you sure you want to delete "${event.title}"?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(dialogCtx, false),
                                          child: const Text('CANCEL'),
                                        ),
                                        FilledButton(
                                          onPressed: () => Navigator.pop(dialogCtx, true),
                                          style: FilledButton.styleFrom(backgroundColor: Colors.red),
                                          child: const Text('DELETE'),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (confirm == true) {
                                    ref.read(eventProvider.notifier).deleteEvent(event.id);
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Event deleted.')),
                                      );
                                    }
                                  }
                                },
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EventActionButton extends StatelessWidget {
  const _EventActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.color,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeColor = color ?? theme.colorScheme.primary;
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: activeColor.withValues(alpha: isDark ? 0.15 : 0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: activeColor.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: activeColor),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: activeColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
