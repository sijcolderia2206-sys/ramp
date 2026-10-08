// lib/widgets/tenant_card.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/state/ramp_state.dart';
import '../core/theme/ramp_theme.dart';
import '../core/widgets/ramp_icon.dart';

class TenantCard extends StatelessWidget {
  final Tenant tenant;
  final bool isExpanded;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onViewProfile;
  final VoidCallback? onSendReminder;

  const TenantCard({
    super.key,
    required this.tenant,
    required this.isExpanded,
    required this.onTap,
    required this.onEdit,
    required this.onViewProfile,
    this.onSendReminder,
  });

  static final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'en_PH',
    symbol: '₱',
    decimalDigits: 2,
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isAssigned = tenant.isAssigned;
    final balance = tenant.balance;
    final isOverdue = balance > 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: RampColors.softBlueTint,
                    child: const RampIcon(assetName: 'tenant', size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tenant.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isAssigned ? 'Unit ${tenant.unitNumber}' : 'Unassigned',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: (isOverdue ? const Color(0xFFDC2626) : const Color(0xFF16A34A))
                          .withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      isOverdue ? 'DUE: ${_currencyFormat.format(balance)}' : 'PAID',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isOverdue ? const Color(0xFFDC2626) : const Color(0xFF16A34A),
                      ),
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert_rounded, size: 20),
                    onSelected: (val) {
                      if (val == 'profile') onViewProfile();
                      if (val == 'edit') onEdit();
                      if (val == 'reminder' && onSendReminder != null) onSendReminder!();
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'profile',
                        child: Row(
                          children: [
                            Icon(Icons.person_outline_rounded, size: 18),
                            SizedBox(width: 8),
                            Text('View Profile'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit_outlined, size: 18),
                            SizedBox(width: 8),
                            Text('Edit Tenant'),
                          ],
                        ),
                      ),
                      if (isOverdue)
                        const PopupMenuItem(
                          value: 'reminder',
                          child: Row(
                            children: [
                              Icon(Icons.send_rounded, size: 18, color: RampColors.primary),
                              SizedBox(width: 8),
                              Text('Send Reminder'),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              if (isExpanded) ...[
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.phone_outlined, size: 14, color: RampColors.mutedText),
                    const SizedBox(width: 6),
                    Text(
                      tenant.phone.isNotEmpty ? tenant.phone : 'No phone',
                      style: theme.textTheme.bodySmall,
                    ),
                    const SizedBox(width: 16),
                    const Icon(Icons.email_outlined, size: 14, color: RampColors.mutedText),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        tenant.email.isNotEmpty ? tenant.email : 'No email',
                        style: theme.textTheme.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: onViewProfile,
                      icon: const Icon(Icons.badge_outlined, size: 16),
                      label: const Text('View Profile'),
                    ),
                    if (isOverdue && onSendReminder != null) ...[
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: RampColors.primary,
                        ),
                        onPressed: onSendReminder,
                        icon: const Icon(Icons.send_rounded, size: 16),
                        label: const Text('Send Reminder'),
                      ),
                    ],
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
