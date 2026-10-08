// lib/features/settings/sub_screens/security_settings_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../core/services/audit_service.dart';
import '../../../core/state/ramp_state.dart';
import '../../../core/theme/ramp_theme.dart';
import '../../../core/utils/toast_service.dart';

class SecuritySettingsScreen extends ConsumerWidget {
  const SecuritySettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final biometrics = ref.watch(biometricsEnabledProvider);
    final authOnResume = ref.watch(requireAuthOnResumeProvider);
    final auditLogs = ref.watch(auditServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Security & Privacy',
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
                  Text(
                    'AUTHENTICATION & ACCESS',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                      color: isDark ? const Color(0xFF94A3B8) : RampColors.mutedText,
                    ),
                  ),
                  const SizedBox(height: 12),

                  RampCard(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      children: [
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
                            ref.read(auditServiceProvider.notifier).logAction(
                                  'TOGGLE_BIOMETRICS',
                                  'Biometrics set to ${val ? "Enabled" : "Disabled"}',
                                );
                            ToastService.showSuccess(
                              val
                                  ? 'Biometric authentication enabled'
                                  : 'Biometric authentication disabled',
                            );
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
                            child: const Icon(Icons.lock_clock_rounded,
                                color: RampColors.primary, size: 20),
                          ),
                          title: Text(
                            'Require Lock on Resume',
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          subtitle: Text(
                            'Re-verify identity when returning from background',
                            style: GoogleFonts.poppins(fontSize: 12),
                          ),
                          value: authOnResume,
                          activeTrackColor: RampColors.primary,
                          onChanged: (val) {
                            HapticFeedback.lightImpact();
                            ref
                                .read(requireAuthOnResumeProvider.notifier)
                                .state = val;
                            persistAppSettings(requireAuthOnResume: val);
                            ToastService.showSuccess(
                              val
                                  ? 'App lock on resume enabled'
                                  : 'App lock on resume disabled',
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  Text(
                    'SECURITY AUDIT TRAIL LOGS',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                      color: isDark ? const Color(0xFF94A3B8) : RampColors.mutedText,
                    ),
                  ),
                  const SizedBox(height: 12),

                  RampCard(
                    padding: const EdgeInsets.all(8),
                    child: auditLogs.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Center(
                              child: Text(
                                'No security audit logs recorded yet.',
                                style: GoogleFonts.poppins(
                                  color: theme.colorScheme.onSurfaceVariant,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          )
                        : ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: auditLogs.length.clamp(0, 8),
                            separatorBuilder: (_, __) =>
                                const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final log = auditLogs[index];
                              final timeStr = DateFormat('MMM d, h:mm a')
                                  .format(log.timestamp);
                              return ListTile(
                                leading: CircleAvatar(
                                  radius: 16,
                                  backgroundColor: RampColors.primary
                                      .withValues(alpha: 0.1),
                                  child: const Icon(Icons.shield_rounded,
                                      size: 16, color: RampColors.primary),
                                ),
                                title: Text(
                                  log.action,
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                                subtitle: Text(
                                  log.details,
                                  style: GoogleFonts.poppins(fontSize: 11),
                                ),
                                trailing: Text(
                                  timeStr,
                                  style: GoogleFonts.poppins(
                                    fontSize: 10,
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              );
                            },
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
