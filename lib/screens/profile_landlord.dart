import 'dart:io';
import '../core/widgets/adaptive_row.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../core/navigation/custom_page_transitions.dart';
import '../core/services/report_export_service.dart';
import '../core/state/ramp_state.dart';
import '../core/theme/ramp_theme.dart';
import '../core/utils/toast_service.dart';
import '../features/settings/settings_screen.dart';
import '../features/settings/sub_screens/billing_rules_settings_screen.dart';
import '../features/settings/sub_screens/security_settings_screen.dart';
import 'landlord_profile_edit_screen.dart';

class ProfileLandlordScreen extends ConsumerStatefulWidget {
  const ProfileLandlordScreen({super.key});

  @override
  ConsumerState<ProfileLandlordScreen> createState() =>
      _ProfileLandlordScreenState();
}

class _ProfileLandlordScreenState extends ConsumerState<ProfileLandlordScreen> {
  final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'en_PH',
    symbol: '₱',
    decimalDigits: 2,
  );

  void _showLogoutDialog(BuildContext context) {
    HapticFeedback.heavyImpact();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: RampColors.dangerTint,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.logout_rounded,
                  color: RampColors.danger, size: 22),
            ),
            const SizedBox(width: 10),
            Text(
              'Log Out',
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Text(
          "Are you sure you want to log out of Emin and Mila's Property Management?",
          style: GoogleFonts.poppins(fontSize: 14),
        ),
        actions: [
          TextButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close_rounded, size: 16),
            label: Text(
              'CANCEL',
              style: GoogleFonts.poppins(
                color: RampColors.mutedText,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: RampColors.danger,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            icon: const Icon(Icons.logout_rounded, size: 18),
            onPressed: () async {
              Navigator.pop(context);
              await FirebaseAuth.instance.signOut();
              if (!mounted) return;
              ref.read(authProvider.notifier).state = null;
            },
            label: Text(
              'LOG OUT',
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _showExportReportDialog(BuildContext context) {
    String reportType = 'Financial Summary';
    String timeFrame = 'This Month';
    bool isGenerating = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: SafeArea(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.sizeOf(context).height * 0.82,
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: const BoxDecoration(
                                      color: RampColors.dangerTint,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                        Icons.picture_as_pdf_rounded,
                                        color: RampColors.danger,
                                        size: 24),
                                  ),
                                  const SizedBox(width: 12),
                                  Flexible(
                                    child: Text(
                                      'Export Report PDF',
                                      style: GoogleFonts.poppins(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close_rounded),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Report Type',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<String>(
                          isExpanded: true,
                          initialValue: reportType,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12)),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 12),
                          ),
                          items: const [
                            DropdownMenuItem(
                                value: 'Financial Summary',
                                child: Text(
                                  'Financial Summary & Income Statement',
                                  overflow: TextOverflow.ellipsis,
                                )),
                            DropdownMenuItem(
                                value: 'Occupancy & Vacancy',
                                child: Text('Unit Occupancy & Rent Roll',
                                    overflow: TextOverflow.ellipsis)),
                            DropdownMenuItem(
                                value: 'Payments History',
                                child: Text('Payment Ledger & Receipts Audit',
                                    overflow: TextOverflow.ellipsis)),
                            DropdownMenuItem(
                                value: 'Maintenance Tickets',
                                child: Text('Maintenance Ticket Resolution Log',
                                    overflow: TextOverflow.ellipsis)),
                          ],
                          onChanged: (val) {
                            if (val != null) {
                              setModalState(() => reportType = val);
                            }
                          },
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'Time Period',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            'This Month',
                            'Last Quarter',
                            'Year to Date',
                            'All Time'
                          ].map((tf) {
                            final isSel = tf == timeFrame;
                            return ChoiceChip(
                              label: Text(tf),
                              selected: isSel,
                              selectedColor: RampColors.primary,
                              labelStyle: TextStyle(
                                color:
                                    isSel ? Colors.white : RampColors.mutedText,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                              onSelected: (selected) {
                                if (selected) {
                                  setModalState(() => timeFrame = tf);
                                }
                              },
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 20),
                        if (isGenerating) ...[
                          const LinearProgressIndicator(
                              color: RampColors.primary),
                          const SizedBox(height: 12),
                          Center(
                            child: Text(
                              "Generating PDF document for Emin and Mila's...",
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                  fontSize: 12, color: RampColors.mutedText),
                            ),
                          ),
                          const SizedBox(height: 12),
                        ] else ...[
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: RampColors.danger,
                                foregroundColor: Colors.white,
                                minimumSize: const Size.fromHeight(50),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              icon: const Icon(Icons.download_rounded),
                              label: Text(
                                'EXPORT PDF REPORT',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              onPressed: () async {
                                setModalState(() => isGenerating = true);
                                try {
                                  final path = await ReportExportService
                                      .exportLandlordReport(
                                    reportType: reportType,
                                    timeFrame: timeFrame,
                                    units: ref.read(unitProvider),
                                    tenants: ref.read(tenantProvider),
                                    payments: ref.read(paymentProvider),
                                    tickets: ref.read(ticketProvider),
                                  );
                                  if (!context.mounted) return;
                                  Navigator.pop(context);
                                  HapticFeedback.mediumImpact();
                                  ToastService.showInfo('PDF saved to $path');
                                } catch (error) {
                                  setModalState(() => isGenerating = false);
                                  if (!context.mounted) return;
                                  ToastService.showError('Could not export PDF: $error');
                                }
                              },
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showEditLateFeeDialog(BuildContext context) {
    final currentLateFee = ref.read(lateFeeAmountProvider);
    final controller =
        TextEditingController(text: currentLateFee.toInt().toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'App Settings: Late Fee',
            style:
                GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Set monthly penalty charge for rent payments submitted after the due date:',
                style: GoogleFonts.poppins(
                    fontSize: 13, color: RampColors.mutedText),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Late Fee Amount (₱)',
                  prefixText: '₱ ',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: [300, 500, 1000].map((amt) {
                  return ActionChip(
                    label: Text('₱$amt'),
                    onPressed: () => controller.text = amt.toString(),
                  );
                }).toList(),
              ),
            ],
          ),
          actions: [
            TextButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close_rounded, size: 16),
              label: const Text('CANCEL'),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: RampColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              icon: const Icon(Icons.save_rounded, size: 16),
              onPressed: () {
                final newFee = double.tryParse(controller.text) ?? 500.0;
                ref.read(lateFeeAmountProvider.notifier).state = newFee;
                persistAppSettings(defaultLateFee: newFee);
                Navigator.pop(context);
                HapticFeedback.lightImpact();
                ToastService.showSuccess('Late Fee setting updated to ₱${newFee.toInt()}!');
              },
              label: const Text('SAVE SETTING'),
            ),
          ],
        );
      },
    );
  }

  void _showEditDueDateDialog(BuildContext context) {
    final currentDueDate = ref.read(dueDateDayProvider);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'App Settings: Due Date',
            style:
                GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select monthly recurring payment due date:',
                style: GoogleFonts.poppins(
                    fontSize: 13, color: RampColors.mutedText),
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<int>(
                initialValue: currentDueDate,
                decoration: InputDecoration(
                  labelText: 'Due Date of Month',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                items: [1, 5, 10, 15, 20, 25].map((day) {
                  return DropdownMenuItem<int>(
                    value: day,
                    child: Text('${day}th of every month'),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    ref.read(dueDateDayProvider.notifier).state = val;
                    persistAppSettings(defaultDueDay: val);
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close_rounded, size: 16),
              label: const Text('CLOSE'),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: RampColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              icon: const Icon(Icons.save_rounded, size: 16),
              onPressed: () {
                Navigator.pop(context);
                HapticFeedback.lightImpact();
                ToastService.showSuccess(
                    'Monthly Due Date setting updated to ${ref.read(dueDateDayProvider)}th of the month!');
              },
              label: const Text('SAVE SETTING'),
            ),
          ],
        );
      },
    );
  }

  void _showLandlordSettingsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: RampColors.softBlueTint,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.settings_rounded,
                              color: RampColors.primary, size: 24),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Landlord App Settings',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const Divider(height: 24),
                ListTile(
                  leading:
                      const Icon(Icons.settings_suggest_rounded, color: RampColors.primary),
                  title: const Text('All Settings Categories'),
                  subtitle: const Text('Account, billing, security, notifications & data'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.of(context, rootNavigator: true).push(
                      SlideUpFadeRoute(page: const SettingsScreen()),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.monetization_on_rounded,
                      color: Color(0xFFD97706)),
                  title: const Text('Financial & Billing Rules'),
                  subtitle: Text(
                      'Rent due day: ${ref.read(dueDateDayProvider)}th • Late fee: ${_currencyFormat.format(ref.read(lateFeeAmountProvider))}'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.of(context, rootNavigator: true).push(
                      SlideUpFadeRoute(page: const BillingRulesSettingsScreen()),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.security_rounded,
                      color: RampColors.primary),
                  title: const Text('Security & Biometrics'),
                  subtitle: const Text('Authentication, lock policy & audit trail'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.of(context, rootNavigator: true).push(
                      SlideUpFadeRoute(page: const SecuritySettingsScreen()),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(darkModeProvider);
    final lateFee = ref.watch(lateFeeAmountProvider);
    final dueDateDay = ref.watch(dueDateDayProvider);
    final units = ref.watch(unitProvider);
    final tenants = ref.watch(tenantProvider);
    final landlordProfile = ref.watch(landlordProfileProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scheme = Theme.of(context).colorScheme;
    final textColor = scheme.onSurface;
    final accent = isDark ? const Color(0xFF7896CC) : RampColors.primary;
    final muted = scheme.onSurfaceVariant;
    final softBlue = isDark ? const Color(0xFF202B3D) : RampColors.softBlueTint;
    final softWarning =
        isDark ? const Color(0xFF342B1D) : RampColors.warningTint;
    final softDanger = isDark ? const Color(0xFF351F22) : RampColors.dangerTint;

    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Profile',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            tooltip: 'App Settings',
            onPressed: () => _showLandlordSettingsSheet(context),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // LANDLORD HEADER CARD
                  RampCard(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      children: [
                        AdaptiveRow(
                          children: [
                            CircleAvatar(
                              radius: 36,
                              backgroundColor: accent,
                              backgroundImage: (landlordProfile.avatarPath != null &&
                                      landlordProfile.avatarPath!.isNotEmpty &&
                                      File(landlordProfile.avatarPath!).existsSync())
                                  ? FileImage(File(landlordProfile.avatarPath!))
                                  : null,
                              child: (landlordProfile.avatarPath == null ||
                                      landlordProfile.avatarPath!.isEmpty ||
                                      !File(landlordProfile.avatarPath!).existsSync())
                                  ? Text(
                                      landlordProfile.name.trim().isEmpty
                                          ? 'AP'
                                          : landlordProfile.name
                                              .trim()
                                              .substring(0, 1)
                                              .toUpperCase(),
                                      style: GoogleFonts.poppins(
                                        fontSize: 26,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    landlordProfile.name,
                                    style: GoogleFonts.poppins(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: textColor,
                                    ),
                                  ),
                                  Text(
                                    landlordProfile.role,
                                    style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? const Color(0xFF7896CC)
                                          : RampColors.primary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    landlordProfile.contact,
                                    style: GoogleFonts.poppins(
                                      fontSize: 11,
                                      color: muted,
                                    ),
                                  ),
                                  IconButton(
                                    tooltip: 'Edit landlord profile',
                                    icon: Icon(Icons.edit_outlined,
                                        color: accent),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              LandlordProfileEditScreen(
                                            initialName: landlordProfile.name,
                                            initialRole: landlordProfile.role,
                                            initialContact:
                                                landlordProfile.contact,
                                            initialAvatarPath:
                                                landlordProfile.avatarPath,
                                            onSaved: (values) {
                                              ref
                                                  .read(landlordProfileProvider
                                                      .notifier)
                                                  .state = (
                                                name: values.name,
                                                role: values.role,
                                                contact: values.contact,
                                                avatarPath: values.avatarPath,
                                              );
                                              persistAppSettings(
                                                landlordName: values.name,
                                                landlordRole: values.role,
                                                landlordContact: values.contact,
                                                landlordAvatarPath: values.avatarPath,
                                              );
                                            },
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Divider(height: 24, color: scheme.outlineVariant),
                        AdaptiveRow(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildHeaderStat(
                                'Managed Units', '${units.length} Units'),
                            _buildHeaderStat(
                                'Active Tenants', '${tenants.length} Tenants'),
                            _buildHeaderStat(
                                'Monthly Due', '${dueDateDay}th of mo'),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // APP SETTINGS SECTION
                  Row(
                    children: [
                      const Icon(Icons.settings_rounded,
                          size: 20, color: RampColors.primary),
                      const SizedBox(width: 8),
                      Text(
                        'App Settings',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  RampCard(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      children: [
                        // LATE FEE SETTING ₱500
                        ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: softWarning,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.monetization_on_rounded,
                                color: Color(0xFFD97706), size: 20),
                          ),
                          title: Text(
                            'Late Fee Rate',
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          subtitle: Text(
                            'Used when a unit has no custom due date',
                            style: GoogleFonts.poppins(
                                fontSize: 12, color: RampColors.mutedText),
                          ),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: softBlue,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              _currencyFormat.format(lateFee),
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? const Color(0xFF7896CC)
                                    : RampColors.primary,
                              ),
                            ),
                          ),
                          onTap: () => _showEditLateFeeDialog(context),
                        ),
                        Divider(height: 1, color: scheme.outlineVariant),

                        // DEFAULT DUE DATE SETTING
                        ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: softBlue,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.event_note_rounded,
                                color: accent, size: 20),
                          ),
                          title: Text(
                            'Default Rent Due Date',
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          subtitle: Text(
                            'Recurring payment deadline date',
                            style: GoogleFonts.poppins(
                                fontSize: 12, color: RampColors.mutedText),
                          ),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: softBlue,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${dueDateDay}th of month',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: accent,
                              ),
                            ),
                          ),
                          onTap: () => _showEditDueDateDialog(context),
                        ),
                        Divider(height: 1, color: scheme.outlineVariant),

                        // DARK MODE TOGGLE (REQUIREMENTS: [Dark Mode Toggle Icon])
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
                              color: isDarkMode ? Colors.amber : textColor,
                              size: 20,
                            ),
                          ),
                          title: Text(
                            'Dark Mode Theme',
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          subtitle: Text(
                            'Toggle application appearance theme',
                            style: GoogleFonts.poppins(
                                fontSize: 12, color: RampColors.mutedText),
                          ),
                          value: isDarkMode,
                          activeTrackColor: accent,
                          onChanged: (val) {
                            HapticFeedback.lightImpact();
                            ref.read(themeModeProvider.notifier).state =
                                val ? ThemeMode.dark : ThemeMode.light;
                            ref.read(darkModeProvider.notifier).state = val;
                            persistAppSettings(darkMode: val);
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // REPORTS & DATA BACKUP SECTION
                  Row(
                    children: [
                      const Icon(Icons.analytics_rounded,
                          size: 20, color: RampColors.primary),
                      const SizedBox(width: 8),
                      Expanded(
                          child: Text(
                        'Reports & Advanced',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      )),
                    ],
                  ),
                  const SizedBox(height: 8),

                  RampCard(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      children: [
                        // EXPORT REPORT PDF
                        ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: softDanger,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.picture_as_pdf_rounded,
                                color: RampColors.danger, size: 20),
                          ),
                          title: Text(
                            'Export Report PDF',
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          subtitle: Text(
                            'Financial ledger, rent roll, & unit reports',
                            style: GoogleFonts.poppins(
                                fontSize: 12, color: RampColors.mutedText),
                          ),
                          trailing: const Icon(Icons.chevron_right_rounded),
                          onTap: () => _showExportReportDialog(context),
                        ),
                        Divider(height: 1, color: scheme.outlineVariant),

                        // ADVANCED SETTINGS NAVIGATION (REQUIREMENTS: [Settings Icon])
                        ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: softBlue,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.settings_rounded,
                                color: accent, size: 20),
                          ),
                          title: Text(
                            'Advanced Preferences',
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          subtitle: Text(
                            'Security, biometrics, & system notifications',
                            style: GoogleFonts.poppins(
                                fontSize: 12, color: RampColors.mutedText),
                          ),
                          trailing: const Icon(Icons.chevron_right_rounded),
                          onTap: () {
                            Navigator.of(context, rootNavigator: true).push(
                              SlideUpFadeRoute(page: const SettingsScreen()),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // LOGOUT BUTTON (REQUIREMENTS: [Logout Icon])
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                            color: RampColors.danger, width: 1.5),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      icon: const Icon(Icons.logout_rounded,
                          color: RampColors.danger),
                      label: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'LOG OUT OF LANDLORD ACCOUNT',
                          style: GoogleFonts.poppins(
                            color: RampColors.danger,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      onPressed: () => _showLogoutDialog(context),
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFF7896CC)
                : RampColors.primary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 11,
            color: RampColors.mutedText,
          ),
        ),
      ],
    );
  }
}
