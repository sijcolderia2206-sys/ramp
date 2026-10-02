// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ticket_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TicketStatusHistoryEntry _$TicketStatusHistoryEntryFromJson(
        Map<String, dynamic> json) =>
    _TicketStatusHistoryEntry(
      status: json['status'] as String? ?? '',
      timestamp: json['timestamp'] == null
          ? null
          : DateTime.parse(json['timestamp'] as String),
      note: json['note'] as String?,
    );

Map<String, dynamic> _$TicketStatusHistoryEntryToJson(
        _TicketStatusHistoryEntry instance) =>
    <String, dynamic>{
      'status': instance.status,
      'timestamp': instance.timestamp?.toIso8601String(),
      'note': instance.note,
    };

_Ticket _$TicketFromJson(Map<String, dynamic> json) => _Ticket(
      id: json['id'] as String? ?? '',
      unitId: json['unitId'] as String?,
      unitNumber: json['unitNumber'] as String? ?? 'Unit 1',
      tenantId: json['tenantId'] as String?,
      tenantName: json['tenantName'] as String? ?? 'Juan Dela Cruz',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      category: json['category'] as String? ?? 'General',
      photoPath: json['photoPath'] as String?,
      photoBefore: json['photoBefore'] as String?,
      photoAfter: json['photoAfter'] as String?,
      photos: (json['photos'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      priority: json['priority'] as String? ?? 'Med',
      status: json['status'] as String? ?? 'Schedule Visit',
      assignedTo:
          json['assignedTo'] as String? ?? 'Alex Rivera (Plumbing & HVAC)',
      assignedToName:
          json['assignedToName'] as String? ?? 'Alex Rivera (Plumbing & HVAC)',
      vendorId: json['vendorId'] as String?,
      estimatedCost: (json['estimatedCost'] as num?)?.toDouble() ?? 0.0,
      actualCost: (json['actualCost'] as num?)?.toDouble() ?? 0.0,
      vendorCost: (json['vendorCost'] as num?)?.toDouble() ?? 0.0,
      date:
          json['date'] == null ? null : DateTime.parse(json['date'] as String),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      slaDueDate: json['slaDueDate'] == null
          ? null
          : DateTime.parse(json['slaDueDate'] as String),
      rating: (json['rating'] as num?)?.toInt() ?? 0,
      ratingFeedback: json['ratingFeedback'] as String?,
      responsibleParty: json['responsibleParty'] as String? ?? 'Landlord',
      paymentRequired: json['paymentRequired'] as bool? ?? false,
      paymentStatus: json['paymentStatus'] as String? ?? 'Not Required',
      tenancyId: json['tenancyId'] as String?,
      statusHistory: (json['statusHistory'] as List<dynamic>?)
              ?.map((e) =>
                  TicketStatusHistoryEntry.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      affectedAreas: (json['affectedAreas'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      issueStartedAt: json['issueStartedAt'] == null
          ? null
          : DateTime.parse(json['issueStartedAt'] as String),
      visitScheduledAt: json['visitScheduledAt'] == null
          ? null
          : DateTime.parse(json['visitScheduledAt'] as String),
      visitTimeWindow: json['visitTimeWindow'] as String? ?? '',
      visitReminderSent: json['visitReminderSent'] as bool? ?? false,
      replacementItems: (json['replacementItems'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      repairScheduledAt: json['repairScheduledAt'] == null
          ? null
          : DateTime.parse(json['repairScheduledAt'] as String),
      repairTimeWindow: json['repairTimeWindow'] as String? ?? '',
      repairer: json['repairer'] as String? ?? '',
      repairReminderSent: json['repairReminderSent'] as bool? ?? false,
      completionSummary: json['completionSummary'] as String? ?? '',
    );

Map<String, dynamic> _$TicketToJson(_Ticket instance) => <String, dynamic>{
      'id': instance.id,
      'unitId': instance.unitId,
      'unitNumber': instance.unitNumber,
      'tenantId': instance.tenantId,
      'tenantName': instance.tenantName,
      'title': instance.title,
      'description': instance.description,
      'category': instance.category,
      'photoPath': instance.photoPath,
      'photoBefore': instance.photoBefore,
      'photoAfter': instance.photoAfter,
      'photos': instance.photos,
      'priority': instance.priority,
      'status': instance.status,
      'assignedTo': instance.assignedTo,
      'assignedToName': instance.assignedToName,
      'vendorId': instance.vendorId,
      'estimatedCost': instance.estimatedCost,
      'actualCost': instance.actualCost,
      'vendorCost': instance.vendorCost,
      'date': instance.date?.toIso8601String(),
      'createdAt': instance.createdAt?.toIso8601String(),
      'slaDueDate': instance.slaDueDate?.toIso8601String(),
      'rating': instance.rating,
      'ratingFeedback': instance.ratingFeedback,
      'responsibleParty': instance.responsibleParty,
      'paymentRequired': instance.paymentRequired,
      'paymentStatus': instance.paymentStatus,
      'tenancyId': instance.tenancyId,
      'statusHistory': instance.statusHistory,
      'affectedAreas': instance.affectedAreas,
      'issueStartedAt': instance.issueStartedAt?.toIso8601String(),
      'visitScheduledAt': instance.visitScheduledAt?.toIso8601String(),
      'visitTimeWindow': instance.visitTimeWindow,
      'visitReminderSent': instance.visitReminderSent,
      'replacementItems': instance.replacementItems,
      'repairScheduledAt': instance.repairScheduledAt?.toIso8601String(),
      'repairTimeWindow': instance.repairTimeWindow,
      'repairer': instance.repairer,
      'repairReminderSent': instance.repairReminderSent,
      'completionSummary': instance.completionSummary,
    };
