// lib/features/calendar/models/calendar_models.dart
import 'package:flutter/material.dart';

enum CalendarCategoryFilter {
  all,
  rent,
  maintenance,
  inspection,
  lease,
  custom,
}

extension CalendarCategoryFilterX on CalendarCategoryFilter {
  String get label {
    switch (this) {
      case CalendarCategoryFilter.all:
        return 'All Events';
      case CalendarCategoryFilter.rent:
        return 'Rent Dues';
      case CalendarCategoryFilter.maintenance:
        return 'Maintenance';
      case CalendarCategoryFilter.inspection:
        return 'Inspections';
      case CalendarCategoryFilter.lease:
        return 'Lease Expirations';
      case CalendarCategoryFilter.custom:
        return 'Custom';
    }
  }

  IconData get icon {
    switch (this) {
      case CalendarCategoryFilter.all:
        return Icons.grid_view_rounded;
      case CalendarCategoryFilter.rent:
        return Icons.payments_outlined;
      case CalendarCategoryFilter.maintenance:
        return Icons.handyman_outlined;
      case CalendarCategoryFilter.inspection:
        return Icons.fact_check_outlined;
      case CalendarCategoryFilter.lease:
        return Icons.description_outlined;
      case CalendarCategoryFilter.custom:
        return Icons.event_note_outlined;
    }
  }

  Color get color {
    switch (this) {
      case CalendarCategoryFilter.all:
        return const Color(0xFF64748B);
      case CalendarCategoryFilter.rent:
        return const Color(0xFF0D6EFD);
      case CalendarCategoryFilter.maintenance:
        return const Color(0xFFF59E0B);
      case CalendarCategoryFilter.inspection:
        return const Color(0xFF0EA5E9);
      case CalendarCategoryFilter.lease:
        return const Color(0xFF8B5CF6);
      case CalendarCategoryFilter.custom:
        return const Color(0xFF10B981);
    }
  }
}
