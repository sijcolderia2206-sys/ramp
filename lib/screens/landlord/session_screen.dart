// lib/screens/landlord/session_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/services/session_service.dart';
import '../../core/services/cache_and_storage_service.dart';
import '../../providers/session_providers.dart';
import '../../widgets/ramp_toast.dart';
import '../../widgets/ramp_skeleton.dart';
import '../../theme.dart';

class SessionScreen extends ConsumerStatefulWidget {
  const SessionScreen({super.key});

  @override
  ConsumerState<SessionScreen> createState() => _SessionScreenState();
}

class _SessionScreenState extends ConsumerState<SessionScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(sessionProvider.notifier).loadSessionData();
    });
  }

  Future<void> _handleRefreshSession() async {
    final success = await ref.read(sessionProvider.notifier).refreshCurrentSession();
    if (mounted) {
      if (success) {
        RampToast.showSuccess(
          context,
          message: 'Active session token refreshed successfully.',
          title: 'Session Updated',
        );
      } else {
        RampToast.showError(
          context,
          message: 'Failed to refresh active session token.',
        );
      }
    }
  }

  Future<void> _handleRevokeOthers() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Revoke Other Device Sessions?'),
        content: const Text('This will immediately terminate active logins on all other devices and web browsers.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: RampTheme.errorRed),
            child: const Text('Revoke All'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final success = await ref.read(sessionProvider.notifier).revokeOtherSessions();
      if (mounted) {
        if (success) {
          RampToast.showSuccess(
            context,
            message: 'All other device sessions have been revoked.',
            title: 'Sessions Terminated',
          );
        } else {
          RampToast.showError(
            context,
            message: 'Could not revoke other device sessions.',
          );
        }
      }
    }
  }

  Future<void> _handleClearCache() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear App Storage & Cache?'),
        content: const Text('This will clear offline database JSON logs, image memory, and HTTP cache. Your account session will remain active.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: RampTheme.primaryBlue),
            child: const Text('Clear Cache'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final success = await ref.read(sessionProvider.notifier).clearAppCache();
      if (mounted) {
        if (success) {
          RampToast.showSuccess(
            context,
            message: 'Local database cache and memory cleared successfully.',
            title: 'Cache Cleared',
          );
        } else {
          RampToast.showError(
            context,
            message: 'Failed to clear local cache.',
          );
        }
      }
    }
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    RampToast.showSuccess(
      context,
      message: '$label copied to clipboard.',
      title: 'Copied',
    );
  }

  @override
  Widget build(BuildContext context) {
    final sessionState = ref.watch(sessionProvider);
    final nowSession = sessionState.nowSession;
    final cacheSummary = sessionState.cacheSummary;

    return Scaffold(
      backgroundColor: RampTheme.scaffoldBackground,
      appBar: AppBar(
        title: const Text('Active Sessions & Security'),
        backgroundColor: RampTheme.scaffoldBackground,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => ref.read(sessionProvider.notifier).loadSessionData(),
            tooltip: 'Refresh Session Info',
          ),
        ],
      ),
      body: sessionState.isLoading
          ? ListView(
              padding: const EdgeInsets.all(16),
              children: const [
                RampSkeletonBox(width: double.infinity, height: 200, borderRadius: 16),
                SizedBox(height: 16),
                RampSkeletonBox(width: double.infinity, height: 180, borderRadius: 16),
                SizedBox(height: 16),
                RampSkeletonBox(width: double.infinity, height: 220, borderRadius: 16),
              ],
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section 1: ACTIVE NOW SESSION CARD
                  _buildHeaderTitle('Current Active Session ("Now Session")'),
                  const SizedBox(height: 8),
                  if (nowSession != null)
                    _buildNowSessionCard(nowSession)
                  else
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'No active session details loaded.',
                          style: GoogleFonts.inter(color: RampTheme.textSecondary),
                        ),
                      ),
                    ),

                  const SizedBox(height: 24),

                  // Section 2: SESSION SECURITY ACTIONS
                  _buildHeaderTitle('Session Security Controls'),
                  const SizedBox(height: 8),
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: RampTheme.primaryBlue.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.autorenew_rounded, color: RampTheme.primaryBlue),
                            ),
                            title: Text(
                              'Refresh Active Session Token',
                              style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 15),
                            ),
                            subtitle: const Text('Extend current token validity with auth server'),
                            trailing: ElevatedButton(
                              onPressed: sessionState.isActionInProgress ? null : _handleRefreshSession,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              ),
                              child: sessionState.isActionInProgress
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                    )
                                  : const Text('Refresh'),
                            ),
                          ),
                          const Divider(height: 24),
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: RampTheme.errorRed.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.devices_other_rounded, color: RampTheme.errorRed),
                            ),
                            title: Text(
                              'Revoke Other Devices',
                              style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 15),
                            ),
                            subtitle: const Text('Sign out all other logged in platforms/browsers'),
                            trailing: OutlinedButton(
                              onPressed: sessionState.isActionInProgress ? null : _handleRevokeOthers,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: RampTheme.errorRed,
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              ),
                              child: const Text('Revoke'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Section 3: STORAGE & CACHE MANAGEMENT
                  _buildHeaderTitle('Cache & Storage Inspection'),
                  const SizedBox(height: 8),
                  if (cacheSummary != null) _buildCacheStorageCard(cacheSummary, sessionState.isActionInProgress),
                ],
              ),
            ),
    );
  }

  Widget _buildHeaderTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: RampTheme.textPrimary,
      ),
    );
  }

  Widget _buildNowSessionCard(SessionInfo session) {
    final dateFormat = DateFormat('MMM dd, yyyy · hh:mm a');

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: RampTheme.successGreen.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.phone_android_rounded, color: RampTheme.successGreen, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              session.deviceName,
                              style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              session.appVersion,
                              style: GoogleFonts.inter(fontSize: 12, color: RampTheme.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: RampTheme.successGreen.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: RampTheme.successGreen,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Active Now',
                        style: GoogleFonts.inter(
                          color: RampTheme.successGreen,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            _buildDetailRow('Platform / Operating System', session.osVersion),
            const SizedBox(height: 8),
            _buildDetailRow('IP Address & Security', session.ipAddress),
            const SizedBox(height: 8),
            _buildDetailRow('Session Initialized', dateFormat.format(session.createdAt)),
            if (session.expiresAt != null) ...[
              const SizedBox(height: 8),
              _buildDetailRow('Token Expiration Date', dateFormat.format(session.expiresAt!)),
            ],
            const SizedBox(height: 12),
            InkWell(
              onTap: () => _copyToClipboard(session.fullToken.isNotEmpty ? session.fullToken : session.tokenPreview, 'Session Token'),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: RampTheme.primaryBlue.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: RampTheme.primaryBlue.withValues(alpha: 0.2)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'JWT Access Token',
                            style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: RampTheme.textSecondary),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            session.tokenPreview,
                            style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: RampTheme.primaryBlue),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.copy_rounded, size: 18, color: RampTheme.primaryBlue),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(fontSize: 13, color: RampTheme.textSecondary),
        ),
        Flexible(
          child: Text(
            value,
            style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: RampTheme.textPrimary),
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildCacheStorageCard(CacheSummary summary, bool isActionInProgress) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildCacheStorageItem(
              icon: Icons.storage_rounded,
              title: 'Offline Database Cache',
              subtitle: 'Units, Tenants, Payments, & Maintenance JSON logs',
              sizeText: summary.databaseCacheFormatted,
            ),
            const Divider(height: 20),
            _buildCacheStorageItem(
              icon: Icons.image_rounded,
              title: 'Image & Memory Cache',
              subtitle: 'Cached property receipts, avatars, & documents',
              sizeText: summary.imageCacheFormatted,
            ),
            const Divider(height: 20),
            _buildCacheStorageItem(
              icon: Icons.cookie_rounded,
              title: 'Auth Tokens & Storage Cookies',
              subtitle: 'Encrypted Supabase auth keys & session credentials',
              sizeText: summary.cookiesAndTokensFormatted,
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total App Storage',
                      style: GoogleFonts.inter(fontSize: 13, color: RampTheme.textSecondary),
                    ),
                    Text(
                      summary.totalStorageFormatted,
                      style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: RampTheme.primaryBlue),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: isActionInProgress ? null : _handleClearCache,
                  icon: const Icon(Icons.cleaning_services_rounded, size: 18),
                  label: const Text('Clear Cache'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: RampTheme.primaryBlue,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCacheStorageItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required String sizeText,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: RampTheme.primaryBlue.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: RampTheme.primaryBlue, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: GoogleFonts.inter(fontSize: 12, color: RampTheme.textSecondary),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          sizeText,
          style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13, color: RampTheme.textPrimary),
        ),
      ],
    );
  }
}
