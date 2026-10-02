// lib/models/payment_data.dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:intl/intl.dart';

part 'payment_data.freezed.dart';
part 'payment_data.g.dart';

@freezed
abstract class PaymentData with _$PaymentData {
  const PaymentData._();

  const factory PaymentData({
    @Default('') String id,
    @Default('Oct') String month,
    @Default(0.0) double amount,
    @Default('GCash') String method,
    @Default('GCash') String paymentMethod,
    DateTime? date,
    DateTime? paymentDate,
    @Default('Paid') String status,
    @Default('u1') String unitId,
    @Default('') String referenceNumber,
    @Default(0.0) double baseRent,
    @Default(0.0) double waterBill,
    @Default(0.0) double electricBill,
    @Default(0.0) double lateFee,
    @Default(0.0) double otherCharge,
    @Default('Juan Dela Cruz') String tenantName,
    @Default('Unit 1') String unitNumber,
    @Default('') String tenantId,
    String? tenancyId,
    @Default('') String proofImageUrl,
    String? remarks,
    String? declineReason,
    @Default('Rent') String transactionType,
    String? ticketId,
  }) = _PaymentData;

  factory PaymentData.fromJson(Map<String, dynamic> json) =>
      _$PaymentDataFromJson(json);

  DateTime get effectivePaymentDate => paymentDate ?? date ?? DateTime.now();

  DateTime get effectiveDate => date ?? paymentDate ?? DateTime.now();

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
      DateFormat('MMM dd, yyyy • hh:mm a').format(effectivePaymentDate);

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
}
