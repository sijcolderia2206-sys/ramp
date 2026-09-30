import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Test ExpansionTile', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.black12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Material(
                type: MaterialType.transparency,
                child: ExpansionTile(
                  title: const Text('Test'),
                  children: [
                    ListTile(title: Text('Child')),
                  ],
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
