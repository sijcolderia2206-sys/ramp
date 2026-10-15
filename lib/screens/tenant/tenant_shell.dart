// lib/screens/tenant/tenant_shell.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../theme.dart';
import '../../widgets/neumorphic_widgets.dart';
import '../../providers/tenant_providers.dart';
import '../../core/supabase_auth_service.dart';
import 'tenant_dashboard_screen.dart';
import 'tenant_payments_screen.dart';
import 'maintenance_repairs_screen.dart';
import 'tenant_profile_screen.dart';

class TenantShell extends ConsumerStatefulWidget {
  const TenantShell({super.key});

  @override
  ConsumerState<TenantShell> createState() => _TenantShellState();
}

class _TenantShellState extends ConsumerState<TenantShell> {
  int _selectedIndex = 0;
  final SupabaseAuthService _authService = SupabaseAuthService();

  void _onTabSelected(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final tenant = ref.watch(currentTenantProvider);

    if (tenant == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFE0E5EC),
        appBar: AppBar(
          backgroundColor: const Color(0xFFE0E5EC),
          title: const Text('RAMP Tenant Portal'),
          actions: [
            IconButton(
              tooltip: 'Sign Out',
              icon: const Icon(Icons.logout, color: RampTheme.textPrimary),
              onPressed: () async {
                await _authService.signOut();
                if (context.mounted) context.go('/login');
              },
            ),
          ],
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: NeumorphicContainer(
              borderRadius: 20,
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.info_outline, size: 56, color: RampTheme.primaryBlue),
                  const SizedBox(height: 16),
                  const Text(
                    'No Active Tenant Account Found',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: RampTheme.textPrimary),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Please contact your landlord to assign your account to an active unit lease.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: RampTheme.textSecondary),
                  ),
                  const SizedBox(height: 20),
                  NeumorphicButton(
                    label: 'Return to Login',
                    icon: Icons.logout,
                    onPressed: () async {
                      await _authService.signOut();
                      if (context.mounted) context.go('/login');
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final pages = [
      TenantDashboardScreen(
        onNavigateToPay: () => _onTabSelected(1),
        onNavigateToRepairs: () => _onTabSelected(2),
        onNavigateToProfile: () => _onTabSelected(3),
      ),
      const TenantPaymentsScreen(),
      const MaintenanceRepairsScreen(),
      const TenantProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFE0E5EC),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: IndexedStack(
            index: _selectedIndex,
            children: pages,
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFE0E5EC),
          boxShadow: [
            BoxShadow(
              color: Colors.white,
              offset: Offset(0, -2),
              blurRadius: 4,
            ),
            BoxShadow(
              color: Color(0xFFA3B1C6),
              offset: Offset(0, 2),
              blurRadius: 4,
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  index: 0,
                  label: 'Home',
                  iconPath: 'assets/icons/dashboard.svg',
                  fallbackIcon: Icons.home_rounded,
                ),
                _buildNavItem(
                  index: 1,
                  label: 'Payments',
                  iconPath: 'assets/icons/payment.svg',
                  fallbackIcon: Icons.payments_rounded,
                ),
                _buildNavItem(
                  index: 2,
                  label: 'Repairs',
                  iconPath: 'assets/icons/wrench.svg',
                  fallbackIcon: Icons.build_rounded,
                ),
                _buildNavItem(
                  index: 3,
                  label: 'Profile',
                  iconPath: 'assets/icons/tenant.svg',
                  fallbackIcon: Icons.person_rounded,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required String label,
    required String iconPath,
    required IconData fallbackIcon,
  }) {
    final isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () => _onTabSelected(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: isSelected
            ? NeumorphicDecoration.inset(
                borderRadius: 16,
                color: RampTheme.primaryBlue.withValues(alpha: 0.12),
              )
            : NeumorphicDecoration.convex(
                borderRadius: 16,
                color: const Color(0xFFE0E5EC),
              ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Builder(
              builder: (context) {
                try {
                  return SvgPicture.asset(
                    iconPath,
                    width: 20,
                    height: 20,
                    colorFilter: ColorFilter.mode(
                      isSelected ? RampTheme.primaryBlue : RampTheme.textSecondary,
                      BlendMode.srcIn,
                    ),
                  );
                } catch (_) {
                  return Icon(
                    fallbackIcon,
                    size: 20,
                    color: isSelected ? RampTheme.primaryBlue : RampTheme.textSecondary,
                  );
                }
              },
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? RampTheme.primaryBlue : RampTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
