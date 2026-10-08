// lib/widgets/unit_tenant_card.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/state/ramp_state.dart';
import '../core/theme/ramp_theme.dart';
import '../core/widgets/ramp_icon.dart';

class UnitTenantCard extends StatelessWidget {
  final Tenant? tenant;
  final VoidCallback? onContactTenant;
  final VoidCallback? onAssignTenant;

  const UnitTenantCard({
    super.key,
    required this.tenant,
    this.onContactTenant,
    this.onAssignTenant,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (tenant == null) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: RampTheme.standardShadow,
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person_off_rounded, color: Colors.grey),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'No Active Tenant',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'This unit is currently vacant.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            if (onAssignTenant != null)
              ElevatedButton.icon(
                onPressed: onAssignTenant,
                icon: const Icon(Icons.person_add_rounded, size: 16),
                label: const Text('Assign'),
              ),
          ],
        ),
      );
    }

    final dateFmt = DateFormat('MMM dd, yyyy');

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
              CircleAvatar(
                radius: 24,
                backgroundColor: RampColors.softBlueTint,
                child: const RampIcon(assetName: 'tenant', size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tenant!.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      tenant!.email.isNotEmpty ? tenant!.email : tenant!.phone,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (onContactTenant != null)
                IconButton(
                  icon: const Icon(Icons.phone_rounded, color: RampColors.primary),
                  onPressed: onContactTenant,
                  tooltip: 'Contact Tenant',
                ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Lease Start: ${tenant!.leaseStart != null ? dateFmt.format(tenant!.leaseStart!) : "N/A"}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                'Lease End: ${tenant!.leaseEnd != null ? dateFmt.format(tenant!.leaseEnd!) : "N/A"}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
