import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/navigation/custom_page_transitions.dart';
import '../../core/state/ramp_state.dart';
import '../../core/theme/ramp_theme.dart';
import '../../core/utils/toast_service.dart';

import 'sub_screens/about_settings_screen.dart';
import 'sub_screens/account_settings_screen.dart';
import 'sub_screens/appearance_settings_screen.dart';
import 'sub_screens/billing_rules_settings_screen.dart';
import 'sub_screens/data_settings_screen.dart';
import 'sub_screens/notification_settings_screen.dart';
import 'sub_screens/security_settings_screen.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _navigateToCategory(Widget page, String routePath) {
    try {
      if (GoRouter.maybeOf(context) != null) {
        context.push(routePath);
        return;
      }
    } catch (_) {}

    Navigator.of(context, rootNavigator: true).push(
      SlideUpFadeRoute(page: page),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isDarkMode = ref.watch(darkModeProvider);
    final biometrics = ref.watch(biometricsEnabledProvider);
    final autoLateFee = ref.watch(autoLateFeeEnabledProvider);
    final dueDateDay = ref.watch(dueDateDayProvider);
    final lateFee = ref.watch(lateFeeAmountProvider);
    final profile = ref.watch(landlordProfileProvider);
    final currencySymbol = ref.watch(currencySymbolProvider);

    final query = _searchQuery.toLowerCase().trim();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search Bar
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search settings (e.g. late fee, biometrics, dark mode)…',
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      filled: true,
                      fillColor: isDark
                          ? const Color(0xFF1E293B)
                          : const Color(0xFFF8FAFC),
                    ),
                    onChanged: (val) => setState(() => _searchQuery = val),
                  ),

                  const SizedBox(height: 16),

                  if (query.isEmpty) ...[
                    // Account Summary Card
                    RampCard(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 26,
                            backgroundColor: RampColors.primary,
                            backgroundImage: (profile.avatarPath != null &&
                                    profile.avatarPath!.isNotEmpty &&
                                    File(profile.avatarPath!).existsSync())
                                ? FileImage(File(profile.avatarPath!))
                                : null,
                            child: (profile.avatarPath == null ||
                                    profile.avatarPath!.isEmpty ||
                                    !File(profile.avatarPath!).existsSync())
                                ? Text(
                                    profile.name.trim().isEmpty
                                        ? 'AP'
                                        : profile.name
                                            .trim()
                                            .substring(0, 1)
                                            .toUpperCase(),
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  )
                                : null,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  profile.name,
                                  style: GoogleFonts.poppins(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  profile.role,
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          TextButton(
                            onPressed: () => _navigateToCategory(
                              const AccountSettingsScreen(),
                              '/settings/account',
                            ),
                            child: const Text('Manage'),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Quick Settings Card (Switches)
                    Text(
                      'QUICK CONTROLS',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.1,
                        color: isDark ? const Color(0xFF94A3B8) : RampColors.mutedText,
                      ),
                    ),
                    const SizedBox(height: 8),

                    RampCard(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        children: [
                          SwitchListTile(
                            secondary: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: isDarkMode
                                    ? const Color(0xFF334155)
                                    : const Color(0xFFF1F5F9),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                isDarkMode
                                    ? Icons.dark_mode_rounded
                                    : Icons.light_mode_rounded,
                                color: isDarkMode ? Colors.amber : theme.colorScheme.onSurface,
                                size: 20,
                              ),
                            ),
                            title: Text(
                              'Dark Mode',
                              style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            subtitle: Text(
                              'Toggle app appearance theme',
                              style: GoogleFonts.poppins(fontSize: 12),
                            ),
                            value: isDarkMode,
                            activeTrackColor: RampColors.primary,
                            onChanged: (val) {
                              HapticFeedback.lightImpact();
                              ref.read(themeModeProvider.notifier).state =
                                  val ? ThemeMode.dark : ThemeMode.light;
                              ref.read(darkModeProvider.notifier).state = val;
                              persistAppSettings(darkMode: val);
                            },
                          ),
                          const Divider(height: 1),
                          SwitchListTile(
                            secondary: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: RampColors.softBlueTint,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.fingerprint_rounded,
                                  color: RampColors.primary, size: 20),
                            ),
                            title: Text(
                              'Biometric Authentication',
                              style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            subtitle: Text(
                              'Require Face ID / Touch ID for app unlock',
                              style: GoogleFonts.poppins(fontSize: 12),
                            ),
                            value: biometrics,
                            activeTrackColor: RampColors.primary,
                            onChanged: (val) {
                              HapticFeedback.lightImpact();
                              ref
                                  .read(biometricsEnabledProvider.notifier)
                                  .state = val;
                              persistAppSettings(biometricsEnabled: val);
                              ToastService.showSuccess(
                                val
                                    ? 'Biometrics enabled'
                                    : 'Biometrics disabled',
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],

                  // Hierarchical Category Sections
                  Text(
                    'CATEGORIES & PREFERENCES',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                      color: isDark ? const Color(0xFF94A3B8) : RampColors.mutedText,
                    ),
                  ),
                  const SizedBox(height: 8),

                  RampCard(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      children: [
                        if (query.isEmpty ||
                            query.contains('account') ||
                            query.contains('profile') ||
                            query.contains('name') ||
                            query.contains('contact')) ...[
                          ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: RampColors.softBlueTint,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.person_rounded,
                                  color: RampColors.primary, size: 20),
                            ),
                            title: Text(
                              'Account & Landlord Profile',
                              style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            subtitle: Text(
                              '${profile.name} • ${profile.contact}',
                              style: GoogleFonts.poppins(fontSize: 12),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: const Icon(Icons.chevron_right_rounded),
                            onTap: () => _navigateToCategory(
                              const AccountSettingsScreen(),
                              '/settings/account',
                            ),
                          ),
                          const Divider(height: 1),
                        ],

                        if (query.isEmpty ||
                            query.contains('billing') ||
                            query.contains('rent') ||
                            query.contains('due') ||
                            query.contains('late') ||
                            query.contains('fee') ||
                            query.contains('water') ||
                            query.contains('electric') ||
                            query.contains('utility')) ...[
                          ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: RampColors.warningTint,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.monetization_on_rounded,
                                  color: RampColors.warning, size: 20),
                            ),
                            title: Text(
                              'Financial & Billing Rules',
                              style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            subtitle: Text(
                              'Due day: ${dueDateDay}th • Late fee: $currencySymbol${lateFee.toStringAsFixed(0)} ${autoLateFee ? "(Auto ON)" : ""}',
                              style: GoogleFonts.poppins(fontSize: 12),
                            ),
                            trailing: const Icon(Icons.chevron_right_rounded),
                            onTap: () => _navigateToCategory(
                              const BillingRulesSettingsScreen(),
                              '/settings/billing-rules',
                            ),
                          ),
                          const Divider(height: 1),
                        ],

                        if (query.isEmpty ||
                            query.contains('security') ||
                            query.contains('biometric') ||
                            query.contains('fingerprint') ||
                            query.contains('face') ||
                            query.contains('lock') ||
                            query.contains('audit') ||
                            query.contains('privacy')) ...[
                          ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: RampColors.softBlueTint,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.security_rounded,
                                  color: RampColors.primary, size: 20),
                            ),
                            title: Text(
                              'Security & Privacy',
                              style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            subtitle: Text(
                              'Biometrics ${biometrics ? "Enabled" : "Disabled"} • Compliance logs',
                              style: GoogleFonts.poppins(fontSize: 12),
                            ),
                            trailing: const Icon(Icons.chevron_right_rounded),
                            onTap: () => _navigateToCategory(
                              const SecuritySettingsScreen(),
                              '/settings/security',
                            ),
                          ),
                          const Divider(height: 1),
                        ],

                        if (query.isEmpty ||
                            query.contains('notification') ||
                            query.contains('alert') ||
                            query.contains('reminder') ||
                            query.contains('sla') ||
                            query.contains('push')) ...[
                          ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: RampColors.softBlueTint,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.notifications_rounded,
                                  color: RampColors.primary, size: 20),
                            ),
                            title: Text(
                              'Notifications & Alerts',
                              style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            subtitle: Text(
                              'Push notifications, rent due, and SLA alerts',
                              style: GoogleFonts.poppins(fontSize: 12),
                            ),
                            trailing: const Icon(Icons.chevron_right_rounded),
                            onTap: () => _navigateToCategory(
                              const NotificationSettingsScreen(),
                              '/settings/notifications',
                            ),
                          ),
                          const Divider(height: 1),
                        ],

                        if (query.isEmpty ||
                            query.contains('appearance') ||
                            query.contains('theme') ||
                            query.contains('dark') ||
                            query.contains('light') ||
                            query.contains('compact') ||
                            query.contains('currency')) ...[
                          ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: RampColors.softBlueTint,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.palette_rounded,
                                  color: RampColors.primary, size: 20),
                            ),
                            title: Text(
                              'Appearance & Display',
                              style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            subtitle: Text(
                              '${isDarkMode ? "Dark" : "Light"} theme • Currency ($currencySymbol)',
                              style: GoogleFonts.poppins(fontSize: 12),
                            ),
                            trailing: const Icon(Icons.chevron_right_rounded),
                            onTap: () => _navigateToCategory(
                              const AppearanceSettingsScreen(),
                              '/settings/appearance',
                            ),
                          ),
                          const Divider(height: 1),
                        ],

                        if (query.isEmpty ||
                            query.contains('data') ||
                            query.contains('backup') ||
                            query.contains('sync') ||
                            query.contains('offline') ||
                            query.contains('pdf') ||
                            query.contains('report') ||
                            query.contains('export')) ...[
                          ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: RampColors.softBlueTint,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.cloud_sync_rounded,
                                  color: RampColors.primary, size: 20),
                            ),
                            title: Text(
                              'Data, Backup & Export',
                              style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            subtitle: Text(
                              'Cloud auto-backup, offline sync & PDF report export',
                              style: GoogleFonts.poppins(fontSize: 12),
                            ),
                            trailing: const Icon(Icons.chevron_right_rounded),
                            onTap: () => _navigateToCategory(
                              const DataSettingsScreen(),
                              '/settings/data',
                            ),
                          ),
                          const Divider(height: 1),
                        ],

                        if (query.isEmpty ||
                            query.contains('about') ||
                            query.contains('version') ||
                            query.contains('ramp') ||
                            query.contains('supabase') ||
                            query.contains('firebase') ||
                            query.contains('help')) ...[
                          ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: RampColors.softBlueTint,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.info_outline_rounded,
                                  color: RampColors.primary, size: 20),
                            ),
                            title: Text(
                              'About RAMP',
                              style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            subtitle: Text(
                              'RAMP v1.0.0 • Backend Diagnostics & SLA Protocols',
                              style: GoogleFonts.poppins(fontSize: 12),
                            ),
                            trailing: const Icon(Icons.chevron_right_rounded),
                            onTap: () => _navigateToCategory(
                              const AboutSettingsScreen(),
                              '/settings/about',
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
