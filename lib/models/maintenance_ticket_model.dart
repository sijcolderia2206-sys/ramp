// lib/models/maintenance_ticket_model.dart

import '../core/utils/safe_parse.dart';

class MaintenanceTicket {
  final String id;
  final String landlordId;
  final String unitId;
  final String unitNumber;
  final String? tenantId;
  final String? tenantName;
  final String title;
  final String description;
  final String unitArea; // 'Bathroom', 'Bedroom', 'Indoor Area', 'Outdoor Area', 'Plumbing', 'Electrical', 'General'
  final String priority; // 'Emergency', 'Medium', 'Low'
  final String stage; // 'Schedule Visit', 'Estimate', 'Schedule Repair', 'Completed'
  final DateTime? visitDate;
  final String? visitTimeSlot;
  final double estimatedCost;
  final double laborCost;
  final double materialsCost;
  final String vendorCategory; // 'Plumbing', 'Electrical', 'Aircon', 'Carpentry', 'General'
  final List<String> replacementItems;
  final String? repairer;
  final String? repairerPhone;
  final DateTime? repairDate;
  final String? repairTimeSlot;
  final bool isTenantChargeable;
  final String? completionSummary;
  final String? photoBefore;
  final String? photoAfter;
  final int? rating;
  final String? tenantFeedback;
  final DateTime slaDueDate;
  final DateTime createdAt;

  const MaintenanceTicket({
    required this.id,
    this.landlordId = 'l1',
    required this.unitId,
    required this.unitNumber,
    this.tenantId,
    this.tenantName,
    required this.title,
    required this.description,
    this.unitArea = 'Indoor Area',
    this.priority = 'Medium',
    this.stage = 'Schedule Visit',
    this.visitDate,
    this.visitTimeSlot,
    this.estimatedCost = 0.0,
    this.laborCost = 0.0,
    this.materialsCost = 0.0,
    this.vendorCategory = 'General',
    this.replacementItems = const [],
    this.repairer,
    this.repairerPhone,
    this.repairDate,
    this.repairTimeSlot,
    this.isTenantChargeable = false,
    this.completionSummary,
    this.photoBefore,
    this.photoAfter,
    this.rating,
    this.tenantFeedback,
    required this.slaDueDate,
    required this.createdAt,
  });

  bool get isOverdue => stage != 'Completed' && stage != 'Resolved' && DateTime.now().isAfter(slaDueDate);
  bool get isSlaBreached => isOverdue;

  double get totalCost => (laborCost + materialsCost > 0) ? (laborCost + materialsCost) : estimatedCost;

  /// Model Compatibility Getters for RAMP Property Management Specification
  String get issueTitle => title;
  String get category => unitArea;
  String get status => stage;
  String? get imageUrl => photoBefore;
  double get repairCost => totalCost;
  DateTime get reportedDate => createdAt;

  /// SLA Helper Getters
  String get slaRemainingText {
    if (stage == 'Completed' || stage == 'Resolved') return 'Completed';
    final now = DateTime.now();
    final diff = slaDueDate.difference(now);
    if (diff.isNegative) {
      final hours = diff.inHours.abs();
      if (hours >= 24) {
        return 'Overdue by ${diff.inDays.abs()}d';
      }
      return 'Overdue by ${hours}h';
    } else {
      if (diff.inHours >= 24) {
        return '${diff.inDays}d left';
      } else if (diff.inHours > 0) {
        return '${diff.inHours}h left';
      } else {
        return '${diff.inMinutes}m left';
      }
    }
  }

  /// Default SLA Target Helper:
  /// Emergency: 24h, Medium: 3 days, Low: 7 days
  static DateTime calculateSlaDueDate(String priority, [DateTime? start]) {
    final base = start ?? DateTime.now();
    switch (priority.toLowerCase()) {
      case 'emergency':
      case 'high':
        return base.add(const Duration(hours: 24));
      case 'medium':
      case 'med':
        return base.add(const Duration(days: 3));
      case 'low':
      default:
        return base.add(const Duration(days: 7));
    }
  }

  MaintenanceTicket copyWith({
    String? id,
    String? landlordId,
    String? unitId,
    String? unitNumber,
    String? tenantId,
    String? tenantName,
    String? title,
    String? description,
    String? unitArea,
    String? priority,
    String? stage,
    DateTime? visitDate,
    String? visitTimeSlot,
    double? estimatedCost,
    double? laborCost,
    double? materialsCost,
    String? vendorCategory,
    List<String>? replacementItems,
    String? repairer,
    String? repairerPhone,
    DateTime? repairDate,
    String? repairTimeSlot,
    bool? isTenantChargeable,
    String? completionSummary,
    String? photoBefore,
    String? photoAfter,
    int? rating,
    String? tenantFeedback,
    DateTime? slaDueDate,
    DateTime? createdAt,
  }) {
    return MaintenanceTicket(
      id: id ?? this.id,
      landlordId: landlordId ?? this.landlordId,
      unitId: unitId ?? this.unitId,
      unitNumber: unitNumber ?? this.unitNumber,
      tenantId: tenantId ?? this.tenantId,
      tenantName: tenantName ?? this.tenantName,
      title: title ?? this.title,
      description: description ?? this.description,
      unitArea: unitArea ?? this.unitArea,
      priority: priority ?? this.priority,
      stage: stage ?? this.stage,
      visitDate: visitDate ?? this.visitDate,
      visitTimeSlot: visitTimeSlot ?? this.visitTimeSlot,
      estimatedCost: estimatedCost ?? this.estimatedCost,
      laborCost: laborCost ?? this.laborCost,
      materialsCost: materialsCost ?? this.materialsCost,
      vendorCategory: vendorCategory ?? this.vendorCategory,
      replacementItems: replacementItems ?? this.replacementItems,
      repairer: repairer ?? this.repairer,
      repairerPhone: repairerPhone ?? this.repairerPhone,
      repairDate: repairDate ?? this.repairDate,
      repairTimeSlot: repairTimeSlot ?? this.repairTimeSlot,
      isTenantChargeable: isTenantChargeable ?? this.isTenantChargeable,
      completionSummary: completionSummary ?? this.completionSummary,
      photoBefore: photoBefore ?? this.photoBefore,
      photoAfter: photoAfter ?? this.photoAfter,
      rating: rating ?? this.rating,
      tenantFeedback: tenantFeedback ?? this.tenantFeedback,
      slaDueDate: slaDueDate ?? this.slaDueDate,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'landlord_id': landlordId,
      'unit_id': unitId,
      'unit_number': unitNumber,
      'tenant_id': tenantId,
      'tenant_name': tenantName,
      'title': title,
      'description': description,
      'category': unitArea,
      'priority': priority,
      'status': stage,
      'visit_scheduled_at': visitDate?.toIso8601String(),
      'visit_time_window': visitTimeSlot,
      'estimated_cost': estimatedCost,
      'labor_cost': laborCost,
      'materials_cost': materialsCost,
      'vendor_category': vendorCategory,
      'replacement_items': replacementItems,
      'repairer': repairer,
      'repairer_phone': repairerPhone,
      'repair_scheduled_at': repairDate?.toIso8601String(),
      'repair_time_window': repairTimeSlot,
      'is_tenant_chargeable': isTenantChargeable,
      'completion_summary': completionSummary,
      'photo_before': photoBefore,
      'photo_after': photoAfter,
      'rating': rating,
      'tenant_feedback': tenantFeedback,
      'sla_due_date': slaDueDate.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory MaintenanceTicket.fromJson(Map<String, dynamic> json) {
    final priority = parseString(json['priority'], 'Medium');
    final createdAt = parseDateTime(json['created_at']);

    return MaintenanceTicket(
      id: parseString(json['id'], 'tkt_${DateTime.now().millisecondsSinceEpoch}'),
      landlordId: parseString(json['landlord_id'], 'l1'),
      unitId: parseString(json['unit_id']),
      unitNumber: parseString(json['unit_number'], 'Unassigned'),
      tenantId: parseNullableString(json['tenant_id']),
      tenantName: parseNullableString(json['tenant_name']),
      title: parseString(json['title'], 'Maintenance Request'),
      description: parseString(json['description']),
      unitArea: parseString(json['category'] ?? json['unit_area'], 'Indoor Area'),
      priority: priority,
      stage: parseString(json['status'] ?? json['stage'], 'Schedule Visit'),
      visitDate: parseNullableDateTime(json['visit_scheduled_at']),
      visitTimeSlot: parseNullableString(json['visit_time_window']),
      estimatedCost: parseDouble(json['estimated_cost']),
      laborCost: parseDouble(json['labor_cost']),
      materialsCost: parseDouble(json['materials_cost']),
      vendorCategory: parseString(json['vendor_category'], 'General'),
      replacementItems: parseStringList(json['replacement_items']),
      repairer: parseNullableString(json['repairer']),
      repairerPhone: parseNullableString(json['repairer_phone']),
      repairDate: parseNullableDateTime(json['repair_scheduled_at']),
      repairTimeSlot: parseNullableString(json['repair_time_window']),
      isTenantChargeable: parseBool(json['is_tenant_chargeable']),
      completionSummary: parseNullableString(json['completion_summary']),
      photoBefore: parseNullableString(json['photo_before'] ?? json['photo_path']),
      photoAfter: parseNullableString(json['photo_after']),
      rating: parseNullableInt(json['rating']),
      tenantFeedback: parseNullableString(json['tenant_feedback']),
      slaDueDate: parseNullableDateTime(json['sla_due_date']) ?? calculateSlaDueDate(priority, createdAt),
      createdAt: createdAt,
    );
  }
}
