// C:/Users/sijco/Downloads/ramp/ramp/ramp/lib/screens/landlord/landlord_dashboard.dart
import 'package:flutter/material.dart';
import '../../core/theme/ramp_theme.dart';
import '../widgets/compact_progress_ring.dart';
import 'ai_query_bar_widget.dart';

class LandlordDashboardScreen extends StatelessWidget {
  const LandlordDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Portfolio Dashboard'),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(RampTheme.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AiQueryBarWidget(),
            SizedBox(height: RampTheme.spacing32),
            _PortfolioSummaryRow(),
            SizedBox(height: RampTheme.spacing32),
            _ActionableInsightsSection(),
          ],
        ),
      ),
    );
  }
}

class _PortfolioSummaryRow extends StatelessWidget {
  const _PortfolioSummaryRow();

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        CompactProgressRing(
          progress: 0.92,
          centerText: '92%',
          label: 'Occupancy',
        ),
        CompactProgressRing(
          progress: 0.75,
          centerText: '75%',
          label: 'Rent Paid',
        ),
        CompactProgressRing(
          progress: 1.0,
          centerText: '3',
          label: 'Open Tickets',
        ),
      ],
    );
  }
}

class _ActionableInsightsSection extends StatelessWidget {
  const _ActionableInsightsSection();

  @override
  Widget build(BuildContext context) {
    return RampCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Actionable Insights',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: RampTheme.spacing16),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.receipt_long, color: RampTheme.successGreen),
            title: const Text('2 Payment Verifications Pending'),
            subtitle: const Text('Review uploaded tenant receipts.'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Navigate to Payment Verification Queue
            },
          ),
          const Divider(),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.warning_amber_rounded, color: RampTheme.errorRed),
            title: const Text('1 Emergency Ticket'),
            subtitle: const Text('Unit 102 - Water Pipe Burst. 20h remaining on SLA.'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Navigate to Maintenance Dispatch
            },
          ),
        ],
      ),
    );
  }
}
