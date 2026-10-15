// lib/widgets/ramp_toast.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';

enum RampToastType { success, error, warning, info }

/// Universal Toast Notification system for RAMP
/// Features M3 design tokens, smooth animations, and neumorphic elevation.
class RampToast {
  static void showSuccess(
    BuildContext context, {
    required String message,
    String? title,
    Duration duration = const Duration(seconds: 3),
  }) {
    show(
      context,
      message: message,
      title: title ?? 'Success',
      type: RampToastType.success,
      duration: duration,
    );
  }

  static void showError(
    BuildContext context, {
    required String message,
    String? title,
    Duration duration = const Duration(seconds: 4),
  }) {
    show(
      context,
      message: message,
      title: title ?? 'Error',
      type: RampToastType.error,
      duration: duration,
    );
  }

  static void showWarning(
    BuildContext context, {
    required String message,
    String? title,
    Duration duration = const Duration(seconds: 3),
  }) {
    show(
      context,
      message: message,
      title: title ?? 'Attention',
      type: RampToastType.warning,
      duration: duration,
    );
  }

  static void showInfo(
    BuildContext context, {
    required String message,
    String? title,
    Duration duration = const Duration(seconds: 3),
  }) {
    show(
      context,
      message: message,
      title: title ?? 'Notice',
      type: RampToastType.info,
      duration: duration,
    );
  }

  static void show(
    BuildContext context, {
    required String message,
    required String title,
    required RampToastType type,
    Duration duration = const Duration(seconds: 3),
  }) {
    final overlayState = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) {
        return _ToastWidget(
          title: title,
          message: message,
          type: type,
          onDismiss: () {
            if (overlayEntry.mounted) {
              overlayEntry.remove();
            }
          },
        );
      },
    );

    overlayState.insert(overlayEntry);

    Future.delayed(duration, () {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
      }
    });
  }
}

class _ToastWidget extends StatelessWidget {
  final String title;
  final String message;
  final RampToastType type;
  final VoidCallback onDismiss;

  const _ToastWidget({
    required this.title,
    required this.message,
    required this.type,
    required this.onDismiss,
  });

  Color get _accentColor {
    switch (type) {
      case RampToastType.success:
        return RampTheme.successGreen;
      case RampToastType.error:
        return RampTheme.errorRed;
      case RampToastType.warning:
        return RampTheme.warningYellow;
      case RampToastType.info:
        return RampTheme.primaryBlue;
    }
  }

  IconData get _icon {
    switch (type) {
      case RampToastType.success:
        return Icons.check_circle_rounded;
      case RampToastType.error:
        return Icons.error_rounded;
      case RampToastType.warning:
        return Icons.warning_amber_rounded;
      case RampToastType.info:
        return Icons.info_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top + 12;

    return Positioned(
      top: topPadding,
      left: 16,
      right: 16,
      child: Material(
        color: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1F000000),
                blurRadius: 16,
                offset: Offset(0, 8),
              ),
            ],
            border: Border.all(
              color: _accentColor.withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: IntrinsicHeight(
              child: Row(
                children: [
                  Container(
                    width: 6,
                    color: _accentColor,
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _accentColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(_icon, color: _accentColor, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            title,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: RampTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            message,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: RampTheme.textSecondary,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 18, color: RampTheme.textSecondary),
                    onPressed: onDismiss,
                  ),
                  const SizedBox(width: 4),
                ],
              ),
            ),
          ),
        )
            .animate()
            .slideY(begin: -0.5, end: 0, duration: 250.ms, curve: Curves.easeOutCubic)
            .fadeIn(duration: 200.ms),
      ),
    );
  }
}
