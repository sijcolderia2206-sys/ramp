import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/ramp_theme.dart';

class SidebarMenu extends ConsumerWidget {
  final int currentIndex;
  final ValueChanged<int> onItemSelected;

  const SidebarMenu({
    super.key,
    required this.currentIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final items = const [
      _SidebarItem(icon: Icons.home_rounded, label: 'Home', index: 0),
      _SidebarItem(icon: Icons.apartment_rounded, label: 'Units', index: 1),
      _SidebarItem(icon: Icons.people_alt_rounded, label: 'Tenants', index: 2),
      _SidebarItem(icon: Icons.build_rounded, label: 'Repairs', index: 3),
      _SidebarItem(icon: Icons.person_rounded, label: 'Profile', index: 4),
    ];

    return Container(
      width: 260,
      color: isDark ? const Color(0xFF1E293B) : Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: RampColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.apartment_rounded,
                    color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              Text(
                'RAMP',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Expanded(
            child: ListView.separated(
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final item = items[index];
                final isSelected = currentIndex == item.index;

                return InkWell(
                  onTap: () => onItemSelected(item.index),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? RampColors.primary.withValues(alpha: 0.12)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          item.icon,
                          color: isSelected
                              ? RampColors.primary
                              : theme.iconTheme.color,
                          size: 22,
                        ),
                        const SizedBox(width: 16),
                        Text(
                          item.label,
                          style: TextStyle(
                            color: isSelected
                                ? RampColors.primary
                                : theme.textTheme.bodyMedium?.color,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarItem {
  final IconData icon;
  final String label;
  final int index;

  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.index,
  });
}
