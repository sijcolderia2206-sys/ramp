import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ramp/core/widgets/clay_container.dart';

void main() {
  testWidgets('Test ClayContainer with ListTile', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: ClayContainer(
              color: Colors.white,
              child: ListTile(
                title: const Text('Test'),
                selectedColor: const Color(0xFF0D6EFD),
                selected: true,
                onTap: () {},
              ),
            ),
          ),
        ),
      ),
    );
    expect(find.text('Test'), findsOneWidget);
    await tester.tap(find.byType(ListTile));
    await tester.pumpAndSettle();
  });
}
