// lib/screens/landlord/landlord_shell.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import '../../theme.dart';
import '../../models/notification_model.dart';
import '../../providers/landlord_providers.dart';
import '../../providers/settings_providers.dart';
import '../../core/supabase_auth_service.dart';
import 'dashboard_screen.dart';
import 'properties_screen.dart';
import 'tenants_screen.dart';
import 'maintenance_screen.dart';
import 'settings_screen.dart';

class LandlordShell extends ConsumerStatefulWidget {
  const LandlordShell({super.key});

  @override
  ConsumerState<LandlordShell> createState() => _LandlordShellState();
}

class _LandlordShellState extends ConsumerState<LandlordShell> {
  final SupabaseAuthService _authService = SupabaseAuthService();

  final List<Widget> _pages = const [
    LandlordDashboardScreen(),
    LandlordPropertiesScreen(),
    LandlordTenantsScreen(),
    LandlordMaintenanceScreen(),
    LandlordSettingsScreen(),
  ];

  String get _dynamicGreeting {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good morning';
    } else if (hour < 18) {
      return 'Good afternoon';
    } else {
      return 'Good evening';
    }
  }

  String get _firstName {
    final profile = ref.read(userProfileProvider);
    if (profile.name.isNotEmpty) {
      final first = profile.name.split(' ').first;
      if (first.isNotEmpty) return first;
    }
    final email = _authService.activeEmail;
    if (email.contains('@')) {
      final part = email.split('@').first;
      if (part.toLowerCase() == 'landlord') return 'Apex';
      return part[0].toUpperCase() + part.substring(1);
    }
    return 'Apex';
  }

  void _showNotificationDetailsModal(BuildContext context, AppNotification item) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: RampTheme.primaryBlue.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  item.type == 'payment'
                      ? Icons.payments
                      : item.type == 'maintenance'
                          ? Icons.build
                          : Icons.notifications,
                  color: RampTheme.primaryBlue,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  item.title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Divider(),
              const SizedBox(height: 8),
              Text(
                item.message,
                style: const TextStyle(fontSize: 14, height: 1.4, color: RampTheme.textPrimary),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateFormat('MMM d, yyyy • h:mm a').format(item.timestamp),
                    style: const TextStyle(fontSize: 11, color: RampTheme.textSecondary),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: RampTheme.successGreen.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Read',
                      style: TextStyle(
                        fontSize: 11,
                        color: RampTheme.successGreen,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            if (item.type == 'payment')
              ElevatedButton.icon(
                icon: const Icon(Icons.arrow_forward, size: 16),
                label: const Text('View Payments'),
                style: ElevatedButton.styleFrom(backgroundColor: RampTheme.primaryBlue),
                onPressed: () {
                  Navigator.pop(context);
                  context.push('/payments');
                },
              )
            else if (item.type == 'maintenance')
              ElevatedButton.icon(
                icon: const Icon(Icons.arrow_forward, size: 16),
                label: const Text('View Repairs'),
                style: ElevatedButton.styleFrom(backgroundColor: RampTheme.primaryBlue),
                onPressed: () {
                  Navigator.pop(context);
                  ref.read(activeShellTabProvider.notifier).state = 3;
                },
              )
            else if (item.type == 'tenant')
              ElevatedButton.icon(
                icon: const Icon(Icons.arrow_forward, size: 16),
                label: const Text('View Tenants'),
                style: ElevatedButton.styleFrom(backgroundColor: RampTheme.primaryBlue),
                onPressed: () {
                  Navigator.pop(context);
                  ref.read(activeShellTabProvider.notifier).state = 2;
                },
              ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _showNotificationsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Consumer(
          builder: (context, ref, child) {
            final notifications = ref.watch(notificationsProvider);

            return Container(
              padding: const EdgeInsets.all(RampTheme.spacing20),
              height: MediaQuery.of(context).size.height * 0.65,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Notifications', style: Theme.of(context).textTheme.titleLarge),
                      Flexible(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: TextButton.icon(
                            icon: const Icon(Icons.done_all, size: 18),
                            label: const Text('Mark all as read'),
                            onPressed: () async {
                              await ref.read(notificationsProvider.notifier).markAllAsRead();
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('All notifications marked as read!')),
                                );
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(),
                  Expanded(
                    child: notifications.isEmpty
                        ? const Center(child: Text('No notifications'))
                        : ListView.builder(
                            itemCount: notifications.length,
                            itemBuilder: (context, index) {
                              final item = notifications[index];
                              return Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(12),
                                  onTap: () async {
                                    await ref.read(notificationsProvider.notifier).markAsRead(item.id);
                                    if (context.mounted) {
                                      _showNotificationDetailsModal(context, item);
                                    }
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: item.isRead
                                          ? RampTheme.scaffoldBackground
                                          : RampTheme.primaryBlue.withValues(alpha: 0.08),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: item.isRead
                                            ? Colors.transparent
                                            : RampTheme.primaryBlue.withValues(alpha: 0.3),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          item.type == 'payment'
                                              ? Icons.payments
                                              : item.type == 'maintenance'
                                                  ? Icons.build
                                                  : Icons.info,
                                          color: RampTheme.primaryBlue,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                              Text(item.message, style: const TextStyle(fontSize: 12)),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeTab = ref.watch(activeShellTabProvider);
    final unreadCount = ref.watch(unreadNotificationsCountProvider);
    final initialLetter = _firstName.isNotEmpty ? _firstName[0].toUpperCase() : 'A';

    return Scaffold(
      appBar: activeTab == 0
          ? AppBar(
              automaticallyImplyLeading: false,
              titleSpacing: RampTheme.spacing16,
              title: Row(
                children: [
                  // Left Profile Avatar
                  InkWell(
                    onTap: () => context.push('/profile'),
                    borderRadius: BorderRadius.circular(24),
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: RampTheme.primaryBlue,
                      child: Text(
                        initialLetter,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: RampTheme.spacing12),

                  // Dynamic Greeting
                  Expanded(
                    child: Text(
                      '$_dynamicGreeting, $_firstName',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              actions: [
                // Right Notification Bell
                Stack(
                  alignment: Alignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.notifications_outlined, size: 26),
                      onPressed: () => _showNotificationsSheet(context),
                    ),
                    if (unreadCount > 0)
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: RampTheme.errorRed,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '$unreadCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: RampTheme.spacing8),
              ],
            )
          : null,
      body: Column(
        children: [
          Consumer(
            builder: (context, ref, child) {
              final pendingQueue = ref.watch(offlineSyncProvider);
              final isOnline = ref.watch(connectivityStatusProvider).value ?? true;
              final isOffline = !isOnline;

              if (!isOffline && pendingQueue.isEmpty) return const SizedBox.shrink();

              final bgColor = isOffline ? RampTheme.warningYellow : RampTheme.primaryBlue;
              final icon = isOffline ? Icons.wifi_off_rounded : Icons.sync_rounded;
              final text = isOffline
                  ? 'Offline Mode — ${pendingQueue.isNotEmpty ? "${pendingQueue.length} action(s) queued for sync" : "Changes cached locally"}'
                  : '${pendingQueue.length} offline action(s) pending sync';

              return Container(
                width: double.infinity,
                color: bgColor,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Icon(icon, color: Colors.white, size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        text,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (pendingQueue.isNotEmpty && isOnline)
                      InkWell(
                        onTap: () {
                          ref.read(offlineSyncProvider.notifier).flushQueue();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Sync Now',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
          Expanded(
            child: IndexedStack(
              index: activeTab,
              children: _pages,
            ),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: activeTab,
        onDestinationSelected: (index) {
          ref.read(activeShellTabProvider.notifier).state = index;
        },
        destinations: [
          NavigationDestination(
            icon: SvgPicture.asset(
              'assets/icons/dashboard.svg',
              width: 22,
              height: 22,
              colorFilter: const ColorFilter.mode(RampTheme.textSecondary, BlendMode.srcIn),
            ),
            selectedIcon: SvgPicture.asset(
              'assets/icons/dashboard.svg',
              width: 22,
              height: 22,
              colorFilter: const ColorFilter.mode(RampTheme.primaryBlue, BlendMode.srcIn),
            ),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: SvgPicture.asset(
              'assets/icons/property.svg',
              width: 22,
              height: 22,
              colorFilter: const ColorFilter.mode(RampTheme.textSecondary, BlendMode.srcIn),
            ),
            selectedIcon: SvgPicture.asset(
              'assets/icons/property.svg',
              width: 22,
              height: 22,
              colorFilter: const ColorFilter.mode(RampTheme.primaryBlue, BlendMode.srcIn),
            ),
            label: 'Units',
          ),
          NavigationDestination(
            icon: SvgPicture.asset(
              'assets/icons/tenant.svg',
              width: 22,
              height: 22,
              colorFilter: const ColorFilter.mode(RampTheme.textSecondary, BlendMode.srcIn),
            ),
            selectedIcon: SvgPicture.asset(
              'assets/icons/tenant.svg',
              width: 22,
              height: 22,
              colorFilter: const ColorFilter.mode(RampTheme.primaryBlue, BlendMode.srcIn),
            ),
            label: 'Tenants',
          ),
          NavigationDestination(
            icon: SvgPicture.asset(
              'assets/icons/maintenance.svg',
              width: 22,
              height: 22,
              colorFilter: const ColorFilter.mode(RampTheme.textSecondary, BlendMode.srcIn),
            ),
            selectedIcon: SvgPicture.asset(
              'assets/icons/maintenance.svg',
              width: 22,
              height: 22,
              colorFilter: const ColorFilter.mode(RampTheme.primaryBlue, BlendMode.srcIn),
            ),
            label: 'Repairs',
          ),
          NavigationDestination(
            icon: SvgPicture.asset(
              'assets/icons/settings.svg',
              width: 22,
              height: 22,
              colorFilter: const ColorFilter.mode(RampTheme.textSecondary, BlendMode.srcIn),
            ),
            selectedIcon: SvgPicture.asset(
              'assets/icons/settings.svg',
              width: 22,
              height: 22,
              colorFilter: const ColorFilter.mode(RampTheme.primaryBlue, BlendMode.srcIn),
            ),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
