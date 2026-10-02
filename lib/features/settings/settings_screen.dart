import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/state/ramp_state.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final isDarkMode = themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SwitchListTile(
            title: const Text('Dark Mode'),
            subtitle: const Text('Toggle app appearance theme'),
            value: isDarkMode,
            onChanged: (val) {
              ref.read(themeModeProvider.notifier).state =
                  val ? ThemeMode.dark : ThemeMode.light;
              ref.read(darkModeProvider.notifier).state = val;
            },
          ),
          const Divider(),
          ListTile(
            title: const Text('Biometric Authentication'),
            subtitle: const Text('Require Face ID / Touch ID for app unlock'),
            trailing: Switch(value: false, onChanged: (_) {}),
          ),
          const Divider(),
          ListTile(
            title: const Text('About RAMP'),
            subtitle:
                const Text('Rental Administration Management Platform v1.0.0'),
            trailing: const Icon(Icons.info_outline_rounded),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
