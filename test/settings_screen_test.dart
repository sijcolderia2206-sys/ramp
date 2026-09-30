import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ramp/features/settings/settings_screen.dart';
import 'package:ramp/theme.dart';

void main() {
  for (final brightness in Brightness.values) {
    testWidgets(
      'Settings has no overflow on a narrow $brightness screen',
      (tester) async {
        tester.view.physicalSize = const Size(320, 700);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: brightness == Brightness.dark
                  ? ThemeMode.dark
                  : ThemeMode.light,
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: const TextScaler.linear(1.5),
                ),
                child: child!,
              ),
              home: const SettingsScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);

        final biometric = find.text('Biometric Authentication');
        await tester.scrollUntilVisible(
          biometric,
          300,
          scrollable: find.byType(Scrollable).last,
        );
        expect(biometric, findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
