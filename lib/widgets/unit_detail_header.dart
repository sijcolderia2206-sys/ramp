// lib/widgets/unit_detail_header.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/state/ramp_state.dart';
import '../core/theme/ramp_theme.dart';
import '../core/widgets/ramp_icon.dart';

class UnitDetailHeader extends StatelessWidget {
  final Unit unit;
  final String propertyName;
  final VoidCallback? onEditUnit;

  const UnitDetailHeader({
    super.key,
    required this.unit,
    required this.propertyName,
    this.onEditUnit,
  });

  static final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'en_PH',
    symbol: '₱',
    decimalDigits: 2,
  );

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'occupied':
        return const Color(0xFF16A34A);
      case 'vacant':
        return const Color(0xFF0284C7);
      case 'maintenance':
        return const Color(0xFFD97706);
      default:
        return RampColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final statusColor = _getStatusColor(unit.status);

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
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: RampColors.softBlueTint,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: RampIcon(assetName: 'unit', size: 28),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Unit ${unit.unitNumber}',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            unit.status.toUpperCase(),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: statusColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      propertyName,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (onEditUnit != null)
                IconButton(
                  icon: const Icon(Icons.edit_rounded),
                  onPressed: onEditUnit,
                  tooltip: 'Edit Unit',
                ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Monthly Base Rent',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    _currencyFormat.format(unit.monthlyRent),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: RampColors.primary,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  _MeterChip(
                    icon: Icons.water_drop_rounded,
                    label: '${unit.waterReadingCurr} m³',
                    color: const Color(0xFF0284C7),
                  ),
                  const SizedBox(width: 8),
                  _MeterChip(
                    icon: Icons.bolt_rounded,
                    label: '${unit.electricReadingCurr} kWh',
                    color: const Color(0xFFD97706),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MeterChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _MeterChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
