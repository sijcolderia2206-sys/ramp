import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../providers/providers.dart';
import '../core/widgets/core_widgets.dart';
import '../core/theme/ramp_theme.dart';
import '../core/validation/app_validators.dart';
import '../core/services/report_export_service.dart';
import '../core/services/pdf_receipt_service.dart';
import '../widgets/receipt_modal.dart';

class PaymentsScreen extends ConsumerStatefulWidget {
  const PaymentsScreen({
    super.key,
    this.initialTenant,
    this.initialPayment,
    this.openPaymentForm = false,
    this.tenantFilter,
  });

  final Tenant? initialTenant;
  final PaymentData? initialPayment;
  final bool openPaymentForm;
  final Tenant? tenantFilter;

  @override
  ConsumerState<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends ConsumerState<PaymentsScreen> {
  String _selectedFilter = 'All'; // 'All', 'This Month', 'Last 3 Months'
  String _statusFilter =
      'All'; // 'All', 'Pending', 'Paid', 'Declined', 'Reversed'
  String _tenantCategoryFilter =
      'All'; // 'All', 'Current Tenants', 'Former Tenants'
  String _sortOption =
      'Newest'; // 'Newest', 'Oldest', 'Highest Amount', 'Lowest Amount'
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';

  final List<String> _paymentMethods = [
    'GCash',
    'Maya',
    'Bank Transfer',
    'Cash'
  ];

  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (widget.initialPayment != null) {
        _showReceiptPdfModal(widget.initialPayment!);
      } else if (widget.initialTenant != null || widget.openPaymentForm) {
        _showPayNowDialog(tenant: widget.initialTenant);
      }
    });
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) setState(() => _isLoading = false);
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<bool> _confirmPaymentAction(String title, String message) async {
    return await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('CANCEL'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: const Text('CONFIRM'),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _showEditPaymentModal(PaymentData payment) async {
    final formKey = GlobalKey<FormState>();
    final monthCtrl = TextEditingController(text: payment.month);
    final baseRentCtrl =
        TextEditingController(text: payment.baseRent.toString());
    final waterCtrl = TextEditingController(text: payment.waterBill.toString());
    final electricCtrl =
        TextEditingController(text: payment.electricBill.toString());
    final lateFeeCtrl = TextEditingController(text: payment.lateFee.toString());
    final otherChargeCtrl =
        TextEditingController(text: payment.otherCharge.toString());
    final refCtrl = TextEditingController(text: payment.referenceNumber);
    String method = payment.method;
    String status = payment.status;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          title: const Text('Edit Payment Record'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: monthCtrl,
                    validator: AppValidators.billingMonth,
                    decoration:
                        const InputDecoration(labelText: 'Payment Month'),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: baseRentCtrl,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration:
                        const InputDecoration(labelText: 'Base Rent (₱)'),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: waterCtrl,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration:
                        const InputDecoration(labelText: 'Water Bill (₱)'),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: electricCtrl,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration:
                        const InputDecoration(labelText: 'Electric Bill (₱)'),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: lateFeeCtrl,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration:
                        const InputDecoration(labelText: 'Late Fee (₱)'),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: otherChargeCtrl,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration:
                        const InputDecoration(labelText: 'Other Charge (₱)'),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: refCtrl,
                    validator: AppValidators.paymentReference,
                    decoration:
                        const InputDecoration(labelText: 'Reference Number'),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: method,
                    items: _paymentMethods
                        .map((item) =>
                            DropdownMenuItem(value: item, child: Text(item)))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) setModalState(() => method = value);
                    },
                    decoration:
                        const InputDecoration(labelText: 'Payment Method'),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: status,
                    items: ['Paid', 'Pending', 'Declined', 'Reversed']
                        .map((item) =>
                            DropdownMenuItem(value: item, child: Text(item)))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) setModalState(() => status = value);
                    },
                    decoration:
                        const InputDecoration(labelText: 'Payment Status'),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('CANCEL'),
            ),
            FilledButton(
              onPressed: () {
                if (formKey.currentState?.validate() ?? false) {
                  Navigator.pop(dialogContext, true);
                }
              },
              child: const Text('SAVE'),
            ),
          ],
        ),
      ),
    );

    if (confirmed != true || !mounted) return;

    final baseRent = double.tryParse(baseRentCtrl.text.trim()) ?? 0.0;
    final water = double.tryParse(waterCtrl.text.trim()) ?? 0.0;
    final electric = double.tryParse(electricCtrl.text.trim()) ?? 0.0;
    final lateFee = double.tryParse(lateFeeCtrl.text.trim()) ?? 0.0;
    final otherCharge = double.tryParse(otherChargeCtrl.text.trim()) ?? 0.0;
    final totalAmount = baseRent + water + electric + lateFee + otherCharge;

    final shouldSave = await _confirmPaymentAction(
      'Save payment changes?',
      'This will update the payment record, audit log, and tenant ledger balance.',
    );
    if (!shouldSave || !mounted) return;

    ref.read(paymentProvider.notifier).updatePayment(
          payment.copyWith(
            month: monthCtrl.text.trim(),
            baseRent: baseRent,
            waterBill: water,
            electricBill: electric,
            lateFee: lateFee,
            otherCharge: otherCharge,
            amount: totalAmount,
            method: method,
            paymentMethod: method,
            status: status,
            referenceNumber: refCtrl.text.trim().isEmpty
                ? payment.referenceNumber
                : refCtrl.text.trim(),
          ),
        );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Payment updated and tenant balance recalculated.'),
        backgroundColor: RampColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showPayNowDialog({Tenant? tenant}) {
    showRecordPaymentSheet(context, ref, initialTenant: tenant);
  }

  void _showReceiptPdfModal(PaymentData payment) {
    showDigitalReceiptModal(
      context,
      payment,
      onEdit: () => _showEditPaymentModal(payment),
    );
  }

  Tenant? get _activeTenantFilter =>
      widget.tenantFilter ?? (!widget.openPaymentForm ? widget.initialTenant : null);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tenants = ref.watch(tenantProvider);
    final allPayments = ref.watch(paymentProvider);

    final activeTenant = _activeTenantFilter;
    List<PaymentData> filteredPayments = allPayments;

    if (activeTenant != null) {
      filteredPayments = filteredPayments
          .where((payment) =>
              payment.tenantId == activeTenant.id ||
              (activeTenant.name.isNotEmpty &&
                  payment.tenantName.toLowerCase() == activeTenant.name.toLowerCase()))
          .toList();
    }

    if (_tenantCategoryFilter == 'Current Tenants') {
      final activeTenantIds =
          tenants.where((t) => !t.isFormer).map((t) => t.id).toSet();
      filteredPayments = filteredPayments
          .where(
              (p) => activeTenantIds.contains(p.tenantId) || p.tenantId.isEmpty)
          .toList();
    } else if (_tenantCategoryFilter == 'Former Tenants') {
      final formerTenantIds =
          tenants.where((t) => t.isFormer).map((t) => t.id).toSet();
      filteredPayments = filteredPayments
          .where((p) => formerTenantIds.contains(p.tenantId))
          .toList();
    }

    if (_selectedFilter == 'This Month') {
      final now = DateTime.now();
      filteredPayments = filteredPayments
          .where((p) =>
              p.paymentDate.month == now.month &&
              p.paymentDate.year == now.year)
          .toList();
    } else if (_selectedFilter == 'Last 3 Months') {
      final now = DateTime.now();
      final threeMonthsAgo = DateTime(now.year, now.month - 3, now.day);
      filteredPayments = filteredPayments
          .where((p) => p.paymentDate.isAfter(threeMonthsAgo))
          .toList();
    }

    if (_statusFilter != 'All') {
      if (_statusFilter == 'Maintenance') {
        filteredPayments =
            filteredPayments.where((p) => p.isMaintenance).toList();
      } else {
        filteredPayments = filteredPayments
            .where((p) =>
                p.isRent &&
                p.status.toLowerCase() == _statusFilter.toLowerCase())
            .toList();
      }
    }

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      filteredPayments = filteredPayments.where((p) {
        return p.tenantName.toLowerCase().contains(q) ||
            p.unitNumber.toLowerCase().contains(q) ||
            p.referenceNumber.toLowerCase().contains(q) ||
            p.method.toLowerCase().contains(q) ||
            p.amount.toString().contains(q);
      }).toList();
    }

    filteredPayments = List.from(filteredPayments);
    if (_sortOption == 'Newest') {
      filteredPayments.sort((a, b) => b.paymentDate.compareTo(a.paymentDate));
    } else if (_sortOption == 'Oldest') {
      filteredPayments.sort((a, b) => a.paymentDate.compareTo(b.paymentDate));
    } else if (_sortOption == 'Highest Amount') {
      filteredPayments.sort((a, b) => b.amount.compareTo(a.amount));
    } else if (_sortOption == 'Lowest Amount') {
      filteredPayments.sort((a, b) => a.amount.compareTo(b.amount));
    }

    return Scaffold(
      backgroundColor: isDark
          ? Theme.of(context).scaffoldBackgroundColor
          : RampColors.background,
      appBar: AppBar(
        title: Text(
          activeTenant != null
              ? "${activeTenant.name}'s Payments"
              : 'Payments Ledger',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : RampColors.slate,
          ),
        ),
        backgroundColor:
            isDark ? Theme.of(context).scaffoldBackgroundColor : Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.download_rounded, color: RampColors.primary),
            tooltip: 'Export Payments Ledger',
            onPressed: () async {
              try {
                final path = await ReportExportService.exportPaymentsCsv(
                    filteredPayments);
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('Payments CSV saved to $path'),
                  backgroundColor: RampColors.primary,
                  behavior: SnackBarBehavior.floating,
                  duration: const Duration(seconds: 6),
                ));
              } catch (error) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('Could not export payments: $error'),
                  backgroundColor: RampColors.danger,
                  behavior: SnackBarBehavior.floating,
                ));
              }
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          HapticFeedback.lightImpact();
          await hydratePersistentAppData(ref);
        },
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: const EdgeInsets.only(
                left: 16.0, right: 16.0, top: 12.0, bottom: 100.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (activeTenant != null) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: RampColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: RampColors.primary.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.filter_alt_rounded,
                            color: RampColors.primary, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Showing payments for ${activeTenant.name}'
                            '${activeTenant.unitNumber.isNotEmpty ? ' (${activeTenant.unitNumber})' : ''}',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : RampColors.slate,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                // Search Input with 1-Tap Clear
                Container(
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color:
                          isDark ? const Color(0xFF334155) : RampColors.border,
                    ),
                  ),
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: (val) =>
                        setState(() => _searchQuery = val.trim()),
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: isDark ? Colors.white : RampColors.slate,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search tenant, unit, ref #, or amount...',
                      hintStyle: GoogleFonts.poppins(
                        fontSize: 13,
                        color: isDark
                            ? const Color(0xFF64748B)
                            : RampColors.mutedText,
                      ),
                      prefixIcon: const Icon(Icons.search_rounded,
                          color: RampColors.primary, size: 20),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded, size: 18),
                              onPressed: () {
                                _searchCtrl.clear();
                                setState(() => _searchQuery = '');
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Payment History Header & Filter Options
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Payment History',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : RampColors.slate,
                      ),
                    ),
                    Row(
                      children: [
                        PopupMenuButton<String>(
                          icon: const Icon(Icons.swap_vert_rounded,
                              color: RampColors.primary, size: 20),
                          tooltip: 'Sort Payments',
                          onSelected: (val) {
                            HapticFeedback.lightImpact();
                            setState(() => _sortOption = val);
                          },
                          itemBuilder: (context) => [
                            'Newest',
                            'Oldest',
                            'Highest Amount',
                            'Lowest Amount'
                          ]
                              .map((opt) => PopupMenuItem<String>(
                                    value: opt,
                                    child: Row(
                                      children: [
                                        if (_sortOption == opt)
                                          const Icon(Icons.check,
                                              size: 16,
                                              color: RampColors.primary)
                                        else
                                          const SizedBox(width: 16),
                                        const SizedBox(width: 8),
                                        Text(opt,
                                            style: GoogleFonts.poppins(
                                                fontSize: 13)),
                                      ],
                                    ),
                                  ))
                              .toList(),
                        ),
                        Text(
                          '${filteredPayments.length} ${filteredPayments.length == 1 ? 'record' : 'records'}',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: isDark
                                ? const Color(0xFF94A3B8)
                                : RampColors.mutedText,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Tenant & Date Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: [
                      ...['All', 'Current Tenants', 'Former Tenants']
                          .map((cat) {
                        final isSelected = _tenantCategoryFilter == cat;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: FilterChip(
                            visualDensity: VisualDensity.compact,
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            label: Text(
                              cat,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: isSelected
                                    ? Theme.of(context).colorScheme.onPrimary
                                    : Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            selected: isSelected,
                            onSelected: (_) {
                              HapticFeedback.lightImpact();
                              setState(() => _tenantCategoryFilter = cat);
                            },
                            selectedColor:
                                Theme.of(context).colorScheme.primary,
                            backgroundColor:
                                Theme.of(context).colorScheme.surface,
                            checkmarkColor:
                                Theme.of(context).colorScheme.onPrimary,
                            side: BorderSide(
                              color: Theme.of(context)
                                  .colorScheme
                                  .outlineVariant,
                            ),
                          ),
                        );
                      }),
                      const SizedBox(width: 8),
                      Container(
                          height: 20,
                          width: 1,
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          color: Theme.of(context).colorScheme.outlineVariant),
                      const SizedBox(width: 8),
                      ...['All', 'This Month', 'Last 3 Months'].map((filter) {
                        final isSelected = _selectedFilter == filter;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: FilterChip(
                            visualDensity: VisualDensity.compact,
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            label: Text(
                              filter,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: isSelected
                                    ? Theme.of(context).colorScheme.onPrimary
                                    : Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            selected: isSelected,
                            onSelected: (_) {
                              HapticFeedback.lightImpact();
                              setState(() => _selectedFilter = filter);
                            },
                            selectedColor:
                                Theme.of(context).colorScheme.primary,
                            backgroundColor:
                                Theme.of(context).colorScheme.surface,
                            checkmarkColor:
                                Theme.of(context).colorScheme.onPrimary,
                            side: BorderSide(
                              color: Theme.of(context)
                                  .colorScheme
                                  .outlineVariant,
                            ),
                          ),
                        );
                      }),
                      const SizedBox(width: 8),
                      Container(
                          height: 20,
                          width: 1,
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          color: Theme.of(context).colorScheme.outlineVariant),
                      const SizedBox(width: 8),
                      ...['All', 'Paid', 'Pending', 'Maintenance', 'Declined', 'Reversed']
                          .map((status) {
                        final isSelected = _statusFilter == status;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: FilterChip(
                            visualDensity: VisualDensity.compact,
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            label: Text(
                              status == 'All' ? 'All Status' : status,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: isSelected
                                    ? Theme.of(context).colorScheme.onPrimary
                                    : Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            selected: isSelected,
                            onSelected: (_) {
                              HapticFeedback.lightImpact();
                              setState(() => _statusFilter = status);
                            },
                            selectedColor: status == 'Paid'
                                ? RampColors.success
                                : status == 'Declined' || status == 'Reversed'
                                    ? Theme.of(context).colorScheme.error
                                    : Theme.of(context).colorScheme.primary,
                            backgroundColor:
                                Theme.of(context).colorScheme.surface,
                            checkmarkColor:
                                Theme.of(context).colorScheme.onPrimary,
                            side: BorderSide(
                              color: Theme.of(context)
                                  .colorScheme
                                  .outlineVariant,
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Payments List
                if (_isLoading)
                  const ShimmerList(
                      itemCount: 4, height: 120, padding: EdgeInsets.zero)
                else if (_hasError)
                  ErrorStateWidget(
                    message:
                        'Failed to load payment history. Please try again.',
                    onRetry: () {
                      setState(() {
                        _hasError = false;
                        _isLoading = true;
                      });
                      Future.delayed(const Duration(milliseconds: 400), () {
                        if (mounted) setState(() => _isLoading = false);
                      });
                    },
                  )
                else
                  filteredPayments.isEmpty
                      ? EmptyStateWidget(
                          title: 'No Payments Found',
                          message:
                              'No payment records match the current filter criteria.',
                          icon: Icons.history_toggle_off_rounded,
                          buttonText: 'Record Payment',
                          buttonIcon: Icons.payments_rounded,
                          onButtonPressed: () => _showPayNowDialog(),
                        )
                      : Column(
                          children:
                              List.generate(filteredPayments.length, (index) {
                            final payment = filteredPayments[index];

                            return StaggeredListItem(
                              index: index,
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 16.0),
                                child: Card(
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    side: BorderSide(
                                      color: Theme.of(context).colorScheme.outlineVariant,
                                    ),
                                  ),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(16),
                                    onTap: () => _showReceiptPdfModal(payment),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Row(
                                                  children: [
                                                    Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              10),
                                                      decoration: BoxDecoration(
                                                        color: payment.isMaintenance
                                                            ? RampColors.warning.withValues(alpha: 0.14)
                                                            : payment.isPaid
                                                            ? RampColors
                                                                .successTint
                                                            : payment.isDeclined ||
                                                                    payment
                                                                        .isReversed
                                                                ? Theme.of(context).colorScheme.errorContainer
                                                                : Theme.of(context).colorScheme.primaryContainer,
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                                12),
                                                      ),
                                                      child: Icon(
                                                        payment.isMaintenance
                                                            ? Icons.home_repair_service_rounded
                                                            : payment.method == 'GCash'
                                                            ? Icons
                                                                .account_balance_wallet_rounded
                                                            : payment.method ==
                                                                    'Maya'
                                                                ? Icons
                                                                    .credit_card_rounded
                                                                : payment.method ==
                                                                        'Bank Transfer'
                                                                    ? Icons
                                                                        .account_balance_rounded
                                                                    : Icons
                                                                        .payments_rounded,
                                                        color: payment.isMaintenance
                                                            ? RampColors.warning
                                                            : payment.isPaid
                                                            ? RampColors.success
                                                            : payment.isDeclined ||
                                                                    payment
                                                                        .isReversed
                                                                ? Theme.of(context).colorScheme.error
                                                                : Theme.of(context).colorScheme.primary,
                                                        size: 22,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 12),
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            payment.isMaintenance
                                                                ? 'Maintenance • ${payment.unitNumber}'
                                                                : '${payment.tenantName} (${payment.unitNumber})',
                                                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                                              fontWeight: FontWeight.bold,
                                                              color: Theme.of(context).colorScheme.onSurface,
                                                            ),
                                                            overflow: TextOverflow
                                                                .ellipsis,
                                                            maxLines: 1,
                                                          ),
                                                          const SizedBox(
                                                              height: 2),
                                                          Text(
                                                            payment.isMaintenance
                                                                ? '${payment.remarks ?? 'Repair estimate'} • Ticket ${payment.ticketId ?? 'Unlinked'}'
                                                                : '${payment.month} • ${payment.method} • ${DateFormat('MMM dd, yyyy').format(payment.paymentDate)}',
                                                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                                                              fontSize: 12,
                                                            ),
                                                            overflow: TextOverflow.ellipsis,
                                                            maxLines: 1,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 10,
                                                        vertical: 6),
                                                decoration: BoxDecoration(
                                                  color: payment.isMaintenance
                                                      ? RampColors.warning.withValues(alpha: 0.14)
                                                      : payment.isPaid
                                                      ? RampColors.successTint
                                                      : payment.isDeclined ||
                                                              payment.isReversed
                                                          ? Theme.of(context).colorScheme.errorContainer
                                                          : Theme.of(context).colorScheme.primaryContainer,
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                child: Text(
                                                  payment.formattedAmount,
                                                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                                    fontWeight: FontWeight.bold,
                                                    color: payment.isMaintenance
                                                        ? RampColors.warning
                                                        : payment.isPaid
                                                        ? RampColors.success
                                                        : payment.isDeclined ||
                                                                payment.isReversed
                                                            ? Theme.of(context).colorScheme.error
                                                            : Theme.of(context).colorScheme.primary,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Divider(
                                              height: 20,
                                              color: Theme.of(context).colorScheme.outlineVariant),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Row(
                                                  children: [
                                                    Icon(
                                                      payment.isPaid
                                                          ? Icons
                                                              .check_circle_rounded
                                                          : payment.isDeclined ||
                                                                  payment.isReversed
                                                              ? Icons.cancel_rounded
                                                              : Icons
                                                                  .pending_actions_rounded,
                                                      color: payment.isPaid
                                                          ? RampColors.success
                                                          : payment.isDeclined ||
                                                                  payment.isReversed
                                                              ? Theme.of(context).colorScheme.error
                                                              : Theme.of(context).colorScheme.primary,
                                                      size: 16,
                                                    ),
                                                    const SizedBox(width: 6),
                                                    Text(
                                                      payment.status.toUpperCase(),
                                                      style: TextStyle(
                                                        fontSize: 11,
                                                        fontWeight: FontWeight.bold,
                                                        color: payment.isPaid
                                                            ? RampColors.success
                                                            : payment.isDeclined ||
                                                                    payment
                                                                        .isReversed
                                                                ? Theme.of(context).colorScheme.error
                                                                : Theme.of(context).colorScheme.primary,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 10),
                                                    Expanded(
                                                      child: Text(
                                                        'Ref: ${payment.referenceNumber}',
                                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                                                        ),
                                                        overflow: TextOverflow.ellipsis,
                                                        maxLines: 1,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Row(
                                                children: [
                                                  IconButton(
                                                    icon: Icon(
                                                        Icons.edit_outlined,
                                                        size: 18,
                                                        color:
                                                            Theme.of(context).colorScheme.primary),
                                                    tooltip: 'Edit Record',
                                                    onPressed: () =>
                                                        _showEditPaymentModal(
                                                            payment),
                                                  ),
                                                  IconButton(
                                                    icon: Icon(
                                                        Icons
                                                            .delete_outline_rounded,
                                                        size: 18,
                                                        color: Theme.of(context).colorScheme.error),
                                                    tooltip: 'Delete Record',
                                                    onPressed: () async {
                                                      final confirm =
                                                          await _confirmPaymentAction(
                                                        'Delete Payment Record?',
                                                        'This will permanently delete this payment from the ledger and recalculate tenant balance.',
                                                      );
                                                      if (confirm) {
                                                        ref
                                                            .read(paymentProvider
                                                                .notifier)
                                                            .deletePayment(
                                                                payment.id);
                                                        if (context.mounted) {
                                                          ScaffoldMessenger.of(
                                                                  context)
                                                              .showSnackBar(
                                                            const SnackBar(
                                                                content: Text(
                                                                    'Payment deleted.')),
                                                          );
                                                        }
                                                      }
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton.extended(
        heroTag: null,
        onPressed: _showPayNowDialog,
        icon: const Icon(Icons.payments_rounded),
        label: const Text(
          'Record Payment',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

typedef TenantPaymentsScreen = PaymentsScreen;

void showRecordPaymentSheet(
  BuildContext context,
  WidgetRef ref, {
  Tenant? initialTenant,
}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  const paymentMethods = ['GCash', 'Maya', 'Bank Transfer', 'Cash'];
  String selectedMethod = 'GCash';
  final allTenants = ref.read(tenantProvider);
  if (allTenants.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Create a tenant profile before recording a payment.'),
    ));
    return;
  }
  Tenant? selectedTenant = initialTenant ??
      allTenants.where((t) => !t.isArchived).firstOrNull ??
      allTenants.firstOrNull;

  final refController = TextEditingController();
  final monthController = TextEditingController(
    text: DateFormat('MMMM yyyy').format(DateTime.now()),
  );
  final amountController = TextEditingController();

  final baseRentCtrl = TextEditingController();
  final waterCtrl = TextEditingController(text: '0.0');
  final electricCtrl = TextEditingController(text: '0.0');
  final lateFeeCtrl = TextEditingController(text: '0.0');

  final currencyFormat = NumberFormat.currency(
    locale: 'en_PH',
    symbol: '₱',
    decimalDigits: 2,
  );

  void applyTenantCharges(Tenant selected) {
    final unit = ref
        .read(unitProvider)
        .where((item) => item.id == selected.unitId)
        .firstOrNull;
    final rates = ref.read(utilityRateProvider);
    final water = unit == null || !unit.waterUtilityEnabled
        ? 0.0
        : unit.waterUsage * unit.effectiveWaterRate(rates.waterRate);
    final electricity = unit == null || !unit.electricityUtilityEnabled
        ? 0.0
        : unit.electricUsage *
            unit.effectiveElectricityRate(rates.electricityRate);
    baseRentCtrl.text = selected.monthlyRent.toStringAsFixed(2);
    waterCtrl.text = water.toStringAsFixed(2);
    electricCtrl.text = electricity.toStringAsFixed(2);
    amountController.text =
        (selected.monthlyRent + water + electricity).toStringAsFixed(2);
  }

  if (selectedTenant != null) {
    applyTenantCharges(selectedTenant);
  }

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor:
        isDark ? Theme.of(context).colorScheme.surface : Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (modalContext) {
      return StatefulBuilder(
        builder: (modalContext, setModalState) {
          final activeTenant = selectedTenant;
          final tenantUnit = activeTenant == null
              ? null
              : ref
                  .read(unitProvider)
                  .where((unit) => unit.id == activeTenant.unitId)
                  .firstOrNull;

          final bottomInset = MediaQuery.of(modalContext).viewInsets.bottom +
              MediaQuery.of(modalContext).padding.bottom +
              28;
          return Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: bottomInset,
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.payments_rounded,
                                color: RampColors.primary, size: 26),
                            const SizedBox(width: 8),
                            Text(
                              'Record Payment',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : RampColors.slate,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(modalContext),
                        ),
                      ],
                    ),
                    Divider(
                        color: isDark
                            ? const Color(0xFF334155)
                            : RampColors.border),
                    const SizedBox(height: 12),
                    if (initialTenant == null && allTenants.isNotEmpty) ...[
                      DropdownButtonFormField<String>(
                        initialValue: selectedTenant?.id,
                        decoration: const InputDecoration(
                          labelText: 'Tenant and unit',
                          prefixIcon: Icon(Icons.person_outline_rounded),
                        ),
                        items: allTenants
                            .map((item) => DropdownMenuItem(
                                  value: item.id,
                                  child: Text(
                                      '${item.name} • ${item.unitNumber}${item.isFormer ? ' (Former)' : ''}'),
                                ))
                            .toList(),
                        onChanged: (tenantId) => setModalState(() {
                          selectedTenant = allTenants
                              .where((item) => item.id == tenantId)
                              .firstOrNull;
                          if (selectedTenant != null) {
                            applyTenantCharges(selectedTenant!);
                          }
                        }),
                      ),
                      const SizedBox(height: 12),
                    ],
                    if (activeTenant != null) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: RampColors.softBlueTint,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(activeTenant.name,
                                style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold,
                                    color: RampColors.slate)),
                            Text(
                              '${activeTenant.unitNumber} • Current Balance: ${currencyFormat.format(activeTenant.balance)}',
                              style: GoogleFonts.poppins(
                                  fontSize: 13, color: RampColors.mutedText),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    RampTextField(
                      controller: monthController,
                      label: 'Payment Month',
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: RampTextField(
                            controller: baseRentCtrl,
                            label: 'Base Rent (₱)',
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: RampTextField(
                            controller: waterCtrl,
                            label: 'Water Bill (₱)',
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: RampTextField(
                            controller: electricCtrl,
                            label: 'Electric Bill (₱)',
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: RampTextField(
                            controller: lateFeeCtrl,
                            label: 'Late Fee (₱)',
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    RampTextField(
                      controller: amountController,
                      label: 'Total Amount Paid (₱)',
                      hintText: 'Enter total amount received',
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Payment Method',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: isDark ? Colors.white : RampColors.slate,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: paymentMethods.map((method) {
                        final isSelected = selectedMethod == method;
                        return ChoiceChip(
                          label: Text(
                            method,
                            style: GoogleFonts.poppins(
                              color: isSelected
                                  ? Colors.white
                                  : (isDark ? Colors.white : RampColors.slate),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: RampColors.primary,
                          backgroundColor: isDark
                              ? const Color(0xFF0F172A)
                              : RampColors.background,
                          onSelected: (selected) {
                            if (selected) {
                              setModalState(() => selectedMethod = method);
                            }
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    RampTextField(
                      controller: refController,
                      label: 'Reference Number / Txn ID',
                      hintText: 'e.g. GC-198273645',
                    ),
                    const SizedBox(height: 20),
                    BouncePillButton(
                      text: 'RECORD PAYMENT',
                      icon: Icons.check_circle_rounded,
                      backgroundColor: RampColors.success,
                      onPressed: () async {
                        final month = monthController.text.trim().isEmpty
                            ? DateFormat('MMM yyyy').format(DateTime.now())
                            : monthController.text.trim();
                        final refNum = refController.text.trim().isEmpty
                            ? 'REF-${DateTime.now().millisecondsSinceEpoch.toString().substring(6)}'
                            : refController.text.trim();

                        final baseRent =
                            double.tryParse(baseRentCtrl.text.trim()) ?? 0.0;
                        final water =
                            double.tryParse(waterCtrl.text.trim()) ?? 0.0;
                        final electric =
                            double.tryParse(electricCtrl.text.trim()) ?? 0.0;
                        final lateFee =
                            double.tryParse(lateFeeCtrl.text.trim()) ?? 0.0;
                        final totalPaid =
                            double.tryParse(amountController.text.trim()) ??
                                (baseRent + water + electric + lateFee);

                        if (totalPaid <= 0) {
                          ScaffoldMessenger.of(modalContext).showSnackBar(
                            const SnackBar(
                                content:
                                    Text('Please enter a valid amount paid.')),
                          );
                          return;
                        }

                        final newPayment = PaymentData(
                          month: month,
                          amount: totalPaid,
                          method: selectedMethod,
                          paymentMethod: selectedMethod,
                          date: DateTime.now(),
                          paymentDate: DateTime.now(),
                          status: 'Paid',
                          referenceNumber: refNum,
                          unitId:
                              activeTenant?.unitId ?? tenantUnit?.id ?? 'u1',
                          unitNumber: activeTenant?.unitNumber ??
                              tenantUnit?.unitNumber ??
                              'Unit 1',
                          tenantId: activeTenant?.id ?? '',
                          tenantName: activeTenant?.name ?? 'Tenant',
                          baseRent: baseRent > 0 ? baseRent : totalPaid,
                          waterBill: water,
                          electricBill: electric,
                          lateFee: lateFee,
                        );

                        final confirmed = await showDialog<bool>(
                              context: modalContext,
                              builder: (dialogContext) => AlertDialog(
                                title: const Text('Record this payment?'),
                                content: const Text(
                                    'Add this payment to the tenant ledger and recalculate balance?'),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(dialogContext, false),
                                    child: const Text('CANCEL'),
                                  ),
                                  FilledButton(
                                    onPressed: () =>
                                        Navigator.pop(dialogContext, true),
                                    child: const Text('CONFIRM'),
                                  ),
                                ],
                              ),
                            ) ??
                            false;

                        if (!confirmed || !modalContext.mounted) return;
                        ref
                            .read(paymentProvider.notifier)
                            .addPayment(newPayment);

                        Navigator.pop(modalContext);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                'Payment for $month submitted successfully! Ref: $refNum'),
                            backgroundColor: RampColors.success,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          );
        },
      );
    },
  );
}
