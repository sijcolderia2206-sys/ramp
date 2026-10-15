// lib/screens/landlord/finance_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import '../../theme.dart';
import '../../models/unit_model.dart';
import '../../models/payment_model.dart';
import '../../providers/landlord_providers.dart';
import '../../core/pdf_exporter.dart';
import '../../core/validators.dart';

class LandlordFinanceScreen extends ConsumerStatefulWidget {
  const LandlordFinanceScreen({super.key});

  @override
  ConsumerState<LandlordFinanceScreen> createState() => _LandlordFinanceScreenState();
}

class _LandlordFinanceScreenState extends ConsumerState<LandlordFinanceScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<int>(financeTabFilterProvider, (previous, next) {
      if (_tabController.index != next) {
        _tabController.animateTo(next.clamp(0, 2));
      }
    });

    final currencyFormat = NumberFormat.currency(symbol: '₱', decimalDigits: 2);
    final gross = ref.watch(grossRevenueProvider);
    final expenses = ref.watch(totalMaintenanceExpensesProvider);
    final noi = ref.watch(netOperatingIncomeProvider);
    final payments = ref.watch(paymentsProvider);
    final pendingQueue = ref.watch(pendingPaymentsQueueProvider);

    final rentLedger = payments.where((p) => p.transactionType == 'Rent' && p.status == 'Paid').toList();
    final maintenanceLedger = payments.where((p) => p.transactionType == 'Maintenance').toList();

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: RampTheme.primaryBlue,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Record Payment', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        onPressed: () => _showRecordPaymentModal(context, ref),
      ),
      body: Column(
        children: [
          // Financial Summary Card
          Container(
            padding: const EdgeInsets.all(RampTheme.spacing16),
            color: RampTheme.cardBackground,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Net Operating Income (NOI)', style: Theme.of(context).textTheme.bodySmall),
                        Text(
                          currencyFormat.format(noi),
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: RampTheme.primaryBlue,
                              ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: RampTheme.scaffoldBackground,
                            foregroundColor: RampTheme.primaryBlue,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          ),
                          icon: SvgPicture.asset(
                            'assets/icons/receipt.svg',
                            width: 16,
                            height: 16,
                            colorFilter: const ColorFilter.mode(RampTheme.primaryBlue, BlendMode.srcIn),
                          ),
                          label: const Text('PDF', style: TextStyle(fontSize: 12)),
                          onPressed: () async {
                            final units = ref.read(unitsProvider);
                            final occupiedCount = units.where((u) => u.status == 'Occupied').length;
                            await RampPdfExporter.printPortfolioIncomeStatementPdf(
                              grossRevenue: gross,
                              totalExpenses: expenses,
                              netIncome: noi,
                              totalUnits: units.length,
                              occupiedUnits: occupiedCount,
                            );
                          },
                        ),
                        const SizedBox(width: 6),
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: RampTheme.primaryBlue,
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            side: const BorderSide(color: RampTheme.primaryBlue),
                          ),
                          icon: const Icon(Icons.table_chart_outlined, size: 16),
                          label: const Text('CSV', style: TextStyle(fontSize: 12)),
                          onPressed: () async {
                            await RampPdfExporter.exportFinancialLedgerCsv(payments);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: RampTheme.spacing12),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: RampTheme.successGreen.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Gross Rent Collected', style: TextStyle(fontSize: 11, color: RampTheme.successGreen)),
                            Text(currencyFormat.format(gross), style: const TextStyle(fontWeight: FontWeight.bold, color: RampTheme.successGreen)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: RampTheme.errorRed.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Maintenance Expenses', style: TextStyle(fontSize: 11, color: RampTheme.errorRed)),
                            Text(currencyFormat.format(expenses), style: const TextStyle(fontWeight: FontWeight.bold, color: RampTheme.errorRed)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Ledger Tabs
          TabBar(
            controller: _tabController,
            onTap: (index) {
              ref.read(financeTabFilterProvider.notifier).state = index;
            },
            tabs: [
              const Tab(text: 'Rent Ledger'),
              const Tab(text: 'Maintenance'),
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Pending'),
                    if (pendingQueue.isNotEmpty) ...[
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: RampTheme.warningYellow,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${pendingQueue.length}',
                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Tab 0: Rent Ledger List
                rentLedger.isEmpty
                    ? const Center(child: Text('No verified rent payments in ledger.'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(RampTheme.spacing16),
                        itemCount: rentLedger.length,
                        itemBuilder: (context, index) {
                          final item = rentLedger[index];
                          return _LedgerCard(record: item, currencyFormat: currencyFormat);
                        },
                      ),

                // Tab 1: Maintenance Expenses List
                maintenanceLedger.isEmpty
                    ? const Center(child: Text('No maintenance expenses recorded.'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(RampTheme.spacing16),
                        itemCount: maintenanceLedger.length,
                        itemBuilder: (context, index) {
                          final item = maintenanceLedger[index];
                          return _LedgerCard(record: item, currencyFormat: currencyFormat);
                        },
                      ),

                // Tab 2: Pending Payment Verification Queue
                pendingQueue.isEmpty
                    ? const Center(child: Text('No pending payments in verification queue.'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(RampTheme.spacing16),
                        itemCount: pendingQueue.length,
                        itemBuilder: (context, index) {
                          final item = pendingQueue[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: RampTheme.cardBackground,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: RampTheme.standardShadow,
                              border: Border.all(color: RampTheme.warningYellow.withValues(alpha: 0.3)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Unit ${item.unitNumber ?? "101"} - ${item.tenantName ?? "Tenant"}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                    Text('₱${item.amount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, color: RampTheme.primaryBlue)),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text('Ref: ${item.referenceNumber} • Method: ${item.paymentMethod}', style: Theme.of(context).textTheme.bodySmall),
                                const Divider(),
                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton(
                                        style: OutlinedButton.styleFrom(foregroundColor: RampTheme.errorRed, side: const BorderSide(color: RampTheme.errorRed)),
                                        onPressed: () {
                                          ref.read(paymentsProvider.notifier).verifyPayment(item.id, false);
                                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payment Declined')));
                                        },
                                        child: const Text('Decline'),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(backgroundColor: RampTheme.successGreen),
                                        onPressed: () {
                                          ref.read(paymentsProvider.notifier).verifyPayment(item.id, true);
                                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payment Verified & Credited!')));
                                        },
                                        child: const Text('Verify & Credit'),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showRecordPaymentModal(BuildContext context, WidgetRef ref) {
    final units = ref.read(unitsProvider);
    String selectedUnitId = units.isNotEmpty ? units.first.id : '';
    final amountCtrl = TextEditingController();
    final refNumCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final selectedUnit = units.firstWhere(
              (u) => u.id == selectedUnitId,
              orElse: () => units.isEmpty
                  ? RentalUnit(id: '', title: '', unitNumber: '', monthlyRent: 0)
                  : units.first,
            );
            final baseRent = selectedUnit.monthlyRent;
            final waterBill = selectedUnit.calculatedWaterBill;
            final electricBill = selectedUnit.calculatedElectricBill;
            final recommendedTotal = baseRent + waterBill + electricBill;

            return Padding(
              padding: EdgeInsets.only(
                top: 24,
                left: 24,
                right: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Record Rent Payment', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 16),

                  DropdownButtonFormField<String>(
                    initialValue: selectedUnitId,
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'Select Rental Unit'),
                    items: units.isEmpty
                        ? [const DropdownMenuItem(value: '', child: Text('No Units Available', overflow: TextOverflow.ellipsis))]
                        : units.map((u) {
                            return DropdownMenuItem(
                              value: u.id,
                              child: Text('Unit ${u.unitNumber} - ${u.tenantName ?? "Vacant"}', overflow: TextOverflow.ellipsis),
                            );
                          }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setModalState(() {
                          selectedUnitId = val;
                        });
                      }
                    },
                  ),

                  const SizedBox(height: 12),

                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: RampTheme.scaffoldBackground,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Itemized Billing Breakdown:', style: Theme.of(context).textTheme.labelSmall),
                        Text('• Base Rent: ₱${baseRent.toStringAsFixed(2)}'),
                        Text('• Water Bill: ₱${waterBill.toStringAsFixed(2)} (${selectedUnit.waterUsage} m³)'),
                        Text('• Electric Bill: ₱${electricBill.toStringAsFixed(2)} (${selectedUnit.electricUsage} kWh)'),
                        const Divider(),
                        Text('Calculated Total Due: ₱${recommendedTotal.toStringAsFixed(2)}',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: RampTheme.primaryBlue)),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  TextField(
                    controller: amountCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Amount Received (PHP)',
                      hintText: recommendedTotal.toStringAsFixed(2),
                    ),
                  ),

                  const SizedBox(height: 12),

                  TextField(
                    controller: refNumCtrl,
                    decoration: const InputDecoration(labelText: 'Reference Number (e.g. GCASH-123456)'),
                  ),

                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        final amountText = amountCtrl.text.trim();
                        final valToValidate = amountText.isEmpty ? recommendedTotal.toString() : amountText;
                        final amountErr = FormValidators.number(
                          valToValidate,
                          'Amount Received',
                          isRequired: true,
                          allowZero: false,
                        );
                        if (amountErr != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(amountErr), backgroundColor: RampTheme.errorRed),
                          );
                          return;
                        }

                        final refErr = RampValidators.validateReferenceNumber(refNumCtrl.text, 'GCash');
                        if (refErr != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(refErr), backgroundColor: RampTheme.errorRed),
                          );
                          return;
                        }

                        final paidAmount = double.tryParse(amountText) ?? recommendedTotal;
                        final newPayment = PaymentRecord(
                          id: 'p_${DateTime.now().millisecondsSinceEpoch}',
                          unitId: selectedUnit.id,
                          unitNumber: selectedUnit.unitNumber,
                          tenantId: selectedUnit.tenantId,
                          tenantName: selectedUnit.tenantName ?? 'Tenant',
                          amount: paidAmount,
                          baseRent: baseRent,
                          waterBill: waterBill,
                          electricBill: electricBill,
                          paymentDate: DateTime.now(),
                          paymentMethod: 'GCash',
                          referenceNumber: refNumCtrl.text.isEmpty ? 'REF-${DateTime.now().millisecondsSinceEpoch}' : refNumCtrl.text,
                          status: 'Paid',
                          transactionType: 'Rent',
                        );

                        ref.read(paymentsProvider.notifier).recordPayment(newPayment);
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Recorded ₱${paidAmount.toStringAsFixed(2)} rent payment for Unit ${selectedUnit.unitNumber}')),
                        );
                      },
                      child: const Text('Record & Credit Rent'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _LedgerCard extends StatelessWidget {
  final PaymentRecord record;
  final NumberFormat currencyFormat;

  const _LedgerCard({required this.record, required this.currencyFormat});

  @override
  Widget build(BuildContext context) {
    final isRent = record.transactionType == 'Rent';

    return Container(
      margin: const EdgeInsets.only(bottom: RampTheme.spacing12),
      padding: const EdgeInsets.all(RampTheme.spacing16),
      decoration: BoxDecoration(
        color: RampTheme.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: RampTheme.standardShadow,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: (isRent ? RampTheme.successGreen : RampTheme.errorRed).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isRent ? Icons.arrow_downward : Icons.arrow_upward,
              color: isRent ? RampTheme.successGreen : RampTheme.errorRed,
            ),
          ),
          const SizedBox(width: RampTheme.spacing12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isRent ? '${record.tenantName ?? "Tenant"} (Unit ${record.unitNumber})' : record.remarks ?? 'Maintenance Expense',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  '${DateFormat.yMMMd().format(record.paymentDate)} • ${record.paymentMethod} (${record.referenceNumber})',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Text(
            '${isRent ? "+" : "-"}${currencyFormat.format(record.amount)}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: isRent ? RampTheme.successGreen : RampTheme.errorRed,
            ),
          ),
        ],
      ),
    );
  }
}
