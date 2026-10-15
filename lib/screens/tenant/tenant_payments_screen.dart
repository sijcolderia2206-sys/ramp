import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../theme.dart';
import '../../models/payment_model.dart';
import '../../models/tenant_model.dart';
import '../../models/unit_model.dart';
import '../../widgets/neumorphic_widgets.dart';
import '../../widgets/dashed_border_container.dart';
import '../../widgets/qr_code_widget.dart';
import '../../providers/tenant_providers.dart';
import '../../providers/landlord_providers.dart';

class TenantPaymentsScreen extends ConsumerStatefulWidget {
  const TenantPaymentsScreen({super.key});

  @override
  ConsumerState<TenantPaymentsScreen> createState() => _TenantPaymentsScreenState();
}

class _TenantPaymentsScreenState extends ConsumerState<TenantPaymentsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _refController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  String _selectedMethod = 'GCash'; // 'GCash', 'Maya', 'Bank Transfer'
  XFile? _proofImageFile;
  bool _isUploadingAndSubmitting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final tenant = ref.read(currentTenantProvider);
      if (tenant != null && tenant.balance > 0) {
        _amountController.text = tenant.balance.toStringAsFixed(2);
      }
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _refController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? file = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (file != null) {
        setState(() => _proofImageFile = file);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
    }
  }

  Future<void> _submitPayment(TenantRecord tenant, RentalUnit? unit) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final refNumber = _refController.text.trim();
    final amountText = _amountController.text.trim();
    final amount = double.tryParse(amountText) ?? 0.0;

    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid payment amount.')),
      );
      return;
    }

    if (_proofImageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please attach a proof of payment screenshot or receipt.')),
      );
      return;
    }

    setState(() => _isUploadingAndSubmitting = true);

    try {
      // 1. Upload proof image to Supabase ramp_media storage bucket
      final proofUrl = await uploadToRampMedia(_proofImageFile!, 'payment_proofs');

      // 2. Build PaymentRecord object with status: 'Pending'
      final paymentRecord = PaymentRecord(
        id: 'pay_${DateTime.now().millisecondsSinceEpoch}',
        unitId: unit?.id ?? tenant.unitId,
        unitNumber: unit?.unitNumber ?? tenant.unitNumber,
        tenantId: tenant.id,
        tenantName: tenant.name,
        amount: amount,
        baseRent: tenant.monthlyRent,
        paymentDate: DateTime.now(),
        paymentMethod: _selectedMethod,
        referenceNumber: refNumber,
        status: 'Pending', // Enforced requirement: set status: 'Pending'
        transactionType: 'Rent',
        proofImageUrl: proofUrl,
      );

      // 3. Insert into public.payments table
      await ref.read(paymentsProvider.notifier).recordPayment(paymentRecord);

      // 4. Trigger system notification
      ref.read(notificationsProvider.notifier).addNotification(
            'Payment Verification Required',
            '${tenant.name} submitted ₱${amount.toStringAsFixed(2)} via $_selectedMethod (Ref: $refNumber)',
            'payment',
          );

      if (mounted) {
        setState(() {
          _isUploadingAndSubmitting = false;
          _proofImageFile = null;
          _refController.clear();
          if (tenant.balance > 0) {
            _amountController.text = tenant.balance.toStringAsFixed(2);
          } else {
            _amountController.clear();
          }
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: RampTheme.successGreen,
            content: Text('Payment proof submitted successfully! Awaiting landlord verification.'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUploadingAndSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: RampTheme.errorRed,
            content: Text('Failed to submit payment: $e'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tenant = ref.watch(currentTenantProvider);
    final unit = ref.watch(currentTenantUnitProvider);
    final tenantPayments = ref.watch(tenantPaymentsProvider);
    final currencyFormat = NumberFormat.currency(locale: 'en_PH', symbol: '₱', decimalDigits: 2);

    if (tenant == null) {
      return const Scaffold(
        backgroundColor: Color(0xFFE0E5EC),
        body: Center(
          child: Text('Tenant record not loaded.'),
        ),
      );
    }

    // 1. Find latest unpaid payment or calculate itemized bill
    PaymentRecord? latestUnpaid;
    try {
      latestUnpaid = tenantPayments.firstWhere((p) => p.status == 'Pending' || p.status == 'Unpaid');
    } catch (_) {
      latestUnpaid = null;
    }

    final propertySettings = ref.watch(propertySettingsProvider);
    final double waterRate = unit?.waterRateOverride ?? propertySettings.waterRate;
    final double electricRate = unit?.electricityRateOverride ?? propertySettings.electricRate;

    final double baseRent = latestUnpaid?.baseRent ?? tenant.monthlyRent;
    final double waterBill = latestUnpaid?.waterBill ??
        (unit?.waterReadingCurr != null
            ? ((unit!.waterReadingCurr - unit.waterReadingPrev) * waterRate).clamp(0.0, double.infinity)
            : 0.0);
    final double electricBill = latestUnpaid?.electricBill ??
        (unit?.electricReadingCurr != null
            ? ((unit!.electricReadingCurr - unit.electricReadingPrev) * electricRate).clamp(0.0, double.infinity)
            : 0.0);
    final double lateFee = latestUnpaid?.lateFee ?? (tenant.isOverdue ? 500.0 : 0.0);
    final double totalDue = (baseRent + waterBill + electricBill + lateFee) > 0
        ? (baseRent + waterBill + electricBill + lateFee)
        : tenant.balance;

    return Scaffold(
      backgroundColor: const Color(0xFFE0E5EC),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(RampTheme.spacing20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Title
                Text(
                  'PAYMENTS & LEDGER',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                    color: RampTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Rent & Utility Bill',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: RampTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: RampTheme.spacing20),

                // 1. ITEMIZED CURRENT BILL CARD
                Text(
                  'CURRENT STATEMENT',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                    color: RampTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: RampTheme.spacing8),

                NeumorphicContainer(
                  borderRadius: 20.0,
                  padding: const EdgeInsets.all(18.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Itemized Breakdown',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: RampTheme.textPrimary,
                            ),
                          ),
                          NeumorphicPill(
                            text: tenant.balance > 0 ? 'Balance Due' : 'Fully Paid',
                            textColor: tenant.balance > 0 ? RampTheme.errorRed : RampTheme.successGreen,
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      const Divider(height: 1),
                      const SizedBox(height: 12),

                      _buildItemizedRow('Base Rent', baseRent, currencyFormat),
                      const SizedBox(height: 8),
                      _buildItemizedRow('Water Utility', waterBill, currencyFormat),
                      const SizedBox(height: 8),
                      _buildItemizedRow('Electricity Utility', electricBill, currencyFormat),
                      const SizedBox(height: 8),
                      _buildItemizedRow('Late Fee', lateFee, currencyFormat, isPenalty: true),

                      const SizedBox(height: 12),
                      const Divider(height: 1),
                      const SizedBox(height: 12),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total Due',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: RampTheme.textPrimary,
                            ),
                          ),
                          Text(
                            currencyFormat.format(totalDue),
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: tenant.balance > 0 ? RampTheme.errorRed : RampTheme.successGreen,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: RampTheme.spacing24),

                // LANDLORD PAYMENT ACCOUNT INFO & QR CARD
                Text(
                  'LANDLORD PAYMENT ACCOUNTS',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                    color: RampTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: RampTheme.spacing8),

                NeumorphicContainer(
                  borderRadius: 20.0,
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: NeumorphicDecoration.convex(shape: BoxShape.circle),
                            child: const Icon(Icons.qr_code_2_rounded, color: RampTheme.primaryBlue, size: 24),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Apex Rental Properties',
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: RampTheme.textPrimary),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'GCash / Maya: 0917-123-4567',
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: RampTheme.primaryBlue),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: NeumorphicButton(
                              label: 'Copy Account #',
                              icon: Icons.copy_rounded,
                              height: 38,
                              backgroundColor: NeumorphicDecoration.baseColor,
                              textColor: RampTheme.primaryBlue,
                              onPressed: () {
                                Clipboard.setData(const ClipboardData(text: '09171234567'));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Payment account number copied to clipboard: 09171234567'),
                                    backgroundColor: RampTheme.successGreen,
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: NeumorphicButton(
                              label: 'Show QR Code',
                              icon: Icons.qr_code_scanner_rounded,
                              height: 38,
                              backgroundColor: NeumorphicDecoration.baseColor,
                              textColor: RampTheme.primaryBlue,
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      backgroundColor: const Color(0xFFE0E5EC),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                      title: const Text(
                                        'Payment QR Code',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: RampTheme.textPrimary),
                                      ),
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const QrCodeWidget(data: 'GCASH:09171234567', size: 180),
                                          const SizedBox(height: 16),
                                          const Text(
                                            'Apex Rental Properties\nGCash / Maya: 0917-123-4567',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: RampTheme.textPrimary),
                                          ),
                                        ],
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context),
                                          child: const Text('Close'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: RampTheme.spacing28),

                // 2. DIGITAL PAYMENT FORM
                Text(
                  'SUBMIT DIGITAL PAYMENT',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                    color: RampTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: RampTheme.spacing12),

                // Method Dropdown
                NeumorphicDropdown<String>(
                  label: 'Payment Method *',
                  value: _selectedMethod,
                  prefixIcon: Icons.account_balance_wallet_outlined,
                  items: const [
                    DropdownMenuItem(value: 'GCash', child: Text('GCash')),
                    DropdownMenuItem(value: 'Maya', child: Text('Maya')),
                    DropdownMenuItem(value: 'Bank Transfer', child: Text('Bank Transfer')),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedMethod = val);
                  },
                ),

                const SizedBox(height: RampTheme.spacing16),

                // Amount Field (Defaulting to current balance)
                NeumorphicTextField(
                  controller: _amountController,
                  label: 'Payment Amount (PHP) *',
                  hintText: 'e.g. 15000.00',
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  prefixIcon: Icons.payments_outlined,
                  suffixIcon: tenant.balance > 0
                      ? TextButton(
                          onPressed: () {
                            _amountController.text = tenant.balance.toStringAsFixed(2);
                          },
                          child: const Text('Auto-Fill', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        )
                      : null,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Please enter payment amount';
                    }
                    final num = double.tryParse(val.trim());
                    if (num == null || num <= 0) {
                      return 'Enter a valid amount greater than 0';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: RampTheme.spacing16),

                // Reference Number Field with Validation Rule: GCash strictly requires 13 digits
                NeumorphicTextField(
                  controller: _refController,
                  label: 'Reference Number *',
                  hintText: _selectedMethod == 'GCash'
                      ? '13-digit GCash Ref (e.g. 1002938475123)'
                      : 'Reference Number',
                  keyboardType: TextInputType.number,
                  prefixIcon: Icons.receipt_long_outlined,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Please enter the transaction reference number';
                    }
                    final trimmed = val.trim();
                    if (_selectedMethod == 'GCash') {
                      if (!RegExp(r'^\d{13}$').hasMatch(trimmed)) {
                        return 'GCash reference number must be strictly 13 digits';
                      }
                    } else if (trimmed.length < 4) {
                      return 'Reference number is too short';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: RampTheme.spacing16),

                // Proof Upload Container
                const Padding(
                  padding: EdgeInsets.only(left: 4, bottom: 8),
                  child: Text(
                    'Proof of Payment Attachment *',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: RampTheme.textPrimary),
                  ),
                ),

                if (_proofImageFile == null)
                  DashedBorderContainer(
                    onTap: _pickImage,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: NeumorphicDecoration.convex(
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.add_a_photo_outlined,
                            color: RampTheme.primaryBlue,
                            size: 26,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Tap to upload receipt screenshot',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: RampTheme.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  NeumorphicContainer(
                    isInset: true,
                    borderRadius: 16.0,
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Stack(
                            alignment: Alignment.topRight,
                            children: [
                              Image.file(
                                File(_proofImageFile!.path),
                                height: 160,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: GestureDetector(
                                  onTap: () => setState(() => _proofImageFile = null),
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: const BoxDecoration(
                                      color: Color(0x8A000000),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.close, color: Colors.white, size: 16),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.check_circle, color: RampTheme.successGreen, size: 16),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                _proofImageFile!.name,
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: RampTheme.textPrimary),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: RampTheme.spacing24),

                // Submit Button
                NeumorphicButton(
                  label: _isUploadingAndSubmitting ? 'Submitting...' : 'Submit Payment',
                  icon: Icons.send_rounded,
                  isLoading: _isUploadingAndSubmitting,
                  onPressed: _isUploadingAndSubmitting ? null : () => _submitPayment(tenant, unit),
                ),

                const SizedBox(height: RampTheme.spacing32),

                // 3. PAYMENT LEDGER (HISTORY)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'PAYMENT HISTORY',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                        color: RampTheme.textSecondary,
                      ),
                    ),
                    Text(
                      '${tenantPayments.length} Records',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: RampTheme.primaryBlue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: RampTheme.spacing12),

                if (tenantPayments.isEmpty)
                  NeumorphicContainer(
                    isInset: true,
                    borderRadius: 16,
                    padding: const EdgeInsets.all(20),
                    child: const Center(
                      child: Text('No previous payment records found.', style: TextStyle(color: RampTheme.textSecondary)),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: tenantPayments.length,
                    itemBuilder: (context, index) {
                      final item = tenantPayments[index];

                      Color statusColor;
                      if (item.status == 'Paid') {
                        statusColor = RampTheme.successGreen;
                      } else if (item.status == 'Pending') {
                        statusColor = RampTheme.warningYellow;
                      } else {
                        statusColor = RampTheme.errorRed;
                      }

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: NeumorphicContainer(
                          borderRadius: 16.0,
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: NeumorphicDecoration.inset(
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.receipt_long_rounded,
                                  color: statusColor,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    currencyFormat.format(item.amount),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: RampTheme.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${item.paymentMethod} • Ref: ${item.referenceNumber}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: RampTheme.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    DateFormat('MMM d, yyyy • h:mm a').format(item.paymentDate),
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: RampTheme.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            NeumorphicPill(
                              text: item.status,
                              textColor: statusColor,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildItemizedRow(String title, double value, NumberFormat formatter, {bool isPenalty = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 13,
            color: isPenalty && value > 0 ? RampTheme.errorRed : RampTheme.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          formatter.format(value),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: isPenalty && value > 0 ? RampTheme.errorRed : RampTheme.textPrimary,
          ),
        ),
      ],
    );
  }
}
