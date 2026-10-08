// lib/widgets/ticket_stage_timeline.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/state/ramp_state.dart';
import '../core/theme/ramp_theme.dart';

class TicketStageTimeline extends StatelessWidget {
  final Ticket ticket;

  const TicketStageTimeline({
    super.key,
    required this.ticket,
  });

  int get _currentStageIndex {
    switch (ticket.status) {
      case 'Schedule Visit':
      case 'New':
      case 'Open':
        return 0;
      case 'Estimate':
      case 'Inspection Completed':
        return 1;
      case 'Schedule Repair':
      case 'Estimate Approved':
      case 'In Progress':
        return 2;
      case 'Completed':
      case 'Closed':
        return 3;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final currentIndex = _currentStageIndex;

    final stages = [
      {'title': 'Reported', 'date': ticket.createdAt},
      {'title': 'Visit Scheduled', 'date': ticket.date},
      {'title': 'Repair Scheduled', 'date': ticket.slaDueDate},
      {'title': 'Completed', 'date': ticket.slaDueDate ?? ticket.createdAt},
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Stage Progress Timeline',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: List.generate(stages.length, (index) {
              final isPassed = index <= currentIndex;
              final isCurrent = index == currentIndex;
              final dateVal = stages[index]['date'] as DateTime?;

              return Expanded(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 2,
                            color: index == 0
                                ? Colors.transparent
                                : (isPassed
                                    ? RampColors.primary
                                    : (isDark
                                        ? const Color(0xFF334155)
                                        : const Color(0xFFCBD5E1))),
                          ),
                        ),
                        Container(
                          width: isCurrent ? 14 : 10,
                          height: isCurrent ? 14 : 10,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isPassed
                                ? RampColors.primary
                                : (isDark
                                    ? const Color(0xFF334155)
                                    : const Color(0xFFCBD5E1)),
                            border: isCurrent
                                ? Border.all(color: Colors.white, width: 2)
                                : null,
                          ),
                        ),
                        Expanded(
                          child: Container(
                            height: 2,
                            color: index == stages.length - 1
                                ? Colors.transparent
                                : (index < currentIndex
                                    ? RampColors.primary
                                    : (isDark
                                        ? const Color(0xFF334155)
                                        : const Color(0xFFCBD5E1))),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      stages[index]['title'] as String,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight:
                            isCurrent ? FontWeight.bold : FontWeight.normal,
                        color: isPassed
                            ? theme.colorScheme.onSurface
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (dateVal != null)
                      Text(
                        DateFormat('MMM d').format(dateVal),
                        style: TextStyle(
                          fontSize: 9,
                          color: theme.colorScheme.onSurfaceVariant,
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
}
