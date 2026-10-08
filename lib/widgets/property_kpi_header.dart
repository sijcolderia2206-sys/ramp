// lib/widgets/property_kpi_header.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/theme/ramp_theme.dart';
import '../core/widgets/ramp_icon.dart';

class PropertyKpiHeader extends StatelessWidget {
  final int totalProperties;
  final int totalUnits;
  final int occupiedUnits;
  final double totalMonthlyRevenue;

  const PropertyKpiHeader({
    super.key,
    required this.totalProperties,
    required this.totalUnits,
    required this.occupiedUnits,
    required this.totalMonthlyRevenue,
  });

  static final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'en_PH',
    symbol: '₱',
    decimalDigits: 0,
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final occupancyRate =
        totalUnits > 0 ? ((occupiedUnits / totalUnits) * 100).round() : 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: RampTheme.standardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const RampIcon(assetName: 'property', size: 24),
              const SizedBox(width: 8),
              Text(
                'Portfolio Overview',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _KpiItem(
                  label: 'Properties',
                  value: '$totalProperties',
                  icon: Icons.apartment_rounded,
                  color: RampColors.primary,
                ),
              ),
              Expanded(
                child: _KpiItem(
                  label: 'Units',
                  value: '$totalUnits',
                  icon: Icons.meeting_room_rounded,
                  color: const Color(0xFF0284C7),
                ),
              ),
              Expanded(
                child: _KpiItem(
                  label: 'Occupancy',
                  value: '$occupancyRate%',
                  icon: Icons.pie_chart_rounded,
                  color: const Color(0xFF16A34A),
                ),
              ),
              Expanded(
                child: _KpiItem(
                  label: 'Est. Revenue',
                  value: _currencyFormat.format(totalMonthlyRevenue),
                  icon: Icons.payments_rounded,
                  color: const Color(0xFFD97706),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _KpiItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _KpiItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            fontSize: 10,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
