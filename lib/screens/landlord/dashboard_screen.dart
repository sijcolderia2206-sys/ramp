import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../theme.dart';
import '../../models/payment_model.dart';
import '../../providers/landlord_providers.dart';
import '../../core/utils/debouncer.dart';

class LandlordDashboardScreen extends ConsumerStatefulWidget {
  const LandlordDashboardScreen({super.key});

  @override
  ConsumerState<LandlordDashboardScreen> createState() => _LandlordDashboardScreenState();
}

class _LandlordDashboardScreenState extends ConsumerState<LandlordDashboardScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  final Debouncer _searchDebouncer = Debouncer(milliseconds: 500);

  DateTime _selectedCalendarDate = DateTime.now();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    _searchDebouncer.dispose();
    super.dispose();
  }

  void _handleSearchSubmit(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return;

    if (q == 'profile') {
      context.push('/profile');
      return;
    }
    if (q == 'payments' || q == 'payment') {
      context.push('/payments');
      return;
    }
    if (q == 'pending') {
      context.push('/pending-items');
      return;
    }

    final payments = ref.read(paymentsProvider);
    final matched = payments.firstWhere(
      (p) => p.id.toLowerCase() == q || p.referenceNumber.toLowerCase() == q || p.id.toLowerCase().contains(q),
      orElse: () => PaymentRecord(id: '', unitId: '', amount: 0, paymentDate: DateTime.now(), paymentMethod: '', referenceNumber: ''),
    );

    if (matched.id.isNotEmpty) {
      context.push('/payment-details/${matched.id}');
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '₱', decimalDigits: 2);

    final gross = ref.watch(grossRevenueProvider);
    final payments = ref.watch(paymentsProvider);
    final pendingPayments = ref.watch(pendingPaymentsQueueProvider);

    final verifiedPaymentsCount = payments.where((p) => p.status == 'Paid').length;

    // Direct search navigation target checking
    PaymentRecord? matchedPayment;
    if (_searchQuery.isNotEmpty) {
      for (final p in payments) {
        if (p.id.toLowerCase() == _searchQuery ||
            p.referenceNumber.toLowerCase() == _searchQuery ||
            p.id.toLowerCase().contains(_searchQuery) ||
            p.referenceNumber.toLowerCase().contains(_searchQuery)) {
          matchedPayment = p;
          break;
        }
      }
    }

    return Scaffold(
      backgroundColor: RampTheme.scaffoldBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(RampTheme.spacing16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Neumorphic Sunken Search Bar
              Container(
                decoration: BoxDecoration(
                  color: RampTheme.neumorphicBase,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: RampTheme.neumorphicConcave,
                ),
                child: TextField(
                  controller: _searchCtrl,
                  decoration: InputDecoration(
                    hintText: 'Search page or payment ID (e.g. "profile", "p_1", "payments")...',
                    prefixIcon: const Icon(Icons.search, color: RampTheme.primaryBlue),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _searchCtrl.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                  ),
                  onSubmitted: _handleSearchSubmit,
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val.trim().toLowerCase();
                    });
                    if (_searchQuery.length >= 3) {
                      _searchDebouncer.run(() {
                        ref.read(geminiAssistantProvider.notifier).askAssistant(_searchQuery);
                      });
                    }
                  },
                ),
              ),

              const SizedBox(height: 10),



              // Direct Navigation Shortcut Chips (Neumorphic Soft Chips)
              if (_searchQuery.isNotEmpty) ...[
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  children: [
                    if (_searchQuery.contains('profile'))
                      _NeumorphicShortcutChip(
                        icon: Icons.person,
                        label: 'Navigate to Profile Page ➔',
                        color: RampTheme.primaryBlue,
                        onPressed: () => context.push('/profile'),
                      ),
                    if (_searchQuery.contains('payment'))
                      _NeumorphicShortcutChip(
                        icon: Icons.payments,
                        label: 'Navigate to Payments Screen ➔',
                        color: RampTheme.primaryBlue,
                        onPressed: () => context.push('/payments'),
                      ),
                    if (_searchQuery.contains('pending'))
                      _NeumorphicShortcutChip(
                        icon: Icons.hourglass_empty,
                        label: 'Navigate to Pending Items Screen ➔',
                        color: RampTheme.primaryBlue,
                        onPressed: () => context.push('/pending-items'),
                      ),
                    if (matchedPayment != null)
                      _NeumorphicShortcutChip(
                        icon: Icons.receipt_long,
                        label: 'Open Payment #${matchedPayment.id} (${matchedPayment.referenceNumber}) ➔',
                        color: RampTheme.successGreen,
                        onPressed: () => context.push('/payment-details/${matchedPayment!.id}'),
                      ),
                  ],
                ),
              ],

              // Gemini AI Quick Insights Card when searching
              if (_searchQuery.length >= 3) ...[
                const SizedBox(height: 12),
                Consumer(
                  builder: (context, ref, child) {
                    final aiState = ref.watch(geminiAssistantProvider);
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: RampTheme.neumorphicBase,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: RampTheme.neumorphicConvex,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.auto_awesome, color: RampTheme.primaryBlue, size: 22),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Gemini AI Portfolio Insight', style: TextStyle(fontWeight: FontWeight.bold, color: RampTheme.primaryBlue, fontSize: 13)),
                                const SizedBox(height: 4),
                                aiState.when(
                                  data: (text) => Text(text.isEmpty ? 'Analyzing portfolio data...' : text, style: const TextStyle(fontSize: 13, height: 1.3)),
                                  loading: () => const Row(
                                    children: [
                                      SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2)),
                                      SizedBox(width: 8),
                                      Text('Querying Gemini AI Engine...', style: TextStyle(fontSize: 12)),
                                    ],
                                  ),
                                  error: (e, _) => Text('AI Note: $e', style: const TextStyle(fontSize: 12, color: RampTheme.errorRed)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],

              const SizedBox(height: RampTheme.spacing20),

              // 2. Neumorphic Overview Card (Total Collected Amount + 2 Pill Buttons for Payments & Pending)
              _OverviewCard(
                collectedAmount: currencyFormat.format(gross),
                verifiedCount: verifiedPaymentsCount,
                pendingCount: pendingPayments.length,
                onTapPayments: () => context.push('/payments'),
                onTapPending: () => context.push('/pending-items'),
              ),

              const SizedBox(height: RampTheme.spacing24),

              // 3. Three Neumorphic Circular Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _CircleActionButton(
                    icon: Icons.person_add_alt_1,
                    label: 'Add Tenant',
                    onTap: () => context.push('/add-tenant'),
                  ),
                  _CircleActionButton(
                    icon: Icons.payments,
                    label: 'Record Payment',
                    onTap: () => context.push('/record-payment'),
                  ),
                  _CircleActionButton(
                    icon: Icons.build,
                    label: 'Add Repairs',
                    onTap: () => context.push('/add-repair'),
                  ),
                ],
              ),

              const SizedBox(height: RampTheme.spacing24),

              // 4. Neumorphic Calendar Card
              _SevenDayCalendarStrip(
                selectedDate: _selectedCalendarDate,
                onDateSelected: (date) {
                  setState(() {
                    _selectedCalendarDate = date;
                  });
                },
              ),

              const SizedBox(height: RampTheme.spacing24),

              // 5. Recent Activities Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Activities',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Text(
                    DateFormat('MMM d, yyyy').format(_selectedCalendarDate),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              const SizedBox(height: RampTheme.spacing12),

              _RecentActivitiesList(
                searchQuery: _searchQuery,
                selectedDate: _selectedCalendarDate,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// NEUMORPHIC OVERVIEW CARD (Total Collected Amount + 2 Pill Buttons)
// ============================================================================
class _OverviewCard extends StatelessWidget {
  final String collectedAmount;
  final int verifiedCount;
  final int pendingCount;
  final VoidCallback onTapPayments;
  final VoidCallback onTapPending;

  const _OverviewCard({
    required this.collectedAmount,
    required this.verifiedCount,
    required this.pendingCount,
    required this.onTapPayments,
    required this.onTapPending,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(RampTheme.spacing20),
      decoration: BoxDecoration(
        color: RampTheme.primaryBlue,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x330052CC),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Collected Amount',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.white70,
                    ),
              ),
              Consumer(
                builder: (context, ref, child) {
                  final pendingSync = ref.watch(offlineSyncProvider);
                  if (pendingSync.isEmpty) return const SizedBox.shrink();
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: RampTheme.warningYellow,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.sync, size: 12, color: Colors.white),
                        const SizedBox(width: 4),
                        Text(
                          'Offline Queue (${pendingSync.length})',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: RampTheme.spacing8),
          Text(
            collectedAmount,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
          ),
          const SizedBox(height: RampTheme.spacing12),

          // Collection Progress Bar
          Consumer(
            builder: (context, ref, child) {
              final collectionRate = ref.watch(collectionRateProvider);
              final expectedRent = ref.watch(expectedMonthlyRentProvider);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Collection Rate: ${collectionRate.toStringAsFixed(0)}%',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white70),
                      ),
                      Text(
                        'Expected: ₱${expectedRent.toStringAsFixed(0)}',
                        style: const TextStyle(fontSize: 11, color: Colors.white70),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: collectionRate / 100.0,
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      valueColor: const AlwaysStoppedAnimation<Color>(RampTheme.successGreen),
                      minHeight: 6,
                    ),
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: RampTheme.spacing16),

          // 2 Pill Buttons (Payments & Pending) in White Styling
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: onTapPayments,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.check_circle_outline, size: 16, color: Colors.white),
                        const SizedBox(width: 6),
                        Text(
                          'Payments ($verifiedCount)',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: RampTheme.spacing16),
              Expanded(
                child: InkWell(
                  onTap: onTapPending,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.hourglass_empty,
                          size: 16,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Pending ($pendingCount)',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// THREE HORIZONTALLY ALIGNED NEUMORPHIC CIRCLE BUTTONS
// ============================================================================
class _CircleActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _CircleActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(32),
          child: Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              color: RampTheme.neumorphicBase,
              shape: BoxShape.circle,
              boxShadow: RampTheme.neumorphicCircle,
            ),
            child: Icon(icon, color: RampTheme.primaryBlue, size: 28),
          ),
        ),
        const SizedBox(height: RampTheme.spacing8),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: RampTheme.textPrimary,
              ),
        ),
      ],
    );
  }
}

// ============================================================================
// NEUMORPHIC CALENDAR CARD
// ============================================================================
class _SevenDayCalendarStrip extends ConsumerWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;

  const _SevenDayCalendarStrip({
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));

    final weekDays = List.generate(7, (index) {
      return monday.add(Duration(days: index));
    });

    final tenants = ref.watch(tenantsProvider);
    final payments = ref.watch(paymentsProvider);
    final tickets = ref.watch(maintenanceTicketsProvider);

    final totalSchedulesCount = tenants.length + payments.length + tickets.length;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.push('/calendar'),
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: RampTheme.neumorphicBase,
            borderRadius: BorderRadius.circular(24),
            boxShadow: RampTheme.neumorphicConvex,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Calendar',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: RampTheme.textPrimary,
                    ),
                  ),
                  Row(
                    children: const [
                      Text('Full View', style: TextStyle(fontSize: 12, color: RampTheme.primaryBlue, fontWeight: FontWeight.bold)),
                      Icon(Icons.chevron_right, size: 16, color: RampTheme.primaryBlue),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),

              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: weekDays.map((date) {
                    final isSelected = date.year == selectedDate.year &&
                        date.month == selectedDate.month &&
                        date.day == selectedDate.day;
                    final isToday = date.year == now.year &&
                        date.month == now.month &&
                        date.day == now.day;

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? RampTheme.primaryBlue
                              : RampTheme.neumorphicBase,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: isSelected
                              ? [
                                  const BoxShadow(
                                    color: Color(0x400052CC),
                                    blurRadius: 8,
                                    offset: Offset(0, 4),
                                  )
                                ]
                              : RampTheme.neumorphicConvex,
                        ),
                        child: Column(
                          children: [
                            Text(
                              DateFormat('EEE').format(date).toUpperCase(),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: isSelected
                                    ? Colors.white
                                    : isToday
                                        ? RampTheme.primaryBlue
                                        : RampTheme.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${date.day}',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: isSelected
                                    ? Colors.white
                                    : isToday
                                        ? RampTheme.primaryBlue
                                        : RampTheme.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              if (totalSchedulesCount > 5) ...[
                const SizedBox(height: 12),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.read_more, size: 16, color: RampTheme.primaryBlue),
                        const SizedBox(width: 6),
                        Text('Show More ($totalSchedulesCount Schedules) ➔', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: RampTheme.primaryBlue)),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// NEUMORPHIC RECENT ACTIVITIES LIST
// ============================================================================
class _RecentActivitiesList extends ConsumerWidget {
  final String searchQuery;
  final DateTime selectedDate;

  const _RecentActivitiesList({
    required this.searchQuery,
    required this.selectedDate,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final payments = ref.watch(paymentsProvider);
    final tickets = ref.watch(maintenanceTicketsProvider);

    final combinedActivities = <Map<String, dynamic>>[];

    for (final p in payments) {
      combinedActivities.add({
        'title': '${p.transactionType} Payment: Unit ${p.unitNumber ?? "N/A"}',
        'subtitle': '${p.tenantName ?? "Tenant"} • ₱${p.amount.toStringAsFixed(2)} (${p.paymentMethod})',
        'time': p.paymentDate,
        'type': 'payment',
        'status': p.status,
      });
    }

    for (final t in tickets) {
      combinedActivities.add({
        'title': 'Repair Dispatch: Unit ${t.unitNumber}',
        'subtitle': '${t.title} • SLA: ${t.priority}',
        'time': t.createdAt,
        'type': 'maintenance',
        'status': t.stage,
      });
    }

    combinedActivities.sort((a, b) => (b['time'] as DateTime).compareTo(a['time'] as DateTime));

    final filteredActivities = combinedActivities.where((act) {
      if (searchQuery.isEmpty) return true;
      final titleStr = (act['title'] as String).toLowerCase();
      final subStr = (act['subtitle'] as String).toLowerCase();
      return titleStr.contains(searchQuery) || subStr.contains(searchQuery);
    }).toList();

    if (filteredActivities.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(RampTheme.spacing20),
        decoration: BoxDecoration(
          color: RampTheme.neumorphicBase,
          borderRadius: BorderRadius.circular(20),
          boxShadow: RampTheme.neumorphicConvex,
        ),
        child: const Center(
          child: Column(
            children: [
              Icon(Icons.history, color: RampTheme.textSecondary, size: 32),
              SizedBox(height: 8),
              Text('No recent activities logged for this selection.'),
            ],
          ),
        ),
      );
    }

    return Column(
      children: filteredActivities.take(5).map((act) {
        final isPayment = act['type'] == 'payment';
        final isPaid = act['status'] == 'Paid' || act['status'] == 'Completed';

        return Container(
          margin: const EdgeInsets.only(bottom: RampTheme.spacing14),
          padding: const EdgeInsets.all(RampTheme.spacing16),
          decoration: BoxDecoration(
            color: RampTheme.neumorphicBase,
            borderRadius: BorderRadius.circular(20),
            boxShadow: RampTheme.neumorphicConvex,
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: const BoxDecoration(
                  color: RampTheme.neumorphicBase,
                  shape: BoxShape.circle,
                  boxShadow: RampTheme.neumorphicCircle,
                ),
                child: Icon(
                  isPayment ? Icons.payments : Icons.build,
                  color: isPayment ? RampTheme.successGreen : RampTheme.primaryBlue,
                  size: 20,
                ),
              ),
              const SizedBox(width: RampTheme.spacing14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      act['title'] as String,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      act['subtitle'] as String,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: RampTheme.neumorphicBase,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: RampTheme.neumorphicConvex,
                ),
                child: Text(
                  act['status'] as String,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isPaid ? RampTheme.successGreen : RampTheme.warningYellow,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

// Helper Widget for Neumorphic Navigation Shortcut Chips
class _NeumorphicShortcutChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;

  const _NeumorphicShortcutChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: RampTheme.neumorphicBase,
        borderRadius: BorderRadius.circular(20),
        boxShadow: RampTheme.neumorphicConvex,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 16, color: color),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
