// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PaymentData _$PaymentDataFromJson(Map<String, dynamic> json) => _PaymentData(
      id: json['id'] as String? ?? '',
      month: json['month'] as String? ?? 'Oct',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      method: json['method'] as String? ?? 'GCash',
      paymentMethod: json['paymentMethod'] as String? ?? 'GCash',
      date:
          json['date'] == null ? null : DateTime.parse(json['date'] as String),
      paymentDate: json['paymentDate'] == null
          ? null
          : DateTime.parse(json['paymentDate'] as String),
      status: json['status'] as String? ?? 'Paid',
      unitId: json['unitId'] as String? ?? 'u1',
      referenceNumber: json['referenceNumber'] as String? ?? '',
      baseRent: (json['baseRent'] as num?)?.toDouble() ?? 0.0,
      waterBill: (json['waterBill'] as num?)?.toDouble() ?? 0.0,
      electricBill: (json['electricBill'] as num?)?.toDouble() ?? 0.0,
      lateFee: (json['lateFee'] as num?)?.toDouble() ?? 0.0,
      otherCharge: (json['otherCharge'] as num?)?.toDouble() ?? 0.0,
      tenantName: json['tenantName'] as String? ?? 'Juan Dela Cruz',
      unitNumber: json['unitNumber'] as String? ?? 'Unit 1',
      tenantId: json['tenantId'] as String? ?? '',
      tenancyId: json['tenancyId'] as String?,
      proofImageUrl: json['proofImageUrl'] as String? ?? '',
      remarks: json['remarks'] as String?,
      declineReason: json['declineReason'] as String?,
      transactionType: json['transactionType'] as String? ?? 'Rent',
      ticketId: json['ticketId'] as String?,
    );

Map<String, dynamic> _$PaymentDataToJson(_PaymentData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'month': instance.month,
      'amount': instance.amount,
      'method': instance.method,
      'paymentMethod': instance.paymentMethod,
      'date': instance.date?.toIso8601String(),
      'paymentDate': instance.paymentDate?.toIso8601String(),
      'status': instance.status,
      'unitId': instance.unitId,
      'referenceNumber': instance.referenceNumber,
      'baseRent': instance.baseRent,
      'waterBill': instance.waterBill,
      'electricBill': instance.electricBill,
      'lateFee': instance.lateFee,
      'otherCharge': instance.otherCharge,
      'tenantName': instance.tenantName,
      'unitNumber': instance.unitNumber,
      'tenantId': instance.tenantId,
      'tenancyId': instance.tenancyId,
      'proofImageUrl': instance.proofImageUrl,
      'remarks': instance.remarks,
      'declineReason': instance.declineReason,
      'transactionType': instance.transactionType,
      'ticketId': instance.ticketId,
    };
