// lib/features/calendar/widgets/calendar_day_builder.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../models/models.dart';

class CalendarDayBuilderHelper {
  /// Custom selected day builder
  static Widget buildSelectedDay(
      BuildContext context, DateTime day, DateTime focusedDay) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.4),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        '${day.day}',
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.w700,
          fontSize: 14,
          color: theme.colorScheme.onPrimary,
        ),
      ),
    );
  }

  /// Custom today builder
  static Widget buildToday(
      BuildContext context, DateTime day, DateTime focusedDay) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.1),
        shape: BoxShape.circle,
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.5),
          width: 1.5,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        '${day.day}',
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.w800,
          fontSize: 14,
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }

  /// Custom marker builder showing dot indicators per event category
  static Widget? buildMarker(
      BuildContext context, DateTime day, List<AppEvent> events) {
    if (events.isEmpty) return null;

    final Set<Color> colors = {};
    bool hasOverdue = false;

    for (final e in events) {
      if (e.isOverdue) hasOverdue = true;
      colors.add(e.categoryColor);
      if (colors.length >= 4) break;
    }

    final displayColors = colors.toList();

    return Positioned(
      bottom: 6,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (hasOverdue)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 1.5),
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                      color: Colors.red.withValues(alpha: 0.5), blurRadius: 2)
                ],
              ),
            ),
          ...displayColors.take(3).map((color) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 1.5),
              width: 4.5,
              height: 4.5,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            );
          }),
        ],
      ),
    );
  }
}
