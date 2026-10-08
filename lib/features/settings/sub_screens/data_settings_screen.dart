// lib/features/settings/sub_screens/data_settings_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/services/persistence_queue.dart';
import '../../../core/services/report_export_service.dart';
import '../../../core/state/ramp_state.dart';
import '../../../core/theme/ramp_theme.dart';
import '../../../core/utils/toast_service.dart';

class DataSettingsScreen extends ConsumerWidget {
  const DataSettingsScreen({super.key});

  void _showExportReportDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            'Export Financial & Property Report',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Generate a complete report containing financial ledger summaries, unit occupancy statuses, and rent roll details.',
            style: GoogleFonts.poppins(fontSize: 13),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('CANCEL'),
            ),
            FilledButton.icon(
              onPressed: () async {
                Navigator.pop(dialogContext);
                ToastService.showInfo('Generating report…');
                try {
                  final units = ref.read(unitProvider);
                  final tenants = ref.read(tenantProvider);
                  final payments = ref.read(paymentProvider);

                  await ReportExportService.exportLandlordReport(
                    units: units,
                    tenants: tenants,
                    payments: payments,
                  );
                  ToastService.showSuccess('Report exported successfully!');
                } catch (e) {
                  ToastService.showError('Failed to export report: $e');
                }
              },
              icon: const Icon(Icons.picture_as_pdf_rounded),
              label: const Text('GENERATE REPORT'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final autoBackup = ref.watch(autoBackupProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Data, Backup & Export',
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
                    'CLOUD BACKUP & SYNCHRONIZATION',
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
                            child: const Icon(Icons.cloud_sync_rounded,
                                color: RampColors.primary, size: 20),
                          ),
                          title: Text(
                            'Auto Cloud Backup',
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          subtitle: Text(
                            'Automatically sync changes to Supabase & Firestore cloud database',
                            style: GoogleFonts.poppins(fontSize: 12),
                          ),
                          value: autoBackup,
                          activeTrackColor: RampColors.primary,
                          onChanged: (val) {
                            HapticFeedback.lightImpact();
                            ref.read(autoBackupProvider.notifier).state = val;
                            persistAppSettings(autoBackupEnabled: val);
                            ToastService.showSuccess(
                              val
                                  ? 'Auto cloud backup enabled'
                                  : 'Auto cloud backup paused',
                            );
                          },
                        ),
                        const Divider(height: 1),
                        ValueListenableBuilder<PersistenceQueueState>(
                          valueListenable: PersistenceQueue.instance,
                          builder: (context, queueState, child) {
                            final pendingCount = queueState.tasks.length;
                            return ListTile(
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: pendingCount > 0
                                      ? RampColors.warningTint
                                      : RampColors.softBlueTint,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  pendingCount > 0
                                      ? Icons.sync_problem_rounded
                                      : Icons.check_circle_rounded,
                                  color: pendingCount > 0
                                      ? RampColors.warning
                                      : const Color(0xFF10B981),
                                  size: 20,
                                ),
                              ),
                              title: Text(
                                'Offline Persistence Engine',
                                style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              subtitle: Text(
                                pendingCount > 0
                                    ? '$pendingCount offline mutation(s) queued'
                                    : 'All local changes synchronized with backend',
                                style: GoogleFonts.poppins(fontSize: 12),
                              ),
                              trailing: OutlinedButton.icon(
                                onPressed: () async {
                                  ToastService.showInfo(
                                      'Processing sync queue…');
                                  await PersistenceQueue.instance.retry();
                                  ToastService.showSuccess(
                                      'Sync queue processed.');
                                },
                                icon: const Icon(Icons.refresh_rounded, size: 16),
                                label: const Text('SYNC NOW'),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  Text(
                    'REPORTS & DATA EXPORT',
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
                    child: ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: RampColors.dangerTint,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.picture_as_pdf_rounded,
                            color: RampColors.danger, size: 20),
                      ),
                      title: Text(
                        'Export Financial Ledger Report',
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      subtitle: Text(
                        'Generate complete property report, rent roll, and unit statuses',
                        style: GoogleFonts.poppins(fontSize: 12),
                      ),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () => _showExportReportDialog(context, ref),
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
