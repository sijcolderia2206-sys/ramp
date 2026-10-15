// test/widget_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ramp/main.dart';

void main() {
  testWidgets('RAMP Landlord App smokescreen test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: RampLandlordApp(),
      ),
    );

    await tester.pump();

    expect(find.text('RAMP Portal'), findsOneWidget);
    expect(find.text('Sign in to your account'), findsOneWidget);
  });
}
