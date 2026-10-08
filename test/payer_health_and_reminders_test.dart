import 'package:flutter_test/flutter_test.dart';
import 'package:ramp/models/models.dart';

void main() {
  group('Tenant Payer Health Engine Tests', () {
    test('Fresh tenant with clear balance has Good Payer status and 100 health score', () {
      final tenant = Tenant(
        id: 't_test1',
        name: 'Maria Santos',
        balance: 0.0,
        status: 'Active',
      );

      expect(tenant.healthScore, equals(100));
      expect(tenant.healthStatusText, contains('Good Payer'));
      expect(tenant.recentRentReminderCount, equals(0));
    });

    test('Tenant due soon with 1 recent reminder drops score and updates health status', () {
      final now = DateTime.now();
      final tenant = Tenant(
        id: 't_test2',
        name: 'Juan Dela Cruz',
        balance: 8500.0,
        dueDate: now.add(const Duration(days: 2)),
        reminderLogs: [
          ReminderLog(
            id: 'log_1',
            tenantId: 't_test2',
            channel: 'SMS',
            timestamp: now,
            messageType: 'Rent Notice',
            rentCycle: 'Oct 2026',
          )
        ],
      );

      expect(tenant.isDueSoon, isTrue);
      expect(tenant.recentRentReminderCount, equals(1));
      expect(tenant.healthScore, equals(75)); // 100 - 10 (due soon) - 15 (1 recent reminder)
      expect(tenant.healthStatusText, contains('Needs Follow-up'));
    });

    test('Overdue tenant gets High Risk status and score penalty proportional to days overdue', () {
      final now = DateTime.now();
      final tenant = Tenant(
        id: 't_test3',
        name: 'Late Tenant',
        balance: 12000.0,
        dueDate: now.subtract(const Duration(days: 4)),
      );

      expect(tenant.isLate, isTrue);
      expect(tenant.daysOverdue, equals(4));
      expect(tenant.healthScore, equals(50)); // 100 - 30 (late) - 20 (4d * 5)
      expect(tenant.healthStatusText, contains('High Risk'));
      expect(tenant.healthStatusText, contains('Overdue by 4d'));
    });

    test('Maintenance/visit reminders do not penalize rent payer health score', () {
      final now = DateTime.now();
      final tenant = Tenant(
        id: 't_test4',
        name: 'Clean Tenant',
        balance: 0.0,
        reminderLogs: [
          ReminderLog(
            id: 'log_m1',
            tenantId: 't_test4',
            channel: 'SMS',
            timestamp: now,
            messageType: 'Visit Reminder',
            rentCycle: 'Oct 2026',
          )
        ],
      );

      expect(tenant.rentReminderCount, equals(0));
      expect(tenant.healthScore, equals(100));
      expect(tenant.healthStatusText, contains('Good Payer'));
    });
  });
}
