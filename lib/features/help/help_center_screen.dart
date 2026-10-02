import 'package:flutter/material.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          ExpansionTile(
            title: Text('How do I record a payment?'),
            children: [
              Padding(
                padding: EdgeInsets.all(12.0),
                child: Text(
                    'Navigate to Payments screen, click "Record Payment", select the tenant and enter amount and reference.'),
              ),
            ],
          ),
          ExpansionTile(
            title: Text('How do I add a new unit?'),
            children: [
              Padding(
                padding: EdgeInsets.all(12.0),
                child: Text(
                    'Go to Units screen, click "+ Add Unit" and fill out unit details and monthly rent.'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
