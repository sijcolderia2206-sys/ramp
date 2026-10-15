// lib/screens/landlord/payment_details_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../theme.dart';
import '../../models/payment_model.dart';
import '../../providers/landlord_providers.dart';

class PaymentDetailsScreen extends ConsumerWidget {
  final String paymentId;

  const PaymentDetailsScreen({super.key, required this.paymentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final payments = ref.watch(paymentsProvider);
    final currencyFormat = NumberFormat.currency(symbol: '₱', decimalDigits: 2);

    final PaymentRecord payment = payments.firstWhere(
      (p) => p.id == paymentId || p.referenceNumber.toLowerCase() == paymentId.toLowerCase(),
      orElse: () => PaymentRecord(
        id: paymentId,
        unitId: 'u101',
        unitNumber: '101',
        tenantName: 'Unknown Tenant',
        amount: 0.0,
        paymentDate: DateTime.now(),
        paymentMethod: 'GCash',
        referenceNumber: paymentId,
        status: 'Unknown',
      ),
    );

    final isPaid = payment.status == 'Paid';
    final isPending = payment.status == 'Pending';

    return Scaffold(
      appBar: AppBar(
        title: Text('Payment #${payment.id}'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(RampTheme.spacing20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status & Amount Card
            Container(
              padding: const EdgeInsets.all(RampTheme.spacing20),
              decoration: BoxDecoration(
                color: RampTheme.cardBackground,
                borderRadius: BorderRadius.circular(20),
                boxShadow: RampTheme.standardShadow,
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isPaid
                              ? RampTheme.successGreen.withValues(alpha: 0.1)
                              : isPending
                                  ? RampTheme.warningYellow.withValues(alpha: 0.15)
                                  : RampTheme.errorRed.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          payment.status,
                          style: TextStyle(
                            color: isPaid
                                ? RampTheme.successGreen
                                : isPending
                                    ? RampTheme.warningYellow
                                    : RampTheme.errorRed,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      Text(
                        DateFormat('MMM d, yyyy • h:mm a').format(payment.paymentDate),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: RampTheme.spacing16),
                  Text(
                    currencyFormat.format(payment.amount),
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: RampTheme.primaryBlue,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${payment.transactionType} Payment',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: RampTheme.textSecondary,
                        ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: RampTheme.spacing20),

            // Payment Metadata
            Container(
              padding: const EdgeInsets.all(RampTheme.spacing20),
              decoration: BoxDecoration(
                color: RampTheme.cardBackground,
                borderRadius: BorderRadius.circular(20),
                boxShadow: RampTheme.standardShadow,
              ),
              child: Column(
                children: [
                  _DetailRow(label: 'Tenant Name', value: payment.tenantName ?? 'N/A'),
                  const Divider(),
                  _DetailRow(label: 'Unit Number', value: 'Unit ${payment.unitNumber ?? "N/A"}'),
                  const Divider(),
                  _DetailRow(label: 'Payment Method', value: payment.paymentMethod),
                  const Divider(),
                  _DetailRow(label: 'Reference No.', value: payment.referenceNumber),
                  if (payment.remarks != null && payment.remarks!.isNotEmpty) ...[
                    const Divider(),
                    _DetailRow(label: 'Remarks', value: payment.remarks!),
                  ],
                ],
              ),
            ),

            const SizedBox(height: RampTheme.spacing20),

            // Itemized Breakdown
            if (payment.baseRent > 0 || payment.waterBill > 0 || payment.electricBill > 0 || payment.lateFee > 0)
              Container(
                padding: const EdgeInsets.all(RampTheme.spacing20),
                decoration: BoxDecoration(
                  color: RampTheme.cardBackground,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: RampTheme.standardShadow,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Itemized Breakdown',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: RampTheme.spacing12),
                    if (payment.baseRent > 0)
                      _DetailRow(label: 'Base Rent', value: currencyFormat.format(payment.baseRent)),
                    if (payment.waterBill > 0)
                      _DetailRow(label: 'Water Bill', value: currencyFormat.format(payment.waterBill)),
                    if (payment.electricBill > 0)
                      _DetailRow(label: 'Electric Bill', value: currencyFormat.format(payment.electricBill)),
                    if (payment.lateFee > 0)
                      _DetailRow(label: 'Late Fee', value: currencyFormat.format(payment.lateFee)),
                  ],
                ),
              ),

            if (isPending) ...[
              const SizedBox(height: RampTheme.spacing24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: RampTheme.errorRed,
                        side: const BorderSide(color: RampTheme.errorRed),
                      ),
                      onPressed: () {
                        ref.read(paymentsProvider.notifier).verifyPayment(payment.id, false);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Payment proof declined.')),
                        );
                        context.pop();
                      },
                      child: const Text('Decline Payment'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: RampTheme.successGreen),
                      onPressed: () {
                        ref.read(paymentsProvider.notifier).verifyPayment(payment.id, true);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Payment verified & balance credited!')),
                        );
                        context.pop();
                      },
                      child: const Text('Approve Payment'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
