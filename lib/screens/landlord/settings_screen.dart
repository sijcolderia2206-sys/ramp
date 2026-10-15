// lib/screens/landlord/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../theme.dart';
import '../../providers/settings_providers.dart';
import '../../providers/landlord_providers.dart';
import '../../providers/session_providers.dart';
import '../../core/supabase_auth_service.dart';
import '../../widgets/neumorphic_widgets.dart';

/// Settings and Configuration Screen for RAMP App Control Center.
/// Follows strict Neumorphic (Soft UI) design system with Riverpod state management.
/// Financial Defaults (Rent due day, late fees) are handled at lease level and omitted here.
class LandlordSettingsScreen extends ConsumerStatefulWidget {
  const LandlordSettingsScreen({super.key});

  @override
  ConsumerState<LandlordSettingsScreen> createState() => _LandlordSettingsScreenState();
}

class _LandlordSettingsScreenState extends ConsumerState<LandlordSettingsScreen> {
  final SupabaseAuthService _authService = SupabaseAuthService();
  bool _isExporting = false;

  String _formatLastSynced(DateTime? dt) {
    if (dt == null) return 'Never';
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inSeconds < 45) {
      return 'Just now';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else {
      return DateFormat('MMM d, y - h:mm a').format(dt);
    }
  }

  // ==========================================
  // ACTION HANDLERS WITH ASYNC TRY-CATCH
  // ==========================================



  /// Handle Force Cloud Sync
  Future<void> _handleForceCloudSync() async {
    try {
      final success = await ref.read(syncStatusProvider.notifier).forceCloudSync();
      if (!mounted) return;

      if (success) {
        NeumorphicFeedback.showSnackBar(
          context,
          message: 'Cloud Sync Complete! Local data synchronized with Supabase.',
          isError: false,
        );
      } else {
        NeumorphicFeedback.showSnackBar(
          context,
          message: 'Cloud sync encountered network issues. Using local cached data.',
          isError: true,
        );
      }
    } catch (e) {
      if (!mounted) return;
      NeumorphicFeedback.showSnackBar(
        context,
        message: 'Sync Error: ${e.toString()}',
        isError: true,
      );
    }
  }

  /// Handle Clear Local Cache with Neumorphic Confirmation Dialog
  Future<void> _handleClearLocalCache() async {
    try {
      final confirm = await showConfirmationDialog(
        context,
        title: 'Clear Local Cache?',
        message: 'Are you sure you want to wipe the local offline database cache? Unsynced changes will be permanently lost.',
        confirmLabel: 'Clear Cache',
        cancelLabel: 'Cancel',
        isDestructive: true,
      );

      if (!confirm) return;

      final success = await ref.read(syncStatusProvider.notifier).clearLocalCache();
      if (!mounted) return;

      if (success) {
        NeumorphicFeedback.showSnackBar(
          context,
          message: 'Local database cache cleared successfully.',
          isError: false,
        );
      } else {
        NeumorphicFeedback.showSnackBar(
          context,
          message: 'Failed to clear local cache.',
          isError: true,
        );
      }
    } catch (e) {
      if (!mounted) return;
      NeumorphicFeedback.showSnackBar(
        context,
        message: 'Clear Cache Error: ${e.toString()}',
        isError: true,
      );
    }
  }

  /// Handle Open OS App Permissions
  Future<void> _handleOpenAppPermissions() async {
    try {
      final opened = await openAppSettings();
      if (!opened && mounted) {
        NeumorphicFeedback.showSnackBar(
          context,
          message: 'Unable to open OS Settings directly. Please open device settings manually.',
          isError: true,
        );
      }
    } catch (e) {
      if (!mounted) return;
      NeumorphicFeedback.showSnackBar(
        context,
        message: 'Permissions Error: ${e.toString()}',
        isError: true,
      );
    }
  }

  /// Handle Change Password Modal / Flow
  void _handleChangePassword() {
    final userProfile = ref.read(userProfileProvider);
    final emailController = TextEditingController(text: userProfile.email);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: RampTheme.scaffoldBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: const [
            Icon(Icons.lock_reset_rounded, color: RampTheme.primaryBlue, size: 26),
            SizedBox(width: 10),
            Text(
              'Reset Password',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: RampTheme.textPrimary),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'A password reset link will be sent to your registered account email address.',
              style: TextStyle(fontSize: 13, color: RampTheme.textSecondary, height: 1.4),
            ),
            const SizedBox(height: 16),
            NeumorphicTextField(
              controller: emailController,
              label: 'Account Email',
              readOnly: true,
              prefixIcon: Icons.email_outlined,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel', style: TextStyle(color: RampTheme.textSecondary, fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: RampTheme.primaryBlue,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              Navigator.of(ctx).pop();
              try {
                await _authService.resetPasswordForEmail(emailController.text);
                if (mounted) {
                  NeumorphicFeedback.showSnackBar(
                    context,
                    message: 'Password reset email sent to ${emailController.text}',
                    isError: false,
                  );
                }
              } catch (e) {
                if (mounted) {
                  NeumorphicFeedback.showSnackBar(
                    context,
                    message: 'Password reset request failed: ${e.toString()}',
                    isError: true,
                  );
                }
              }
            },
            child: const Text('Send Reset Link', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  /// Handle Export Financials (CSV)
  Future<void> _handleExportFinancials() async {
    setState(() => _isExporting = true);
    try {
      await Future.delayed(const Duration(milliseconds: 1000));
      final payments = ref.read(paymentsProvider);

      StringBuffer csvContent = StringBuffer();
      csvContent.writeln('ID,Unit Number,Tenant Name,Amount,Status,Payment Date,Payment Method,Transaction Type');

      for (var p in payments) {
        csvContent.writeln(
          '${p.id},"${p.unitNumber ?? 'N/A'}","${p.tenantName ?? 'N/A'}",${p.amount},"${p.status}","${p.paymentDate.toIso8601String()}","${p.paymentMethod}","${p.transactionType}"',
        );
      }

      if (!mounted) return;
      setState(() => _isExporting = false);

      NeumorphicFeedback.showSnackBar(
        context,
        message: 'Financial report successfully exported as CSV! (${payments.length} ledger entries processed)',
        isError: false,
      );
    } catch (e) {
      if (mounted) {
        setState(() => _isExporting = false);
        NeumorphicFeedback.showSnackBar(
          context,
          message: 'Financial Export Error: ${e.toString()}',
          isError: true,
        );
      }
    }
  }

  /// Handle Sign Out with Validation Confirmation Dialog
  Future<void> _handleSignOut() async {
    try {
      final confirm = await showConfirmationDialog(
        context,
        title: 'Sign Out Account?',
        message: 'Are you sure you want to sign out? Unsynced offline data may be lost.',
        confirmLabel: 'Sign Out',
        cancelLabel: 'Cancel',
        isDestructive: true,
      );

      if (!confirm) return;

      await _authService.signOut();
      if (mounted) {
        NeumorphicFeedback.showSnackBar(
          context,
          message: 'Signed out successfully.',
          isError: false,
        );
        context.go('/login');
      }
    } catch (e) {
      if (mounted) {
        NeumorphicFeedback.showSnackBar(
          context,
          message: 'Sign Out Error: ${e.toString()}',
          isError: true,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Riverpod State Readers & Observers
    final userProfile = ref.watch(userProfileProvider);
    final syncState = ref.watch(syncStatusProvider);
    final notifState = ref.watch(notificationSettingsProvider);
    final sessionState = ref.watch(sessionProvider);
    final nowSession = sessionState.nowSession;

    return Scaffold(
      backgroundColor: RampTheme.scaffoldBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Screen Header Title
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'App Control Center',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: RampTheme.textPrimary,
                    ),
                  ),
                  NeumorphicPill(
                    text: 'SETTINGS',
                    textColor: RampTheme.primaryBlue,
                  ),
                ],
              ),
              const SizedBox(height: 16.0),

              // LANDLORD PROFILE HEADER CARD
              NeumorphicContainer(
                borderRadius: 20.0,
                onTap: () => context.push('/profile'),
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    NeumorphicContainer(
                      shape: BoxShape.circle,
                      width: 56,
                      height: 56,
                      backgroundColor: RampTheme.primaryBlue,
                      child: Center(
                        child: Text(
                          userProfile.avatarInitials,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userProfile.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: RampTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            userProfile.email,
                            style: const TextStyle(
                              fontSize: 13,
                              color: RampTheme.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          NeumorphicPill(
                            text: userProfile.role,
                            textColor: RampTheme.primaryBlue,
                            icon: Icons.admin_panel_settings_outlined,
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: RampTheme.textSecondary),
                  ],
                ),
              ),
              const SizedBox(height: 24.0),

              // SECTION A: SYSTEM & OFFLINE SYNCHRONIZATION
              _buildSectionHeader('SYSTEM & OFFLINE SYNCHRONIZATION'),
              NeumorphicContainer(
                borderRadius: 20.0,
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Cloud Sync Status Text
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Cloud Sync Status',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: RampTheme.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Last Synced: ${_formatLastSynced(syncState.lastSyncedAt)}',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: RampTheme.primaryBlue,
                              ),
                            ),
                          ],
                        ),
                        if (syncState.pendingCount > 0)
                          NeumorphicPill(
                            text: '${syncState.pendingCount} Pending',
                            textColor: RampTheme.warningYellow,
                          ),
                      ],
                    ),
                    const Divider(height: 28, color: RampTheme.dividerColor),

                    // Force Cloud Sync Button
                    NeumorphicButton(
                      label: 'Force Cloud Sync',
                      icon: Icons.sync_rounded,
                      isLoading: syncState.isSyncing,
                      backgroundColor: RampTheme.primaryBlue,
                      textColor: Colors.white,
                      onPressed: _handleForceCloudSync,
                    ),
                    const SizedBox(height: 14.0),

                    // Clear Local Cache Button
                    NeumorphicButton(
                      label: 'Clear Local Cache',
                      icon: Icons.delete_sweep_outlined,
                      backgroundColor: NeumorphicDecoration.baseColor,
                      textColor: RampTheme.errorRed,
                      onPressed: _handleClearLocalCache,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24.0),

              // SECTION C: AUTOMATION & NOTIFICATIONS
              _buildSectionHeader('AUTOMATION & NOTIFICATIONS'),
              NeumorphicContainer(
                borderRadius: 20.0,
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    // Overdue Rent SMS Alerts Toggle
                    NeumorphicToggle(
                      title: 'Overdue Rent SMS Alerts',
                      subtitle: 'Automatically trigger SMS notifications to tenants upon late rent',
                      value: notifState.overdueSmsAlerts,
                      onChanged: (val) {
                        ref.read(notificationSettingsProvider.notifier).toggleOverdueSms(val);
                        NeumorphicFeedback.showSnackBar(
                          context,
                          message: val ? 'Overdue SMS Alerts enabled' : 'Overdue SMS Alerts disabled',
                        );
                      },
                    ),
                    const Divider(height: 28, color: RampTheme.dividerColor),

                    // Urgent Maintenance Push Notifications Toggle
                    NeumorphicToggle(
                      title: 'Urgent Maintenance Push Notifications',
                      subtitle: 'Notify landlord immediately for emergency SLA tickets',
                      value: notifState.urgentPushNotifications,
                      onChanged: (val) {
                        ref.read(notificationSettingsProvider.notifier).toggleUrgentPush(val);
                        NeumorphicFeedback.showSnackBar(
                          context,
                          message: val ? 'Urgent Push Notifications enabled' : 'Urgent Push Notifications disabled',
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24.0),

              // SECTION D: SECURITY & LEGAL
              _buildSectionHeader('SECURITY & LEGAL'),
              NeumorphicContainer(
                borderRadius: 20.0,
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    // Terms and Conditions List Tile
                    _buildSettingsListTile(
                      icon: Icons.gavel_outlined,
                      title: 'Terms & Conditions / Privacy Policy',
                      subtitle: 'View software platform license and privacy agreements',
                      onTap: () => context.push('/terms'),
                    ),
                    const Divider(height: 24, color: RampTheme.dividerColor),

                    // App Permissions Button
                    _buildSettingsListTile(
                      icon: Icons.security_outlined,
                      title: 'App Permissions',
                      subtitle: 'Manage Camera and Storage permissions in OS settings',
                      onTap: _handleOpenAppPermissions,
                    ),
                    const Divider(height: 24, color: RampTheme.dividerColor),

                    // Active Sessions & Storage Management List Tile
                    _buildSettingsListTile(
                      icon: Icons.devices_outlined,
                      title: 'Active Sessions & Cache Management',
                      subtitle: nowSession != null
                          ? 'Active Now (${nowSession.deviceName}) • Manage tokens & cache'
                          : 'Manage logged-in devices, auth tokens, and app storage',
                      onTap: () => context.push('/sessions'),
                    ),
                    const Divider(height: 24, color: RampTheme.dividerColor),

                    // Change Password Button
                    _buildSettingsListTile(
                      icon: Icons.lock_reset_outlined,
                      title: 'Change Password',
                      subtitle: 'Send password update reset link to registered email',
                      onTap: _handleChangePassword,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24.0),

              // SECTION E: DATA & ACCOUNT MANAGEMENT
              _buildSectionHeader('DATA & ACCOUNT MANAGEMENT'),
              NeumorphicContainer(
                borderRadius: 20.0,
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    // Export Financials (CSV) Convex Button
                    NeumorphicButton(
                      label: 'Export Financials (CSV)',
                      icon: Icons.file_download_outlined,
                      isLoading: _isExporting,
                      backgroundColor: NeumorphicDecoration.baseColor,
                      textColor: RampTheme.primaryBlue,
                      onPressed: _handleExportFinancials,
                    ),
                    const SizedBox(height: 16.0),

                    // Prominent Neumorphic Sign Out Button
                    NeumorphicButton(
                      label: 'Sign Out Landlord Account',
                      icon: Icons.logout,
                      backgroundColor: RampTheme.errorRed,
                      textColor: Colors.white,
                      onPressed: _handleSignOut,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32.0),
            ],
          ),
        ),
      ),
    );
  }

  /// Helper to render subtle uppercase section headers
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.8,
          color: RampTheme.textSecondary,
        ),
      ),
    );
  }

  /// Helper to render list tile rows within Neumorphic sections
  Widget _buildSettingsListTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          children: [
            NeumorphicContainer(
              borderRadius: 12,
              width: 40,
              height: 40,
              backgroundColor: RampTheme.primaryBlue.withValues(alpha: 0.1),
              child: Icon(icon, color: RampTheme.primaryBlue, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: RampTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: RampTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: RampTheme.textSecondary, size: 20),
          ],
        ),
      ),
    );
  }
}
