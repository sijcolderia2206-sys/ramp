// lib/features/settings/sub_screens/notification_settings_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/state/ramp_state.dart';
import '../../../core/theme/ramp_theme.dart';
import '../../../core/utils/toast_service.dart';

class NotificationSettingsScreen extends ConsumerWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final pushEnabled = ref.watch(pushNotificationsEnabledProvider);
    final dueReminders = ref.watch(rentDueRemindersEnabledProvider);
    final slaAlerts = ref.watch(slaAlertsEnabledProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Notifications & Alerts',
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
                    'SYSTEM NOTIFICATION PREFERENCES',
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
                            child: const Icon(Icons.notifications_active_rounded,
                                color: RampColors.primary, size: 20),
                          ),
                          title: Text(
                            'Allow Push Notifications',
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          subtitle: Text(
                            'Receive real-time mobile push notifications',
                            style: GoogleFonts.poppins(fontSize: 12),
                          ),
                          value: pushEnabled,
                          activeTrackColor: RampColors.primary,
                          onChanged: (val) {
                            HapticFeedback.lightImpact();
                            ref
                                .read(pushNotificationsEnabledProvider.notifier)
                                .state = val;
                            persistAppSettings(pushNotificationsEnabled: val);
                            ToastService.showSuccess(
                              val
                                  ? 'Push notifications enabled'
                                  : 'Push notifications muted',
                            );
                          },
                        ),
                        const Divider(height: 1),
                        SwitchListTile(
                          secondary: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: RampColors.warningTint,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.alarm_rounded,
                                color: RampColors.warning, size: 20),
                          ),
                          title: Text(
                            'Rent Due Reminders',
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          subtitle: Text(
                            'Alert landlord 3 days before tenant rent deadline',
                            style: GoogleFonts.poppins(fontSize: 12),
                          ),
                          value: dueReminders,
                          activeTrackColor: RampColors.primary,
                          onChanged: pushEnabled
                              ? (val) {
                                  HapticFeedback.lightImpact();
                                  ref
                                      .read(rentDueRemindersEnabledProvider
                                          .notifier)
                                      .state = val;
                                  persistAppSettings(
                                      rentDueRemindersEnabled: val);
                                  ToastService.showSuccess(
                                    val
                                        ? 'Rent due reminders enabled'
                                        : 'Rent due reminders disabled',
                                  );
                                }
                              : null,
                        ),
                        const Divider(height: 1),
                        SwitchListTile(
                          secondary: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: RampColors.dangerTint,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.build_circle_rounded,
                                color: RampColors.danger, size: 20),
                          ),
                          title: Text(
                            'SLA Maintenance Alerts',
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          subtitle: Text(
                            'Alert when emergency repair ticket approaches SLA breach',
                            style: GoogleFonts.poppins(fontSize: 12),
                          ),
                          value: slaAlerts,
                          activeTrackColor: RampColors.primary,
                          onChanged: pushEnabled
                              ? (val) {
                                  HapticFeedback.lightImpact();
                                  ref
                                      .read(slaAlertsEnabledProvider.notifier)
                                      .state = val;
                                  persistAppSettings(slaAlertsEnabled: val);
                                  ToastService.showSuccess(
                                    val
                                        ? 'Maintenance SLA alerts enabled'
                                        : 'Maintenance SLA alerts disabled',
                                  );
                                }
                              : null,
                        ),
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
