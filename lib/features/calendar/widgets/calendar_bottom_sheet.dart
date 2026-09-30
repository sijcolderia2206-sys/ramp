// lib/features/calendar/widgets/calendar_bottom_sheet.dart
import 'package:flutter/material.dart';
import 'calendar_view.dart';

void showRampCalendarBottomSheet(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: isDark ? Theme.of(context).colorScheme.surface : Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheetContext) {
      return DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.45,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return RampCalendarView(
            scrollController: scrollController,
            onCloseSheet: () {
              if (Navigator.canPop(sheetContext)) {
                Navigator.pop(sheetContext);
              }
            },
          );
        },
      );
    },
  );
}
