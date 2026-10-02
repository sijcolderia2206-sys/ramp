// lib/features/calendar/providers/calendar_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../core/state/ramp_state.dart';
import '../models/calendar_models.dart';

/// Active category filter provider
final calendarFilterProvider =
    StateProvider<CalendarCategoryFilter>((ref) => CalendarCategoryFilter.all);

/// Active format provider (month, twoWeeks, week)
final calendarFormatProvider =
    StateProvider<CalendarFormat>((ref) => CalendarFormat.month);

/// Selected day provider
final calendarSelectedDayProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
});

/// Focused day provider
final calendarFocusedDayProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
});

/// Search query provider
final calendarSearchQueryProvider = StateProvider<String>((ref) => '');

/// Unified Calendar Events Provider
/// Aggregates Custom Events, Maintenance Tickets, Rent Dues, and Lease Expirations.
final unifiedCalendarEventsProvider = Provider<List<AppEvent>>((ref) {
  final customEvents = ref.watch(eventProvider);
  final tickets = ref.watch(ticketProvider);
  final tenants = ref.watch(tenantProvider);
  final units = ref.watch(unitProvider);
  final focusedDay = ref.watch(calendarFocusedDayProvider);

  final List<AppEvent> unified = [];

  // 1. Custom events
  unified.addAll(customEvents);

  // 2. Maintenance Tickets
  for (final t in tickets) {
    unified.add(
      AppEvent(
        id: 'ticket_${t.id}',
        title: 'Ticket: ${t.title}',
        date: t.effectiveDate,
        type: 'maintenance',
        ticketId: t.id,
        unitNumber: t.unitNumber,
        description:
            '${t.tenantName} • Status: ${t.status} • Cost: ${t.formattedCost}',
        priority: t.priority.toLowerCase(),
        isCompleted: t.status.toLowerCase() == 'resolved' ||
            t.status.toLowerCase() == 'closed',
      ),
    );
  }

  // 3. Rent Dues dynamically generated for the focused year/month
  // Generate rent due events for previous month, focused month, and next month to cover calendar transitions smoothly
  final monthReferences = [
    DateTime(focusedDay.year, focusedDay.month - 1, 1),
    DateTime(focusedDay.year, focusedDay.month, 1),
    DateTime(focusedDay.year, focusedDay.month + 1, 1),
  ];

  for (final monthRef in monthReferences) {
    for (final tenant in tenants) {
      if (tenant.isArchived) continue;
      final unit = units.where((u) => u.id == tenant.unitId).firstOrNull;
      final rentDueDay = unit?.rentDueDay ?? tenant.effectiveDueDate.day;
      final lastDayOfMonth = DateTime(monthRef.year, monthRef.month + 1, 0).day;
      final actualDueDay = rentDueDay.clamp(1, lastDayOfMonth);
      final dueDateTime = DateTime(monthRef.year, monthRef.month, actualDueDay);

      final isPaid = tenant.balance <= 0;
      unified.add(
        AppEvent(
          id: 'rent_${tenant.id}_${monthRef.year}_${monthRef.month}',
          title: 'Rent Due: ${tenant.name}',
          date: dueDateTime,
          type: 'rent',
          tenantId: tenant.id,
          unitId: unit?.id,
          unitNumber: tenant.unitNumber,
          description:
              'Unit ${tenant.unitNumber} • Rent: ₱${tenant.monthlyRent.toStringAsFixed(2)} • Balance: ₱${tenant.balance.toStringAsFixed(2)}',
          priority: tenant.balance > 0 ? 'high' : 'medium',
          isCompleted: isPaid,
        ),
      );
    }
  }

  // 4. Lease Expirations
  for (final tenant in tenants) {
    if (tenant.isArchived) continue;
    final unit = units.where((u) => u.id == tenant.unitId).firstOrNull;
    unified.add(
      AppEvent(
        id: 'lease_${tenant.id}',
        title: 'Lease Expires: ${tenant.name}',
        date: tenant.effectiveLeaseEnd,
        type: 'lease_expiration',
        tenantId: tenant.id,
        unitId: unit?.id,
        unitNumber: tenant.unitNumber,
        description: 'Lease contract ends for Unit ${tenant.unitNumber}',
        priority: 'high',
      ),
    );
  }

  return unified;
});

/// Events for Selected Day filtered by active category and search query
final eventsForSelectedDayProvider = Provider<List<AppEvent>>((ref) {
  final allEvents = ref.watch(unifiedCalendarEventsProvider);
  final selectedDay = ref.watch(calendarSelectedDayProvider);
  final activeFilter = ref.watch(calendarFilterProvider);
  final searchQuery =
      ref.watch(calendarSearchQueryProvider).trim().toLowerCase();

  return allEvents.where((event) {
    final sameDay = isSameDay(event.date, selectedDay);
    if (!sameDay) return false;

    // Filter category
    if (activeFilter != CalendarCategoryFilter.all) {
      final t = event.type.toLowerCase();
      switch (activeFilter) {
        case CalendarCategoryFilter.rent:
          if (!t.contains('rent')) return false;
          break;
        case CalendarCategoryFilter.maintenance:
          if (!t.contains('maintenance') && !t.contains('ticket')) return false;
          break;
        case CalendarCategoryFilter.inspection:
          if (!t.contains('inspection')) return false;
          break;
        case CalendarCategoryFilter.lease:
          if (!t.contains('lease')) return false;
          break;
        case CalendarCategoryFilter.custom:
          if (t.contains('rent') ||
              t.contains('maintenance') ||
              t.contains('inspection') ||
              t.contains('lease')) {
            return false;
          }
          break;
        case CalendarCategoryFilter.all:
          break;
      }
    }

    // Search query
    if (searchQuery.isNotEmpty) {
      final matchTitle = event.title.toLowerCase().contains(searchQuery);
      final matchDesc =
          (event.description ?? '').toLowerCase().contains(searchQuery);
      final matchUnit =
          (event.unitNumber ?? '').toLowerCase().contains(searchQuery);
      if (!matchTitle && !matchDesc && !matchUnit) return false;
    }

    return true;
  }).toList();
});
