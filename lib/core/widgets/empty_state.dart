import 'package:flutter/material.dart';
import '../theme/ramp_theme.dart';
import 'bouncing_interactive.dart';

/// Reusable Empty State Widget with Big Icon + Text + CTA Button with Icon
class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? buttonText;
  final VoidCallback? onButtonPressed;
  final IconData? buttonIcon;
  final Color? iconColor;
  final EdgeInsetsGeometry padding;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.buttonText,
    this.onButtonPressed,
    this.buttonIcon,
    this.iconColor,
    this.padding = const EdgeInsets.all(24.0),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final effectiveIconColor = iconColor ?? RampColors.primary;

    return Center(
      child: Padding(
        padding: padding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Big Icon Container
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: effectiveIconColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
                border: Border.all(
                  color: effectiveIconColor.withValues(alpha: 0.25),
                  width: 1.5,
                ),
              ),
              child: Center(
                child: Icon(
                  icon,
                  size: 52,
                  color: effectiveIconColor,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Title Text
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: isDark ? Colors.white : RampColors.slate,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            // Message / Description Text
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark ? const Color(0xFF94A3B8) : RampColors.mutedText,
                fontSize: 13,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),

            // CTA Button with Icon
            if (buttonText != null && onButtonPressed != null) ...[
              const SizedBox(height: 24),
              BouncePillButton(
                text: buttonText!,
                icon: buttonIcon ?? Icons.add_rounded,
                height: 48,
                backgroundColor: RampColors.primary,
                onPressed: onButtonPressed,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Convenience Alias
typedef EmptyState = EmptyStateWidget;

/// Reusable Error State Widget showing Error Icon + "Retry" Button
class ErrorStateWidget extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback onRetry;
  final String buttonText;
  final IconData buttonIcon;

  const ErrorStateWidget({
    super.key,
    this.title = 'Oops! Something went wrong',
    required this.message,
    required this.onRetry,
    this.buttonText = 'Retry',
    this.buttonIcon = Icons.refresh_rounded,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      icon: Icons.error_outline_rounded,
      iconColor: RampColors.danger,
      title: title,
      message: message,
      buttonText: buttonText,
      buttonIcon: buttonIcon,
      onButtonPressed: onRetry,
    );
  }
}

/// Convenience Alias
typedef ErrorState = ErrorStateWidget;
