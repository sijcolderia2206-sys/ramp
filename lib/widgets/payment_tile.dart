// lib/widgets/payment_tile.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/state/ramp_state.dart';
import '../core/theme/ramp_theme.dart';
import '../core/widgets/ramp_icon.dart';

class PaymentTile extends StatelessWidget {
  final PaymentData payment;
  final VoidCallback onTap;
  final VoidCallback? onViewReceipt;

  const PaymentTile({
    super.key,
    required this.payment,
    required this.onTap,
    this.onViewReceipt,
  });

  static final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'en_PH',
    symbol: '₱',
    decimalDigits: 2,
  );

  Color _getMethodColor(String method) {
    final m = method.toLowerCase();
    if (m.contains('gcash')) return const Color(0xFF007CFF);
    if (m.contains('maya')) return const Color(0xFF00B0FF);
    if (m.contains('bank')) return const Color(0xFF8B5CF6);
    if (m.contains('cash')) return const Color(0xFF10B981);
    return RampColors.primary;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isVerified = payment.status.toLowerCase() == 'verified' || payment.status.toLowerCase() == 'paid';
    final methodColor = _getMethodColor(payment.method);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: RampTheme.standardShadow,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        onTap: onTap,
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: methodColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: RampIcon(
              assetName: 'payment',
              size: 20,
              color: methodColor,
            ),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                payment.tenantName.isNotEmpty ? payment.tenantName : 'Unit ${payment.unitNumber}',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              _currencyFormat.format(payment.amount),
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: isVerified ? const Color(0xFF16A34A) : const Color(0xFFD97706),
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: methodColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    payment.method,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: methodColor,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  DateFormat('MMM dd, yyyy').format(payment.effectivePaymentDate),
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 11,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: (isVerified ? const Color(0xFF16A34A) : const Color(0xFFD97706))
                        .withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    isVerified ? 'Verified' : 'Pending',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isVerified ? const Color(0xFF16A34A) : const Color(0xFFD97706),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
