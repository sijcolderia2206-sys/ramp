// lib/features/calendar/widgets/calendar_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../models/models.dart';
import '../../../core/widgets/core_widgets.dart';
import '../providers/calendar_providers.dart';
import 'calendar_header.dart';
import 'calendar_filter_bar.dart';
import 'calendar_day_builder.dart';
import 'event_card.dart';

class RampCalendarView extends ConsumerStatefulWidget {
  const RampCalendarView({
    super.key,
    this.onCloseSheet,
    this.scrollController,
  });

  final VoidCallback? onCloseSheet;
  final ScrollController? scrollController;

  @override
  ConsumerState<RampCalendarView> createState() => _RampCalendarViewState();
}

class _RampCalendarViewState extends ConsumerState<RampCalendarView> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final selectedDay = ref.watch(calendarSelectedDayProvider);
    final focusedDay = ref.watch(calendarFocusedDayProvider);
    final currentFormat = ref.watch(calendarFormatProvider);
    final allEvents = ref.watch(unifiedCalendarEventsProvider);
    final dayEvents = ref.watch(eventsForSelectedDayProvider);

    return SingleChildScrollView(
      controller: widget.scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF34383C) : const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // 1. Calendar Header (Month Name, Jump to Today, Format Switcher, Schedule Button)
          CalendarHeaderWidget(
            focusedDay: focusedDay,
            onTodayPressed: () {
              final today = DateTime.now();
              final todayMidnight = DateTime(today.year, today.month, today.day);
              ref.read(calendarSelectedDayProvider.notifier).state = todayMidnight;
              ref.read(calendarFocusedDayProvider.notifier).state = todayMidnight;
            },
          ),
          const SizedBox(height: 12),

          // 2. Category Filter Bar
          const CalendarFilterBarWidget(),
          const SizedBox(height: 10),

          // 3. Search Bar
          Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                )
              ],
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (query) {
                ref.read(calendarSearchQueryProvider.notifier).state = query;
              },
              style: GoogleFonts.poppins(fontSize: 13, color: theme.colorScheme.onSurface),
              decoration: InputDecoration(
                hintText: 'Search schedule, unit, or tenant...',
                hintStyle: GoogleFonts.poppins(fontSize: 13, color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7)),
                prefixIcon: Icon(Icons.search_rounded, size: 20, color: theme.colorScheme.primary),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.cancel_rounded, size: 18, color: theme.colorScheme.onSurfaceVariant),
                        onPressed: () {
                          _searchController.clear();
                          ref.read(calendarSearchQueryProvider.notifier).state = '';
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                filled: true,
                fillColor: isDark ? const Color(0xFF1E2022) : Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: theme.colorScheme.outlineVariant.withValues(alpha: 0.2),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: theme.colorScheme.outlineVariant.withValues(alpha: 0.2),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: theme.colorScheme.primary.withValues(alpha: 0.5),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 4. Interactive TableCalendar Widget
          Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E2022) : Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
              border: Border.all(
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.2),
              ),
            ),
            padding: const EdgeInsets.all(8),
            child: TableCalendar<AppEvent>(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2035, 12, 31),
              focusedDay: focusedDay,
              calendarFormat: currentFormat,
              selectedDayPredicate: (day) => isSameDay(selectedDay, day),
              onDaySelected: (sDay, fDay) {
                ref.read(calendarSelectedDayProvider.notifier).state =
                    DateTime(sDay.year, sDay.month, sDay.day);
                ref.read(calendarFocusedDayProvider.notifier).state =
                    DateTime(fDay.year, fDay.month, fDay.day);
              },
              onFormatChanged: (format) {
                ref.read(calendarFormatProvider.notifier).state = format;
              },
              onPageChanged: (fDay) {
                ref.read(calendarFocusedDayProvider.notifier).state =
                    DateTime(fDay.year, fDay.month, fDay.day);
              },
              eventLoader: (day) {
                return allEvents.where((e) => isSameDay(e.date, day)).toList();
              },
              calendarBuilders: CalendarBuilders(
                selectedBuilder: CalendarDayBuilderHelper.buildSelectedDay,
                todayBuilder: CalendarDayBuilderHelper.buildToday,
                markerBuilder: (context, day, events) =>
                    CalendarDayBuilderHelper.buildMarker(context, day, events),
              ),
              calendarStyle: CalendarStyle(
                defaultTextStyle: GoogleFonts.poppins(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                ),
                weekendTextStyle: GoogleFonts.poppins(
                  color: isDark ? const Color(0xFFF87171) : const Color(0xFFEF4444),
                  fontWeight: FontWeight.w500,
                ),
                outsideTextStyle: GoogleFonts.poppins(
                  color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                ),
              ),
              headerStyle: const HeaderStyle(
                formatButtonVisible: false, // We use custom format buttons in header
                titleCentered: true,
                titleTextStyle: TextStyle(fontSize: 0), // Title handled in custom header
              ),
            ),
          ),
          const SizedBox(height: 20),

          // 5. Selected Day Events Feed Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Schedule for ${DateFormat('MMMM d, yyyy').format(selectedDay)}',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${dayEvents.length} Event${dayEvents.length == 1 ? '' : 's'}',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 6. Selected Day Events Feed Cards
          if (dayEvents.isEmpty)
            RampEmptyState(
              title: 'No Events Scheduled',
              description:
                  'No rent dues, maintenance visits, or custom events on ${DateFormat('MMMM d').format(selectedDay)}.',
              icon: Icons.event_available_rounded,
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            )
          else
            Column(
              children: dayEvents.map((event) {
                return RampCalendarEventCard(
                  event: event,
                  onCloseSheet: widget.onCloseSheet,
                );
              }).toList(),
            ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
