// lib/core/services/pdf_receipt_service.dart
import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../models/models.dart';

class PdfReceiptService {
  static Future<Uint8List> generateReceiptPdf(PaymentData payment) async {
    final pdf = pw.Document();

    final currencyFormatter = NumberFormat.currency(
      locale: 'en_PH',
      symbol: 'PHP ',
      decimalDigits: 2,
    );

    final totalAmount =
        payment.amount > 0 ? payment.amount : payment.calculatedTotal;

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header Banner
              pw.Container(
                padding: const pw.EdgeInsets.all(16),
                decoration: const pw.BoxDecoration(
                  color: PdfColors.blueGrey900,
                  borderRadius: pw.BorderRadius.all(pw.Radius.circular(8)),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'RAMP - OFFICIAL RECEIPT',
                          style: pw.TextStyle(
                            color: PdfColors.white,
                            fontSize: 18,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          "Emin & Mila's Rental Properties • Apex Rental Properties",
                          style: const pw.TextStyle(
                            color: PdfColors.grey300,
                            fontSize: 10,
                          ),
                        ),
                        pw.Text(
                          'Pagsanjan, Laguna, Philippines',
                          style: const pw.TextStyle(
                            color: PdfColors.grey400,
                            fontSize: 9,
                          ),
                        ),
                      ],
                    ),
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: const pw.BoxDecoration(
                        color: PdfColors.green600,
                        borderRadius:
                            pw.BorderRadius.all(pw.Radius.circular(4)),
                      ),
                      child: pw.Text(
                        'PAID & VERIFIED',
                        style: pw.TextStyle(
                          color: PdfColors.white,
                          fontSize: 11,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),

              // Metadata Grid
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(
                    child: pw.Container(
                      padding: const pw.EdgeInsets.all(12),
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(color: PdfColors.grey300),
                        borderRadius:
                            const pw.BorderRadius.all(pw.Radius.circular(6)),
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'BILLED TO / TENANT DETAILS',
                            style: pw.TextStyle(
                              fontSize: 9,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.grey700,
                            ),
                          ),
                          pw.Divider(color: PdfColors.grey300, height: 12),
                          _pdfInfoRow('Tenant Name:', payment.tenantName),
                          _pdfInfoRow('Unit Number:', payment.unitNumber),
                          _pdfInfoRow('Billing Period:', payment.month),
                        ],
                      ),
                    ),
                  ),
                  pw.SizedBox(width: 16),
                  pw.Expanded(
                    child: pw.Container(
                      padding: const pw.EdgeInsets.all(12),
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(color: PdfColors.grey300),
                        borderRadius:
                            const pw.BorderRadius.all(pw.Radius.circular(6)),
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'TRANSACTION METADATA',
                            style: pw.TextStyle(
                              fontSize: 9,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.grey700,
                            ),
                          ),
                          pw.Divider(color: PdfColors.grey300, height: 12),
                          _pdfInfoRow(
                              'Receipt Ref #:', payment.referenceNumber),
                          _pdfInfoRow(
                            'Payment Date:',
                            DateFormat('MMM dd, yyyy • hh:mm a')
                                .format(payment.effectivePaymentDate),
                          ),
                          _pdfInfoRow('Payment Method:', payment.method),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 24),

              // Itemized Section
              pw.Text(
                'ITEMIZED FINANCIAL BREAKDOWN',
                style: pw.TextStyle(
                  fontSize: 11,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blueGrey900,
                ),
              ),
              pw.SizedBox(height: 8),

              pw.Table(
                border:
                    pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
                children: [
                  pw.TableRow(
                    decoration:
                        const pw.BoxDecoration(color: PdfColors.grey100),
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('Item Description',
                            style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold, fontSize: 10)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('Category',
                            style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold, fontSize: 10)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Align(
                          alignment: pw.Alignment.centerRight,
                          child: pw.Text('Amount',
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  fontSize: 10)),
                        ),
                      ),
                    ],
                  ),
                  _pdfTableRow('Base Monthly Rent', 'Rental Fee',
                      currencyFormatter.format(payment.baseRent)),
                  if (payment.waterBill > 0)
                    _pdfTableRow('Water Submeter Charges', 'Utilities',
                        currencyFormatter.format(payment.waterBill)),
                  if (payment.electricBill > 0)
                    _pdfTableRow('Electricity Submeter Charges', 'Utilities',
                        currencyFormatter.format(payment.electricBill)),
                  if (payment.lateFee > 0)
                    _pdfTableRow('Late Settlement Surcharge', 'Penalty',
                        currencyFormatter.format(payment.lateFee)),
                  if (payment.otherCharge > 0)
                    _pdfTableRow('Miscellaneous / Other Charges', 'Others',
                        currencyFormatter.format(payment.otherCharge)),
                ],
              ),
              pw.SizedBox(height: 12),

              // Total Highlight
              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: const pw.BoxDecoration(
                  color: PdfColors.green50,
                  borderRadius: pw.BorderRadius.all(pw.Radius.circular(6)),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'TOTAL AMOUNT PAID:',
                      style: pw.TextStyle(
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.green900,
                      ),
                    ),
                    pw.Text(
                      currencyFormatter.format(totalAmount),
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.green800,
                      ),
                    ),
                  ],
                ),
              ),

              pw.Spacer(),

              // Verification & Footer Stamp
              pw.Divider(color: PdfColors.grey300),
              pw.SizedBox(height: 8),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'This is an official digital receipt generated by RAMP.',
                        style: const pw.TextStyle(
                            fontSize: 8, color: PdfColors.grey600),
                      ),
                      pw.Text(
                        'Generated: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now())}',
                        style: const pw.TextStyle(
                            fontSize: 8, color: PdfColors.grey500),
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Container(
                        width: 130,
                        decoration: const pw.BoxDecoration(
                          border: pw.Border(
                              bottom: pw.BorderSide(
                                  color: PdfColors.grey400, width: 1)),
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        'Authorized RAMP Management Stamp',
                        style: pw.TextStyle(
                            fontSize: 8,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.grey700),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  static pw.TableRow _pdfTableRow(String desc, String cat, String amount) {
    return pw.TableRow(
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Text(desc, style: const pw.TextStyle(fontSize: 9)),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Text(cat,
              style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Text(amount,
                style:
                    pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  static pw.Widget _pdfInfoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label,
              style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
          pw.Text(value,
              style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
        ],
      ),
    );
  }

  static Future<void> printReceipt(PaymentData payment) async {
    final pdfData = await generateReceiptPdf(payment);
    await Printing.layoutPdf(
      onLayout: (_) async => pdfData,
      name: 'Receipt_${payment.referenceNumber}.pdf',
    );
  }

  static Future<void> shareReceipt(PaymentData payment) async {
    final pdfData = await generateReceiptPdf(payment);
    await Printing.sharePdf(
      bytes: pdfData,
      filename: 'Receipt_${payment.referenceNumber}.pdf',
    );
  }

  static Future<void> printOrShareReceipt(PaymentData payment) async {
    await printReceipt(payment);
  }
}
