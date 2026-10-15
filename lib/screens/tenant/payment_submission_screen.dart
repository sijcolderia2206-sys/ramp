// lib/screens/tenant/payment_submission_screen.dart
import 'package:flutter/material.dart';
import 'tenant_payments_screen.dart';

/// Legacy export/alias for TenantPaymentsScreen
class PaymentSubmissionScreen extends StatelessWidget {
  const PaymentSubmissionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const TenantPaymentsScreen();
  }
}
