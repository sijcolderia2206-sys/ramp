import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Test Material Transparency with ListTile',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Container(
              decoration: const BoxDecoration(color: Colors.red),
              child: Material(
                type: MaterialType.transparency,
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
      ),
    );
    expect(find.text('Test'), findsOneWidget);
  });
}
