// lib/screens/tenant/tenant_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../theme.dart';
import '../../widgets/neumorphic_widgets.dart';
import '../../providers/tenant_providers.dart';
import '../../providers/landlord_providers.dart';
import '../../core/pdf_exporter.dart';

class TenantDashboardScreen extends ConsumerWidget {
  final VoidCallback? onNavigateToPay;
  final VoidCallback? onNavigateToRepairs;
  final VoidCallback? onNavigateToProfile;

  const TenantDashboardScreen({
    super.key,
    this.onNavigateToPay,
    this.onNavigateToRepairs,
    this.onNavigateToProfile,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tenant = ref.watch(currentTenantProvider);
    final announcements = ref.watch(announcementsProvider);
    final currencyFormatter = NumberFormat.currency(locale: 'en_PH', symbol: '₱', decimalDigits: 2);

    final firstName = (tenant?.firstName != null && tenant!.firstName!.isNotEmpty)
        ? tenant.firstName!
        : (tenant?.name.isNotEmpty ?? false)
            ? tenant!.name.split(' ').first
            : 'Tenant';

    final balance = tenant?.balance ?? 0.0;
    final dueDate = tenant?.dueDate ?? DateTime.now();
    final isOverdue = balance > 0 && DateTime.now().isAfter(dueDate);

    // Lease Status Calculation
    final now = DateTime.now();
    final daysUntilLeaseEnd = tenant != null ? tenant.leaseEnd.difference(now).inDays : 365;
    final isLeaseExpiringSoon = daysUntilLeaseEnd < 30;

    return Scaffold(
      backgroundColor: const Color(0xFFE0E5EC),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(RampTheme.spacing20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (tenant == null)
                Padding(
                  padding: const EdgeInsets.only(bottom: RampTheme.spacing16),
                  child: NeumorphicContainer(
                    borderRadius: 16.0,
                    padding: const EdgeInsets.all(16.0),
                    child: const Row(
                      children: [
                        Icon(Icons.info_outline, color: RampTheme.warningYellow, size: 28),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'No active tenancy found for this account. Please contact your landlord to link your tenant profile.',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: RampTheme.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else if (!tenant.isConfirmed)
                Padding(
                  padding: const EdgeInsets.only(bottom: RampTheme.spacing16),
                  child: NeumorphicContainer(
                    borderRadius: 16.0,
                    padding: const EdgeInsets.all(16.0),
                    child: const Row(
                      children: [
                        Icon(Icons.hourglass_top, color: RampTheme.warningYellow, size: 28),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Account Pending Landlord Confirmation. Your tenancy details are being verified by your property manager.',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: RampTheme.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // 1. HEADER & ACCOUNT STANDING
              NeumorphicContainer(
                borderRadius: 20.0,
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 18.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hello, $firstName',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: RampTheme.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                'Unit ${tenant?.unitNumber ?? "Unassigned"}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: RampTheme.primaryBlue,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Consumer(
                                builder: (context, ref, child) {
                                  final isLive = ref.watch(supabaseRealtimeStatusProvider).value ?? true;
                                  return Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: (isLive ? RampTheme.successGreen : RampTheme.warningYellow).withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          width: 6,
                                          height: 6,
                                          decoration: BoxDecoration(
                                            color: isLive ? RampTheme.successGreen : RampTheme.warningYellow,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          isLive ? 'Live Sync' : 'Connecting...',
                                          style: TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                            color: isLive ? RampTheme.successGreen : RampTheme.warningYellow,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Neumorphic Pill Badge for Lease Status
                    NeumorphicPill(
                      text: isLeaseExpiringSoon ? 'Lease Expiring Soon' : 'Active Lease',
                      textColor: isLeaseExpiringSoon ? RampTheme.errorRed : RampTheme.successGreen,
                      icon: isLeaseExpiringSoon ? Icons.warning_amber_rounded : Icons.verified_user_rounded,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: RampTheme.spacing24),

              // 2. RENT BALANCE CARD
              Text(
                'RENT BALANCE',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                  color: RampTheme.textSecondary,
                ),
              ),
              const SizedBox(height: RampTheme.spacing8),

              NeumorphicContainer(
                borderRadius: 22.0,
                padding: const EdgeInsets.all(RampTheme.spacing20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Current Balance',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: RampTheme.textSecondary,
                          ),
                        ),
                        NeumorphicPill(
                          text: isOverdue
                              ? 'Overdue'
                              : balance > 0
                                  ? 'Payment Due'
                                  : 'Paid in Full',
                          textColor: isOverdue
                              ? RampTheme.errorRed
                              : balance > 0
                                  ? RampTheme.warningYellow
                                  : RampTheme.successGreen,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Balance Display (Soft-red if balance > 0 and past due date)
                    Text(
                      currencyFormatter.format(balance),
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                        color: isOverdue
                            ? RampTheme.errorRed
                            : balance > 0
                                ? RampTheme.textPrimary
                                : RampTheme.successGreen,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Due Date Row
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          size: 14,
                          color: isOverdue ? RampTheme.errorRed : RampTheme.textSecondary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Due Date: ${DateFormat('MMM d, yyyy').format(dueDate)}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isOverdue ? FontWeight.bold : FontWeight.w500,
                            color: isOverdue ? RampTheme.errorRed : RampTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),
                    Row(
                      children: [
                        if (balance > 0)
                          Expanded(
                            child: NeumorphicButton(
                              label: 'Pay Now',
                              icon: Icons.payments_rounded,
                              backgroundColor: RampTheme.primaryBlue,
                              textColor: Colors.white,
                              onPressed: onNavigateToPay,
                            ),
                          ),
                        if (balance > 0) const SizedBox(width: 10),
                        Expanded(
                          child: NeumorphicButton(
                            label: 'Statement PDF',
                            icon: Icons.picture_as_pdf_outlined,
                            backgroundColor: NeumorphicDecoration.baseColor,
                            textColor: RampTheme.primaryBlue,
                            onPressed: () {
                              final unit = ref.read(currentTenantUnitProvider);
                              if (tenant != null && unit != null) {
                                RampPdfExporter.printTenantStatement(tenant: tenant, unit: unit);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Unit details loading...')),
                                );
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: RampTheme.spacing24),

              // 3. QUICK NAVIGATION SHORTCUTS
              Text(
                'QUICK SHORTCUTS',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                  color: RampTheme.textSecondary,
                ),
              ),
              const SizedBox(height: RampTheme.spacing12),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildCircularActionButton(
                    icon: Icons.payments_outlined,
                    label: 'Pay Rent',
                    onTap: onNavigateToPay,
                  ),
                  _buildCircularActionButton(
                    icon: Icons.build_circle_outlined,
                    label: 'Report Issue',
                    onTap: onNavigateToRepairs,
                  ),
                  _buildCircularActionButton(
                    icon: Icons.folder_shared_outlined,
                    label: 'Documents',
                    onTap: onNavigateToProfile,
                  ),
                ],
              ),

              const SizedBox(height: RampTheme.spacing28),

              // 4. ANNOUNCEMENTS FEED
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'ANNOUNCEMENTS',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                      color: RampTheme.textSecondary,
                    ),
                  ),
                  Text(
                    '${announcements.length} Posts',
                    style: const TextStyle(
                      fontSize: 12,
                      color: RampTheme.primaryBlue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: RampTheme.spacing12),

              announcements.isEmpty
                  ? NeumorphicContainer(
                      isInset: true,
                      borderRadius: 16,
                      padding: const EdgeInsets.all(20),
                      child: const Center(
                        child: Text(
                          'No announcements broadcasted yet.',
                          style: TextStyle(color: RampTheme.textSecondary, fontSize: 13),
                        ),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: announcements.length,
                      itemBuilder: (context, index) {
                        final item = announcements[index];
                        final isImportant = item.isImportant;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: NeumorphicContainer(
                            isInset: true,
                            borderRadius: 18.0,
                            backgroundColor: isImportant
                                ? RampTheme.errorRed.withValues(alpha: 0.08)
                                : NeumorphicDecoration.baseColor,
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    if (isImportant) ...[
                                      const Icon(
                                        Icons.priority_high_rounded,
                                        color: RampTheme.errorRed,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 6),
                                    ],
                                    Expanded(
                                      child: Text(
                                        item.title,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                          color: isImportant
                                              ? RampTheme.errorRed
                                              : RampTheme.textPrimary,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      DateFormat('MMM d').format(item.timestamp),
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: RampTheme.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  item.message,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: RampTheme.textPrimary,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCircularActionButton({
    required IconData icon,
    required String label,
    required VoidCallback? onTap,
  }) {
    return Column(
      children: [
        NeumorphicContainer(
          shape: BoxShape.circle,
          width: 60,
          height: 60,
          onTap: onTap,
          child: Center(
            child: Icon(
              icon,
              color: RampTheme.primaryBlue,
              size: 26,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: RampTheme.textPrimary,
          ),
        ),
      ],
    );
  }
}
