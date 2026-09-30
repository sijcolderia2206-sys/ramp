import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'firebase_options.dart';
import 'core/network/supabase/supabase_config.dart';
import 'theme.dart';
import 'providers/providers.dart';
import 'screens/screens.dart';
import 'core/widgets/core_widgets.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SupabaseConfig.initialize();
  await SupabaseConfig.testConnection();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const ProviderScope(child: RampApp()));
}

class RampApp extends ConsumerStatefulWidget {
  const RampApp({super.key});

  @override
  ConsumerState<RampApp> createState() => _RampAppState();
}

class _RampAppState extends ConsumerState<RampApp> {
  bool _isRestoringSession = true;

  @override
  void initState() {
    super.initState();
    _restoreSession();
  }

  Future<void> _restoreSession() async {
    try {
      if (Firebase.apps.isEmpty) {
        ref.read(authProvider.notifier).state = null;
        return;
      }
      final user = await FirebaseAuth.instance.authStateChanges().first;
      if (user != null) {
        ref.read(authProvider.notifier).state = user.uid;
        try {
          await hydratePersistentAppData(ref);
        } on FirebaseException {
          // Keep the authenticated session and use the available local state.
        }
      } else {
        ref.read(authProvider.notifier).state = null;
      }
    } on FirebaseAuthException {
      ref.read(authProvider.notifier).state = null;
    } finally {
      if (mounted) setState(() => _isRestoringSession = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAuthenticated = ref.watch(authProvider) != null;
    final isDarkMode = ref.watch(darkModeProvider);
    final currentRole = ref.watch(currentRoleProvider);

    Widget homeWidget;
    if (_isRestoringSession) {
      homeWidget = const _SessionRestoreScreen();
    } else if (isAuthenticated) {
      if (currentRole == 'tenant') {
        homeWidget = const TenantPortalScreen();
      } else {
        homeWidget = const LandlordShell();
      }
    } else {
      homeWidget = const LoginScreen();
    }

    return MaterialApp(
      title: 'RAMP',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: homeWidget,
    );
  }
}

class _SessionRestoreScreen extends StatelessWidget {
  const _SessionRestoreScreen();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  Icons.apartment_rounded,
                  size: 34,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'RAMP',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2.5),
              ),
              const SizedBox(height: 10),
              Text(
                'Restoring your session…',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The only authenticated shell. Tenants are managed profiles, never accounts.
class LandlordShell extends ConsumerWidget {
  const LandlordShell({super.key});

  final List<Widget> _screens = const [
    HomeScreen(),
    UnitsScreen(), // Properties
    TenantsScreen(), // Tenants
    MaintenanceScreen(), // Maintenance
    ProfileScreen(), // Profile
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(bottomNavIndexProvider);

    final items = const [
      _NavItem(icon: Icons.home_rounded, label: 'Home'),
      _NavItem(icon: Icons.apartment_rounded, label: 'Units'),
      _NavItem(icon: Icons.people_alt_rounded, label: 'Tenants'),
      _NavItem(icon: Icons.build_rounded, label: 'Repairs'),
      _NavItem(icon: Icons.person_rounded, label: 'Profile'),
    ];

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;

        if (currentIndex != 0) {
          ref.read(bottomNavIndexProvider.notifier).state = 0;
          return;
        }

        final shouldExit = await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('Exit RAMP App?'),
            content: const Text('Are you sure you want to exit the application?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('CANCEL'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: const Text('EXIT APP'),
              ),
            ],
          ),
        );

        if (shouldExit == true) {
          SystemNavigator.pop();
        }
      },
      child: SafeArea(
        child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        resizeToAvoidBottomInset: false,
        body: Column(
          children: [
            const OfflineSyncBanner(),
            Expanded(
              child: IndexedStack(
                index: currentIndex,
                children: _screens,
              ),
            ),
          ],
        ),
        bottomNavigationBar: _FloatingPillBottomBar(
          currentIndex: currentIndex,
          items: items,
          onTap: (index) {
            HapticFeedback.selectionClick();
            ref.read(bottomNavIndexProvider.notifier).state = index;
          },
        ),
      ),
    ),
  );
  }
}

class _NavItem {
  final IconData icon;
  final String label;

  const _NavItem({required this.icon, required this.label});
}

class _FloatingPillBottomBar extends StatelessWidget {
  final int currentIndex;
  final List<_NavItem> items;
  final ValueChanged<int> onTap;

  const _FloatingPillBottomBar({
    required this.currentIndex,
    required this.items,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceBg = isDark
        ? Theme.of(context).colorScheme.surface
        : const Color(0xFFF1F5F9);

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 10),
      child: ClayContainer(
        height: 68,
        color: surfaceBg,
        borderRadius: 28,
        depth: 8.0,
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(items.length, (index) {
            final isSelected = currentIndex == index;
            final item = items[index];

            final selectedBg = Theme.of(context).colorScheme.primary;

            return Expanded(
              child: BounceNavTab(
                isSelected: isSelected,
                onTap: () => onTap(index),
                child: isSelected
                    ? ClayContainer(
                        color: selectedBg,
                        borderRadius: 20,
                        depth: 5.0,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 2, vertical: 6),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              item.icon,
                              size: 20,
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                            const SizedBox(height: 3),
                            Text(
                              item.label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onPrimary,
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      )
                    : Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 2, vertical: 6),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              item.icon,
                              size: 20,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                            const SizedBox(height: 3),
                            Text(
                              item.label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                                fontSize: 11.5,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
