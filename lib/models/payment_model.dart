// lib/models/payment_model.dart

import '../core/utils/safe_parse.dart';

class PaymentRecord {
  final String id;
  final String landlordId;
  final String unitId;
  final String? tenantId;
  final String? tenantName;
  final String? unitNumber;
  final double amount;
  final double baseRent;
  final double waterBill;
  final double electricBill;
  final double lateFee;
  final DateTime paymentDate;
  final String paymentMethod; // 'GCash', 'Maya', 'Bank Transfer', 'Cash'
  final String referenceNumber;
  final String status; // 'Paid', 'Pending', 'Declined'
  final String transactionType; // 'Rent', 'Maintenance'
  final String? proofImageUrl;
  final String? remarks;
  final String? ticketId;

  const PaymentRecord({
    required this.id,
    this.landlordId = 'l1',
    required this.unitId,
    this.tenantId,
    this.tenantName,
    this.unitNumber,
    required this.amount,
    this.baseRent = 0.0,
    this.waterBill = 0.0,
    this.electricBill = 0.0,
    this.lateFee = 0.0,
    required this.paymentDate,
    required this.paymentMethod,
    required this.referenceNumber,
    this.status = 'Paid',
    this.transactionType = 'Rent',
    this.proofImageUrl,
    this.remarks,
    this.ticketId,
  });

  PaymentRecord copyWith({
    String? id,
    String? landlordId,
    String? unitId,
    String? tenantId,
    String? tenantName,
    String? unitNumber,
    double? amount,
    double? baseRent,
    double? waterBill,
    double? electricBill,
    double? lateFee,
    DateTime? paymentDate,
    String? paymentMethod,
    String? referenceNumber,
    String? status,
    String? transactionType,
    String? proofImageUrl,
    String? remarks,
    String? ticketId,
  }) {
    return PaymentRecord(
      id: id ?? this.id,
      landlordId: landlordId ?? this.landlordId,
      unitId: unitId ?? this.unitId,
      tenantId: tenantId ?? this.tenantId,
      tenantName: tenantName ?? this.tenantName,
      unitNumber: unitNumber ?? this.unitNumber,
      amount: amount ?? this.amount,
      baseRent: baseRent ?? this.baseRent,
      waterBill: waterBill ?? this.waterBill,
      electricBill: electricBill ?? this.electricBill,
      lateFee: lateFee ?? this.lateFee,
      paymentDate: paymentDate ?? this.paymentDate,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      referenceNumber: referenceNumber ?? this.referenceNumber,
      status: status ?? this.status,
      transactionType: transactionType ?? this.transactionType,
      proofImageUrl: proofImageUrl ?? this.proofImageUrl,
      remarks: remarks ?? this.remarks,
      ticketId: ticketId ?? this.ticketId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'landlord_id': landlordId,
      'unit_id': unitId,
      'tenant_id': tenantId,
      'tenant_name': tenantName,
      'unit_number': unitNumber,
      'amount': amount,
      'base_rent': baseRent,
      'water_bill': waterBill,
      'electric_bill': electricBill,
      'late_fee': lateFee,
      'payment_date': paymentDate.toIso8601String(),
      'payment_method': paymentMethod,
      'reference_number': referenceNumber,
      'status': status,
      'transaction_type': transactionType,
      'proof_image_url': proofImageUrl,
      'remarks': remarks,
      'ticket_id': ticketId,
    };
  }

  factory PaymentRecord.fromJson(Map<String, dynamic> json) {
    return PaymentRecord(
      id: parseString(json['id'], 'pay_${DateTime.now().millisecondsSinceEpoch}'),
      landlordId: parseString(json['landlord_id'], 'l1'),
      unitId: parseString(json['unit_id']),
      tenantId: parseNullableString(json['tenant_id']),
      tenantName: parseNullableString(json['tenant_name']),
      unitNumber: parseNullableString(json['unit_number']),
      amount: parseDouble(json['amount']),
      baseRent: parseDouble(json['base_rent']),
      waterBill: parseDouble(json['water_bill']),
      electricBill: parseDouble(json['electric_bill']),
      lateFee: parseDouble(json['late_fee']),
      paymentDate: parseDateTime(json['payment_date'] ?? json['date']),
      paymentMethod: parseString(json['payment_method'] ?? json['method'], 'GCash'),
      referenceNumber: parseString(json['reference_number'], 'REF-000'),
      status: parseString(json['status'], 'Paid'),
      transactionType: parseString(json['transaction_type'], 'Rent'),
      proofImageUrl: parseNullableString(json['proof_image_url']),
      remarks: parseNullableString(json['remarks']),
      ticketId: parseNullableString(json['ticket_id']),
    );
  }
}
