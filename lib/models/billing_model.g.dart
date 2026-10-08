// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'billing_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_BillingInvoice _$BillingInvoiceFromJson(Map<String, dynamic> json) =>
    _BillingInvoice(
      id: json['id'] as String,
      tenantId: json['tenantId'] as String,
      unitId: json['unitId'] as String,
      baseRent: (json['baseRent'] as num).toDouble(),
      waterUsage: (json['waterUsage'] as num).toDouble(),
      electricUsage: (json['electricUsage'] as num).toDouble(),
      lateFees: (json['lateFees'] as num?)?.toDouble() ?? 0.0,
      dueDate: DateTime.parse(json['dueDate'] as String),
      status: $enumDecodeNullable(_$InvoiceStatusEnumMap, json['status']) ??
          InvoiceStatus.pending,
      paidAt: json['paidAt'] == null
          ? null
          : DateTime.parse(json['paidAt'] as String),
    );

Map<String, dynamic> _$BillingInvoiceToJson(_BillingInvoice instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tenantId': instance.tenantId,
      'unitId': instance.unitId,
      'baseRent': instance.baseRent,
      'waterUsage': instance.waterUsage,
      'electricUsage': instance.electricUsage,
      'lateFees': instance.lateFees,
      'dueDate': instance.dueDate.toIso8601String(),
      'status': _$InvoiceStatusEnumMap[instance.status]!,
      'paidAt': instance.paidAt?.toIso8601String(),
    };

const _$InvoiceStatusEnumMap = {
  InvoiceStatus.pending: 'pending',
  InvoiceStatus.paid: 'paid',
  InvoiceStatus.overdue: 'overdue',
};
