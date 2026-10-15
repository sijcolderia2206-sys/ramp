// lib/screens/landlord/pending_items_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../theme.dart';
import '../../providers/landlord_providers.dart';

class PendingItemsScreen extends ConsumerStatefulWidget {
  const PendingItemsScreen({super.key});

  @override
  ConsumerState<PendingItemsScreen> createState() => _PendingItemsScreenState();
}

class _PendingItemsScreenState extends ConsumerState<PendingItemsScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';
  String _selectedTypeFilter = 'All';

  final List<String> _typeFilters = [
    'All',
    'Pending Payments',
    'Pending Repairs',
  ];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '₱', decimalDigits: 2);

    final pendingPayments = ref.watch(pendingPaymentsQueueProvider);
    final tickets = ref.watch(maintenanceTicketsProvider);
    final pendingTickets = tickets.where((t) => t.stage != 'Completed').toList();

    final List<Map<String, dynamic>> combinedItems = [];

    if (_selectedTypeFilter == 'All' || _selectedTypeFilter == 'Pending Payments') {
      for (final p in pendingPayments) {
        combinedItems.add({
          'type': 'payment',
          'id': p.id,
          'title': 'Payment: Unit ${p.unitNumber ?? "N/A"}',
          'subtitle': '${p.tenantName ?? "Tenant"} • ${currencyFormat.format(p.amount)} (${p.paymentMethod})',
          'date': p.paymentDate,
          'raw': p,
        });
      }
    }

    if (_selectedTypeFilter == 'All' || _selectedTypeFilter == 'Pending Repairs') {
      for (final t in pendingTickets) {
        combinedItems.add({
          'type': 'repair',
          'id': t.id,
          'title': 'Repair: Unit ${t.unitNumber}',
          'subtitle': '${t.title} • SLA Priority: ${t.priority}',
          'date': t.createdAt,
          'raw': t,
        });
      }
    }

    final filteredItems = combinedItems.where((item) {
      if (_searchQuery.isEmpty) return true;
      final titleStr = (item['title'] as String).toLowerCase();
      final subStr = (item['subtitle'] as String).toLowerCase();
      return titleStr.contains(_searchQuery) || subStr.contains(_searchQuery);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pending Items'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          // Search & Filter Header
          Container(
            padding: const EdgeInsets.all(RampTheme.spacing16),
            color: RampTheme.cardBackground,
            child: Column(
              children: [
                TextField(
                  controller: _searchCtrl,
                  decoration: InputDecoration(
                    hintText: 'Search pending payments or repairs...',
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

                // Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _typeFilters.map((filter) {
                      final isSelected = _selectedTypeFilter == filter;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          selected: isSelected,
                          label: Text(filter),
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : RampTheme.textPrimary,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            fontSize: 12,
                          ),
                          selectedColor: RampTheme.primaryBlue,
                          backgroundColor: RampTheme.scaffoldBackground,
                          checkmarkColor: Colors.white,
                          onSelected: (val) {
                            setState(() => _selectedTypeFilter = filter);
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

          // Items List
          Expanded(
            child: filteredItems.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.check_circle_outline, size: 48, color: RampTheme.successGreen),
                        const SizedBox(height: 12),
                        Text(
                          'No pending items in queue!',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: RampTheme.textSecondary,
                              ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(RampTheme.spacing16),
                    itemCount: filteredItems.length,
                    itemBuilder: (context, index) {
                      final item = filteredItems[index];
                      final isPayment = item['type'] == 'payment';

                      if (isPayment) {
                        final p = item['raw'];
                        return Container(
                          margin: const EdgeInsets.only(bottom: RampTheme.spacing12),
                          padding: const EdgeInsets.all(RampTheme.spacing16),
                          decoration: BoxDecoration(
                            color: RampTheme.cardBackground,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: RampTheme.standardShadow,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.hourglass_top, color: RampTheme.warningYellow, size: 20),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      item['title'] as String,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                    ),
                                  ),
                                  Text(
                                    currencyFormat.format(p.amount),
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: RampTheme.primaryBlue),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(item['subtitle'] as String, style: const TextStyle(fontSize: 13)),
                              Text(
                                'Ref: ${p.referenceNumber} • Date: ${DateFormat.yMMMd().format(p.paymentDate)}',
                                style: const TextStyle(fontSize: 11, color: RampTheme.textSecondary),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: RampTheme.errorRed,
                                      side: const BorderSide(color: RampTheme.errorRed),
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                    ),
                                    onPressed: () {
                                      ref.read(paymentsProvider.notifier).verifyPayment(p.id, false);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Payment proof declined.')),
                                      );
                                    },
                                    child: const Text('Decline', style: TextStyle(fontSize: 12)),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: RampTheme.successGreen,
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    ),
                                    onPressed: () {
                                      ref.read(paymentsProvider.notifier).verifyPayment(p.id, true);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Payment verified & tenant balance credited!')),
                                      );
                                    },
                                    child: const Text('Approve Payment', style: TextStyle(fontSize: 12)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      } else {
                        final t = item['raw'];
                        return Container(
                          margin: const EdgeInsets.only(bottom: RampTheme.spacing12),
                          padding: const EdgeInsets.all(RampTheme.spacing16),
                          decoration: BoxDecoration(
                            color: RampTheme.cardBackground,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: RampTheme.standardShadow,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.build_circle_outlined, color: RampTheme.primaryBlue, size: 20),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      item['title'] as String,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: RampTheme.primaryBlue.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      t.stage,
                                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: RampTheme.primaryBlue),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(item['subtitle'] as String, style: const TextStyle(fontSize: 13)),
                              if (t.description.isNotEmpty)
                                Text(
                                  'Details: ${t.description}',
                                  style: const TextStyle(fontSize: 12, color: RampTheme.textSecondary),
                                ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                    ),
                                    onPressed: () {
                                      context.push('/add-repair');
                                    },
                                    child: const Text('Manage Repairs', style: TextStyle(fontSize: 12)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
