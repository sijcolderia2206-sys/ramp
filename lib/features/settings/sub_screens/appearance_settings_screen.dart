// lib/features/settings/sub_screens/appearance_settings_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/state/ramp_state.dart';
import '../../../core/theme/ramp_theme.dart';
import '../../../core/utils/toast_service.dart';

class AppearanceSettingsScreen extends ConsumerWidget {
  const AppearanceSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isDarkModeState = ref.watch(darkModeProvider);
    final compactMode = ref.watch(compactModeProvider);
    final currencySymbol = ref.watch(currencySymbolProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Appearance & Display',
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
                    'THEME & VISUAL STYLE',
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
                            decoration: BoxDecoration(
                              color: isDarkModeState
                                  ? const Color(0xFF334155)
                                  : const Color(0xFFF1F5F9),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isDarkModeState
                                  ? Icons.dark_mode_rounded
                                  : Icons.light_mode_rounded,
                              color: isDarkModeState
                                  ? Colors.amber
                                  : theme.colorScheme.onSurface,
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
                            style: GoogleFonts.poppins(fontSize: 12),
                          ),
                          value: isDarkModeState,
                          activeTrackColor: RampColors.primary,
                          onChanged: (val) {
                            HapticFeedback.lightImpact();
                            ref.read(darkModeProvider.notifier).state = val;
                            persistAppSettings(darkMode: val);
                            ToastService.showSuccess(
                              val
                                  ? 'Dark theme activated'
                                  : 'Light theme activated',
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
                            child: const Icon(Icons.density_medium_rounded,
                                color: RampColors.primary, size: 20),
                          ),
                          title: Text(
                            'Compact Data Density',
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          subtitle: Text(
                            'Use tighter padding for data-heavy dashboard tables',
                            style: GoogleFonts.poppins(fontSize: 12),
                          ),
                          value: compactMode,
                          activeTrackColor: RampColors.primary,
                          onChanged: (val) {
                            HapticFeedback.lightImpact();
                            ref.read(compactModeProvider.notifier).state = val;
                            persistAppSettings(compactMode: val);
                            ToastService.showSuccess(
                              val
                                  ? 'Compact layout density enabled'
                                  : 'Standard layout density enabled',
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  Text(
                    'CURRENCY & FORMATTING',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                      color: isDark ? const Color(0xFF94A3B8) : RampColors.mutedText,
                    ),
                  ),
                  const SizedBox(height: 12),

                  RampCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Preferred Currency Symbol',
                          style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Primary symbol used across ledger and receipt displays',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            ChoiceChip(
                              label: const Text('₱ Philippine Peso (PHP)'),
                              selected: currencySymbol == '₱',
                              selectedColor: RampColors.primary,
                              labelStyle: TextStyle(
                                color: currencySymbol == '₱'
                                    ? Colors.white
                                    : theme.colorScheme.onSurface,
                                fontWeight: FontWeight.bold,
                              ),
                              onSelected: (selected) {
                                if (selected) {
                                  ref
                                      .read(currencySymbolProvider.notifier)
                                      .state = '₱';
                                  persistAppSettings(currencySymbol: '₱');
                                }
                              },
                            ),
                            const SizedBox(width: 12),
                            ChoiceChip(
                              label: const Text('\$ US Dollar (USD)'),
                              selected: currencySymbol == '\$',
                              selectedColor: RampColors.primary,
                              labelStyle: TextStyle(
                                color: currencySymbol == '\$'
                                    ? Colors.white
                                    : theme.colorScheme.onSurface,
                                fontWeight: FontWeight.bold,
                              ),
                              onSelected: (selected) {
                                if (selected) {
                                  ref
                                      .read(currencySymbolProvider.notifier)
                                      .state = '\$';
                                  persistAppSettings(currencySymbol: '\$');
                                }
                              },
                            ),
                          ],
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
