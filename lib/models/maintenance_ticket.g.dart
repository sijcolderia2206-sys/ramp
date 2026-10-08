// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'maintenance_ticket.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MaintenanceTicket _$MaintenanceTicketFromJson(Map<String, dynamic> json) =>
    _MaintenanceTicket(
      id: json['id'] as String,
      tenantId: json['tenantId'] as String,
      unitId: json['unitId'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      severity: $enumDecode(_$TicketSeverityEnumMap, json['severity']),
      status: $enumDecodeNullable(_$TicketStatusEnumMap, json['status']) ??
          TicketStatus.open,
      photoUrls: (json['photoUrls'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      rating: (json['rating'] as num?)?.toInt(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      resolvedAt: json['resolvedAt'] == null
          ? null
          : DateTime.parse(json['resolvedAt'] as String),
    );

Map<String, dynamic> _$MaintenanceTicketToJson(_MaintenanceTicket instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tenantId': instance.tenantId,
      'unitId': instance.unitId,
      'title': instance.title,
      'description': instance.description,
      'severity': _$TicketSeverityEnumMap[instance.severity]!,
      'status': _$TicketStatusEnumMap[instance.status]!,
      'photoUrls': instance.photoUrls,
      'rating': instance.rating,
      'createdAt': instance.createdAt.toIso8601String(),
      'resolvedAt': instance.resolvedAt?.toIso8601String(),
    };

const _$TicketSeverityEnumMap = {
  TicketSeverity.emergency: 'emergency',
  TicketSeverity.medium: 'medium',
  TicketSeverity.low: 'low',
};

const _$TicketStatusEnumMap = {
  TicketStatus.open: 'open',
  TicketStatus.inProgress: 'in_progress',
  TicketStatus.resolved: 'resolved',
  TicketStatus.closed: 'closed',
};
