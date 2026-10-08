// lib/widgets/tenant_portal_header.dart
import 'package:flutter/material.dart';
import '../core/state/ramp_state.dart';
import '../core/theme/ramp_theme.dart';
import '../core/widgets/ramp_icon.dart';

class TenantPortalHeader extends StatelessWidget {
  final Tenant? tenant;
  final Unit? unit;
  final VoidCallback? onProfileTap;

  const TenantPortalHeader({
    super.key,
    required this.tenant,
    required this.unit,
    this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final tenantName = tenant?.name ?? 'Tenant Portal';
    final unitName = unit != null ? 'Unit ${unit!.unitNumber}' : 'No Assigned Unit';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: RampTheme.standardShadow,
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: RampColors.softBlueTint,
            child: const RampIcon(assetName: 'tenant', size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome, $tenantName',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(Icons.home_work_outlined,
                        size: 14, color: RampColors.primary),
                    const SizedBox(width: 4),
                    Text(
                      unitName,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (onProfileTap != null)
            IconButton(
              icon: const Icon(Icons.person_outline_rounded),
              onPressed: onProfileTap,
              tooltip: 'My Profile',
            ),
        ],
      ),
    );
  }
}
