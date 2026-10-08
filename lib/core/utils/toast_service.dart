// lib/core/utils/toast_service.dart
import 'package:flutter/material.dart';

enum ToastType {
  success,
  error,
  info,
  warning,
}

class ToastService {
  /// Global scaffold messenger key used to trigger toasts from anywhere in the app without BuildContext.
  static final GlobalKey<ScaffoldMessengerState> scaffoldKey =
      GlobalKey<ScaffoldMessengerState>();

  /// Display a success toast
  static void showSuccess(String message, {String? actionLabel, VoidCallback? onAction}) {
    show(message: message, type: ToastType.success, actionLabel: actionLabel, onAction: onAction);
  }

  /// Display an error toast
  static void showError(String message, {String? actionLabel, VoidCallback? onAction}) {
    show(message: message, type: ToastType.error, actionLabel: actionLabel, onAction: onAction);
  }

  /// Display an informational toast
  static void showInfo(String message, {String? actionLabel, VoidCallback? onAction}) {
    show(message: message, type: ToastType.info, actionLabel: actionLabel, onAction: onAction);
  }

  /// Display a warning toast
  static void showWarning(String message, {String? actionLabel, VoidCallback? onAction}) {
    show(message: message, type: ToastType.warning, actionLabel: actionLabel, onAction: onAction);
  }

  /// Main method to present Material 3 styled floating toast notifications
  static void show({
    required String message,
    ToastType type = ToastType.info,
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = const Duration(seconds: 4),
  }) {
    final context = scaffoldKey.currentContext;
    final scaffoldState = scaffoldKey.currentState;
    if (scaffoldState == null) return;

    final theme = context != null ? Theme.of(context) : null;

    Color backgroundColor;
    Color foregroundColor;
    IconData icon;

    switch (type) {
      case ToastType.success:
        backgroundColor = theme?.colorScheme.primaryContainer ?? const Color(0xFFE0F2FE);
        foregroundColor = theme?.colorScheme.onPrimaryContainer ?? const Color(0xFF0369A1);
        icon = Icons.check_circle_rounded;
        break;
      case ToastType.error:
        backgroundColor = theme?.colorScheme.errorContainer ?? const Color(0xFFFEE2E2);
        foregroundColor = theme?.colorScheme.onErrorContainer ?? const Color(0xFF991B1B);
        icon = Icons.error_rounded;
        break;
      case ToastType.warning:
        backgroundColor = const Color(0xFFFEF3C7);
        foregroundColor = const Color(0xFF92400E);
        icon = Icons.warning_rounded;
        break;
      case ToastType.info:
        backgroundColor = theme?.colorScheme.surfaceContainerHigh ?? const Color(0xFFF1F5F9);
        foregroundColor = theme?.colorScheme.onSurfaceVariant ?? const Color(0xFF334155);
        icon = Icons.info_rounded;
        break;
    }

    scaffoldState
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          elevation: 4,
          backgroundColor: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          content: Row(
            children: [
              Icon(icon, color: foregroundColor, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(
                    color: foregroundColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (actionLabel != null && onAction != null) ...[
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () {
                    scaffoldState.hideCurrentSnackBar();
                    onAction();
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    foregroundColor: foregroundColor,
                  ),
                  child: Text(
                    actionLabel,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ],
          ),
          duration: duration,
        ),
      );
  }
}

/// Extension on BuildContext for quick and clean access inside widget build trees
extension ToastContextExtension on BuildContext {
  void showSuccessToast(String message) => ToastService.showSuccess(message);
  void showErrorToast(String message) => ToastService.showError(message);
  void showInfoToast(String message) => ToastService.showInfo(message);
  void showWarningToast(String message) => ToastService.showWarning(message);
}
