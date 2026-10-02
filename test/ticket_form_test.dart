import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ramp/providers/providers.dart';
import 'package:ramp/screens/ticket_form.dart';

void main() {
  for (final brightness in Brightness.values) {
    testWidgets('Ticket form creates and edits on a narrow $brightness screen',
        (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final navigator = GlobalKey<NavigatorState>();
      await tester.pumpWidget(UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          navigatorKey: navigator,
          theme: ThemeData(brightness: brightness, useMaterial3: true),
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: const TextScaler.linear(1.3)),
            child: child!,
          ),
          home: const Scaffold(body: Text('Home')),
        ),
      ));

      Future<void> open(Ticket? ticket) async {
        navigator.currentState!.push(MaterialPageRoute<void>(
          builder: (_) => TicketFormScreen(existingTicket: ticket),
        ));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }

      await open(null);
      await tester.enterText(
          find.byType(TextFormField).first, 'Kitchen tap repair');
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('CREATE MAINTENANCE TICKET'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      final startingTicketCount = container.read(ticketProvider).length;
      final startingActivityCount = container.read(activityProvider).length;
      await tester.tap(find.text('CREATE MAINTENANCE TICKET'));
      await tester.pumpAndSettle();
      expect(
          container.read(ticketProvider), hasLength(startingTicketCount + 1));
      expect(container.read(activityProvider),
          hasLength(startingActivityCount + 1));
      final created = container
          .read(ticketProvider)
          .singleWhere((t) => t.title == 'Kitchen tap repair');
      expect(created.estimatedCost, 0);
      expect(created.priority, 'Med');
      expect(created.status, 'Schedule Visit');

      final scheduledAt = DateTime(2026, 10, 12);
      final ticketWithProgress = created.copyWith(
        visitScheduledAt: scheduledAt,
        visitTimeWindow: 'Morning (8 AM - 12 PM)',
        replacementItems: const ['Faucet'],
        statusHistory: [
          ...created.statusHistory,
          TicketStatusHistoryEntry(
            status: 'Schedule Visit',
            timestamp: scheduledAt,
            note: 'Visit scheduled',
          ),
        ],
      );
      container.read(ticketProvider.notifier).updateTicket(ticketWithProgress);

      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();
      await open(ticketWithProgress);
      await tester.enterText(
          find.byType(TextFormField).first, 'Kitchen tap repaired');
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('UPDATE TICKET'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('UPDATE TICKET'));
      await tester.pumpAndSettle();
      final edited =
          container.read(ticketProvider).singleWhere((t) => t.id == created.id);
      expect(edited.title, 'Kitchen tap repaired');
      expect(edited.visitScheduledAt, scheduledAt);
      expect(edited.visitTimeWindow, 'Morning (8 AM - 12 PM)');
      expect(edited.replacementItems, const ['Faucet']);
      expect(edited.statusHistory, hasLength(1));
      expect(
          container.read(ticketProvider), hasLength(startingTicketCount + 1));
      expect(container.read(activityProvider),
          hasLength(startingActivityCount + 1));
      expect(tester.takeException(), isNull);
    });
  }
}
