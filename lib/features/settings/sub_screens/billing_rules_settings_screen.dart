// lib/features/settings/sub_screens/billing_rules_settings_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../core/state/ramp_state.dart';
import '../../../core/theme/ramp_theme.dart';
import '../../../core/utils/toast_service.dart';

class BillingRulesSettingsScreen extends ConsumerStatefulWidget {
  const BillingRulesSettingsScreen({super.key});

  @override
  ConsumerState<BillingRulesSettingsScreen> createState() =>
      _BillingRulesSettingsScreenState();
}

class _BillingRulesSettingsScreenState
    extends ConsumerState<BillingRulesSettingsScreen> {
  final _currencyFormat =
      NumberFormat.currency(locale: 'en_PH', symbol: '₱', decimalDigits: 2);

  void _showEditLateFeeDialog() {
    final currentFee = ref.read(lateFeeAmountProvider);
    final controller =
        TextEditingController(text: currentFee.toStringAsFixed(0));

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            'Edit Default Late Fee',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
          content: TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              labelText: 'Late Fee Amount (₱)',
              prefixText: '₱ ',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('CANCEL'),
            ),
            FilledButton(
              onPressed: () {
                final newFee = double.tryParse(controller.text);
                if (newFee != null && newFee >= 0) {
                  ref.read(lateFeeAmountProvider.notifier).state = newFee;
                  persistAppSettings(defaultLateFee: newFee);
                  ToastService.showSuccess(
                      'Default late fee updated to ${_currencyFormat.format(newFee)}');
                }
                Navigator.pop(dialogContext);
              },
              child: const Text('SAVE'),
            ),
          ],
        );
      },
    );
  }

  void _showEditDueDateDialog() {
    int selectedDay = ref.read(dueDateDayProvider);

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(
                'Default Rent Due Date',
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Select recurring day of month for rent deadline:',
                    style: GoogleFonts.poppins(fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    initialValue: selectedDay,
                    decoration: const InputDecoration(
                      labelText: 'Due Day',
                      border: OutlineInputBorder(),
                    ),
                    items: List.generate(
                      31,
                      (index) => DropdownMenuItem(
                        value: index + 1,
                        child: Text('${index + 1}th of every month'),
                      ),
                    ),
                    onChanged: (val) {
                      if (val != null) {
                        setDialogState(() => selectedDay = val);
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('CANCEL'),
                ),
                FilledButton(
                  onPressed: () {
                    ref.read(dueDateDayProvider.notifier).state = selectedDay;
                    persistAppSettings(defaultDueDay: selectedDay);
                    ToastService.showSuccess(
                        'Default rent due date set to ${selectedDay}th of month');
                    Navigator.pop(dialogContext);
                  },
                  child: const Text('SAVE'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showUpdateUtilityRateDialog(String utility) {
    final utilityState = ref.read(utilityRateProvider);
    final isWater = utility == 'Water';
    final currentRate =
        isWater ? utilityState.waterRate : utilityState.electricityRate;
    final controller = TextEditingController(text: currentRate.toString());

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            'Update $utility Rate',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
          content: TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: 'Rate (₱ per ${isWater ? 'cu.m' : 'kWh'})',
              prefixText: '₱ ',
              border: const OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('CANCEL'),
            ),
            FilledButton(
              onPressed: () {
                final newRate = double.tryParse(controller.text);
                if (newRate != null && newRate > 0) {
                  ref.read(utilityRateProvider.notifier).updateRate(
                        utility: utility,
                        newRate: newRate,
                        note: 'Updated via Billing Settings',
                      );
                  ToastService.showSuccess(
                      '$utility rate updated to ₱${newRate.toStringAsFixed(2)}');
                }
                Navigator.pop(dialogContext);
              },
              child: const Text('SAVE'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final lateFee = ref.watch(lateFeeAmountProvider);
    final dueDateDay = ref.watch(dueDateDayProvider);
    final autoLateFee = ref.watch(autoLateFeeEnabledProvider);
    final utilityState = ref.watch(utilityRateProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Financial & Billing Rules',
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
                    'RENT & LATE FEES',
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
                        ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: RampColors.softBlueTint,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.event_note_rounded,
                                color: RampColors.primary, size: 20),
                          ),
                          title: Text(
                            'Default Rent Due Date',
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          subtitle: Text(
                            'Day of month rent is due for units without override',
                            style: GoogleFonts.poppins(fontSize: 12),
                          ),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: RampColors.softBlueTint,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${dueDateDay}th / month',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: RampColors.primary,
                              ),
                            ),
                          ),
                          onTap: _showEditDueDateDialog,
                        ),
                        const Divider(height: 1),
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
                            'Default Late Fee Amount',
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          subtitle: Text(
                            'Penalty applied when payment is past due date',
                            style: GoogleFonts.poppins(fontSize: 12),
                          ),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: RampColors.warningTint,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              _currencyFormat.format(lateFee),
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: const Color(0xFFD97706),
                              ),
                            ),
                          ),
                          onTap: _showEditLateFeeDialog,
                        ),
                        const Divider(height: 1),
                        SwitchListTile(
                          secondary: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: RampColors.softBlueTint,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.auto_awesome_rounded,
                                color: RampColors.primary, size: 20),
                          ),
                          title: Text(
                            'Auto Late Fee Engine',
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          subtitle: Text(
                            'Automatically add late penalty when tenant goes overdue',
                            style: GoogleFonts.poppins(fontSize: 12),
                          ),
                          value: autoLateFee,
                          activeTrackColor: RampColors.primary,
                          onChanged: (val) {
                            HapticFeedback.lightImpact();
                            ref
                                .read(autoLateFeeEnabledProvider.notifier)
                                .state = val;
                            persistAppSettings(autoLateFeeEnabled: val);
                            ToastService.showSuccess(
                              val
                                  ? 'Automatic late fee engine enabled'
                                  : 'Automatic late fee engine disabled',
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  Text(
                    'UTILITY SUBMETER RATES',
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
                        ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: RampColors.softBlueTint,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.water_drop_rounded,
                                color: RampColors.primary, size: 20),
                          ),
                          title: Text(
                            'Water Rate',
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          subtitle: Text(
                            'Base price per cubic meter (cu.m)',
                            style: GoogleFonts.poppins(fontSize: 12),
                          ),
                          trailing: Text(
                            '₱${utilityState.waterRate.toStringAsFixed(2)} / m³',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: RampColors.primary,
                            ),
                          ),
                          onTap: () => _showUpdateUtilityRateDialog('Water'),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: RampColors.warningTint,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.bolt_rounded,
                                color: RampColors.warning, size: 20),
                          ),
                          title: Text(
                            'Electricity Rate',
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          subtitle: Text(
                            'Base price per kilowatt-hour (kWh)',
                            style: GoogleFonts.poppins(fontSize: 12),
                          ),
                          trailing: Text(
                            '₱${utilityState.electricityRate.toStringAsFixed(2)} / kWh',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: const Color(0xFFD97706),
                            ),
                          ),
                          onTap: () =>
                              _showUpdateUtilityRateDialog('Electricity'),
                        ),
                      ],
                    ),
                  ),

                  if (utilityState.history.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Text(
                      'RATE CHANGE LOGS',
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
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: utilityState.history.length.clamp(0, 5),
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final change = utilityState.history[index];
                          final dateStr = DateFormat('MMM d, yyyy')
                              .format(change.effectiveAt);
                          return ListTile(
                            dense: true,
                            title: Text(
                              '${change.utility}: ₱${change.previousRate.toStringAsFixed(2)} → ₱${change.newRate.toStringAsFixed(2)}',
                              style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600, fontSize: 13),
                            ),
                            subtitle: Text(
                              '$dateStr ${change.note.isNotEmpty ? "• ${change.note}" : ""}',
                              style: GoogleFonts.poppins(fontSize: 11),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
