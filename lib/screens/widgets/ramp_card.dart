// C:/Users/sijco/Downloads/ramp/ramp/ramp/lib/screens/widgets/ramp_card.dart
import 'package:flutter/material.dart';
import '../../core/theme/ramp_theme.dart';

/// The standard white card used across the RAMP platform.
/// Features a pure white background and a standardized soft drop shadow.
class RampCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;

  const RampCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      padding: padding ?? const EdgeInsets.all(RampTheme.spacing16),
      decoration: BoxDecoration(
        color: RampTheme.cardBackground,
        borderRadius: BorderRadius.circular(12),
        boxShadow: RampTheme.standardShadow,
      ),
      child: cardWidget(context),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: card,
      );
    }
    
    return card;
  }

  Widget cardWidget(BuildContext context) => child;
}
