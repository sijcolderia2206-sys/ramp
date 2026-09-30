export 'gps_location.dart';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Ticket Status History Entry
class TicketStatusHistoryEntry {
  final String status;
  final DateTime timestamp;
  final String? note;

  const TicketStatusHistoryEntry({
    required this.status,
    required this.timestamp,
    this.note,
  });

  String get formattedTime =>
      DateFormat('MMM dd, yyyy • hh:mm a').format(timestamp);

  Map<String, dynamic> toJson() => {
        'status': status,
        'timestamp': timestamp.toIso8601String(),
        'note': note,
      };

  factory TicketStatusHistoryEntry.fromJson(Map<String, dynamic> json) {
    return TicketStatusHistoryEntry(
      status: json['status'] as String? ?? 'Pending',
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp'] as String) ?? DateTime.now()
          : DateTime.now(),
      note: json['note'] as String?,
    );
  }
}

/// Canonical Unit Model
class Unit {
  final String id;
  final String name; // e.g. "Executive Studio 1" or "Unit 1"
  final String title; // Secondary title or alias
  final String unitNumber; // e.g. "Unit 1"
  final String floor; // e.g. "1st Floor"
  final String location;
  final double rent;
  final double monthlyRent; // Alias for rent
  final String status; // 'Vacant', 'Occupied', 'Maintenance', 'Inactive'
  final String description;
  final double area;
  final double areaSqm; // Alias for area
  final int bedrooms;
  final int bathrooms;
  final List<String> amenities;
  final List<String> inclusions; // ['Water', 'Electricity', 'Wifi']
  final List<String> images;
  final String imageUrl; // Primary image URL
  final String? tenantId;
  final String? tenantName;
  final String? currentTenancyId;
  final DateTime? dueDate;
  final int rentDueDay;
  final double lateFee;
  final int vacantDays;
  final double waterReadingPrev;
  final double waterReadingCurr;
  final double electricReadingPrev;
  final double electricReadingCurr;
  final String? leasePdfTitle;
  final bool isArchived;
  final bool detailsCompleted;
  final bool waterUtilityEnabled;
  final bool electricityUtilityEnabled;
  final double? waterRateOverride;
  final double? electricityRateOverride;
  final List<String> maintenanceAreas;
  final double? latitude;
  final double? longitude;

  Unit({
    required this.id,
    required this.name,
    String? title,
    String? unitNumber,
    this.floor = '1st Floor',
    this.location = 'Main Property',
    this.latitude,
    this.longitude,
    double? rent,
    double? monthlyRent,
    this.status = 'Vacant',
    this.description = '',
    double area = 0.0,
    double? areaSqm,
    this.bedrooms = 1,
    this.bathrooms = 1,
    this.amenities = const [],
    this.inclusions = const ['Water', 'Electricity', 'Wifi'],
    this.images = const [],
    String? imageUrl,
    this.tenantId,
    this.tenantName,
    this.currentTenancyId,
    this.dueDate,
    this.rentDueDay = 5,
    this.lateFee = 500.0,
    this.vacantDays = 0,
    this.waterReadingPrev = 120.5,
    this.waterReadingCurr = 135.2,
    this.electricReadingPrev = 1450.0,
    this.electricReadingCurr = 1620.0,
    this.leasePdfTitle,
    this.isArchived = false,
    this.detailsCompleted = true,
    this.waterUtilityEnabled = true,
    this.electricityUtilityEnabled = true,
    this.waterRateOverride,
    this.electricityRateOverride,
    this.maintenanceAreas = const [
      'Bathroom',
      'Bedroom',
      'Indoor Area',
      'Outdoor Area',
    ],
  })  : title = title ?? name,
        unitNumber = unitNumber ?? name,
        rent = rent ?? monthlyRent ?? 8500.0,
        monthlyRent = monthlyRent ?? rent ?? 8500.0,
        area = area > 0 ? area : (areaSqm ?? 28.0),
        areaSqm = areaSqm ?? (area > 0 ? area : 28.0),
        imageUrl = imageUrl ??
            (images.isNotEmpty
                ? images.first
                : 'https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?q=80&w=300&auto=format&fit=crop');

  bool get isOccupied => status.toLowerCase() == 'occupied';
  bool get isVacant => status.toLowerCase() == 'vacant';
  bool get isMaintenance => status.toLowerCase() == 'maintenance';
  bool get isLongVacant => isVacant && vacantDays > 30;

  bool get hasWater => waterUtilityEnabled;
  bool get hasElectricity => electricityUtilityEnabled;
  bool get hasWifi => inclusions.any((i) =>
      i.toLowerCase().contains('wifi') || i.toLowerCase().contains('internet'));

  double get waterUsage => (waterReadingCurr - waterReadingPrev).clamp(0, 9999);
  double get electricUsage =>
      (electricReadingCurr - electricReadingPrev).clamp(0, 9999);

  double utilityBill(
          {required double waterRate, required double electricityRate}) =>
      (waterUtilityEnabled ? waterUsage * effectiveWaterRate(waterRate) : 0) +
      (electricityUtilityEnabled
          ? electricUsage * effectiveElectricityRate(electricityRate)
          : 0);

  double effectiveWaterRate(double masterRate) =>
      waterRateOverride ?? masterRate;
  double effectiveElectricityRate(double masterRate) =>
      electricityRateOverride ?? masterRate;

  String get formattedRent {
    final formatter = NumberFormat.currency(
      locale: 'en_PH',
      symbol: '₱',
      decimalDigits: 0,
    );
    return '${formatter.format(rent)}/mo';
  }

  String get formattedDueDate {
    if (dueDate == null) return 'Due date not set';
    return DateFormat('MMM dd, yyyy').format(dueDate!);
  }

  String get formattedRentDueDay =>
      '$rentDueDay${_daySuffix(rentDueDay)} of month';

  static String _daySuffix(int day) {
    if (day >= 11 && day <= 13) return 'th';
    switch (day % 10) {
      case 1:
        return 'st';
      case 2:
        return 'nd';
      case 3:
        return 'rd';
      default:
        return 'th';
    }
  }

  Unit copyWith({
    String? id,
    String? name,
    String? title,
    String? unitNumber,
    String? floor,
    String? location,
    double? rent,
    double? monthlyRent,
    String? status,
    String? description,
    double? area,
    double? areaSqm,
    int? bedrooms,
    int? bathrooms,
    List<String>? amenities,
    List<String>? inclusions,
    List<String>? images,
    String? imageUrl,
    String? tenantId,
    String? tenantName,
    String? currentTenancyId,
    bool clearTenantAssignment = false,
    DateTime? dueDate,
    int? rentDueDay,
    double? lateFee,
    int? vacantDays,
    double? waterReadingPrev,
    double? waterReadingCurr,
    double? electricReadingPrev,
    double? electricReadingCurr,
    String? leasePdfTitle,
    bool? isArchived,
    bool? detailsCompleted,
    bool? waterUtilityEnabled,
    bool? electricityUtilityEnabled,
    double? waterRateOverride,
    double? electricityRateOverride,
    bool clearWaterRateOverride = false,
    bool clearElectricityRateOverride = false,
    List<String>? maintenanceAreas,
    double? latitude,
    double? longitude,
  }) {
    return Unit(
      id: id ?? this.id,
      name: name ?? this.name,
      title: title ?? this.title,
      unitNumber: unitNumber ?? this.unitNumber,
      floor: floor ?? this.floor,
      location: location ?? this.location,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      rent: rent ?? this.rent,
      monthlyRent: monthlyRent ?? this.monthlyRent,
      status: status ?? this.status,
      description: description ?? this.description,
      area: area ?? this.area,
      areaSqm: areaSqm ?? this.areaSqm,
      bedrooms: bedrooms ?? this.bedrooms,
      bathrooms: bathrooms ?? this.bathrooms,
      amenities: amenities ?? this.amenities,
      inclusions: inclusions ?? this.inclusions,
      images: images ?? this.images,
      imageUrl: imageUrl ?? this.imageUrl,
      tenantId: clearTenantAssignment ? null : (tenantId ?? this.tenantId),
      tenantName:
          clearTenantAssignment ? null : (tenantName ?? this.tenantName),
      currentTenancyId: clearTenantAssignment
          ? null
          : (currentTenancyId ?? this.currentTenancyId),
      dueDate: dueDate ?? this.dueDate,
      rentDueDay: rentDueDay ?? this.rentDueDay,
      lateFee: lateFee ?? this.lateFee,
      vacantDays: vacantDays ?? this.vacantDays,
      waterReadingPrev: waterReadingPrev ?? this.waterReadingPrev,
      waterReadingCurr: waterReadingCurr ?? this.waterReadingCurr,
      electricReadingPrev: electricReadingPrev ?? this.electricReadingPrev,
      electricReadingCurr: electricReadingCurr ?? this.electricReadingCurr,
      leasePdfTitle: leasePdfTitle ?? this.leasePdfTitle,
      isArchived: isArchived ?? this.isArchived,
      detailsCompleted: detailsCompleted ?? this.detailsCompleted,
      waterUtilityEnabled: waterUtilityEnabled ?? this.waterUtilityEnabled,
      electricityUtilityEnabled:
          electricityUtilityEnabled ?? this.electricityUtilityEnabled,
      waterRateOverride: clearWaterRateOverride
          ? null
          : (waterRateOverride ?? this.waterRateOverride),
      electricityRateOverride: clearElectricityRateOverride
          ? null
          : (electricityRateOverride ?? this.electricityRateOverride),
      maintenanceAreas: maintenanceAreas ?? this.maintenanceAreas,
    );
  }
}

/// Structured Tenant Rent Reminder Log
class ReminderLog {
  final String id;
  final String tenantId;
  final String channel; // 'SMS' or 'Messenger'
  final DateTime timestamp;
  final String rentCycle; // e.g. 'Oct 2026'
  final String messageType;

  const ReminderLog({
    required this.id,
    required this.tenantId,
    required this.channel,
    required this.timestamp,
    required this.rentCycle,
    this.messageType = 'Rent Notice',
  });

  String get formattedTime => DateFormat('MMM dd, yyyy • hh:mm a').format(timestamp);
}

/// Canonical Tenant Model
class Tenant {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String contactNumber; // Alias for phone
  final String address;
  final String referral;
  final String unitId;
  final String unitNumber;
  final double monthlyRent;
  final DateTime leaseStart;
  final DateTime leaseEnd;
  final DateTime dueDate;
  final double balance;
  final String status; // 'Active', 'Pending Renewal', 'Former', 'Archived'
  final bool isArchived;
  final String? avatarUrl;
  final String? currentTenancyId;
  final String? messengerHandle;
  final List<ReminderLog> reminderLogs;

  Tenant({
    required this.id,
    required this.name,
    this.email = '',
    String phone = '',
    String? contactNumber,
    this.address = '',
    this.referral = '',
    this.unitId = '',
    this.unitNumber = 'Unassigned',
    this.monthlyRent = 0.0,
    DateTime? leaseStart,
    DateTime? leaseEnd,
    DateTime? dueDate,
    this.balance = 0.0,
    this.status = 'Active',
    this.isArchived = false,
    this.avatarUrl,
    this.currentTenancyId,
    int reminderCount = 0,
    this.messengerHandle,
    List<ReminderLog>? reminderLogs,
  })  : phone = contactNumber ?? phone,
        contactNumber = contactNumber ?? phone,
        leaseStart = leaseStart ?? DateTime.now(),
        leaseEnd = leaseEnd ?? DateTime.now().add(const Duration(days: 365)),
        dueDate = dueDate ?? DateTime.now().add(const Duration(days: 5)),
        reminderLogs = reminderLogs ?? [];

  int get reminderCount => reminderLogs.length;

  bool get isFormer =>
      isArchived ||
      status.toLowerCase() == 'former' ||
      status.toLowerCase() == 'archived';

  bool get isAssigned => unitId.isNotEmpty && unitNumber != 'Unassigned';

  bool get isLate => balance > 0 && DateTime.now().isAfter(dueDate);

  bool get isDueSoon {
    if (balance <= 0) return false;
    final diff = dueDate.difference(DateTime.now()).inDays;
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

  Color get healthColor {
    if (isFormer) return const Color(0xFF6B7280);
    if (isLate || reminderCount >= 5) return const Color(0xFFEF4444);
    if (reminderCount >= 2 || isDueSoon || balance > 0) {
      return const Color(0xFFF59E0B);
    }
    return const Color(0xFF10B981);
  }

  String get healthStatusText {
    if (isFormer) return 'Former Tenant';
    if (isLate || reminderCount >= 5) return 'High Risk (Frequently Late)';
    if (reminderCount >= 2 || isDueSoon || balance > 0) {
      return 'Needs Follow-up';
    }
    return 'Good Payer';
  }

  String get leaseStartDate => DateFormat('MMM dd, yyyy').format(leaseStart);
  String get leaseEndDate => DateFormat('MMM dd, yyyy').format(leaseEnd);

  Tenant copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? contactNumber,
    String? address,
    String? referral,
    String? unitId,
    String? unitNumber,
    double? monthlyRent,
    DateTime? leaseStart,
    DateTime? leaseEnd,
    DateTime? dueDate,
    double? balance,
    String? status,
    bool? isArchived,
    String? avatarUrl,
    String? currentTenancyId,
    int? reminderCount,
    String? messengerHandle,
    List<ReminderLog>? reminderLogs,
  }) {
    return Tenant(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      contactNumber: contactNumber ?? this.contactNumber,
      address: address ?? this.address,
      referral: referral ?? this.referral,
      unitId: unitId ?? this.unitId,
      unitNumber: unitNumber ?? this.unitNumber,
      monthlyRent: monthlyRent ?? this.monthlyRent,
      leaseStart: leaseStart ?? this.leaseStart,
      leaseEnd: leaseEnd ?? this.leaseEnd,
      dueDate: dueDate ?? this.dueDate,
      balance: balance ?? this.balance,
      status: status ?? this.status,
      isArchived: isArchived ?? this.isArchived,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      currentTenancyId: currentTenancyId ?? this.currentTenancyId,
      messengerHandle: messengerHandle ?? this.messengerHandle,
      reminderLogs: reminderLogs ?? this.reminderLogs,
    );
  }
}

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

/// Canonical maintenance ticket model.
class Ticket {
  final String id;
  final String? unitId;
  final String unitNumber;
  final String? tenantId;
  final String tenantName;
  final String title;
  final String description;
  final String
      category; // 'Plumbing', 'Electrical', 'Appliance', 'Structural', 'General'
  final String? photoPath;
  final String? photoBefore;
  final String? photoAfter;
  final List<String> photos;
  final String priority; // 'Low', 'Med', 'High', 'Emergency'
  final String
      status; // 'Pending', 'In Progress', 'Completed', 'Closed', 'Cancelled'
  final String assignedTo;
  final String? assignedToName; // Alias for assignedTo
  final String? vendorId;
  final double estimatedCost;
  final double actualCost;
  final double? vendorCost; // Alias for actualCost
  final DateTime date;
  final DateTime createdAt; // Alias for date
  final DateTime slaDueDate;
  final int rating; // 1-5 Stars
  final String? ratingFeedback;
  final String responsibleParty; // 'Landlord', 'Tenant', 'Shared'
  final bool paymentRequired;
  final String paymentStatus; // 'Not Required', 'Pending', 'Paid'
  final String? tenancyId;
  final List<TicketStatusHistoryEntry> statusHistory;
  final List<String> affectedAreas;
  final DateTime? issueStartedAt;
  final DateTime? visitScheduledAt;
  final String visitTimeWindow;
  final bool visitReminderSent;
  final List<String> replacementItems;
  final DateTime? repairScheduledAt;
  final String repairTimeWindow;
  final String repairer;
  final bool repairReminderSent;
  final String completionSummary;

  Ticket({
    required this.id,
    this.unitId,
    this.unitNumber = 'Unit 1',
    this.tenantId,
    this.tenantName = 'Juan Dela Cruz',
    required this.title,
    this.description = '',
    this.category = 'General',
    this.photoPath,
    this.photoBefore,
    this.photoAfter,
    List<String>? photos,
    this.priority = 'Med',
    this.status = 'Schedule Visit',
    String? assignedTo,
    String? assignedToName,
    this.vendorId,
    this.estimatedCost = 0.0,
    double actualCost = 0.0,
    double? vendorCost,
    DateTime? date,
    DateTime? createdAt,
    DateTime? slaDueDate,
    this.rating = 0,
    this.ratingFeedback,
    this.responsibleParty = 'Landlord',
    this.paymentRequired = false,
    this.paymentStatus = 'Not Required',
    this.tenancyId,
    List<TicketStatusHistoryEntry>? statusHistory,
    this.affectedAreas = const [],
    this.issueStartedAt,
    this.visitScheduledAt,
    this.visitTimeWindow = '',
    this.visitReminderSent = false,
    this.replacementItems = const [],
    this.repairScheduledAt,
    this.repairTimeWindow = '',
    this.repairer = '',
    this.repairReminderSent = false,
    this.completionSummary = '',
  })  : assignedTo =
            assignedToName ?? assignedTo ?? 'Alex Rivera (Plumbing & HVAC)',
        assignedToName =
            assignedToName ?? assignedTo ?? 'Alex Rivera (Plumbing & HVAC)',
        photos = photos ?? (photoPath != null ? [photoPath] : []),
        actualCost = vendorCost ?? actualCost,
        vendorCost = vendorCost ?? actualCost,
        date = createdAt ?? date ?? DateTime.now(),
        createdAt = createdAt ?? date ?? DateTime.now(),
        slaDueDate = slaDueDate ??
            computeSlaDueDate(priority, createdAt ?? date ?? DateTime.now()),
        statusHistory = statusHistory ??
            [
              TicketStatusHistoryEntry(
                status: status,
                timestamp: createdAt ?? date ?? DateTime.now(),
                note: 'Ticket created',
              )
            ];

  static DateTime computeSlaDueDate(String priority, DateTime created) {
    switch (priority.toLowerCase()) {
      case 'high':
      case 'emergency':
        return created.add(const Duration(days: 1));
      case 'low':
        return created.add(const Duration(days: 7));
      case 'med':
      case 'medium':
      default:
        return created.add(const Duration(days: 3));
    }
  }

  bool get isSlaBreached {
    if (status.toLowerCase() == 'completed' ||
        status.toLowerCase() == 'closed') {
      return false;
    }
    return DateTime.now().isAfter(slaDueDate);
  }

  String get slaStatusText {
    if (status.toLowerCase() == 'completed' ||
        status.toLowerCase() == 'closed') {
      return 'SLA Met';
    }
    final diff = slaDueDate.difference(DateTime.now()).inHours;
    if (diff < 0) return 'SLA Breached!';
    if (diff < 24) return 'SLA Due in ${diff}h';
    return 'SLA Due in ${(diff / 24).ceil()}d';
  }

  double get cost => actualCost > 0 ? actualCost : estimatedCost;

  String get formattedCost {
    final formatter = NumberFormat.currency(
      locale: 'en_PH',
      symbol: '₱',
      decimalDigits: 2,
    );
    return formatter.format(estimatedCost);
  }

  String get formattedActualCost {
    final formatter = NumberFormat.currency(
      locale: 'en_PH',
      symbol: '₱',
      decimalDigits: 2,
    );
    return formatter.format(actualCost);
  }

  String get formattedDate =>
      DateFormat('MMM dd, yyyy • hh:mm a').format(createdAt);

  bool get isScheduleVisitStage =>
      status.toLowerCase() == 'pending' ||
      status.toLowerCase() == 'schedule visit';

  bool get isEstimateStage => status.toLowerCase() == 'estimate';

  bool get isScheduleRepairStage =>
      status.toLowerCase() == 'schedule repair' ||
      status.toLowerCase() == 'in progress';

  bool get isCompletedStage =>
      status.toLowerCase() == 'completed' || status.toLowerCase() == 'closed';

  Ticket copyWith({
    String? id,
    String? unitId,
    String? unitNumber,
    String? tenantId,
    String? tenantName,
    String? title,
    String? description,
    String? category,
    String? photoPath,
    String? photoBefore,
    String? photoAfter,
    List<String>? photos,
    String? priority,
    String? status,
    String? assignedToName,
    String? vendorId,
    double? estimatedCost,
    double? actualCost,
    double? vendorCost,
    DateTime? date,
    DateTime? createdAt,
    DateTime? slaDueDate,
    int? rating,
    String? ratingFeedback,
    String? responsibleParty,
    bool? paymentRequired,
    String? paymentStatus,
    List<TicketStatusHistoryEntry>? statusHistory,
    List<String>? affectedAreas,
    DateTime? issueStartedAt,
    DateTime? visitScheduledAt,
    String? visitTimeWindow,
    bool? visitReminderSent,
    List<String>? replacementItems,
    DateTime? repairScheduledAt,
    String? repairTimeWindow,
    String? repairer,
    bool? repairReminderSent,
    String? completionSummary,
  }) {
    return Ticket(
      id: id ?? this.id,
      unitId: unitId ?? this.unitId,
      unitNumber: unitNumber ?? this.unitNumber,
      tenantId: tenantId ?? this.tenantId,
      tenantName: tenantName ?? this.tenantName,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      photoPath: photoPath ?? this.photoPath,
      photoBefore: photoBefore ?? this.photoBefore,
      photoAfter: photoAfter ?? this.photoAfter,
      photos: photos ?? this.photos,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      assignedToName: assignedToName ?? this.assignedToName,
      vendorId: vendorId ?? this.vendorId,
      estimatedCost: estimatedCost ?? this.estimatedCost,
      actualCost: actualCost ?? this.actualCost,
      vendorCost: vendorCost ?? this.vendorCost,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
      slaDueDate: slaDueDate ?? this.slaDueDate,
      rating: rating ?? this.rating,
      ratingFeedback: ratingFeedback ?? this.ratingFeedback,
      responsibleParty: responsibleParty ?? this.responsibleParty,
      paymentRequired: paymentRequired ?? this.paymentRequired,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      statusHistory: statusHistory ?? this.statusHistory,
      affectedAreas: affectedAreas ?? this.affectedAreas,
      issueStartedAt: issueStartedAt ?? this.issueStartedAt,
      visitScheduledAt: visitScheduledAt ?? this.visitScheduledAt,
      visitTimeWindow: visitTimeWindow ?? this.visitTimeWindow,
      visitReminderSent: visitReminderSent ?? this.visitReminderSent,
      replacementItems: replacementItems ?? this.replacementItems,
      repairScheduledAt: repairScheduledAt ?? this.repairScheduledAt,
      repairTimeWindow: repairTimeWindow ?? this.repairTimeWindow,
      repairer: repairer ?? this.repairer,
      repairReminderSent: repairReminderSent ?? this.repairReminderSent,
      completionSummary: completionSummary ?? this.completionSummary,
    );
  }
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
    final nowAtMidnight = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    final eventAtMidnight = DateTime(date.year, date.month, date.day);
    return eventAtMidnight.isBefore(nowAtMidnight);
  }

  String get categoryLabel {
    final t = type.toLowerCase();
    if (t.contains('rent') || t.contains('payment')) return 'Rent Due';
    if (t.contains('maintenance') || t.contains('ticket') || t.contains('repair')) return 'Maintenance';
    if (t.contains('inspection')) return 'Inspection';
    if (t.contains('lease')) return 'Lease Expiration';
    if (t.contains('meter')) return 'Meter Reading';
    return 'Custom Event';
  }

  Color get categoryColor {
    if (color != null) return color!;
    final t = type.toLowerCase();
    if (t.contains('rent') || t.contains('payment')) return const Color(0xFF0D6EFD);
    if (t.contains('maintenance') || t.contains('ticket') || t.contains('repair')) return const Color(0xFFF59E0B);
    if (t.contains('inspection')) return const Color(0xFF0EA5E9);
    if (t.contains('lease')) return const Color(0xFF8B5CF6);
    if (t.contains('meter')) return const Color(0xFF6366F1);
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
      id: json['id'] as String? ?? 'evt_${DateTime.now().millisecondsSinceEpoch}',
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

/// Canonical payment model.
class PaymentData {
  final String id;
  final String month;
  final double amount;
  final String method; // 'GCash', 'Maya', 'Bank Transfer', 'Cash'
  final String paymentMethod; // Alias for method
  final DateTime date;
  final DateTime paymentDate; // Alias for date
  final String status; // 'Paid', 'Pending', 'Declined', 'Reversed'
  final String unitId;
  final String referenceNumber;
  final double baseRent;
  final double waterBill;
  final double electricBill;
  final double lateFee;
  final double otherCharge;
  final String tenantName;
  final String unitNumber;
  final String tenantId;
  final String? tenancyId;
  final String proofImageUrl;
  final String? remarks;
  final String? declineReason;
  final String transactionType;
  final String? ticketId;

  PaymentData({
    String? id,
    String? month,
    required this.amount,
    String method = 'GCash',
    String? paymentMethod,
    DateTime? date,
    DateTime? paymentDate,
    this.status = 'Paid',
    this.unitId = 'u1',
    String? referenceNumber,
    double? baseRent,
    this.waterBill = 0.0,
    this.electricBill = 0.0,
    this.lateFee = 0.0,
    this.otherCharge = 0.0,
    this.tenantName = 'Juan Dela Cruz',
    this.unitNumber = 'Unit 1',
    this.tenantId = '',
    this.tenancyId,
    this.proofImageUrl = '',
    this.remarks,
    this.declineReason,
    this.transactionType = 'Rent',
    this.ticketId,
  })  : id = id ?? 'pay_${DateTime.now().millisecondsSinceEpoch}',
        month = month ?? 'Oct',
        method = paymentMethod ?? method,
        paymentMethod = paymentMethod ?? method,
        date = paymentDate ?? date ?? DateTime.now(),
        paymentDate = paymentDate ?? date ?? DateTime.now(),
        referenceNumber = referenceNumber ??
            'GC-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}',
        baseRent = baseRent ??
            (amount > (waterBill + electricBill + lateFee + otherCharge)
                ? amount - (waterBill + electricBill + lateFee + otherCharge)
                : amount);

  bool get isPaid => status.toLowerCase() == 'paid';
  bool get isPending => status.toLowerCase() == 'pending';
  bool get isDeclined => status.toLowerCase() == 'declined';
  bool get isReversed => status.toLowerCase() == 'reversed';
  bool get isMaintenance => transactionType.toLowerCase() == 'maintenance';
  bool get isRent => transactionType.toLowerCase() == 'rent';

  double get calculatedTotal =>
      baseRent + waterBill + electricBill + lateFee + otherCharge;

  String get formattedAmount {
    final formatter = NumberFormat.currency(
      locale: 'en_PH',
      symbol: '₱',
      decimalDigits: 2,
    );
    return formatter.format(amount > 0 ? amount : calculatedTotal);
  }

  String get formattedDate =>
      DateFormat('MMM dd, yyyy • hh:mm a').format(paymentDate);

  String get formattedBaseRent {
    final formatter = NumberFormat.currency(
      locale: 'en_PH',
      symbol: '₱',
      decimalDigits: 2,
    );
    return formatter.format(baseRent);
  }

  String get formattedWaterBill {
    final formatter = NumberFormat.currency(
      locale: 'en_PH',
      symbol: '₱',
      decimalDigits: 2,
    );
    return formatter.format(waterBill);
  }

  String get formattedElectricBill {
    final formatter = NumberFormat.currency(
      locale: 'en_PH',
      symbol: '₱',
      decimalDigits: 2,
    );
    return formatter.format(electricBill);
  }

  String get formattedLateFee {
    final formatter = NumberFormat.currency(
      locale: 'en_PH',
      symbol: '₱',
      decimalDigits: 2,
    );
    return formatter.format(lateFee);
  }

  PaymentData copyWith({
    String? id,
    String? month,
    double? amount,
    String? method,
    String? paymentMethod,
    DateTime? date,
    DateTime? paymentDate,
    String? status,
    String? unitId,
    String? referenceNumber,
    double? baseRent,
    double? waterBill,
    double? electricBill,
    double? lateFee,
    double? otherCharge,
    String? tenantName,
    String? unitNumber,
    String? tenantId,
    String? tenancyId,
    String? proofImageUrl,
    String? remarks,
    String? declineReason,
    String? transactionType,
    String? ticketId,
  }) {
    return PaymentData(
      id: id ?? this.id,
      month: month ?? this.month,
      amount: amount ?? this.amount,
      method: method ?? paymentMethod ?? this.method,
      paymentMethod: paymentMethod ?? method ?? this.paymentMethod,
      date: date ?? paymentDate ?? this.date,
      paymentDate: paymentDate ?? date ?? this.paymentDate,
      status: status ?? this.status,
      unitId: unitId ?? this.unitId,
      referenceNumber: referenceNumber ?? this.referenceNumber,
      baseRent: baseRent ?? this.baseRent,
      waterBill: waterBill ?? this.waterBill,
      electricBill: electricBill ?? this.electricBill,
      lateFee: lateFee ?? this.lateFee,
      otherCharge: otherCharge ?? this.otherCharge,
      tenantName: tenantName ?? this.tenantName,
      unitNumber: unitNumber ?? this.unitNumber,
      tenantId: tenantId ?? this.tenantId,
      tenancyId: tenancyId ?? this.tenancyId,
      proofImageUrl: proofImageUrl ?? this.proofImageUrl,
      remarks: remarks ?? this.remarks,
      declineReason: declineReason ?? this.declineReason,
      transactionType: transactionType ?? this.transactionType,
      ticketId: ticketId ?? this.ticketId,
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
