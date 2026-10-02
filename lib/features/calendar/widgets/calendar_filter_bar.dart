// lib/features/calendar/widgets/calendar_filter_bar.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/calendar_models.dart';
import '../providers/calendar_providers.dart';

class CalendarFilterBarWidget extends ConsumerWidget {
  const CalendarFilterBarWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final activeFilter = ref.watch(calendarFilterProvider);
    final allEvents = ref.watch(unifiedCalendarEventsProvider);
    final selectedDay = ref.watch(calendarSelectedDayProvider);
    final isDark = theme.brightness == Brightness.dark;

    // Get count for selected day for each filter
    int getCountForFilter(CalendarCategoryFilter filter) {
      return allEvents.where((e) {
        if (!isSameDay(e.date, selectedDay)) return false;
        if (filter == CalendarCategoryFilter.all) return true;
        final t = e.type.toLowerCase();
        switch (filter) {
          case CalendarCategoryFilter.rent:
            return t.contains('rent');
          case CalendarCategoryFilter.maintenance:
            return t.contains('maintenance') || t.contains('ticket');
          case CalendarCategoryFilter.inspection:
            return t.contains('inspection');
          case CalendarCategoryFilter.lease:
            return t.contains('lease');
          case CalendarCategoryFilter.custom:
            return !t.contains('rent') &&
                !t.contains('maintenance') &&
                !t.contains('inspection') &&
                !t.contains('lease');
          case CalendarCategoryFilter.all:
            return true;
        }
      }).length;
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: CalendarCategoryFilter.values.map((filter) {
          final isSelected = activeFilter == filter;
          final count = getCountForFilter(filter);
          final filterColor = filter == CalendarCategoryFilter.all
              ? theme.colorScheme.primary
              : filter.color;

          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: GestureDetector(
              onTap: () =>
                  ref.read(calendarFilterProvider.notifier).state = filter,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? filterColor
                      : (isDark ? const Color(0xFF1E2022) : Colors.white),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isSelected
                        ? filterColor
                        : theme.colorScheme.outlineVariant
                            .withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                  boxShadow: null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      filter.icon,
                      size: 16,
                      color: isSelected ? Colors.white : filterColor,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      filter.label,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: isSelected
                            ? Colors.white
                            : theme.colorScheme.onSurface,
                      ),
                    ),
                    if (count > 0) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.white.withValues(alpha: 0.25)
                              : filterColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '$count',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: isSelected ? Colors.white : filterColor,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
