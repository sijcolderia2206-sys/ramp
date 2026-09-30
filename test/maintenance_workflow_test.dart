import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ramp/core/state/ramp_state.dart';

void main() {
  test('maintenance workflow enforces each stage in order', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final notifier = container.read(ticketProvider.notifier);
    final ticket = Ticket(
      id: 'workflow_ticket',
      unitId: 'u1',
      unitNumber: 'Unit 1',
      tenantId: 't1',
      tenantName: 'Tenant One',
      title: 'Leaking faucet',
      description: 'Water is leaking below the sink.',
      affectedAreas: const ['Bathroom'],
      status: 'Schedule Visit',
    );
    notifier.addTicket(ticket);

    expect(notifier.markTicketVisitDone(ticket.id), isFalse);
    expect(notifier.prepareTicketVisitReminder(ticket.id), isFalse);

    final visitDate = DateTime(2026, 10, 10);
    expect(
      notifier.scheduleTicketVisit(
          ticket.id, visitDate, 'Morning (8 AM - 12 PM)'),
      isTrue,
    );
    expect(notifier.prepareTicketVisitReminder(ticket.id), isTrue);
    expect(notifier.markTicketVisitDone(ticket.id), isTrue);

    var current = container
        .read(ticketProvider)
        .singleWhere((item) => item.id == ticket.id);
    expect(current.status, 'Estimate');
    expect(current.visitScheduledAt, visitDate);
    expect(current.visitReminderSent, isTrue);

    expect(
        notifier.submitTicketEstimate(ticket.id, 0, const ['Faucet']), isFalse);
    expect(notifier.submitTicketEstimate(ticket.id, 1500, const []), isFalse);
    expect(
        notifier
            .submitTicketEstimate(ticket.id, 1500, const ['Faucet', 'Pipe']),
        isTrue);

    expect(
      notifier.scheduleTicketRepair(
          ticket.id, DateTime(2026, 10, 12), 'Afternoon', ''),
      isFalse,
    );
    expect(
      notifier.markTicketCompleted(ticket.id, summary: 'Replaced faucet.'),
      isFalse,
    );

    final repairDate = DateTime(2026, 10, 12);
    expect(
      notifier.scheduleTicketRepair(
          ticket.id, repairDate, 'Afternoon (12 PM - 5 PM)', 'Alex Rivera'),
      isTrue,
    );
    expect(notifier.prepareTicketRepairReminder(ticket.id), isTrue);
    expect(notifier.markTicketCompleted(ticket.id, summary: '  '), isFalse);
    expect(
      notifier.markTicketCompleted(
        ticket.id,
        summary: 'Replaced the faucet and tested the water flow.',
        completionPhoto: 'repair-complete.jpg',
      ),
      isTrue,
    );

    current = container
        .read(ticketProvider)
        .singleWhere((item) => item.id == ticket.id);
    expect(current.status, 'Completed');
    expect(current.repairScheduledAt, repairDate);
    expect(current.repairReminderSent, isTrue);
    expect(current.repairer, 'Alex Rivera');
    expect(current.estimatedCost, 1500);
    expect(current.replacementItems, const ['Faucet', 'Pipe']);
    expect(current.completionSummary,
        'Replaced the faucet and tested the water flow.');
    expect(current.photoAfter, 'repair-complete.jpg');
    expect(
      current.statusHistory.map((entry) => entry.status),
      containsAllInOrder([
        'Schedule Visit',
        'Schedule Visit',
        'Estimate',
        'Schedule Repair',
        'Schedule Repair',
        'Completed'
      ]),
    );
  });

  test('maintenance reminders are unavailable for vacant units', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final notifier = container.read(ticketProvider.notifier);
    final ticket = Ticket(
      id: 'vacant_workflow_ticket',
      unitId: 'u5',
      unitNumber: 'Unit 5',
      tenantName: 'Unoccupied',
      title: 'Outdoor light',
      affectedAreas: const ['Outdoor Area'],
      status: 'Schedule Visit',
    );
    notifier.addTicket(ticket);
    notifier.scheduleTicketVisit(
        ticket.id, DateTime(2026, 10, 10), 'Evening (5 PM - 8 PM)');

    expect(notifier.prepareTicketVisitReminder(ticket.id), isFalse);
  });

  test('estimate creates one unit expense without changing rent accounting', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final notifier = container.read(ticketProvider.notifier);
    final tenantBefore = container
        .read(tenantProvider)
        .singleWhere((tenant) => tenant.id == 't2');
    final revenueBefore = container.read(kpiTotalRevenueProvider);
    final expensesBefore = container.read(totalExpensesProvider);
    final ticket = Ticket(
      id: 'accounting_ticket',
      unitId: 'u1',
      unitNumber: 'Unit 1',
      tenantId: tenantBefore.id,
      tenantName: tenantBefore.name,
      title: 'Broken pipe',
      affectedAreas: const ['Bathroom'],
      status: 'Estimate',
    );
    notifier.addTicket(ticket);

    expect(
      notifier.submitTicketEstimate(ticket.id, 1800, const ['Pipe']),
      isTrue,
    );
    var entries = container
        .read(paymentProvider)
        .where((entry) => entry.ticketId == ticket.id)
        .toList();
    expect(entries, hasLength(1));
    expect(entries.single.isMaintenance, isTrue);
    expect(entries.single.unitId, 'u1');
    expect(entries.single.baseRent, 0);
    expect(entries.single.status, 'Recorded');
    expect(container.read(kpiTotalRevenueProvider), revenueBefore);
    expect(container.read(totalExpensesProvider), expensesBefore + 1800);
    expect(
      container
          .read(tenantProvider)
          .singleWhere((tenant) => tenant.id == tenantBefore.id)
          .balance,
      tenantBefore.balance,
    );

    expect(
      notifier.submitTicketEstimate(ticket.id, 2200, const ['Pipe', 'Valve']),
      isTrue,
    );
    entries = container
        .read(paymentProvider)
        .where((entry) => entry.ticketId == ticket.id)
        .toList();
    expect(entries, hasLength(1));
    expect(entries.single.amount, 2200);
    expect(entries.single.remarks, contains('Pipe, Valve'));
    expect(container.read(kpiTotalRevenueProvider), revenueBefore);
    expect(container.read(totalExpensesProvider), expensesBefore + 2200);
  });
}
