// lib/screens/tenant_portal_screen.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../core/services/receipt_ocr_service.dart';
import '../core/services/user_database_service.dart';
import '../core/theme/ramp_theme.dart';
import '../core/utils/toast_service.dart';
import '../core/validation/app_validators.dart';
import '../providers/providers.dart';
import '../core/widgets/core_widgets.dart';
import '../widgets/receipt_modal.dart';

class TenantPortalScreen extends ConsumerStatefulWidget {
  const TenantPortalScreen({super.key});

  @override
  ConsumerState<TenantPortalScreen> createState() => _TenantPortalScreenState();
}

class _TenantPortalScreenState extends ConsumerState<TenantPortalScreen> {
  String _selectedTenantId = 't1'; // Default fallback for preview

  final currencyFormatter = NumberFormat.currency(
    locale: 'en_PH',
    symbol: '₱',
    decimalDigits: 2,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkMustChangePassword();
    });
  }

  void _checkMustChangePassword() {
    final currentUser = ref.read(currentUserProvider);
    if (currentUser != null && currentUser.mustChangePassword) {
      _showMandatoryChangePasswordDialog(currentUser);
    }
  }

  void _showMandatoryChangePasswordDialog(RampUser user) {
    final newPassCtrl = TextEditingController();
    final confirmPassCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isSaving = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (context, setModalState) => PopScope(
          canPop: false,
          child: AlertDialog(
            title: Row(
              children: [
                const Icon(Icons.lock_reset_rounded,
                    color: RampColors.primary, size: 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Change Default Password',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                ),
              ],
            ),
            content: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome to RAMP! Your account was initialized with a temporary default password (tenant123). Please set a new secure password to continue.',
                    style: TextStyle(
                      fontSize: 12.5,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: newPassCtrl,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'New Password',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lock_outline_rounded),
                    ),
                    validator: AppValidators.password,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: confirmPassCtrl,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Confirm New Password',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lock_outline_rounded),
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Please confirm your new password.';
                      }
                      if (val.trim() != newPassCtrl.text.trim()) {
                        return 'Passwords do not match.';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            actions: [
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: RampColors.primary,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                icon: isSaving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.check_circle_rounded, size: 18),
                label: Text(isSaving ? 'UPDATING...' : 'SAVE NEW PASSWORD'),
                onPressed: isSaving
                    ? null
                    : () async {
                        if (!(formKey.currentState?.validate() ?? false)) {
                          return;
                        }

                        setModalState(() => isSaving = true);
                        final newPass = newPassCtrl.text.trim();

                        try {
                          final firebaseUser =
                              FirebaseAuth.instance.currentUser;
                          if (firebaseUser != null) {
                            await firebaseUser.updatePassword(newPass);
                          }
                        } catch (e) {
                          debugPrint('ℹ️ Auth password update notice: $e');
                        }

                        await UserDatabaseService()
                            .clearMustChangePassword(user.uid);

                        final updatedUser =
                            user.copyWith(mustChangePassword: false);
                        ref.read(currentUserProvider.notifier).state =
                            updatedUser;

                        if (!context.mounted) return;
                        Navigator.pop(dialogCtx);
                        ToastService.showSuccess(
                            'Password updated successfully! Welcome to your portal.');
                      },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final roleEnum = ref.watch(userRoleEnumProvider);
    final currentUser = ref.watch(currentUserProvider);
    final isLandlordOrAdmin =
        roleEnum == UserRole.landlord || roleEnum == UserRole.superAdmin;

    final tenants =
        ref.watch(tenantProvider).where((t) => !t.isArchived).toList();

    // Secure profile binding: Lock tenant to their own tenant record if authenticated as Tenant
    final effectiveTenantId = (!isLandlordOrAdmin &&
            currentUser?.tenantId != null &&
            currentUser!.tenantId!.isNotEmpty)
        ? currentUser.tenantId!
        : _selectedTenantId;

    final activeTenant = tenants.firstWhere(
      (t) => t.id == effectiveTenantId,
      orElse: () => tenants.isNotEmpty ? tenants.first : _dummyTenant,
    );
    final units = ref.watch(unitProvider);
    final tenantUnit = units.firstWhere(
      (u) =>
          u.id == activeTenant.unitId ||
          u.unitNumber == activeTenant.unitNumber,
      orElse: () => _dummyUnit,
    );
    final utilityRates = ref.watch(utilityRateProvider);
    final payments = ref
        .watch(paymentProvider)
        .where((p) =>
            p.tenantId == activeTenant.id || p.tenantName == activeTenant.name)
        .toList();
    final tickets = ref
        .watch(ticketProvider)
        .where((t) =>
            t.tenantId == activeTenant.id ||
            t.unitNumber == activeTenant.unitNumber)
        .toList();

    // Compute itemized charges
    final waterRate = tenantUnit.effectiveWaterRate(utilityRates.waterRate);
    final electricRate =
        tenantUnit.effectiveElectricityRate(utilityRates.electricityRate);
    final waterCharge = tenantUnit.waterUtilityEnabled
        ? tenantUnit.waterUsage * waterRate
        : 0.0;
    final electricCharge = tenantUnit.electricityUtilityEnabled
        ? tenantUnit.electricUsage * electricRate
        : 0.0;
    final lateFee = activeTenant.isLate ? tenantUnit.lateFee : 0.0;

    // Itemized Billing Engine: Base Rent + Water Usage + Electric Usage + Late Fees
    final totalBill =
        activeTenant.monthlyRent + waterCharge + electricCharge + lateFee;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Tenant Portal',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          // Switch to Landlord Role Button (Gated to Landlord/SuperAdmin only)
          if (isLandlordOrAdmin)
            TextButton.icon(
              style: TextButton.styleFrom(
                foregroundColor: RampColors.primary,
              ),
              icon: const Icon(Icons.admin_panel_settings_rounded, size: 18),
              label: const Text('Landlord Mode'),
              onPressed: () {
                ref.read(rampProvider.notifier).setRole('landlord');
                ToastService.showInfo('Switched to Landlord Admin View');
              },
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tenant Selector Bar (Gated for Landlords/Admins testing tenant profiles)
              if (isLandlordOrAdmin && tenants.length > 1) ...[
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE0E5EC),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color:
                          isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isDark ? Colors.black.withValues(alpha: 0.5) : const Color(0xFFA3B1C6).withValues(alpha: 0.6),
                        blurRadius: 10,
                        offset: const Offset(5, 5),
                      ),
                      BoxShadow(
                        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white.withValues(alpha: 0.8),
                        blurRadius: 10,
                        offset: const Offset(-5, -5),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.person_pin_rounded,
                          color: RampColors.primary, size: 20),
                      const SizedBox(width: 10),
                      Text(
                        'Viewing as:',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: isDark
                              ? Colors.grey.shade400
                              : RampColors.mutedText,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: activeTenant.id,
                            isExpanded: true,
                            items: tenants.map((t) {
                              return DropdownMenuItem<String>(
                                value: t.id,
                                child: Text(
                                  '${t.name} (${t.unitNumber})',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() => _selectedTenantId = val);
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Tenant Header Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE0E5EC),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: isDark ? Colors.black.withValues(alpha: 0.5) : const Color(0xFFA3B1C6).withValues(alpha: 0.6),
                      blurRadius: 10,
                      offset: const Offset(5, 5),
                    ),
                    BoxShadow(
                      color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white.withValues(alpha: 0.8),
                      blurRadius: 10,
                      offset: const Offset(-5, -5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              activeTenant.name,
                              style: GoogleFonts.poppins(
                                color: isDark ? Colors.white : Colors.black87,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                            Text(
                              '${activeTenant.unitNumber} • ${tenantUnit.floor}',
                              style: GoogleFonts.poppins(
                                color: isDark ? const Color(0xFF94A3B8) : Colors.black54,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: activeTenant.balance > 0
                                ? const Color(0xFFEF4444).withValues(alpha: 0.2)
                                : const Color(0xFF10B981)
                                    .withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: activeTenant.balance > 0
                                  ? const Color(0xFFEF4444)
                                  : const Color(0xFF10B981),
                            ),
                          ),
                          child: Text(
                            activeTenant.balance > 0
                                ? 'Payment Due'
                                : 'Paid in Full',
                            style: GoogleFonts.poppins(
                              color: activeTenant.balance > 0
                                  ? const Color(0xFFFCA5A5)
                                  : const Color(0xFF6EE7B7),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Itemized Billing Breakdown Statement
              Text(
                'Current Billing Statement',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE0E5EC),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isDark ? Colors.black.withValues(alpha: 0.5) : const Color(0xFFA3B1C6).withValues(alpha: 0.6),
                      blurRadius: 10,
                      offset: const Offset(5, 5),
                    ),
                    BoxShadow(
                      color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white.withValues(alpha: 0.8),
                      blurRadius: 10,
                      offset: const Offset(-5, -5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildBillLineItem(
                        'Base Rent',
                        currencyFormatter.format(activeTenant.monthlyRent),
                        isDark),
                    if (tenantUnit.waterUtilityEnabled) ...[
                      const Divider(height: 20),
                      _buildBillLineItem(
                        'Water (${tenantUnit.waterUsage.toStringAsFixed(1)} m³ @ ₱${waterRate.toStringAsFixed(2)}/m³)',
                        currencyFormatter.format(waterCharge),
                        isDark,
                      ),
                    ],
                    if (tenantUnit.electricityUtilityEnabled) ...[
                      const Divider(height: 20),
                      _buildBillLineItem(
                        'Electricity (${tenantUnit.electricUsage.toStringAsFixed(0)} kWh @ ₱${electricRate.toStringAsFixed(2)}/kWh)',
                        currencyFormatter.format(electricCharge),
                        isDark,
                      ),
                    ],
                    if (lateFee > 0) ...[
                      const Divider(height: 20),
                      _buildBillLineItem(
                        'Late Fee',
                        currencyFormatter.format(lateFee),
                        isDark,
                      ),
                    ],
                    const Divider(height: 24, thickness: 1.5),
                    _buildBillLineItem(
                      'Total Amount Due',
                      currencyFormatter.format(totalBill),
                      isDark,
                      isBold: true,
                    ),
                    const SizedBox(height: 18),

                    // Pay / Upload Receipt CTA Button
                    Container(
                      width: double.infinity,
                      height: 48,
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE0E5EC),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: isDark ? Colors.black.withValues(alpha: 0.5) : const Color(0xFFA3B1C6).withValues(alpha: 0.6),
                            blurRadius: 10,
                            offset: const Offset(5, 5),
                          ),
                          BoxShadow(
                            color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white.withValues(alpha: 0.8),
                            blurRadius: 10,
                            offset: const Offset(-5, -5),
                          ),
                        ],
                      ),
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: const Color(0xFF10B981),
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                        ),
                        icon: const Icon(Icons.upload_file_rounded, size: 20),
                        label: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'Submit Payment Proof',
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ),
                        onPressed: () => _showPaymentUploadSheet(
                            context, activeTenant, totalBill),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Utility Submeters Section
              Text(
                'Submeter Reading History',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  if (tenantUnit.waterUtilityEnabled)
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color:
                              isDark ? const Color(0xFF1E293B) : const Color(0xFFE0E5EC),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: isDark
                                  ? Colors.grey.shade800
                                  : Colors.grey.shade200),
                          boxShadow: [
                            BoxShadow(
                              color: isDark ? Colors.black.withValues(alpha: 0.5) : const Color(0xFFA3B1C6).withValues(alpha: 0.6),
                              blurRadius: 10,
                              offset: const Offset(5, 5),
                            ),
                            BoxShadow(
                              color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white.withValues(alpha: 0.8),
                              blurRadius: 10,
                              offset: const Offset(-5, -5),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.water_drop_rounded,
                                    color: Color(0xFF0284C7), size: 18),
                                SizedBox(width: 6),
                                Text('Water Submeter',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${tenantUnit.waterReadingCurr.toStringAsFixed(1)} m³',
                              style: GoogleFonts.poppins(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Usage: ${tenantUnit.waterUsage.toStringAsFixed(1)} m³',
                              style: TextStyle(
                                  fontSize: 11,
                                  color: isDark
                                      ? Colors.grey.shade400
                                      : RampColors.mutedText),
                            ),
                          ],
                        ),
                      ),
                    ),
                  if (tenantUnit.waterUtilityEnabled &&
                      tenantUnit.electricityUtilityEnabled)
                    const SizedBox(width: 12),
                  if (tenantUnit.electricityUtilityEnabled)
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color:
                              isDark ? const Color(0xFF1E293B) : const Color(0xFFE0E5EC),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: isDark
                                  ? Colors.grey.shade800
                                  : Colors.grey.shade200),
                          boxShadow: [
                            BoxShadow(
                              color: isDark ? Colors.black.withValues(alpha: 0.5) : const Color(0xFFA3B1C6).withValues(alpha: 0.6),
                              blurRadius: 10,
                              offset: const Offset(5, 5),
                            ),
                            BoxShadow(
                              color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white.withValues(alpha: 0.8),
                              blurRadius: 10,
                              offset: const Offset(-5, -5),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.bolt_rounded,
                                    color: Color(0xFFEAB308), size: 18),
                                SizedBox(width: 6),
                                Text('Electricity Submeter',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${tenantUnit.electricReadingCurr.toStringAsFixed(0)} kWh',
                              style: GoogleFonts.poppins(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Usage: ${tenantUnit.electricUsage.toStringAsFixed(0)} kWh',
                              style: TextStyle(
                                  fontSize: 11,
                                  color: isDark
                                      ? Colors.grey.shade400
                                      : RampColors.mutedText),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 24),

              // Maintenance Requests & Rating
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Maintenance & Repairs',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline_rounded,
                        color: RampColors.primary),
                    onPressed: () =>
                        _showCreateTicketSheet(context, activeTenant),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (tickets.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE0E5EC),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: isDark ? Colors.black.withValues(alpha: 0.5) : const Color(0xFFA3B1C6).withValues(alpha: 0.6),
                        blurRadius: 10,
                        offset: const Offset(5, 5),
                      ),
                      BoxShadow(
                        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white.withValues(alpha: 0.8),
                        blurRadius: 10,
                        offset: const Offset(-5, -5),
                      ),
                    ],
                  ),
                  child: Text(
                    'No repair tickets active for your unit.',
                    style: TextStyle(
                        color: isDark
                            ? Colors.grey.shade400
                            : RampColors.mutedText),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: tickets.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final ticket = tickets[index];
                    return _buildTicketCard(context, ticket, isDark);
                  },
                ),
              const SizedBox(height: 24),

              // Payment History
              Text(
                'Recent Payment History',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 10),
              if (payments.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE0E5EC),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: isDark ? Colors.black.withValues(alpha: 0.5) : const Color(0xFFA3B1C6).withValues(alpha: 0.6),
                        blurRadius: 10,
                        offset: const Offset(5, 5),
                      ),
                      BoxShadow(
                        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white.withValues(alpha: 0.8),
                        blurRadius: 10,
                        offset: const Offset(-5, -5),
                      ),
                    ],
                  ),
                  child: Text(
                    'No payment records found.',
                    style: TextStyle(
                        color: isDark
                            ? Colors.grey.shade400
                            : RampColors.mutedText),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: payments.length > 5 ? 5 : payments.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final p = payments[index];
                    final isPending = p.status.toLowerCase() == 'pending';
                    return InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () => showDigitalReceiptModal(context, p),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color:
                              isDark ? const Color(0xFF1E293B) : const Color(0xFFE0E5EC),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isPending
                                ? const Color(0xFFF59E0B)
                                : (isDark
                                    ? Colors.grey.shade800
                                    : Colors.grey.shade200),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: isDark ? Colors.black.withValues(alpha: 0.5) : const Color(0xFFA3B1C6).withValues(alpha: 0.6),
                              blurRadius: 10,
                              offset: const Offset(5, 5),
                            ),
                            BoxShadow(
                              color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white.withValues(alpha: 0.8),
                              blurRadius: 10,
                              offset: const Offset(-5, -5),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isPending
                                  ? Icons.pending_actions_rounded
                                  : Icons.check_circle_rounded,
                              color: isPending
                                  ? const Color(0xFFF59E0B)
                                  : const Color(0xFF10B981),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${p.month} Rent (${p.method})',
                                    style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13),
                                  ),
                                  Text(
                                    'Ref: ${p.referenceNumber.isNotEmpty ? p.referenceNumber : "N/A"} • Tap to view receipt',
                                    style: TextStyle(
                                        fontSize: 11,
                                        color: isDark
                                            ? Colors.grey.shade400
                                            : RampColors.mutedText),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  currencyFormatter.format(p.amount),
                                  style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14),
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    Text(
                                      'Receipt',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: RampColors.primary,
                                      ),
                                    ),
                                    const SizedBox(width: 2),
                                    const Icon(
                                      Icons.arrow_forward_ios_rounded,
                                      size: 10,
                                      color: RampColors.primary,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBillLineItem(String label, String amount, bool isDark,
      {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: isBold ? 14 : 13,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              color: isBold
                  ? (isDark ? Colors.white : RampColors.slate)
                  : (isDark ? Colors.grey.shade300 : RampColors.slate),
            ),
          ),
        ),
        Text(
          amount,
          style: GoogleFonts.poppins(
            fontSize: isBold ? 16 : 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: isBold
                ? const Color(0xFF10B981)
                : (isDark ? Colors.white : RampColors.slate),
          ),
        ),
      ],
    );
  }

  Color _getStatusDotColor(Ticket ticket) {
    if (ticket.status == 'Completed' ||
        ticket.status == 'Closed' ||
        ticket.status.toLowerCase() == 'resolved') {
      return const Color(0xFF10B981); // Green
    }
    if (ticket.priority.toLowerCase() == 'urgent' ||
        ticket.priority.toLowerCase() == 'emergency') {
      return const Color(0xFFEF4444); // Red
    }
    if (ticket.priority.toLowerCase() == 'high') {
      return const Color(0xFFF59E0B); // Amber / Orange
    }
    return RampColors.primary; // Primary blue
  }

  Widget _buildTicketCard(BuildContext context, Ticket ticket, bool isDark) {
    final isCompleted = ticket.status.toLowerCase() == 'completed' ||
        ticket.status.toLowerCase() == 'resolved';
    final statusColor = _getStatusDotColor(ticket);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE0E5EC),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withValues(alpha: 0.5) : const Color(0xFFA3B1C6).withValues(alpha: 0.6),
            blurRadius: 10,
            offset: const Offset(5, 5),
          ),
          BoxShadow(
            color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white.withValues(alpha: 0.8),
            blurRadius: 10,
            offset: const Offset(-5, -5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Single Colored Dot on Left Side
              Container(
                width: 10,
                height: 10,
                margin: const EdgeInsets.only(right: 10),
                decoration: BoxDecoration(
                  color: statusColor,
                  shape: BoxShape.circle,
                ),
              ),
              Expanded(
                child: Text(
                  ticket.title,
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
              StatusBadge(status: ticket.status),
            ],
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 20.0),
            child: Text(
              ticket.description,
              style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.grey.shade400 : RampColors.mutedText),
            ),
          ),
          if (isCompleted) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Text(
                  'Your Satisfaction Rating: ',
                  style: GoogleFonts.poppins(
                      fontSize: 12, fontWeight: FontWeight.w600),
                ),
                Row(
                  children: List.generate(5, (starIdx) {
                    final ratingVal = starIdx + 1;
                    return GestureDetector(
                      onTap: () {
                        ref.read(ticketProvider.notifier).updateTicket(
                              ticket.copyWith(rating: ratingVal),
                            );
                      },
                      child: Icon(
                        starIdx < ticket.rating
                            ? Icons.star_rounded
                            : Icons.star_outline_rounded,
                        color: const Color(0xFFEAB308),
                        size: 20,
                      ),
                    );
                  }),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  void _showPaymentUploadSheet(
      BuildContext context, Tenant tenant, double amount) {
    final methodNotifier = ValueNotifier<String>('GCash');
    final refCtrl = TextEditingController();
    final ocrService = ReceiptOcrService();
    bool isScanning = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF1E293B)
          : const Color(0xFFE0E5EC),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (modalCtx) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(modalCtx).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Submit Digital Payment',
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 6),
              Text(
                'Upload reference details or scan payment receipt screenshot to auto-fill.',
                style: TextStyle(fontSize: 12, color: RampColors.mutedText),
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFF1E293B)
                      : const Color(0xFFE0E5EC),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).brightness == Brightness.dark ? Colors.black.withValues(alpha: 0.5) : const Color(0xFFA3B1C6).withValues(alpha: 0.6),
                      blurRadius: 10,
                      offset: const Offset(5, 5),
                    ),
                    BoxShadow(
                      color: Theme.of(context).brightness == Brightness.dark ? Colors.white.withValues(alpha: 0.05) : Colors.white.withValues(alpha: 0.8),
                      blurRadius: 10,
                      offset: const Offset(-5, -5),
                    ),
                  ],
                ),
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: const BorderSide(color: Color(0xFF3B82F6), width: 1.5),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                icon: isScanning
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Color(0xFF3B82F6)),
                      )
                    : const Icon(Icons.document_scanner_rounded,
                        color: Color(0xFF3B82F6)),
                label: Text(
                  isScanning
                      ? 'Scanning Receipt with AI OCR...'
                      : 'Auto-Fill via Receipt Screenshot OCR',
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, color: Color(0xFF3B82F6)),
                ),
                onPressed: isScanning
                    ? null
                    : () async {
                        final source = await showModalBottomSheet<ImageSource>(
                          context: context,
                          builder: (sheetCtx) => SafeArea(
                            child: Wrap(
                              children: [
                                ListTile(
                                  leading:
                                      const Icon(Icons.photo_library_rounded),
                                  title: const Text(
                                      'Choose from Gallery / Screenshot'),
                                  onTap: () => Navigator.pop(
                                      sheetCtx, ImageSource.gallery),
                                ),
                                ListTile(
                                  leading: const Icon(Icons.camera_alt_rounded),
                                  title: const Text('Take Photo of Receipt'),
                                  onTap: () => Navigator.pop(
                                      sheetCtx, ImageSource.camera),
                                ),
                              ],
                            ),
                          ),
                        );

                        if (source == null) return;

                        setModalState(() => isScanning = true);
                        final result =
                            await ocrService.pickAndScanReceipt(source);
                        setModalState(() => isScanning = false);

                        if (result != null && result.isSuccess) {
                          if (result.referenceNumber != null &&
                              result.referenceNumber!.isNotEmpty) {
                            refCtrl.text = result.referenceNumber!;
                          }
                          if (result.paymentMethod != null &&
                              ['GCash', 'Maya', 'Bank Transfer', 'Cash']
                                  .contains(result.paymentMethod)) {
                            methodNotifier.value = result.paymentMethod!;
                          }
                          if (modalCtx.mounted) {
                            ToastService.showSuccess(
                              'Receipt scanned! Ref: ${result.referenceNumber ?? "N/A"}'
                              '${result.amount != null ? " • Amount: ₱${result.amount!.toStringAsFixed(2)}" : ""}',
                            );
                          }
                        } else if (result != null && modalCtx.mounted) {
                          ToastService.showError(result.errorMessage ??
                              'Could not extract details from receipt image.');
                        }
                      },
                ),
              ),
              const SizedBox(height: 16),
              ValueListenableBuilder<String>(
                valueListenable: methodNotifier,
                builder: (_, method, __) => DropdownButtonFormField<String>(
                  key: ValueKey(method),
                  initialValue: method,
                  decoration: const InputDecoration(
                      labelText: 'Payment Method',
                      border: OutlineInputBorder()),
                  items: ['GCash', 'Maya', 'Bank Transfer', 'Cash']
                      .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) methodNotifier.value = val;
                  },
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: refCtrl,
                decoration: const InputDecoration(
                  labelText: 'Reference Number / Transaction ID',
                  hintText: 'e.g. GC-102910291',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFF1E293B)
                      : const Color(0xFFE0E5EC),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).brightness == Brightness.dark ? Colors.black.withValues(alpha: 0.5) : const Color(0xFFA3B1C6).withValues(alpha: 0.6),
                      blurRadius: 10,
                      offset: const Offset(5, 5),
                    ),
                    BoxShadow(
                      color: Theme.of(context).brightness == Brightness.dark ? Colors.white.withValues(alpha: 0.05) : Colors.white.withValues(alpha: 0.8),
                      blurRadius: 10,
                      offset: const Offset(-5, -5),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: const Color(0xFF10B981),
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                onPressed: () {
                  final refNum = refCtrl.text.trim();
                  final refError = AppValidators.paymentReference(refNum);
                  if (refError != null) {
                    ToastService.showError(refError);
                    return;
                  }
                  final now = DateTime.now();
                  final payment = PaymentData(
                    id: 'p_${now.millisecondsSinceEpoch}',
                    month: DateFormat('MMMM yyyy').format(now),
                    amount: amount,
                    method: methodNotifier.value,
                    paymentMethod: methodNotifier.value,
                    date: now,
                    status: 'Pending',
                    unitId: tenant.unitId,
                    unitNumber: tenant.unitNumber,
                    tenantId: tenant.id,
                    tenantName: tenant.name,
                    referenceNumber: refNum,
                    baseRent: tenant.monthlyRent,
                  );

                  ref.read(paymentProvider.notifier).addPayment(payment);
                  Navigator.pop(modalCtx);
                  ToastService.showSuccess('Payment submitted! Pending landlord verification.');
                },
                child: const Text('Submit Payment Proof',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCreateTicketSheet(BuildContext context, Tenant tenant) {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    String priority = 'Medium';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF1E293B)
          : const Color(0xFFE0E5EC),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (modalCtx) => StatefulBuilder(
        builder: (modalCtx, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(modalCtx).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Report Repair Issue',
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(
                    labelText: 'Issue Title', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                    labelText: 'Description', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: priority,
                decoration: const InputDecoration(
                    labelText: 'Severity / Priority',
                    border: OutlineInputBorder()),
                items: ['Low', 'Medium', 'Emergency']
                    .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) setModalState(() => priority = val);
                },
              ),
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFF1E293B)
                      : const Color(0xFFE0E5EC),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).brightness == Brightness.dark ? Colors.black.withValues(alpha: 0.5) : const Color(0xFFA3B1C6).withValues(alpha: 0.6),
                      blurRadius: 10,
                      offset: const Offset(5, 5),
                    ),
                    BoxShadow(
                      color: Theme.of(context).brightness == Brightness.dark ? Colors.white.withValues(alpha: 0.05) : Colors.white.withValues(alpha: 0.8),
                      blurRadius: 10,
                      offset: const Offset(-5, -5),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: RampColors.primary,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                onPressed: () {
                  if (titleCtrl.text.trim().isEmpty) return;
                  final ticket = Ticket(
                    id: 't_${DateTime.now().millisecondsSinceEpoch}',
                    unitId: tenant.unitId,
                    unitNumber: tenant.unitNumber,
                    tenantId: tenant.id,
                    tenantName: tenant.name,
                    title: titleCtrl.text.trim(),
                    description: descCtrl.text.trim(),
                    priority: priority,
                    status: 'Pending',
                  );
                  ref.read(ticketProvider.notifier).addTicket(ticket);
                  Navigator.pop(modalCtx);
                  ToastService.showSuccess('Repair ticket created.');
                },
                child: const Text('Submit Repair Ticket',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static final Tenant _dummyTenant = Tenant(
    id: 't1',
    name: 'Maria Santos',
    unitId: 'u2',
    unitNumber: 'Unit 2',
    monthlyRent: 12000.0,
    dueDate: DateTime.now(),
    balance: 0.0,
    email: 'maria@example.com',
    phone: '09171234567',
  );

  static final Unit _dummyUnit = Unit(
    id: 'u2',
    name: 'Unit 2',
    unitNumber: 'Unit 2',
    floor: '2nd Floor',
    rent: 12000.0,
    waterReadingPrev: 40.0,
    waterReadingCurr: 52.0,
    electricReadingPrev: 200.0,
    electricReadingCurr: 350.0,
  );
}
