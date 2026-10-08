// lib/widgets/property_card.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/property_model.dart';
import '../core/state/ramp_state.dart';
import '../core/theme/ramp_theme.dart';
import '../core/widgets/ramp_icon.dart';

class PropertyCard extends StatelessWidget {
  final Property property;
  final List<Unit> units;
  final VoidCallback onTap;
  final VoidCallback onAddUnit;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const PropertyCard({
    super.key,
    required this.property,
    required this.units,
    required this.onTap,
    required this.onAddUnit,
    required this.onEdit,
    required this.onDelete,
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
    final totalUnits = units.length;
    final occupiedUnits =
        units.where((u) => u.status.toLowerCase() == 'occupied').length;
    final occupancyPct = totalUnits > 0 ? (occupiedUnits / totalUnits) : 0.0;
    final totalRevenue = units.fold(0.0, (sum, u) => sum + u.monthlyRent);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: RampTheme.standardShadow,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: RampColors.softBlueTint,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: RampIcon(assetName: 'property', size: 24),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          property.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            const Icon(Icons.location_on_outlined,
                                size: 14, color: RampColors.mutedText),
                            const SizedBox(width: 2),
                            Expanded(
                              child: Text(
                                property.address,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert_rounded, size: 20),
                    onSelected: (val) {
                      if (val == 'add') onAddUnit();
                      if (val == 'edit') onEdit();
                      if (val == 'delete') onDelete();
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'add',
                        child: Row(
                          children: [
                            Icon(Icons.add_circle_outline, size: 18),
                            SizedBox(width: 8),
                            Text('Add Unit'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit_outlined, size: 18),
                            SizedBox(width: 8),
                            Text('Edit Property'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline,
                                size: 18, color: RampColors.danger),
                            SizedBox(width: 8),
                            Text('Delete',
                                style: TextStyle(color: RampColors.danger)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Occupancy Progress Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Occupancy ($occupiedUnits/$totalUnits units)',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${(occupancyPct * 100).round()}%',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: RampColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: occupancyPct,
                  minHeight: 8,
                  backgroundColor: isDark
                      ? const Color(0xFF334155)
                      : const Color(0xFFE2E8F0),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                      RampColors.primary),
                ),
              ),
              const SizedBox(height: 12),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Monthly Potential: ${_currencyFormat.format(totalRevenue)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: onAddUnit,
                    icon: const Icon(Icons.add_rounded, size: 16),
                    label: const Text('Add Unit',
                        style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
