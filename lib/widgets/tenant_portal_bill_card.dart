// lib/widgets/tenant_portal_bill_card.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/theme/ramp_theme.dart';
import '../core/widgets/ramp_icon.dart';

class TenantPortalBillCard extends StatelessWidget {
  final double baseRent;
  final double waterCharges;
  final double electricCharges;
  final double lateFees;
  final String dueDate;
  final bool isPaid;
  final VoidCallback onPayNow;

  const TenantPortalBillCard({
    super.key,
    required this.baseRent,
    required this.waterCharges,
    required this.electricCharges,
    required this.lateFees,
    required this.dueDate,
    required this.isPaid,
    required this.onPayNow,
  });

  static final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'en_PH',
    symbol: '₱',
    decimalDigits: 2,
  );

  double get totalAmount => baseRent + waterCharges + electricCharges + lateFees;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: RampTheme.standardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const RampIcon(assetName: 'receipt', size: 22),
                  const SizedBox(width: 8),
                  Text(
                    'Current Statement',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: (isPaid ? const Color(0xFF16A34A) : const Color(0xFFDC2626))
                      .withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isPaid ? 'PAID' : 'DUE SOON',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isPaid ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _ItemRow(label: 'Base Rent', amount: baseRent),
          _ItemRow(label: 'Water Usage (Submeter)', amount: waterCharges),
          _ItemRow(label: 'Electricity Usage (Submeter)', amount: electricCharges),
          if (lateFees > 0)
            _ItemRow(label: 'Late Fee / Penalties', amount: lateFees, isDeduction: false, color: RampColors.danger),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Amount Due',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    _currencyFormat.format(totalAmount),
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: RampColors.primary,
                    ),
                  ),
                ],
              ),
              if (!isPaid)
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: RampColors.primary,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                  ),
                  icon: const Icon(Icons.payment_rounded, size: 18),
                  label: const Text('Pay Now'),
                  onPressed: onPayNow,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ItemRow extends StatelessWidget {
  final String label;
  final double amount;
  final bool isDeduction;
  final Color? color;

  const _ItemRow({
    required this.label,
    required this.amount,
    this.isDeduction = false,
    this.color,
  });

  static final NumberFormat _fmt = NumberFormat.currency(
    locale: 'en_PH',
    symbol: '₱',
    decimalDigits: 2,
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          Text(
            _fmt.format(amount),
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
