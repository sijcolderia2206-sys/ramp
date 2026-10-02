// lib/core/widgets/role_guard.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/providers.dart';

/// Reusable Role Guard Widget that conditionally renders child widgets based on user roles
class RoleGuard extends ConsumerWidget {
  final List<UserRole> allowedRoles;
  final Widget child;
  final Widget? fallback;

  const RoleGuard({
    super.key,
    required this.allowedRoles,
    required this.child,
    this.fallback,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentRoleStr = ref.watch(currentRoleProvider);
    final currentRole = UserRole.fromString(currentRoleStr);

    if (allowedRoles.contains(currentRole)) {
      return child;
    }

    return fallback ?? const SizedBox.shrink();
  }
}
