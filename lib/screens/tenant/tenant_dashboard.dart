// C:/Users/sijco/Downloads/ramp/ramp/ramp/lib/screens/tenant/tenant_dashboard.dart
import 'package:flutter/material.dart';
import '../../core/theme/ramp_theme.dart';

class TenantDashboardScreen extends StatelessWidget {
  const TenantDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Rent'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(RampTheme.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _CurrentBalanceCard(),
            const SizedBox(height: RampTheme.spacing24),
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: RampTheme.spacing16),
            const _QuickActionsGrid(),
          ],
        ),
      ),
    );
  }
}

class _CurrentBalanceCard extends StatelessWidget {
  const _CurrentBalanceCard();

  @override
  Widget build(BuildContext context) {
    return RampCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Outstanding Balance',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: RampTheme.spacing8),
          Text(
            'PHP 15,500.00',
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
              color: RampTheme.errorRed, // Visually indicates unpaid state
            ),
          ),
          const SizedBox(height: RampTheme.spacing4),
          Text(
            'Due in 3 days (Nov 15)',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: RampTheme.warningYellow,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: RampTheme.spacing24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // Trigger digital payment upload flow
              },
              child: const Text('Upload Payment Receipt'),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionsGrid extends StatelessWidget {
  const _QuickActionsGrid();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: RampCard(
            onTap: () {},
            padding: const EdgeInsets.symmetric(vertical: RampTheme.spacing24, horizontal: RampTheme.spacing16),
            child: const Column(
              children: [
                Icon(Icons.electric_meter, size: 32, color: RampTheme.primaryBlue),
                SizedBox(height: RampTheme.spacing16),
                Text('Submeters', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ),
        const SizedBox(width: RampTheme.spacing16),
        Expanded(
          child: RampCard(
            onTap: () {},
            padding: const EdgeInsets.symmetric(vertical: RampTheme.spacing24, horizontal: RampTheme.spacing16),
            child: const Column(
              children: [
                Icon(Icons.handyman, size: 32, color: RampTheme.primaryBlue),
                SizedBox(height: RampTheme.spacing16),
                Text('Request Repair', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
