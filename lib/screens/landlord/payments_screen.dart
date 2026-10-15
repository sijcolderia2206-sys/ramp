// lib/screens/landlord/payments_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../theme.dart';
import '../../providers/landlord_providers.dart';

class PaymentsScreen extends ConsumerStatefulWidget {
  const PaymentsScreen({super.key});

  @override
  ConsumerState<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends ConsumerState<PaymentsScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';
  String _selectedMethodFilter = 'All';

  final List<String> _methodFilters = [
    'All',
    'Cash',
    'GCash',
    'Maya',
    'Bank Transfer',
  ];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '₱', decimalDigits: 2);
    final payments = ref.watch(paymentsProvider);

    final filteredPayments = payments.where((p) {
      final queryMatches = _searchQuery.isEmpty ||
          p.id.toLowerCase().contains(_searchQuery) ||
          p.referenceNumber.toLowerCase().contains(_searchQuery) ||
          (p.tenantName ?? '').toLowerCase().contains(_searchQuery) ||
          (p.unitNumber ?? '').toLowerCase().contains(_searchQuery);

      final filterMatches = _selectedMethodFilter == 'All' ||
          p.paymentMethod.toLowerCase() == _selectedMethodFilter.toLowerCase();

      return queryMatches && filterMatches;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payments'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          // Search & Filter Header Section
          Container(
            padding: const EdgeInsets.all(RampTheme.spacing16),
            color: RampTheme.cardBackground,
            child: Column(
              children: [
                TextField(
                  controller: _searchCtrl,
                  decoration: InputDecoration(
                    hintText: 'Search by tenant, unit, or payment ID...',
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
                  ),
                  onChanged: (val) {
                    setState(() => _searchQuery = val.trim().toLowerCase());
                  },
                ),
                const SizedBox(height: RampTheme.spacing12),

                // Method Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _methodFilters.map((method) {
                      final isSelected = _selectedMethodFilter == method;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          selected: isSelected,
                          label: Text(method),
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : RampTheme.textPrimary,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            fontSize: 12,
                          ),
                          selectedColor: RampTheme.primaryBlue,
                          backgroundColor: RampTheme.scaffoldBackground,
                          checkmarkColor: Colors.white,
                          onSelected: (val) {
                            setState(() => _selectedMethodFilter = method);
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Payment List
          Expanded(
            child: filteredPayments.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.payments_outlined, size: 48, color: RampTheme.textSecondary),
                        const SizedBox(height: 12),
                        Text(
                          'No payments match your criteria.',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: RampTheme.textSecondary,
                              ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(RampTheme.spacing16),
                    itemCount: filteredPayments.length,
                    itemBuilder: (context, index) {
                      final p = filteredPayments[index];
                      final isPaid = p.status == 'Paid';
                      final isPending = p.status == 'Pending';

                      return Container(
                        margin: const EdgeInsets.only(bottom: RampTheme.spacing12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: RampTheme.standardShadow,
                        ),
                        child: Material(
                          color: RampTheme.cardBackground,
                          borderRadius: BorderRadius.circular(16),
                          child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          leading: CircleAvatar(
                            backgroundColor: isPaid
                                ? RampTheme.successGreen.withValues(alpha: 0.15)
                                : isPending
                                    ? RampTheme.warningYellow.withValues(alpha: 0.15)
                                    : RampTheme.errorRed.withValues(alpha: 0.15),
                            child: Icon(
                              Icons.payments,
                              color: isPaid
                                  ? RampTheme.successGreen
                                  : isPending
                                      ? RampTheme.warningYellow
                                      : RampTheme.errorRed,
                              size: 22,
                            ),
                          ),
                          title: Row(
                            children: [
                              Text(
                                'Unit ${p.unitNumber ?? "N/A"}',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  '(${p.tenantName ?? "Tenant"})',
                                  style: const TextStyle(fontSize: 12, color: RampTheme.textSecondary),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 2),
                              Text(
                                '${p.paymentMethod} • Ref: ${p.referenceNumber}',
                                style: const TextStyle(fontSize: 12),
                              ),
                              Text(
                                DateFormat('MMM d, yyyy • h:mm a').format(p.paymentDate),
                                style: const TextStyle(fontSize: 11, color: RampTheme.textSecondary),
                              ),
                            ],
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                currencyFormat.format(p.amount),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: RampTheme.primaryBlue,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: isPaid
                                      ? RampTheme.successGreen.withValues(alpha: 0.1)
                                      : isPending
                                          ? RampTheme.warningYellow.withValues(alpha: 0.15)
                                          : RampTheme.errorRed.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  p.status,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: isPaid
                                        ? RampTheme.successGreen
                                        : isPending
                                            ? RampTheme.warningYellow
                                            : RampTheme.errorRed,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          onTap: () => context.push('/payment-details/${p.id}'),
                        ),
                      ),
                    );
                  },
                  ),
          ),
        ],
      ),
    );
  }
}
