// lib/widgets/receipt_modal.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../core/services/pdf_receipt_service.dart';
import '../core/theme/ramp_theme.dart';
import '../models/models.dart';

void showDigitalReceiptModal(
  BuildContext context,
  PaymentData payment, {
  VoidCallback? onEdit,
}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (modalCtx) {
      final bottomPadding = MediaQuery.of(modalCtx).padding.bottom + 20;

      return Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 16,
          bottom: bottomPadding,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Modal Drag Handle Bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Top Title Header Bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: RampColors.primary.withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.receipt_long_rounded,
                            color: RampColors.primary,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Official Digital Receipt',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : RampColors.slate,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        // Status Badge Pill
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: payment.isPaid
                                ? const Color(0xFF10B981).withOpacity(0.15)
                                : const Color(0xFFF59E0B).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: payment.isPaid
                                  ? const Color(0xFF10B981).withOpacity(0.4)
                                  : const Color(0xFFF59E0B).withOpacity(0.4),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                payment.isPaid ? Icons.check_circle_rounded : Icons.pending_actions_rounded,
                                size: 14,
                                color: payment.isPaid ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                payment.status.toUpperCase(),
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: payment.isPaid ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 4),
                        IconButton(
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () => Navigator.pop(modalCtx),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Digital Paper Receipt Ticket Container
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark ? const Color(0xFF334155) : RampColors.border,
                    ),
                  ),
                  child: Column(
                    children: [
                      // Paper Top Header Accent
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E293B) : Colors.white,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                          border: Border(
                            bottom: BorderSide(
                              color: isDark ? const Color(0xFF334155) : RampColors.border,
                            ),
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'RAMP OFFICIAL RECEIPT',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                letterSpacing: 1.1,
                                color: isDark ? Colors.white : RampColors.slate,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              "Emin & Mila's Rental Properties • Pagsanjan, Laguna",
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                color: isDark ? const Color(0xFF94A3B8) : RampColors.mutedText,
                              ),
                            ),
                          ],
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Giant Total Amount Display
                            Text(
                              'TOTAL PAID',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.2,
                                color: isDark ? const Color(0xFF94A3B8) : RampColors.mutedText,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              payment.formattedAmount,
                              style: GoogleFonts.poppins(
                                fontSize: 28,
                                fontWeight: FontWeight.extrabold,
                                color: const Color(0xFF10B981),
                              ),
                            ),
                            Text(
                              DateFormat('EEEE, MMMM dd, yyyy • hh:mm a').format(payment.paymentDate),
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                color: isDark ? const Color(0xFF94A3B8) : RampColors.mutedText,
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Reference Number Banner with Copy Action
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isDark ? const Color(0xFF334155) : RampColors.border,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'REFERENCE NUMBER',
                                        style: GoogleFonts.poppins(
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.8,
                                          color: isDark ? const Color(0xFF94A3B8) : RampColors.mutedText,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        payment.referenceNumber,
                                        style: GoogleFonts.poppins(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: isDark ? Colors.white : RampColors.slate,
                                        ),
                                      ),
                                    ],
                                  ),
                                  InkWell(
                                    borderRadius: BorderRadius.circular(8),
                                    onTap: () {
                                      Clipboard.setData(
                                        ClipboardData(text: payment.referenceNumber),
                                      );
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Reference number copied to clipboard!'),
                                          behavior: SnackBarBehavior.floating,
                                          duration: Duration(seconds: 2),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: RampColors.primary.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(
                                        Icons.copy_rounded,
                                        color: RampColors.primary,
                                        size: 16,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Dashed Line Divider
                            Row(
                              children: List.generate(
                                30,
                                (i) => Expanded(
                                  child: Container(
                                    height: 1,
                                    color: i % 2 == 0
                                        ? (isDark ? const Color(0xFF334155) : RampColors.border)
                                        : Colors.transparent,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Itemized Breakdown Header
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Itemized Breakdown',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? const Color(0xFF94A3B8) : RampColors.mutedText,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),

                            _buildLineItem(
                              icon: Icons.home_work_outlined,
                              label: 'Base Rent (${payment.month})',
                              amount: payment.formattedBaseRent,
                              isDark: isDark,
                            ),
                            if (payment.waterBill > 0)
                              _buildLineItem(
                                icon: Icons.water_drop_outlined,
                                label: 'Water Submeter Charges',
                                amount: payment.formattedWaterBill,
                                isDark: isDark,
                              ),
                            if (payment.electricBill > 0)
                              _buildLineItem(
                                icon: Icons.bolt_outlined,
                                label: 'Electricity Submeter Charges',
                                amount: payment.formattedElectricBill,
                                isDark: isDark,
                              ),
                            if (payment.lateFee > 0)
                              _buildLineItem(
                                icon: Icons.warning_amber_rounded,
                                label: 'Late Payment Fee',
                                amount: payment.formattedLateFee,
                                isDark: isDark,
                              ),

                            const SizedBox(height: 12),

                            // Dashed Line Divider
                            Row(
                              children: List.generate(
                                30,
                                (i) => Expanded(
                                  child: Container(
                                    height: 1,
                                    color: i % 2 == 0
                                        ? (isDark ? const Color(0xFF334155) : RampColors.border)
                                        : Colors.transparent,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 12),

                            // Billed To & Payment Method Details Grid
                            _buildInfoRow('Tenant Name:', payment.tenantName, isDark),
                            _buildInfoRow('Unit Assigned:', payment.unitNumber, isDark),
                            _buildInfoRow('Payment Channel:', payment.method, isDark),

                            if (payment.proofImageUrl.isNotEmpty) ...[
                              const SizedBox(height: 14),
                              InkWell(
                                onTap: () => _showProofImageDialog(context, payment.proofImageUrl),
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isDark ? const Color(0xFF334155) : RampColors.border,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.image_outlined, color: RampColors.primary, size: 20),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'View Payment Screenshot Attachment',
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: RampColors.primary,
                                          ),
                                        ),
                                      ),
                                      const Icon(Icons.chevron_right_rounded, color: RampColors.primary, size: 18),
                                    ],
                                  ),
                                ),
                              ),
                            ],

                            const SizedBox(height: 16),

                            // Barcode Aesthetic Visual Footer
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.qr_code_2_rounded, size: 28, color: RampColors.mutedText),
                                const SizedBox(width: 8),
                                Text(
                                  'VERIFIED ELECTRONIC RECEIPT • RAMP SYSTEM',
                                  style: GoogleFonts.poppins(
                                    fontSize: 9,
                                    letterSpacing: 0.8,
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? const Color(0xFF94A3B8) : RampColors.mutedText,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // Action Toolbar Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        icon: const Icon(Icons.share_rounded, size: 18),
                        label: const FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text('SHARE RECEIPT'),
                        ),
                        onPressed: () async {
                          await PdfReceiptService.shareReceipt(payment);
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: RampColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        icon: const Icon(Icons.print_rounded, size: 18),
                        label: const FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text('PRINT / PDF'),
                        ),
                        onPressed: () async {
                          await PdfReceiptService.printReceipt(payment);
                        },
                      ),
                    ),
                    if (onEdit != null) ...[
                      const SizedBox(width: 10),
                      IconButton(
                        style: IconButton.styleFrom(
                          backgroundColor: isDark ? const Color(0xFF334155) : RampColors.border.withOpacity(0.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        icon: const Icon(Icons.edit_outlined, size: 20),
                        tooltip: 'Edit Payment Record',
                        onPressed: () {
                          Navigator.pop(modalCtx);
                          onEdit();
                        },
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

Widget _buildLineItem({
  required IconData icon,
  required String label,
  required String amount,
  required bool isDark,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: isDark ? const Color(0xFF94A3B8) : RampColors.mutedText),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: isDark ? const Color(0xFFCBD5E1) : RampColors.slate,
              ),
            ),
          ],
        ),
        Text(
          amount,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : RampColors.slate,
          ),
        ),
      ],
    ),
  );
}

Widget _buildInfoRow(String label, String value, bool isDark) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 3.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: isDark ? const Color(0xFF94A3B8) : RampColors.mutedText,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : RampColors.slate,
          ),
        ),
      ],
    ),
  );
}

void _showProofImageDialog(BuildContext context, String imageUrl) {
  showDialog(
    context: context,
    builder: (ctx) => Dialog(
      backgroundColor: Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
            alignment: Alignment.topRight,
            child: IconButton(
              icon: const Icon(Icons.close_rounded, color: Colors.white, size: 28),
              onPressed: () => Navigator.pop(ctx),
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              imageUrl,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => Container(
                padding: const EdgeInsets.all(20),
                color: Colors.white,
                child: const Text('Could not load payment image.'),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
