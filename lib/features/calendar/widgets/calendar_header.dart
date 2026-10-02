// lib/features/calendar/widgets/calendar_header.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../providers/calendar_providers.dart';
import 'add_edit_event_sheet.dart';

class CalendarHeaderWidget extends ConsumerWidget {
  const CalendarHeaderWidget({
    super.key,
    required this.focusedDay,
    required this.onTodayPressed,
  });

  final DateTime focusedDay;
  final VoidCallback onTodayPressed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final currentFormat = ref.watch(calendarFormatProvider);
    final monthYearText = DateFormat('MMMM yyyy').format(focusedDay);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Month & Year title
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    monthYearText,
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: theme.colorScheme.onSurface,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  InkWell(
                    onTap: onTodayPressed,
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.adjust_rounded,
                            size: 14,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Jump to Today',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // "+ New Event" Button
            FilledButton.icon(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor:
                      isDark ? theme.colorScheme.surface : Colors.white,
                  shape: const RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  builder: (_) => const AddEditEventSheet(),
                );
              },
              style: FilledButton.styleFrom(
                elevation: 0,
                backgroundColor: theme.colorScheme.primary,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: Text(
                'New Event',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // Modern Segmented Control for View Format
        Container(
          height: 40,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E2022) : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: _FormatSegmentButton(
                  label: 'Month',
                  isSelected: currentFormat == CalendarFormat.month,
                  onTap: () => ref.read(calendarFormatProvider.notifier).state =
                      CalendarFormat.month,
                ),
              ),
              Expanded(
                child: _FormatSegmentButton(
                  label: '2 Weeks',
                  isSelected: currentFormat == CalendarFormat.twoWeeks,
                  onTap: () => ref.read(calendarFormatProvider.notifier).state =
                      CalendarFormat.twoWeeks,
                ),
              ),
              Expanded(
                child: _FormatSegmentButton(
                  label: 'Week',
                  isSelected: currentFormat == CalendarFormat.week,
                  onTap: () => ref.read(calendarFormatProvider.notifier).state =
                      CalendarFormat.week,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FormatSegmentButton extends StatelessWidget {
  const _FormatSegmentButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? const Color(0xFF34383C) : Colors.white)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
          boxShadow: null,
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected
                ? theme.colorScheme.onSurface
                : theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
