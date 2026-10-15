import 'dart:convert';
import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/unit_model.dart';
import '../models/tenant_model.dart';
import '../models/payment_model.dart';

class RampPdfExporter {
  /// Generate Official Payment Receipt PDF
  static Future<void> printPaymentReceiptPdf(PaymentRecord payment) async {
    final pdf = pw.Document();

    final formattedDate = '${payment.paymentDate.year}-${payment.paymentDate.month.toString().padLeft(2, '0')}-${payment.paymentDate.day.toString().padLeft(2, '0')}';
    final formattedTime = '${payment.paymentDate.hour.toString().padLeft(2, '0')}:${payment.paymentDate.minute.toString().padLeft(2, '0')}';

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a5,
        build: (pw.Context context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(24),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header Banner
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'RAMP PROPERTIES',
                          style: pw.TextStyle(
                            fontSize: 20,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.blue900,
                          ),
                        ),
                        pw.Text(
                          'Official Payment Receipt',
                          style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
                        ),
                      ],
                    ),
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.green100,
                        borderRadius: pw.BorderRadius.circular(6),
                      ),
                      child: pw.Text(
                        payment.status.toUpperCase(),
                        style: pw.TextStyle(
                          color: PdfColors.green900,
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 16),
                pw.Divider(),
                pw.SizedBox(height: 12),

                // Receipt Details Table
                pw.Container(
                  padding: const pw.EdgeInsets.all(12),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey100,
                    borderRadius: pw.BorderRadius.circular(8),
                    border: pw.Border.all(color: PdfColors.grey300),
                  ),
                  child: pw.Column(
                    children: [
                      _buildReceiptRow('Receipt ID:', payment.id),
                      pw.SizedBox(height: 6),
                      _buildReceiptRow('Reference No.:', payment.referenceNumber),
                      pw.SizedBox(height: 6),
                      _buildReceiptRow('Date & Time:', '$formattedDate $formattedTime'),
                      pw.SizedBox(height: 6),
                      _buildReceiptRow('Tenant Name:', payment.tenantName ?? 'N/A'),
                      pw.SizedBox(height: 6),
                      _buildReceiptRow('Unit Number:', 'Unit ${payment.unitNumber ?? "N/A"}'),
                      pw.SizedBox(height: 6),
                      _buildReceiptRow('Payment Method:', payment.paymentMethod),
                      pw.SizedBox(height: 6),
                      _buildReceiptRow('Transaction Type:', payment.transactionType),
                    ],
                  ),
                ),

                pw.SizedBox(height: 16),

                // Itemized Breakdown
                pw.Text('PAYMENT SUMMARY', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
                pw.SizedBox(height: 6),
                pw.TableHelper.fromTextArray(
                  headers: ['Description', 'Amount (PHP)'],
                  data: [
                    if (payment.baseRent > 0) ['Base Rent', 'PHP ${payment.baseRent.toStringAsFixed(2)}'],
                    if (payment.waterBill > 0) ['Water Submeter', 'PHP ${payment.waterBill.toStringAsFixed(2)}'],
                    if (payment.electricBill > 0) ['Electric Submeter', 'PHP ${payment.electricBill.toStringAsFixed(2)}'],
                    if (payment.lateFee > 0) ['Late Penalty', 'PHP ${payment.lateFee.toStringAsFixed(2)}'],
                    ['TOTAL RECEIVED', 'PHP ${payment.amount.toStringAsFixed(2)}'],
                  ],
                  headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                  headerDecoration: const pw.BoxDecoration(color: PdfColors.blue900),
                ),

                pw.Spacer(),

                // Stamp / Footer Signature
                pw.Divider(),
                pw.SizedBox(height: 8),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Authorized Property Manager', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
                    pw.Text('Apex Property Management', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'RAMP_Receipt_${payment.referenceNumber}',
    );
  }

  static pw.Widget _buildReceiptRow(String label, String value) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(label, style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
        pw.Text(value, style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
      ],
    );
  }

  /// Generate Itemized Billing Statement PDF for Tenant
  static Future<void> printTenantStatement({
    required TenantRecord tenant,
    required RentalUnit unit,
  }) async {
    final pdf = pw.Document();

    final waterUsage = unit.waterUsage;
    final waterBill = unit.calculatedWaterBill;
    final electricUsage = unit.electricUsage;
    final electricBill = unit.calculatedElectricBill;
    final baseRent = tenant.monthlyRent;
    final totalDue = baseRent + waterBill + electricBill + (tenant.balance > 0 ? unit.lateFee : 0.0);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(32),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'RAMP PROPERTIES',
                          style: pw.TextStyle(
                            fontSize: 24,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.blue900,
                          ),
                        ),
                        pw.Text(
                          'Rental Administration and Maintenance Platform',
                          style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
                        ),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text('STATEMENT OF ACCOUNT', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                        pw.Text('Date: ${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}'),
                      ],
                    )
                  ],
                ),
                pw.SizedBox(height: 24),
                pw.Divider(),
                pw.SizedBox(height: 16),

                // Tenant & Unit Details
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('TENANT DETAILS', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
                        pw.Text('Name: ${tenant.name}'),
                        pw.Text('Phone: ${tenant.phone}'),
                        pw.Text('Email: ${tenant.email ?? "N/A"}'),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('UNIT DETAILS', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
                        pw.Text('Unit Number: ${unit.unitNumber}'),
                        pw.Text('Location: ${unit.location}'),
                        pw.Text('Rent Due Date: ${tenant.dueDate.year}-${tenant.dueDate.month}-${tenant.dueDate.day}'),
                      ],
                    ),
                  ],
                ),
                pw.SizedBox(height: 24),

                // Itemized Table
                pw.Text('ITEMIZED BILLING BREAKDOWN', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)),
                pw.SizedBox(height: 8),
                pw.TableHelper.fromTextArray(
                  headers: ['Description', 'Usage / Rate', 'Amount (PHP)'],
                  data: [
                    ['Base Monthly Rent', 'Standard Rate', 'PHP ${baseRent.toStringAsFixed(2)}'],
                    ['Water Submeter', '${waterUsage.toStringAsFixed(1)} cu.m @ PHP 45.00/cu.m', 'PHP ${waterBill.toStringAsFixed(2)}'],
                    ['Electric Submeter', '${electricUsage.toStringAsFixed(1)} kWh @ PHP 12.50/kWh', 'PHP ${electricBill.toStringAsFixed(2)}'],
                    if (tenant.balance > 0) ['Late Penalty Fee', 'Standard Fee', 'PHP ${unit.lateFee.toStringAsFixed(2)}'],
                  ],
                  headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                  headerDecoration: const pw.BoxDecoration(color: PdfColors.blue900),
                  rowDecoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey300))),
                ),
                pw.SizedBox(height: 16),

                // Total Summary
                pw.Align(
                  alignment: pw.Alignment.centerRight,
                  child: pw.Container(
                    width: 200,
                    padding: const pw.EdgeInsets.all(12),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.blue50,
                      borderRadius: pw.BorderRadius.circular(8),
                      border: pw.Border.all(color: PdfColors.blue200),
                    ),
                    child: pw.Column(
                      children: [
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text('TOTAL DUE:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14, color: PdfColors.blue900)),
                            pw.Text('PHP ${totalDue.toStringAsFixed(2)}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14, color: PdfColors.blue900)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                pw.Spacer(),

                // Footer
                pw.Divider(),
                pw.SizedBox(height: 8),
                pw.Center(
                  child: pw.Text(
                    'Thank you for your prompt payment. Please send digital receipt via GCash or Bank Transfer.',
                    style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'RAMP_Statement_${unit.unitNumber}_${tenant.name.replaceAll(' ', '_')}',
    );
  }

  /// Generate Portfolio Income Statement PDF Report
  static Future<void> printPortfolioIncomeStatementPdf({
    required double grossRevenue,
    required double totalExpenses,
    required double netIncome,
    required int totalUnits,
    required int occupiedUnits,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(32),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('RAMP PROPERTY MANAGEMENT', style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
                        pw.Text('Monthly Net Operating Income (NOI) Statement', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                      ],
                    ),
                    pw.Text('Date: ${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}'),
                  ],
                ),
                pw.SizedBox(height: 20),
                pw.Divider(),
                pw.SizedBox(height: 16),

                pw.Text('FINANCIAL SUMMARY', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 8),

                pw.TableHelper.fromTextArray(
                  headers: ['Financial Metric', 'Value (PHP)'],
                  data: [
                    ['Gross Rental Revenue Collected', 'PHP ${grossRevenue.toStringAsFixed(2)}'],
                    ['Maintenance & Repair Expenses', 'PHP ${totalExpenses.toStringAsFixed(2)}'],
                    ['Net Operating Income (NOI)', 'PHP ${netIncome.toStringAsFixed(2)}'],
                    ['Total Portfolio Units', '$totalUnits Units'],
                    ['Occupied Units', '$occupiedUnits Occupied (${totalUnits > 0 ? (occupiedUnits / totalUnits * 100).toStringAsFixed(0) : 0}%)'],
                  ],
                  headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                  headerDecoration: const pw.BoxDecoration(color: PdfColors.blue900),
                ),

                pw.Spacer(),
                pw.Divider(),
                pw.Center(child: pw.Text('RAMP Landlord Financial Statement Report', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600))),
              ],
            ),
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'RAMP_Portfolio_NOI_Report',
    );
  }

  /// Exports Financial Ledger as CSV File and invokes Share / Print dialog
  static Future<void> exportFinancialLedgerCsv(List<PaymentRecord> payments) async {
    final buffer = StringBuffer();
    // Header
    buffer.writeln('ID,Transaction Type,Tenant Name,Unit Number,Amount (PHP),Base Rent,Water Bill,Electric Bill,Payment Date,Payment Method,Reference Number,Status,Remarks');

    final dateFormat = DateFormat('yyyy-MM-dd HH:mm');

    for (final p in payments) {
      final sanitizedTenant = (p.tenantName ?? '').replaceAll(',', ' ');
      final sanitizedRemarks = (p.remarks ?? '').replaceAll(',', ' ').replaceAll('\n', ' ');
      buffer.writeln(
        '${p.id},${p.transactionType},"$sanitizedTenant",${p.unitNumber},${p.amount.toStringAsFixed(2)},${p.baseRent.toStringAsFixed(2)},${p.waterBill.toStringAsFixed(2)},${p.electricBill.toStringAsFixed(2)},${dateFormat.format(p.paymentDate)},${p.paymentMethod},"${p.referenceNumber}",${p.status},"$sanitizedRemarks"',
      );
    }

    final csvBytes = Uint8List.fromList(utf8.encode(buffer.toString()));

    await Printing.sharePdf(
      bytes: csvBytes,
      filename: 'RAMP_Financial_Ledger_${DateFormat('yyyyMMdd').format(DateTime.now())}.csv',
    );
  }
}
