// lib/core/router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../core/theme/ramp_theme.dart';
import '../core/state/ramp_state.dart';

// Import Screens
import '../screens/login_screen.dart';
import '../screens/landlord/landlord_dashboard.dart';
import '../screens/tenant/tenant_dashboard.dart';
import '../screens/properties_screen.dart';
import '../screens/maintenance_screen.dart';

// Settings Screens
import '../features/settings/settings_screen.dart';
import '../features/settings/sub_screens/account_settings_screen.dart';
import '../features/settings/sub_screens/billing_rules_settings_screen.dart';
import '../features/settings/sub_screens/security_settings_screen.dart';
import '../features/settings/sub_screens/notification_settings_screen.dart';
import '../features/settings/sub_screens/appearance_settings_screen.dart';
import '../features/settings/sub_screens/data_settings_screen.dart';
import '../features/settings/sub_screens/about_settings_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final goRouterProvider = Provider<GoRouter>((ref) {
  // Listen to currentUserProvider directly
  final authNotifier = ValueNotifier<RampUser?>(null);

  ref.listen<RampUser?>(currentUserProvider, (_, next) {
    authNotifier.value = next;
  });

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/login',
    refreshListenable: authNotifier,
    redirect: (context, state) {
      final user = ref.read(currentUserProvider);
      final role = user?.role;
      final isGoingToLogin = state.matchedLocation == '/login';

      // Redirect unauthenticated users to login
      if (user == null && !isGoingToLogin) {
        return '/login';
      }

      // Allow authenticated users into settings subroutes
      if (user != null && state.matchedLocation.startsWith('/settings')) {
        return null;
      }

      // Redirect authenticated users away from login based on role
      if (user != null && isGoingToLogin) {
        return role == UserRole.landlord || role == UserRole.superAdmin ? '/landlord/dashboard' : '/tenant/dashboard';
      }

      // Role-based route protection
      if (state.matchedLocation.startsWith('/landlord') && role != UserRole.landlord && role != UserRole.superAdmin) {
        return '/login';
      }
      if (state.matchedLocation.startsWith('/tenant') && role != UserRole.tenant) {
        return '/login';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/settings',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SettingsScreen(),
        routes: [
          GoRoute(
            path: 'account',
            parentNavigatorKey: _rootNavigatorKey,
            builder: (context, state) => const AccountSettingsScreen(),
          ),
          GoRoute(
            path: 'billing-rules',
            parentNavigatorKey: _rootNavigatorKey,
            builder: (context, state) => const BillingRulesSettingsScreen(),
          ),
          GoRoute(
            path: 'security',
            parentNavigatorKey: _rootNavigatorKey,
            builder: (context, state) => const SecuritySettingsScreen(),
          ),
          GoRoute(
            path: 'notifications',
            parentNavigatorKey: _rootNavigatorKey,
            builder: (context, state) => const NotificationSettingsScreen(),
          ),
          GoRoute(
            path: 'appearance',
            parentNavigatorKey: _rootNavigatorKey,
            builder: (context, state) => const AppearanceSettingsScreen(),
          ),
          GoRoute(
            path: 'data',
            parentNavigatorKey: _rootNavigatorKey,
            builder: (context, state) => const DataSettingsScreen(),
          ),
          GoRoute(
            path: 'about',
            parentNavigatorKey: _rootNavigatorKey,
            builder: (context, state) => const AboutSettingsScreen(),
          ),
        ],
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          final user = ref.read(currentUserProvider);
          final role = user?.role;
          return AppScaffold(role: role, child: child);
        },
        routes: [
          // Landlord Routes
          GoRoute(
            path: '/landlord/dashboard',
            builder: (context, state) => const LandlordDashboardScreen(),
          ),
          GoRoute(
            path: '/landlord/portfolio',
            builder: (context, state) => const PropertiesScreen(),
          ),
          GoRoute(
            path: '/landlord/maintenance',
            builder: (context, state) => const MaintenanceScreen(),
          ),
          // Tenant Routes
          GoRoute(
            path: '/tenant/dashboard',
            builder: (context, state) => const TenantDashboardScreen(),
          ),
          GoRoute(
            path: '/tenant/utilities',
            builder: (context, state) => const Scaffold(body: Center(child: Text('Tenant Utilities'))),
          ),
          GoRoute(
            path: '/tenant/tickets',
            builder: (context, state) => const Scaffold(body: Center(child: Text('Tenant Tickets'))),
          ),
        ],
      ),
    ],
  );
});

class AppScaffold extends StatelessWidget {
  final UserRole? role;
  final Widget child;

  const AppScaffold({
    super.key,
    required this.role,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    if (role == null) return child;

    final isLandlord = role == UserRole.landlord;

    return Scaffold(
      backgroundColor: RampTheme.scaffoldBackground,
      body: child,
      bottomNavigationBar: NavigationBar(
        backgroundColor: Colors.white,
        selectedIndex: _calculateSelectedIndex(context, isLandlord),
        onDestinationSelected: (index) => _onItemTapped(index, context, isLandlord),
        destinations: isLandlord
            ? [
                _buildNavDestination('assets/icons/dashboard.svg', 'Dashboard'),
                _buildNavDestination('assets/icons/portfolio.svg', 'Portfolio'),
                _buildNavDestination('assets/icons/wrench.svg', 'Maintenance'),
              ]
            : [
                _buildNavDestination('assets/icons/home.svg', 'Rent'),
                _buildNavDestination('assets/icons/utility_water.svg', 'Utilities'),
                _buildNavDestination('assets/icons/ticket.svg', 'Tickets'),
              ],
      ),
    );
  }

  NavigationDestination _buildNavDestination(String assetPath, String label) {
    return NavigationDestination(
      icon: SvgPicture.asset(
        assetPath,
        width: 24,
        colorFilter: const ColorFilter.mode(RampTheme.textSecondary, BlendMode.srcIn),
      ),
      selectedIcon: SvgPicture.asset(
        assetPath,
        width: 24,
        colorFilter: const ColorFilter.mode(RampTheme.primaryBlue, BlendMode.srcIn),
      ),
      label: label,
    );
  }

  int _calculateSelectedIndex(BuildContext context, bool isLandlord) {
    final String location = GoRouterState.of(context).matchedLocation;
    if (isLandlord) {
      if (location.startsWith('/landlord/portfolio')) return 1;
      if (location.startsWith('/landlord/maintenance')) return 2;
      return 0;
    } else {
      if (location.startsWith('/tenant/utilities')) return 1;
      if (location.startsWith('/tenant/tickets')) return 2;
      return 0;
    }
  }

  void _onItemTapped(int index, BuildContext context, bool isLandlord) {
    if (isLandlord) {
      switch (index) {
        case 0: context.go('/landlord/dashboard'); break;
        case 1: context.go('/landlord/portfolio'); break;
        case 2: context.go('/landlord/maintenance'); break;
      }
    } else {
      switch (index) {
        case 0: context.go('/tenant/dashboard'); break;
        case 1: context.go('/tenant/utilities'); break;
        case 2: context.go('/tenant/tickets'); break;
      }
    }
  }
}
