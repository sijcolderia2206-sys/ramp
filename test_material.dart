import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    home: Scaffold(
      body: Center(
        child: Container(
          decoration: BoxDecoration(color: Colors.red),
          child: Material(
            type: MaterialType.transparency,
            child: ListTile(
              title: const Text('Test'),
              tileColor: Colors.blue,
              onTap: () {},
            ),
          ),
        ),
      ),
    ),
  ));
}
