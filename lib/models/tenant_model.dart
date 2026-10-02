// lib/models/tenant_model.dart
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:intl/intl.dart';

part 'tenant_model.freezed.dart';
part 'tenant_model.g.dart';

@freezed
abstract class ReminderLog with _$ReminderLog {
  const ReminderLog._();

  const factory ReminderLog({
    @Default('') String id,
    @Default('') String tenantId,
    @Default('') String channel,
    DateTime? timestamp,
    @Default('') String rentCycle,
    @Default('Rent Notice') String messageType,
  }) = _ReminderLog;

  factory ReminderLog.fromJson(Map<String, dynamic> json) =>
      _$ReminderLogFromJson(json);

  DateTime get effectiveTimestamp => timestamp ?? DateTime.now();

  String get formattedTime =>
      DateFormat('MMM dd, yyyy • hh:mm a').format(effectiveTimestamp);
}

@freezed
abstract class Tenant with _$Tenant {
  const Tenant._();

  const factory Tenant({
    @Default('') String id,
    @Default('') String name,
    @Default('') String email,
    @Default('') String phone,
    @Default('') String contactNumber,
    @Default('') String address,
    @Default('') String referral,
    @Default('') String unitId,
    @Default('Unassigned') String unitNumber,
    @Default(0.0) double monthlyRent,
    DateTime? leaseStart,
    DateTime? leaseEnd,
    DateTime? dueDate,
    @Default(0.0) double balance,
    @Default('Active') String status,
    @Default(false) bool isArchived,
    String? avatarUrl,
    String? currentTenancyId,
    String? messengerHandle,
    @Default([]) List<ReminderLog> reminderLogs,
  }) = _Tenant;

  factory Tenant.fromJson(Map<String, dynamic> json) => _$TenantFromJson(json);

  DateTime get effectiveLeaseStart => leaseStart ?? DateTime.now();

  DateTime get effectiveLeaseEnd =>
      leaseEnd ?? DateTime.now().add(const Duration(days: 365));

  DateTime get effectiveDueDate =>
      dueDate ?? DateTime.now().add(const Duration(days: 5));

  int get reminderCount => reminderLogs.length;

  bool get isFormer =>
      isArchived ||
      status.toLowerCase() == 'former' ||
      status.toLowerCase() == 'archived';

  bool get isAssigned => unitId.isNotEmpty && unitNumber != 'Unassigned';

  bool get isLate => balance > 0 && DateTime.now().isAfter(effectiveDueDate);

  bool get isDueSoon {
    if (balance <= 0) return false;
    final diff = effectiveDueDate.difference(DateTime.now()).inDays;
    return diff >= 0 && diff <= 5;
  }

  Color get statusColor {
    if (isFormer) return const Color(0xFF6B7280);
    if (!isAssigned) return const Color(0xFF2563EB);
    if (isLate) return const Color(0xFFEF4444);
    if (isDueSoon || balance > 0) return const Color(0xFFF59E0B);
    return const Color(0xFF10B981);
  }

  String get balanceStatusText {
    if (isFormer) return 'FORMER';
    if (!isAssigned) return 'UNASSIGNED';
    if (isLate) return 'LATE';
    if (isDueSoon) return 'DUE SOON';
    if (balance > 0) return 'PENDING';
    return 'CLEAR';
  }

  String get formattedBalance {
    final formatter = NumberFormat.currency(
      locale: 'en_PH',
      symbol: '₱',
      decimalDigits: 2,
    );
    return formatter.format(balance);
  }

  String get formattedRent {
    final formatter = NumberFormat.currency(
      locale: 'en_PH',
      symbol: '₱',
      decimalDigits: 0,
    );
    return '${formatter.format(monthlyRent)}/mo';
  }

  /// Counts rent-related reminders, ignoring maintenance or visit logs.
  int get rentReminderCount => reminderLogs.where((log) {
        final mt = log.messageType.toLowerCase();
        return mt.isEmpty || mt.contains('rent') || mt == 'rent notice';
      }).length;

  /// Rent reminders dispatched in the current billing cycle or within the last 30 days.
  int get recentRentReminderCount {
    final now = DateTime.now();
    final currentCycle = DateFormat('MMM yyyy').format(now);
    return reminderLogs.where((log) {
      final mt = log.messageType.toLowerCase();
      final isRent = mt.isEmpty || mt.contains('rent') || mt == 'rent notice';
      if (!isRent) return false;
      if (log.rentCycle.isNotEmpty && log.rentCycle == currentCycle) {
        return true;
      }
      final ts = log.effectiveTimestamp;
      return now.difference(ts).inDays <= 30;
    }).length;
  }

  /// Days overdue (0 if balance <= 0 or not yet past due date).
  int get daysOverdue {
    if (!isLate) return 0;
    final diff = DateTime.now().difference(effectiveDueDate).inDays;
    return diff < 1 ? 1 : diff;
  }

  /// Days until due date (0 or positive if in the future, negative if overdue).
  int get daysUntilDue {
    return effectiveDueDate.difference(DateTime.now()).inDays;
  }

  /// Calculates a dynamic Health Score (0 - 100) based on payment status, timeliness,
  /// and recent vs lifetime reminder frequencies.
  int get healthScore {
    if (isFormer) return 0;
    int score = 100;

    // Overdue penalty
    if (isLate) {
      score -= 30;
      score -= (daysOverdue * 5).clamp(0, 30);
    } else if (isDueSoon) {
      score -= 10;
    }

    // Recent rent reminders penalty (15 pts each)
    score -= (recentRentReminderCount * 15);

    // Lifetime rent reminders penalty (5 pts each beyond recent)
    final olderReminders = (rentReminderCount - recentRentReminderCount).clamp(0, 10);
    score -= (olderReminders * 5);

    return score.clamp(0, 100);
  }

  Color get healthColor {
    if (isFormer) return const Color(0xFF6B7280);
    if (isLate || recentRentReminderCount >= 3 || rentReminderCount >= 5 || healthScore < 50) {
      return const Color(0xFFEF4444);
    }
    if (recentRentReminderCount >= 1 || isDueSoon || rentReminderCount >= 2 || healthScore < 85) {
      return const Color(0xFFF59E0B);
    }
    return const Color(0xFF10B981);
  }

  String get healthStatusText {
    if (isFormer) return 'Former Tenant';
    if (isLate) {
      final days = daysOverdue;
      return 'High Risk (Overdue by ${days}d)';
    }
    if (recentRentReminderCount >= 3) {
      return 'High Risk ($recentRentReminderCount Recent Reminders)';
    }
    if (rentReminderCount >= 5) {
      return 'High Risk (Frequent Reminders)';
    }
    if (recentRentReminderCount >= 1) {
      final count = recentRentReminderCount;
      return 'Needs Follow-up ($count ${count == 1 ? "Reminder" : "Reminders"} Sent)';
    }
    if (isDueSoon) {
      final days = daysUntilDue;
      return days <= 0
          ? 'Needs Follow-up (Due Today)'
          : 'Needs Follow-up (Due in ${days}d)';
    }
    if (balance <= 0) return 'Good Payer (Clear Balance)';
    return 'Good Payer (On Schedule)';
  }

  String get leaseStartDate =>
      DateFormat('MMM dd, yyyy').format(effectiveLeaseStart);
  String get leaseEndDate =>
      DateFormat('MMM dd, yyyy').format(effectiveLeaseEnd);
}
