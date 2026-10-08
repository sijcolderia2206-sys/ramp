// lib/widgets/maintenance_filter_bar.dart
import 'package:flutter/material.dart';
import '../core/theme/ramp_theme.dart';
import '../core/widgets/ramp_icon.dart';

class MaintenanceFilterBar extends StatelessWidget {
  final TextEditingController searchController;
  final String selectedFilter;
  final List<String> filters;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onFilterSelected;

  const MaintenanceFilterBar({
    super.key,
    required this.searchController,
    required this.selectedFilter,
    required this.filters,
    required this.onSearchChanged,
    required this.onFilterSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      children: [
        // Search Bar
        TextField(
          controller: searchController,
          onChanged: onSearchChanged,
          decoration: InputDecoration(
            hintText: 'Search tickets by title, unit, or tenant...',
            prefixIcon: const Padding(
              padding: EdgeInsets.all(12.0),
              child: RampIcon(assetName: 'search', size: 20),
            ),
            suffixIcon: searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear_rounded, size: 18),
                    onPressed: () {
                      searchController.clear();
                      onSearchChanged('');
                    },
                  )
                : null,
            filled: true,
            fillColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Horizontal Category Filter List
        SizedBox(
          height: 38,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: filters.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final filter = filters[index];
              final isSelected = filter == selectedFilter;

              return ChoiceChip(
                label: Text(filter),
                selected: isSelected,
                selectedColor: RampColors.primary,
                backgroundColor: isDark
                    ? const Color(0xFF1E293B)
                    : const Color(0xFFF1F5F9),
                labelStyle: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected
                      ? Colors.white
                      : (isDark ? Colors.white : const Color(0xFF1E293B)),
                ),
                checkmarkColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                side: BorderSide(
                  color: isSelected
                      ? RampColors.primary
                      : (isDark
                          ? const Color(0xFF334155)
                          : const Color(0xFFCBD5E1)),
                ),
                onSelected: (_) => onFilterSelected(filter),
              );
            },
          ),
        ),
      ],
    );
  }
}
