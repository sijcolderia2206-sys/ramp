import 'package:flutter/material.dart';
import '../core/state/ramp_state.dart';
import '../core/theme/ramp_theme.dart';
import 'ticket_stage_timeline.dart';

class MaintenanceTicketCard extends StatelessWidget {
  final Ticket ticket;
  final bool isExpanded;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onViewTimeline;
  final VoidCallback onDelete;
  final VoidCallback? onScheduleVisit;
  final VoidCallback? onEstimate;
  final VoidCallback? onScheduleRepair;
  final VoidCallback? onComplete;

  const MaintenanceTicketCard({
    super.key,
    required this.ticket,
    required this.isExpanded,
    required this.onTap,
    required this.onEdit,
    required this.onViewTimeline,
    required this.onDelete,
    this.onScheduleVisit,
    this.onEstimate,
    this.onScheduleRepair,
    this.onComplete,
  });

  Color _getStatusDotColor() {
    switch (ticket.status) {
      case 'Schedule Visit':
      case 'New':
      case 'Open':
        return const Color(0xFF3B82F6);
      case 'Estimate':
        return const Color(0xFF8B5CF6);
      case 'Schedule Repair':
      case 'In Progress':
        return const Color(0xFFF59E0B);
      case 'Completed':
      case 'Closed':
        return const Color(0xFF10B981);
      default:
        return RampColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final foreground = theme.colorScheme.onSurface;
    final muted = theme.colorScheme.onSurfaceVariant;
    final completed = ticket.status == 'Completed' || ticket.status == 'Closed';
    final statusColor = _getStatusDotColor();

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: RampTheme.standardShadow,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
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
                      ticket.title.replaceAll(
                          RegExp(r'^Ticket:\s*', caseSensitive: false), ''),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: foreground,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  PopupMenuButton<String>(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: Icon(Icons.more_vert_rounded, size: 20, color: muted),
                    tooltip: 'Ticket Actions',
                    onSelected: (val) {
                      if (val == 'edit') onEdit();
                      if (val == 'timeline') onViewTimeline();
                      if (val == 'delete') onDelete();
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

              // Badges Row
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
                ],
              ),

              // Expanded Details Section
              if (isExpanded) ...[
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
                TicketStageTimeline(ticket: ticket),
                const SizedBox(height: 12),
                if (ticket.description.isNotEmpty) ...[
                  Text(
                    'Description:',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: foreground),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    ticket.description,
                    style: TextStyle(fontSize: 12, color: muted),
                  ),
                  const SizedBox(height: 12),
                ],
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (onScheduleVisit != null)
                      TextButton.icon(
                        icon: const Icon(Icons.event_rounded, size: 16),
                        label: const Text('Schedule Visit'),
                        onPressed: onScheduleVisit,
                      ),
                    if (onEstimate != null)
                      TextButton.icon(
                        icon: const Icon(Icons.description_rounded, size: 16),
                        label: const Text('Add Estimate'),
                        onPressed: onEstimate,
                      ),
                    if (onScheduleRepair != null)
                      TextButton.icon(
                        icon: const Icon(Icons.build_rounded, size: 16),
                        label: const Text('Schedule Repair'),
                        onPressed: onScheduleRepair,
                      ),
                    if (onComplete != null)
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: RampColors.success,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                        ),
                        icon: const Icon(Icons.check_circle_rounded, size: 16),
                        label: const Text('Complete',
                            style: TextStyle(fontSize: 12)),
                        onPressed: onComplete,
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
}
