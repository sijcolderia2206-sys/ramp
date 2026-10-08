// C:/Users/sijco/Downloads/ramp/ramp/ramp/lib/models/billing_model.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'billing_model.freezed.dart';
part 'billing_model.g.dart';

enum InvoiceStatus {
  @JsonValue('pending') pending,
  @JsonValue('paid') paid,
  @JsonValue('overdue') overdue,
}

@freezed
abstract class BillingInvoice with _$BillingInvoice {
  const factory BillingInvoice({
    required String id,
    required String tenantId,
    required String unitId,
    required double baseRent,
    required double waterUsage, // in cu.m
    required double electricUsage, // in kWh
    @Default(0.0) double lateFees,
    required DateTime dueDate,
    @Default(InvoiceStatus.pending) InvoiceStatus status,
    DateTime? paidAt,
  }) = _BillingInvoice;

  const BillingInvoice._();

  // Itemized Billing Engine Logic: 
  // Formula = Base Rent + Water Usage (PHP 45.00 per cu.m) + Electric Usage (PHP 12.50 per kWh) + Late Fees
  double get waterCost => waterUsage * 45.00;
  double get electricCost => electricUsage * 12.50;
  double get totalAmount => baseRent + waterCost + electricCost + lateFees;

  factory BillingInvoice.fromJson(Map<String, dynamic> json) => _$BillingInvoiceFromJson(json);
}
