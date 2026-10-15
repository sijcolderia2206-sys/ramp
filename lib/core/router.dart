// lib/core/router.dart
import 'package:go_router/go_router.dart';
import '../core/supabase_auth_service.dart';
import '../screens/auth/login_screen.dart';
import '../screens/landlord/landlord_shell.dart';
import '../screens/landlord/profile_screen.dart';
import '../screens/landlord/add_tenant_screen.dart';
import '../screens/landlord/add_repair_screen.dart';
import '../screens/landlord/add_unit_screen.dart';
import '../screens/landlord/payments_screen.dart';
import '../screens/landlord/pending_items_screen.dart';
import '../screens/landlord/payment_details_screen.dart';
import '../screens/landlord/record_payment_screen.dart';
import '../screens/landlord/calendar_screen.dart';
import '../screens/landlord/terms_and_conditions_screen.dart';
import '../screens/landlord/session_screen.dart';
import '../screens/tenant/tenant_shell.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  redirect: (context, state) {
    final authService = SupabaseAuthService();
    final isAuthenticated = authService.isAuthenticated;
    final isLoggingIn = state.uri.toString() == '/login';
    final role = authService.activeRole;

    if (!isAuthenticated) {
      return isLoggingIn ? null : '/login';
    }

    if (isLoggingIn) {
      return role == 'tenant' ? '/tenant-dashboard' : '/';
    }

    // Role-based Route Protection: Restrict tenant access to landlord management screens
    if (role == 'tenant') {
      final path = state.uri.path;
      final landlordOnlyPaths = [
        '/add-tenant',
        '/add-repair',
        '/add-unit',
        '/payments',
        '/pending-items',
        '/record-payment',
        '/calendar',
      ];

      if (landlordOnlyPaths.contains(path) || path.startsWith('/payment-details/')) {
        return '/tenant-dashboard';
      }
    }

    return null;
  },
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) {
        final authService = SupabaseAuthService();
        if (authService.activeRole == 'tenant') {
          return const TenantShell();
        }
        return const LandlordShell();
      },
    ),
    GoRoute(
      path: '/tenant-dashboard',
      builder: (context, state) => const TenantShell(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      path: '/add-tenant',
      builder: (context, state) => const AddTenantScreen(),
    ),
    GoRoute(
      path: '/add-repair',
      builder: (context, state) => const AddRepairScreen(),
    ),
    GoRoute(
      path: '/add-unit',
      builder: (context, state) => const AddUnitScreen(),
    ),
    GoRoute(
      path: '/payments',
      builder: (context, state) => const PaymentsScreen(),
    ),
    GoRoute(
      path: '/pending-items',
      builder: (context, state) => const PendingItemsScreen(),
    ),
    GoRoute(
      path: '/payment-details/:id',
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        return PaymentDetailsScreen(paymentId: id);
      },
    ),
    GoRoute(
      path: '/record-payment',
      builder: (context, state) => const RecordPaymentScreen(),
    ),
    GoRoute(
      path: '/calendar',
      builder: (context, state) => const CalendarScreen(),
    ),
    GoRoute(
      path: '/terms',
      builder: (context, state) => const TermsAndConditionsScreen(),
    ),
    GoRoute(
      path: '/sessions',
      builder: (context, state) => const SessionScreen(),
    ),
  ],
);
