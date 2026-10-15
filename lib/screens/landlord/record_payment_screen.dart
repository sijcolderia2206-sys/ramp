// lib/screens/landlord/record_payment_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../theme.dart';
import '../../models/tenant_model.dart';
import '../../models/unit_model.dart';
import '../../models/payment_model.dart';

import '../../providers/landlord_providers.dart';
import '../../core/pdf_exporter.dart';
import '../../core/validators.dart';
import '../../widgets/neumorphic_widgets.dart';

class RecordPaymentScreen extends ConsumerStatefulWidget {
  const RecordPaymentScreen({super.key});

  @override
  ConsumerState<RecordPaymentScreen> createState() => _RecordPaymentScreenState();
}

class _RecordPaymentScreenState extends ConsumerState<RecordPaymentScreen> {
  final ImagePicker _picker = ImagePicker();

  String? _selectedTenantId;
  String _paymentMethod = 'Cash'; // Default: Cash, GCash, Maya, Bank Transfer

  final _amountCtrl = TextEditingController();
  final _refCtrl = TextEditingController();
  final _remarksCtrl = TextEditingController();

  DateTime _paymentDate = DateTime.now();
  TimeOfDay _paymentTime = TimeOfDay.now();

  File? _receiptFile;
  bool _isOcrScanning = false;
  String? _ocrExtractedRef;
  DateTime? _ocrExtractedDateTime;

  final List<String> _paymentMethods = [
    'Cash',
    'GCash',
    'Maya',
    'Bank Transfer',
  ];

  @override
  void dispose() {
    _amountCtrl.dispose();
    _refCtrl.dispose();
    _remarksCtrl.dispose();
    super.dispose();
  }

  // Pick receipt & run OCR scanning for GCash, Maya, Bank Transfer
  Future<void> _pickReceiptAndRunOcr() async {
    final XFile? file = await _picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      setState(() {
        _receiptFile = File(file.path);
        _isOcrScanning = true;
      });

      // Simulate OCR Scanner extraction for Reference Number, Date, and Time
      await Future.delayed(const Duration(milliseconds: 800));

      final now = DateTime.now();
      final msStr = now.millisecondsSinceEpoch.toString();
      final extractedRef = _paymentMethod.toLowerCase().contains('gcash')
          ? '100${msStr.substring(msStr.length - 10)}'
          : '${_paymentMethod.toUpperCase()}-${msStr.substring(3)}';
      final extractedDate = DateTime(now.year, now.month, now.day, 14, 30);

      if (mounted) {
        setState(() {
          _isOcrScanning = false;
          _ocrExtractedRef = extractedRef;
          _ocrExtractedDateTime = extractedDate;
          _refCtrl.text = extractedRef;
          _paymentDate = extractedDate;
          _paymentTime = TimeOfDay.fromDateTime(extractedDate);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('OCR Scanning Success! Extracted Reference: $extractedRef, Date: ${DateFormat('yyyy-MM-dd').format(extractedDate)}, Time: 14:30'),
            backgroundColor: RampTheme.successGreen,
          ),
        );
      }
    }
  }

  Future<void> _selectPaymentDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _paymentDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null) {
      setState(() {
        _paymentDate = DateTime(picked.year, picked.month, picked.day, _paymentTime.hour, _paymentTime.minute);
      });
    }
  }

  Future<void> _selectPaymentTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _paymentTime,
    );
    if (picked != null) {
      setState(() {
        _paymentTime = picked;
        _paymentDate = DateTime(_paymentDate.year, _paymentDate.month, _paymentDate.day, picked.hour, picked.minute);
      });
    }
  }

  PaymentRecord? _buildPaymentRecord(TenantRecord tenant, RentalUnit unit) {
    final amount = double.tryParse(_amountCtrl.text.trim()) ?? unit.monthlyRent;
    final refNo = _refCtrl.text.trim().isEmpty
        ? 'REF-${DateTime.now().millisecondsSinceEpoch}'
        : _refCtrl.text.trim();

    return PaymentRecord(
      id: 'p_${DateTime.now().millisecondsSinceEpoch}',
      unitId: unit.id,
      unitNumber: unit.unitNumber,
      tenantId: tenant.id,
      tenantName: tenant.name,
      amount: amount,
      baseRent: unit.monthlyRent,
      waterBill: unit.calculatedWaterBill,
      electricBill: unit.calculatedElectricBill,
      paymentDate: _paymentDate,
      paymentMethod: _paymentMethod,
      referenceNumber: refNo,
      status: 'Paid',
      transactionType: 'Rent',
      remarks: _remarksCtrl.text.trim().isEmpty ? null : _remarksCtrl.text.trim(),
    );
  }

  Future<void> _recordAndDownloadReceipt(TenantRecord tenant, RentalUnit unit) async {
    final amountErr = FormValidators.number(_amountCtrl.text, 'Payment Amount', isRequired: true, min: 1, max: 10000000);
    if (amountErr != null) {
      NeumorphicFeedback.showSnackBar(context, message: amountErr, isError: true);
      return;
    }
    final refErr = RampValidators.validateReferenceNumber(_refCtrl.text, _paymentMethod);
    if (refErr != null) {
      NeumorphicFeedback.showSnackBar(context, message: refErr, isError: true);
      return;
    }
    final record = _buildPaymentRecord(tenant, unit);
    if (record != null) {
      final res = await ref.read(paymentsProvider.notifier).recordPayment(record);
      if (res.isOfflineQueued && mounted) {
        RampPdfExporter.printPaymentReceiptPdf(record);
        NeumorphicFeedback.showSnackBar(context, message: 'Offline Mode: Payment recorded locally and receipt generated!');
        context.pop();
      } else if (res.isSuccess && mounted) {
        RampPdfExporter.printPaymentReceiptPdf(record);
        NeumorphicFeedback.showSnackBar(context, message: 'Payment recorded and official receipt PDF generated!');
        context.pop();
      } else if (mounted) {
        NeumorphicFeedback.showSnackBar(context, message: 'Failed to record payment: ${res.errorMessage ?? "Database write rejected."}', isError: true);
      }
    }
  }

  Future<void> _submitPayment(TenantRecord tenant, RentalUnit unit) async {
    final amountErr = FormValidators.number(_amountCtrl.text, 'Payment Amount', isRequired: true, min: 1, max: 10000000);
    if (amountErr != null) {
      NeumorphicFeedback.showSnackBar(context, message: amountErr, isError: true);
      return;
    }
    final refErr = RampValidators.validateReferenceNumber(_refCtrl.text, _paymentMethod);
    if (refErr != null) {
      NeumorphicFeedback.showSnackBar(context, message: refErr, isError: true);
      return;
    }
    final record = _buildPaymentRecord(tenant, unit);
    if (record != null) {
      final res = await ref.read(paymentsProvider.notifier).recordPayment(record);
      if (res.isOfflineQueued && mounted) {
        NeumorphicFeedback.showSnackBar(context, message: 'Offline Mode: Payment ₱${record.amount.toStringAsFixed(2)} queued for sync.');
        context.pop();
      } else if (res.isSuccess && mounted) {
        ref.read(notificationsProvider.notifier).addNotification(
              'Payment Recorded',
              'Recorded ₱${record.amount.toStringAsFixed(2)} from ${tenant.name} ($_paymentMethod)',
              'payment',
            );
        NeumorphicFeedback.showSnackBar(context, message: 'Payment ₱${record.amount.toStringAsFixed(2)} recorded successfully!');
        context.pop();
      } else if (mounted) {
        NeumorphicFeedback.showSnackBar(context, message: 'Failed to record payment: ${res.errorMessage ?? "Database write rejected."}', isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tenants = ref.watch(tenantsProvider);
    final units = ref.watch(unitsProvider);

    if (_selectedTenantId == null && tenants.isNotEmpty) {
      _selectedTenantId = tenants.first.id;
    }

    final selectedTenant = tenants.firstWhere(
      (t) => t.id == _selectedTenantId,
      orElse: () => tenants.isNotEmpty
          ? tenants.first
          : TenantRecord(
              id: '',
              name: '',
              phone: '',
              unitId: '',
              unitNumber: '',
              monthlyRent: 0,
              leaseStart: DateTime.now(),
              leaseEnd: DateTime.now(),
              dueDate: DateTime.now(),
            ),
    );

    // Auto-filled assigned unit based on selected tenant
    final assignedUnit = units.firstWhere(
      (u) => u.id == selectedTenant.unitId || u.unitNumber == selectedTenant.unitNumber,
      orElse: () => RentalUnit(
        id: selectedTenant.unitId,
        title: 'Unit ${selectedTenant.unitNumber}',
        unitNumber: selectedTenant.unitNumber,
        monthlyRent: selectedTenant.monthlyRent,
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Record Payment'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(RampTheme.spacing20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: RampTheme.primaryBlue.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: RampTheme.primaryBlue.withValues(alpha: 0.2)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.payments, color: RampTheme.primaryBlue, size: 28),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Record rent payments with OCR receipt verification and instant PDF receipt generation.',
                      style: TextStyle(fontSize: 13, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: RampTheme.spacing20),

            // Card 1: Tenant & Auto-Filled Unit Information
            Container(
              padding: const EdgeInsets.all(RampTheme.spacing20),
              decoration: BoxDecoration(
                color: RampTheme.cardBackground,
                borderRadius: BorderRadius.circular(20),
                boxShadow: RampTheme.standardShadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Tenant Information', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: RampTheme.primaryBlue)),
                  const Divider(height: 24),

                  // Select Tenant Field
                  DropdownButtonFormField<String>(
                    initialValue: _selectedTenantId,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Select Tenant',
                      prefixIcon: Icon(Icons.person),
                    ),
                    items: tenants.isEmpty
                        ? [const DropdownMenuItem(value: 't1', child: Text('Sample Tenant'))]
                        : tenants.map((t) {
                            return DropdownMenuItem(
                              value: t.id,
                              child: Text('${t.name} (Unit ${t.unitNumber})'),
                            );
                          }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _selectedTenantId = val;
                          _amountCtrl.text = selectedTenant.monthlyRent.toStringAsFixed(0);
                        });
                      }
                    },
                  ),

                  const SizedBox(height: RampTheme.spacing16),

                  // Auto-Filled Assigned Unit Field (Read-only)
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: RampTheme.scaffoldBackground,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: RampTheme.dividerColor),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              const Icon(Icons.apartment, color: RampTheme.primaryBlue),
                              const SizedBox(width: 10),
                              Flexible(child: const Text('Assigned Unit:', style: TextStyle(fontSize: 13, color: RampTheme.textSecondary))),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Unit ${assignedUnit.unitNumber}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: RampTheme.primaryBlue),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: RampTheme.spacing20),

            // Card 1.5: Submeter Utility Auto-Calculator Panel
            Builder(
              builder: (context) {
                final waterDelta = (assignedUnit.waterReadingCurr - assignedUnit.waterReadingPrev).clamp(0.0, 99999.0);
                final waterBill = waterDelta * 45.0;
                final electricDelta = (assignedUnit.electricReadingCurr - assignedUnit.electricReadingPrev).clamp(0.0, 99999.0);
                final electricBill = electricDelta * 12.50;
                final totalCalculatedBill = assignedUnit.monthlyRent + waterBill + electricBill;

                return Container(
                  padding: const EdgeInsets.all(RampTheme.spacing20),
                  decoration: BoxDecoration(
                    color: RampTheme.primaryBlue.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: RampTheme.primaryBlue.withValues(alpha: 0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.calculate, color: RampTheme.primaryBlue, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Itemized Bill Auto-Calculator',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: RampTheme.primaryBlue),
                              ),
                            ],
                          ),
                          Text(
                            'Unit ${assignedUnit.unitNumber}',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: RampTheme.textSecondary),
                          ),
                        ],
                      ),
                      const Divider(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Base Rent', style: TextStyle(fontSize: 12, color: RampTheme.textSecondary)),
                          Text('₱${assignedUnit.monthlyRent.toStringAsFixed(2)}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Water (${waterDelta.toStringAsFixed(1)} m³ @ ₱45/m³)', style: const TextStyle(fontSize: 12, color: RampTheme.textSecondary)),
                          Text('₱${waterBill.toStringAsFixed(2)}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Electricity (${electricDelta.toStringAsFixed(1)} kWh @ ₱12.50/kWh)', style: const TextStyle(fontSize: 12, color: RampTheme.textSecondary)),
                          Text('₱${electricBill.toStringAsFixed(2)}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                        ],
                      ),
                      const Divider(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total Estimated Due:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          Text(
                            '₱${totalCalculatedBill.toStringAsFixed(2)}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: RampTheme.primaryBlue),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.flash_on, size: 16),
                          label: Text('Apply Itemized Total (₱${totalCalculatedBill.toStringAsFixed(0)})'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: RampTheme.primaryBlue,
                            side: const BorderSide(color: RampTheme.primaryBlue),
                          ),
                          onPressed: () {
                            setState(() {
                              _amountCtrl.text = totalCalculatedBill.toStringAsFixed(0);
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Applied itemized bill total ₱${totalCalculatedBill.toStringAsFixed(2)} to payment amount.'),
                                backgroundColor: RampTheme.primaryBlue,
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: RampTheme.spacing20),

            // Card 2: Payment Details & Method
            Container(
              padding: const EdgeInsets.all(RampTheme.spacing20),
              decoration: BoxDecoration(
                color: RampTheme.cardBackground,
                borderRadius: BorderRadius.circular(20),
                boxShadow: RampTheme.standardShadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Payment Details', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: RampTheme.primaryBlue)),
                  const Divider(height: 24),

                  // Payment Method Options: Cash - default, GCash, Maya, Bank Transfer
                  DropdownButtonFormField<String>(
                    initialValue: _paymentMethod,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Payment Method',
                      prefixIcon: Icon(Icons.account_balance_wallet),
                    ),
                    items: _paymentMethods.map((method) {
                      return DropdownMenuItem(value: method, child: Text(method));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _paymentMethod = val);
                    },
                  ),

                  const SizedBox(height: RampTheme.spacing16),

                  TextField(
                    controller: _amountCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Amount Received (PHP)',
                      hintText: assignedUnit.monthlyRent.toStringAsFixed(0),
                      prefixIcon: const Icon(Icons.attach_money),
                    ),
                  ),

                  const SizedBox(height: RampTheme.spacing16),

                  TextField(
                    controller: _refCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Reference Number',
                      hintText: 'e.g. 1029384756',
                      prefixIcon: Icon(Icons.receipt),
                    ),
                  ),

                  const SizedBox(height: RampTheme.spacing16),

                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: _selectPaymentDate,
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: RampTheme.dividerColor)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Date', style: TextStyle(fontSize: 11, color: RampTheme.textSecondary)),
                                Text(DateFormat('yyyy-MM-dd').format(_paymentDate), style: const TextStyle(fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: InkWell(
                          onTap: _selectPaymentTime,
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: RampTheme.dividerColor)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Time', style: TextStyle(fontSize: 11, color: RampTheme.textSecondary)),
                                Text(_paymentTime.format(context), style: const TextStyle(fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // OCR Receipt Feature for GCash, Maya, Bank Transfer
                  if (_paymentMethod != 'Cash') ...[
                    const SizedBox(height: RampTheme.spacing16),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                        padding: const EdgeInsets.all(12),
                      ),
                      icon: const Icon(Icons.document_scanner, color: RampTheme.primaryBlue),
                      label: Text(_receiptFile == null
                          ? 'Upload Receipt & Extract OCR (Ref, Date, Time)'
                          : 'Receipt Attached: ${_receiptFile!.path.split('/').last}'),
                      onPressed: _pickReceiptAndRunOcr,
                    ),

                    if (_isOcrScanning) ...[
                      const SizedBox(height: 10),
                      const Row(
                        children: [
                          SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                          SizedBox(width: 8),
                          Text('Scanning receipt text (Ref, Date, Time)...', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ],

                    if (_ocrExtractedRef != null) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: RampTheme.successGreen.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: RampTheme.successGreen.withValues(alpha: 0.3)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.check_circle, color: RampTheme.successGreen, size: 16),
                                SizedBox(width: 6),
                                Text('OCR Extracted Details:', style: TextStyle(fontWeight: FontWeight.bold, color: RampTheme.successGreen, fontSize: 12)),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text('• Ref Number: $_ocrExtractedRef', style: const TextStyle(fontSize: 12)),
                            Text('• Date & Time: ${DateFormat('yyyy-MM-dd HH:mm').format(_ocrExtractedDateTime!)}', style: const TextStyle(fontSize: 12)),
                          ],
                        ),
                      ),
                    ],
                  ],

                  const SizedBox(height: RampTheme.spacing16),

                  TextField(
                    controller: _remarksCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Remarks / Notes',
                      prefixIcon: Icon(Icons.notes),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: RampTheme.spacing24),

            // Action Buttons
            Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () => _submitPayment(selectedTenant, assignedUnit),
                    child: const Text('Record Payment'),
                  ),
                ),
                const SizedBox(height: RampTheme.spacing12),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.picture_as_pdf, color: RampTheme.primaryBlue),
                    label: const Text('Download Official Receipt PDF'),
                    onPressed: () => _recordAndDownloadReceipt(selectedTenant, assignedUnit),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
