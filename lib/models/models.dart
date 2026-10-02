export 'gps_location.dart';
export 'rental_unit.dart';
export 'tenant_model.dart';
export 'ticket_model.dart';
export 'payment_data.dart';
export 'user_role.dart';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Canonical Tenancy Model
class Tenancy {
  final String id;
  final String tenantId;
  final String tenantName;
  final String unitId;
  final String unitNumber;
  final DateTime startDate;
  final DateTime? endDate;
  final double agreedRent;
  final int rentDueDay;
  final double lateFee;
  final String status; // 'Active', 'Ended', 'Terminated'

  const Tenancy({
    required this.id,
    required this.tenantId,
    this.tenantName = '',
    required this.unitId,
    required this.unitNumber,
    required this.startDate,
    this.endDate,
    required this.agreedRent,
    this.rentDueDay = 5,
    this.lateFee = 500,
    this.status = 'Active',
  });

  bool get isActive => status.toLowerCase() == 'active' && endDate == null;

  Tenancy copyWith({
    DateTime? endDate,
    String? status,
    String? tenantName,
  }) =>
      Tenancy(
        id: id,
        tenantId: tenantId,
        tenantName: tenantName ?? this.tenantName,
        unitId: unitId,
        unitNumber: unitNumber,
        startDate: startDate,
        endDate: endDate ?? this.endDate,
        agreedRent: agreedRent,
        rentDueDay: rentDueDay,
        lateFee: lateFee,
        status: status ?? this.status,
      );
}

/// Canonical Utility Reading Model
class UtilityReading {
  final String id;
  final String unitId;
  final String? tenancyId;
  final String type; // 'Water' or 'Electricity'
  final double previousReading;
  final double currentReading;
  final double rate;
  final DateTime readingDate;
  final DateTime createdAt;

  UtilityReading({
    required this.id,
    required this.unitId,
    this.tenancyId,
    required this.type,
    required this.previousReading,
    required this.currentReading,
    required this.rate,
    DateTime? readingDate,
    DateTime? createdAt,
  })  : readingDate = readingDate ?? DateTime.now(),
        createdAt = createdAt ?? DateTime.now();

  double get consumption =>
      (currentReading - previousReading).clamp(0, double.infinity);
  double get charge => consumption * rate;

  String get formattedReadingDate =>
      DateFormat('MMM dd, yyyy').format(readingDate);
}

/// Auditable change to a property-wide utility rate.
class UtilityRateChange {
  const UtilityRateChange({
    required this.id,
    required this.utility,
    required this.previousRate,
    required this.newRate,
    required this.effectiveAt,
    this.note = '',
  });

  final String id;
  final String utility; // Water or Electricity
  final double previousRate;
  final double newRate;
  final DateTime effectiveAt;
  final String note;

  String get unitLabel => utility == 'Water' ? 'm³' : 'kWh';
  String get formattedDate =>
      DateFormat('MMM dd, yyyy • hh:mm a').format(effectiveAt);
}

/// Record Changes / Unit & Tenant Audit Entries
class RecordChange {
  final String id;
  final String entityType; // 'Unit', 'Tenant', 'Payment', 'Ticket'
  final String entityId;
  final String action;
  final String description;
  final String? tenantId;
  final String? tenancyId;
  final String? unitId;
  final DateTime timestamp;

  RecordChange({
    required this.id,
    required this.entityType,
    required this.entityId,
    required this.action,
    required this.description,
    this.tenantId,
    this.tenancyId,
    this.unitId,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  String get formattedTimestamp =>
      DateFormat('MMM dd • hh:mm a').format(timestamp);

  IconData get icon {
    switch (entityType.toLowerCase()) {
      case 'payment':
        return Icons.payments;
      case 'ticket':
      case 'maintenanceticket':
        return Icons.build;
      case 'unit':
        return Icons.apartment;
      case 'tenant':
        return Icons.person;
      default:
        return Icons.notifications;
    }
  }

  Color get iconBgColor {
    switch (entityType.toLowerCase()) {
      case 'payment':
        return const Color(0x3310B981);
      case 'ticket':
      case 'maintenanceticket':
        return const Color(0x33F59E0B);
      default:
        return const Color(0x330D6EFD);
    }
  }

  String get title => action;
  String get timeAgo => DateFormat('MMM dd • hh:mm a').format(timestamp);
}

/// Calendar App Event
class AppEvent {
  final String id;
  final String title;
  final DateTime date;
  final String
      type; // 'rent', 'maintenance', 'inspection', 'lease_expiration', 'meter_reading', 'general'
  final String? tenantId;
  final String? unitId;
  final String? ticketId;
  final String? unitNumber;
  final String? description;
  final Color? color;
  final bool isCompleted;
  final String priority; // 'low', 'medium', 'high', 'urgent'
  final String? timeWindow;
  final String? location;

  AppEvent({
    required this.id,
    required this.title,
    required this.date,
    this.type = 'general',
    this.tenantId,
    this.unitId,
    this.ticketId,
    this.unitNumber,
    this.description,
    this.color,
    this.isCompleted = false,
    this.priority = 'medium',
    this.timeWindow,
    this.location,
  });

  String get formattedDate => DateFormat('MMM dd, yyyy').format(date);
  String get formattedTime => DateFormat('hh:mm a').format(date);

  bool get isOverdue {
    if (isCompleted) return false;
    final nowAtMidnight =
        DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    final eventAtMidnight = DateTime(date.year, date.month, date.day);
    return eventAtMidnight.isBefore(nowAtMidnight);
  }

  String get categoryLabel {
    final t = type.toLowerCase();
    if (t.contains('rent') || t.contains('payment')) {
      return 'Rent Due';
    }
    if (t.contains('maintenance') ||
        t.contains('ticket') ||
        t.contains('repair')) {
      return 'Maintenance';
    }
    if (t.contains('inspection')) {
      return 'Inspection';
    }
    if (t.contains('lease')) {
      return 'Lease Expiration';
    }
    if (t.contains('meter')) {
      return 'Meter Reading';
    }
    return 'Custom Event';
  }

  Color get categoryColor {
    if (color != null) {
      return color!;
    }
    final t = type.toLowerCase();
    if (t.contains('rent') || t.contains('payment')) {
      return const Color(0xFF0D6EFD);
    }
    if (t.contains('maintenance') ||
        t.contains('ticket') ||
        t.contains('repair')) {
      return const Color(0xFFF59E0B);
    }
    if (t.contains('inspection')) {
      return const Color(0xFF0EA5E9);
    }
    if (t.contains('lease')) {
      return const Color(0xFF8B5CF6);
    }
    if (t.contains('meter')) {
      return const Color(0xFF6366F1);
    }
    return const Color(0xFF10B981);
  }

  AppEvent copyWith({
    String? id,
    String? title,
    DateTime? date,
    String? type,
    String? tenantId,
    String? unitId,
    String? ticketId,
    String? unitNumber,
    String? description,
    Color? color,
    bool? isCompleted,
    String? priority,
    String? timeWindow,
    String? location,
  }) {
    return AppEvent(
      id: id ?? this.id,
      title: title ?? this.title,
      date: date ?? this.date,
      type: type ?? this.type,
      tenantId: tenantId ?? this.tenantId,
      unitId: unitId ?? this.unitId,
      ticketId: ticketId ?? this.ticketId,
      unitNumber: unitNumber ?? this.unitNumber,
      description: description ?? this.description,
      color: color ?? this.color,
      isCompleted: isCompleted ?? this.isCompleted,
      priority: priority ?? this.priority,
      timeWindow: timeWindow ?? this.timeWindow,
      location: location ?? this.location,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'date': date.toIso8601String(),
      'type': type,
      'tenantId': tenantId,
      'unitId': unitId,
      'ticketId': ticketId,
      'unitNumber': unitNumber,
      'description': description,
      'isCompleted': isCompleted,
      'priority': priority,
      'timeWindow': timeWindow,
      'location': location,
    };
  }

  factory AppEvent.fromJson(Map<String, dynamic> json) {
    return AppEvent(
      id: json['id'] as String? ??
          'evt_${DateTime.now().millisecondsSinceEpoch}',
      title: json['title'] as String? ?? 'Untitled Event',
      date: json['date'] != null
          ? (DateTime.tryParse(json['date'].toString()) ?? DateTime.now())
          : DateTime.now(),
      type: json['type'] as String? ?? 'general',
      tenantId: json['tenantId'] as String?,
      unitId: json['unitId'] as String?,
      ticketId: json['ticketId'] as String?,
      unitNumber: json['unitNumber'] as String?,
      description: json['description'] as String?,
      isCompleted: json['isCompleted'] as bool? ?? false,
      priority: json['priority'] as String? ?? 'medium',
      timeWindow: json['timeWindow'] as String?,
      location: json['location'] as String?,
    );
  }
}

/// Announcement Model
class Announcement {
  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  final String author;
  final bool isImportant;
  final String category; // 'General', 'Maintenance', 'Billing', 'Emergency'
  final bool isArchived;

  Announcement({
    required this.id,
    required this.title,
    required this.message,
    DateTime? timestamp,
    this.author = "Emin and Mila's Property Management",
    this.isImportant = true,
    this.category = 'General',
    this.isArchived = false,
  }) : timestamp = timestamp ?? DateTime.now();

  String get formattedDate {
    return DateFormat('MMM dd, yyyy • hh:mm a').format(timestamp);
  }

  Announcement copyWith({
    String? id,
    String? title,
    String? message,
    DateTime? timestamp,
    String? author,
    bool? isImportant,
    String? category,
    bool? isArchived,
  }) {
    return Announcement(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      author: author ?? this.author,
      isImportant: isImportant ?? this.isImportant,
      category: category ?? this.category,
      isArchived: isArchived ?? this.isArchived,
    );
  }
}

/// App Notification Model
class AppNotification {
  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  final bool isRead;
  final bool isArchived;
  final String type; // 'payment', 'ticket', 'unit', 'tenant', 'system'
  final String? entityType;
  final String? entityId;
  final String? action;

  AppNotification({
    required this.id,
    String? title,
    required this.message,
    required this.timestamp,
    this.isRead = false,
    this.isArchived = false,
    String type = 'system',
    this.entityType,
    this.entityId,
    this.action,
  })  : title = title ?? message,
        type = entityType ?? type;

  String get timeAgo {
    final diff = DateTime.now().difference(timestamp);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return DateFormat('MMM dd').format(timestamp);
  }

  AppNotification copyWith({
    String? id,
    String? title,
    String? message,
    DateTime? timestamp,
    bool? isRead,
    bool? isArchived,
    String? type,
    String? entityType,
    String? entityId,
    String? action,
  }) =>
      AppNotification(
        id: id ?? this.id,
        title: title ?? this.title,
        message: message ?? this.message,
        timestamp: timestamp ?? this.timestamp,
        isRead: isRead ?? this.isRead,
        isArchived: isArchived ?? this.isArchived,
        type: type ?? this.type,
        entityType: entityType ?? this.entityType,
        entityId: entityId ?? this.entityId,
        action: action ?? this.action,
      );
}

/// Tenant Document Model
class TenantDocument {
  final String id;
  final String tenantId;
  final String tenantName;
  final String title;
  final String type; // 'Contract', 'ID', 'Receipt', 'Other'
  final String fileName;
  final String fileSize;
  final DateTime uploadedAt;

  TenantDocument({
    required this.id,
    required this.tenantId,
    required this.tenantName,
    required this.title,
    required this.type,
    required this.fileName,
    required this.fileSize,
    DateTime? uploadedAt,
  }) : uploadedAt = uploadedAt ?? DateTime.now();

  String get formattedDate {
    return DateFormat('MMM dd, yyyy').format(uploadedAt);
  }
}

/// Operational Expense Item Model
class ExpenseItem {
  final String id;
  final String title;
  final String
      category; // 'Maintenance', 'Utilities', 'Taxes', 'Supplies', 'Services', 'Other'
  final double amount;
  final DateTime date;
  final String? unitId;
  final String? unitNumber;
  final String recordedBy;
  final String? notes;

  const ExpenseItem({
    required this.id,
    required this.title,
    required this.category,
    required this.amount,
    required this.date,
    this.unitId,
    this.unitNumber,
    this.recordedBy = "Ein and Mila's Property Management",
    this.notes,
  });

  String get formattedAmount {
    final formatter = NumberFormat.currency(
      locale: 'en_PH',
      symbol: '₱',
      decimalDigits: 2,
    );
    return formatter.format(amount);
  }

  String get formattedDate {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  ExpenseItem copyWith({
    String? id,
    String? title,
    String? category,
    double? amount,
    DateTime? date,
    String? unitId,
    String? unitNumber,
    String? recordedBy,
    String? notes,
  }) {
    return ExpenseItem(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      unitId: unitId ?? this.unitId,
      unitNumber: unitNumber ?? this.unitNumber,
      recordedBy: recordedBy ?? this.recordedBy,
      notes: notes ?? this.notes,
    );
  }
}
