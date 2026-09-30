import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ramp/core/services/report_export_data.dart';
import 'package:ramp/core/services/persistence_queue.dart';
import 'package:ramp/core/state/ramp_state.dart';

void main() {
  test('payments CSV escapes user data and preserves stable identity', () {
    final csv = buildPaymentsCsv([
      PaymentData(
        id: 'payment-1',
        tenantId: 'tenant-1',
        tenantName: 'Santos, Maria',
        unitId: 'unit-2',
        unitNumber: 'Unit 2',
        amount: 12500,
        referenceNumber: 'GC-100',
      ),
    ]);

    expect(csv, contains('"Santos, Maria"'));
    expect(csv, contains('"12500.00"'));
    expect(csv, contains('"GC-100"'));
  });

  test('failed Firestore writes remain queued and succeed on retry', () async {
    var shouldFail = true;
    var writes = 0;
    final queue = PersistenceQueue.forTesting(
      upsert: (collection, documentId, data) async {
        writes++;
        if (shouldFail) throw Exception('offline');
      },
      delete: (collection, documentId) async {},
    );
    addTearDown(queue.dispose);

    queue.enqueueUpsert('units', 'unit-1', {'name': 'Unit 1'});
    await Future<void>.delayed(Duration.zero);
    expect(queue.value.pending, hasLength(1));
    expect(queue.value.lastError, isNotNull);

    shouldFail = false;
    await queue.retry();
    expect(queue.value.pending, isEmpty);
    expect(queue.value.lastError, isNull);
    expect(writes, 2);
  });

  testWidgets('an empty remote snapshot clears every seeded collection',
      (tester) async {
    await tester
        .pumpWidget(const ProviderScope(child: _EmptySnapshotHarness()));
    await tester.tap(find.text('Apply empty snapshot'));
    await tester.pump();

    final element = tester.element(find.byType(_EmptySnapshotHarness));
    final container = ProviderScope.containerOf(element);
    expect(container.read(unitProvider), isEmpty);
    expect(container.read(tenantProvider), isEmpty);
    expect(container.read(paymentProvider), isEmpty);
    expect(container.read(ticketProvider), isEmpty);
    expect(container.read(announcementProvider), isEmpty);
    expect(container.read(notificationProvider), isEmpty);
    expect(container.read(expenseProvider), isEmpty);
    expect(container.read(tenantDocumentProvider), isEmpty);
  });
}

class _EmptySnapshotHarness extends ConsumerWidget {
  const _EmptySnapshotHarness();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      home: Scaffold(
        body: TextButton(
          onPressed: () => replacePersistentCollections(
            ref,
            units: const [],
            tenants: const [],
            payments: const [],
            tickets: const [],
            announcements: const [],
            notifications: const [],
            expenses: const [],
            documents: const [],
          ),
          child: const Text('Apply empty snapshot'),
        ),
      ),
    );
  }
}
