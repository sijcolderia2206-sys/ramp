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
import 'core/utils/toast_service.dart';
import 'core/router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await SupabaseConfig.initialize();
    await SupabaseConfig.testConnection();
  } catch (e) {
    debugPrint('Supabase initialization exception: $e');
  }

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase initialization exception: $e');
  }

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
        } catch (e) {
          debugPrint('Hydrate persistent app data exception: $e');
        }
      } else {
        ref.read(authProvider.notifier).state = null;
      }
    } catch (e) {
      debugPrint('Auth restore session exception: $e');
      ref.read(authProvider.notifier).state = null;
    } finally {
      if (mounted) setState(() => _isRestoringSession = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);

    if (_isRestoringSession) {
      return MaterialApp(
        title: 'RAMP',
        debugShowCheckedModeBanner: false,
        theme: RampTheme.lightTheme,
        darkTheme: RampTheme.darkTheme,
        themeMode: themeMode,
        home: const _SessionRestoreScreen(),
      );
    }

    final goRouter = ref.watch(goRouterProvider);

    return MaterialApp.router(
      title: 'RAMP',
      debugShowCheckedModeBanner: false,
      theme: RampTheme.lightTheme,
      darkTheme: RampTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: goRouter,
      builder: (context, child) {
        return ScaffoldMessenger(
          key: ToastService.scaffoldKey,
          child: child ?? const SizedBox.shrink(),
        );
      },
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
              SizedBox(
                width: 150, // A balanced, "perfect" size for a logo
                height: 150, 
                // Removed Container, BoxDecoration, and Clip.antiAlias completely
                // so there is no shape, no background, just the raw image.
                child: Image.asset(
                  'assets/logo.png',
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.image_not_supported, 
                      size: 50, 
                      color: theme.colorScheme.error,
                    );
                  },
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
            content:
                const Text('Are you sure you want to exit the application?'),
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
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  transitionBuilder: (Widget child, Animation<double> animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0.0, 0.05),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      ),
                    );
                  },
                  child: KeyedSubtree(
                    key: ValueKey<int>(currentIndex),
                    child: _screens[currentIndex],
                  ),
                ),
              ),
            ],
          ),
          extendBody: true,
          bottomNavigationBar: SafeArea(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: NavigationBar(
                  selectedIndex: currentIndex,
                  onDestinationSelected: (index) {
                    HapticFeedback.selectionClick();
                    ref.read(bottomNavIndexProvider.notifier).state = index;
                  },
                  elevation: 0,
                  height: 66,
                  backgroundColor: Colors.transparent,
                  indicatorColor: Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFF0284C7).withValues(alpha: 0.20)
                      : const Color(0xFFE0F2FE),
                  labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
                  destinations: const [
                    NavigationDestination(
                      icon: Icon(Icons.home_outlined),
                      selectedIcon: GradientIcon(
                        icon: Icons.home_rounded,
                        size: 24,
                      ),
                      label: 'Home',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.apartment_outlined),
                      selectedIcon: GradientIcon(
                        icon: Icons.apartment_rounded,
                        size: 24,
                      ),
                      label: 'Units',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.people_outline_rounded),
                      selectedIcon: GradientIcon(
                        icon: Icons.people_rounded,
                        size: 24,
                      ),
                      label: 'Tenants',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.build_outlined),
                      selectedIcon: GradientIcon(
                        icon: Icons.build_rounded,
                        size: 24,
                      ),
                      label: 'Repairs',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.person_outline_rounded),
                      selectedIcon: GradientIcon(
                        icon: Icons.person_rounded,
                        size: 24,
                      ),
                      label: 'Profile',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class GradientIcon extends StatelessWidget {
  final IconData icon;
  final double size;
  final Gradient? gradient;

  const GradientIcon({
    super.key,
    required this.icon,
    this.size = 24.0,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveGradient = gradient ??
        const LinearGradient(
          colors: [Color(0xFF0052CC), Color(0xFF0284C7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );

    return ShaderMask(
      shaderCallback: (bounds) => effectiveGradient.createShader(bounds),
      child: Icon(
        icon,
        size: size,
        color: Colors.white,
      ),
    );
  }
}
