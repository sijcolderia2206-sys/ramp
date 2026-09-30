import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CompactInfoGrid extends StatelessWidget {
  const CompactInfoGrid({
    super.key,
    required this.items,
    this.columnSpacing = 14,
    this.rowSpacing = 8,
  });

  final List<CompactInfoItem> items;
  final double columnSpacing;
  final double rowSpacing;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 360 ? 2 : 1;
        final itemWidth =
            (constraints.maxWidth - columnSpacing * (columns - 1)) / columns;

        return Wrap(
          spacing: columnSpacing,
          runSpacing: rowSpacing,
          children: items
              .map(
                (item) => SizedBox(
                  width: itemWidth,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (item.icon != null) ...[
                        Icon(
                          item.icon,
                          size: 16,
                          color: item.color ??
                              Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 6),
                      ],
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                            ),
                            Text(
                              item.value,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: item.valueColor ??
                                    Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class CompactInfoItem {
  const CompactInfoItem({
    required this.label,
    required this.value,
    this.icon,
    this.color,
    this.valueColor,
  });

  final String label;
  final String value;
  final IconData? icon;
  final Color? color;
  final Color? valueColor;
}
