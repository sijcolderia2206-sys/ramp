// lib/screens/tenant/tenant_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../theme.dart';
import '../../models/tenant_model.dart';
import '../../models/unit_model.dart';
import '../../models/tenant_document_model.dart';
import '../../widgets/neumorphic_widgets.dart';
import '../../providers/tenant_providers.dart';
import '../../providers/landlord_providers.dart';
import '../../providers/session_providers.dart';
import '../../core/supabase_auth_service.dart';
import '../../core/pdf_exporter.dart';
import '../../core/validators.dart';

class TenantProfileScreen extends ConsumerStatefulWidget {
  const TenantProfileScreen({super.key});

  @override
  ConsumerState<TenantProfileScreen> createState() => _TenantProfileScreenState();
}

class _TenantProfileScreenState extends ConsumerState<TenantProfileScreen> {
  final _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final tenant = ref.read(currentTenantProvider);
      if (tenant != null) {
        _phoneController.text = tenant.phone;
      }
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _showUpdateContactDialog(TenantRecord tenant) {
    _phoneController.text = tenant.phone;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFFE0E5EC),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Update Contact Number', style: TextStyle(fontWeight: FontWeight.bold, color: RampTheme.textPrimary)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              NeumorphicTextField(
                controller: _phoneController,
                label: 'New Phone Number',
                hintText: 'e.g. 0917 123 4567',
                keyboardType: TextInputType.phone,
                inputFormatters: [PhilippinePhoneInputFormatter()],
                prefixIcon: Icons.phone_android_outlined,
                validator: (val) => FormValidators.phone(val),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: RampTheme.primaryBlue,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () async {
                final newPhone = _phoneController.text.trim();
                final phoneErr = FormValidators.phone(newPhone);
                if (phoneErr != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: RampTheme.errorRed,
                      content: Text(phoneErr),
                    ),
                  );
                  return;
                }

                final updatedTenant = tenant.copyWith(phone: newPhone);
                final res = await ref.read(tenantsProvider.notifier).updateTenant(updatedTenant);

                if (context.mounted) {
                  Navigator.pop(context);
                  if (res.isSuccess) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: RampTheme.successGreen,
                        content: Text('Contact number updated to $newPhone'),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: RampTheme.errorRed,
                        content: Text('Failed to update phone number: ${res.errorMessage}'),
                      ),
                    );
                  }
                }
              },
              child: const Text('Save Changes', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void _showUnitDetailsModal(BuildContext context, RentalUnit unit) {
    final currencyFormatter = NumberFormat.currency(locale: 'en_PH', symbol: '₱', decimalDigits: 2);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFFE0E5EC),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Unit ${unit.unitNumber}',
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: RampTheme.textPrimary),
                        ),
                        Text(
                          '${unit.location} • ${unit.floor}',
                          style: const TextStyle(fontSize: 12, color: RampTheme.textSecondary, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: RampTheme.textSecondary),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const Divider(height: 24),

                // Overview Specifications Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildUnitSpecBadge(Icons.square_foot_rounded, '${unit.areaSqm.round()} sqm'),
                    _buildUnitSpecBadge(Icons.bed_outlined, '${unit.bedrooms} Bed'),
                    _buildUnitSpecBadge(Icons.bathtub_outlined, '${unit.bathrooms} Bath'),
                    _buildUnitSpecBadge(Icons.chair_outlined, unit.furnishingStatus),
                  ],
                ),

                const SizedBox(height: 20),

                // Property Terms
                NeumorphicContainer(
                  isInset: true,
                  borderRadius: 16,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Property Specifications', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: RampTheme.textPrimary)),
                      const SizedBox(height: 10),
                      _buildModalSpecRow('Property Type', unit.propertyType),
                      const SizedBox(height: 6),
                      _buildModalSpecRow('Monthly Rent', currencyFormatter.format(unit.monthlyRent)),
                      const SizedBox(height: 6),
                      _buildModalSpecRow('Rent Due Day', '${unit.rentDueDay}th of every month'),
                    ],
                  ),
                ),

                if (unit.inclusions.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Text('Unit Inclusions & Amenities', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: RampTheme.textPrimary)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: unit.inclusions.map((item) {
                      return NeumorphicPill(
                        text: item,
                        textColor: RampTheme.primaryBlue,
                        icon: Icons.check_circle_outline_rounded,
                      );
                    }).toList(),
                  ),
                ],

                const SizedBox(height: 16),
                const Text('Submeter Serial Numbers', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: RampTheme.textPrimary)),
                const SizedBox(height: 8),

                NeumorphicContainer(
                  borderRadius: 16,
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.water_drop_outlined, color: RampTheme.primaryBlue, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Water Meter Serial', style: TextStyle(fontSize: 11, color: RampTheme.textSecondary, fontWeight: FontWeight.bold)),
                                Text(unit.waterMeterSerialNumber.isNotEmpty ? unit.waterMeterSerialNumber : 'MTR-WTR-${unit.unitNumber}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: RampTheme.textPrimary)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 16),
                      Row(
                        children: [
                          const Icon(Icons.electric_bolt_outlined, color: RampTheme.warningYellow, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Electricity Meter Serial', style: TextStyle(fontSize: 11, color: RampTheme.textSecondary, fontWeight: FontWeight.bold)),
                                Text(unit.electricMeterSerialNumber.isNotEmpty ? unit.electricMeterSerialNumber : 'MTR-ELE-${unit.unitNumber}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: RampTheme.textPrimary)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildUnitSpecBadge(IconData icon, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: NeumorphicDecoration.convex(shape: BoxShape.circle),
          child: Icon(icon, size: 20, color: RampTheme.primaryBlue),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: RampTheme.textPrimary),
        ),
      ],
    );
  }

  Widget _buildModalSpecRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: RampTheme.textSecondary)),
        Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: RampTheme.textPrimary)),
      ],
    );
  }

  Future<void> _handleDocumentTap(TenantDocumentRecord doc, TenantRecord? tenant, RentalUnit? unit) async {
    if (doc.type == 'Lease' && tenant != null && unit != null) {
      RampPdfExporter.printTenantStatement(tenant: tenant, unit: unit);
      return;
    }

    if (doc.fileUrl != null && doc.fileUrl!.isNotEmpty) {
      final uri = Uri.parse(doc.fileUrl!);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Opening ${doc.title}...')),
          );
        }
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Document URL not available for "${doc.title}"')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tenant = ref.watch(currentTenantProvider);
    final unit = ref.watch(currentTenantUnitProvider);
    final documents = ref.watch(tenantDocumentsProvider);
    final sessionState = ref.watch(sessionProvider);
    final nowSession = sessionState.nowSession;
    final authService = SupabaseAuthService();
    final currencyFormatter = NumberFormat.currency(locale: 'en_PH', symbol: '₱', decimalDigits: 2);

    final name = tenant?.name ?? 'Tenant';
    final unitNumber = tenant?.unitNumber ?? 'Unassigned';
    final avatarUrl = tenant?.profileImageUrl;

    return Scaffold(
      backgroundColor: const Color(0xFFE0E5EC),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(RampTheme.spacing20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'PROFILE & DOCUMENTS',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                  color: RampTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'My Account & Lease Vault',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: RampTheme.textPrimary,
                ),
              ),
              const SizedBox(height: RampTheme.spacing20),

              // 1. PROFILE HEADER (Convex Neumorphic Card)
              NeumorphicContainer(
                borderRadius: 22.0,
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    // Avatar Image or Placeholder
                    Container(
                      width: 68,
                      height: 68,
                      decoration: NeumorphicDecoration.convex(
                        shape: BoxShape.circle,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(34),
                        child: avatarUrl != null && avatarUrl.isNotEmpty
                            ? Image.network(
                                avatarUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => _buildAvatarPlaceholder(name),
                              )
                            : _buildAvatarPlaceholder(name),
                      ),
                    ),
                    const SizedBox(width: 18),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: RampTheme.textPrimary,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Unit Number: $unitNumber',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: RampTheme.primaryBlue,
                            ),
                          ),
                          if (tenant?.email != null && tenant!.email!.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              tenant.email!,
                              style: const TextStyle(
                                fontSize: 12,
                                color: RampTheme.textSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: RampTheme.spacing24),

              // 2. ASSIGNED UNIT CARD (New feature allowing tenant to view unit details)
              if (unit != null) ...[
                Text(
                  'MY ASSIGNED UNIT',
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
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Unit ${unit.unitNumber}',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: RampTheme.textPrimary),
                              ),
                              Text(
                                '${unit.location} • ${unit.floor}',
                                style: const TextStyle(fontSize: 12, color: RampTheme.textSecondary),
                              ),
                            ],
                          ),
                          NeumorphicPill(
                            text: unit.furnishingStatus,
                            textColor: RampTheme.primaryBlue,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.home_work_outlined, size: 16, color: RampTheme.primaryBlue),
                          const SizedBox(width: 6),
                          Text(
                            '${unit.propertyType} • ${unit.areaSqm.round()} sqm • ${unit.bedrooms} Bed / ${unit.bathrooms} Bath',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: RampTheme.textPrimary),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        child: NeumorphicButton(
                          label: 'View Full Unit Specifications',
                          icon: Icons.info_outline_rounded,
                          height: 42,
                          backgroundColor: NeumorphicDecoration.baseColor,
                          textColor: RampTheme.primaryBlue,
                          onPressed: () => _showUnitDetailsModal(context, unit),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: RampTheme.spacing24),
              ],

              // 3. LEASE DETAILS (Inset Container with Read-Only Data)
              Text(
                'LEASE DETAILS',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                  color: RampTheme.textSecondary,
                ),
              ),
              const SizedBox(height: RampTheme.spacing8),

              NeumorphicContainer(
                isInset: true,
                borderRadius: 20.0,
                padding: const EdgeInsets.all(18.0),
                child: Column(
                  children: [
                    _buildReadOnlyRow(
                      'Lease Start Date',
                      tenant != null
                          ? DateFormat('MMM d, yyyy').format(tenant.leaseStart)
                          : 'N/A',
                      Icons.calendar_month_outlined,
                    ),
                    const SizedBox(height: 12),
                    const Divider(height: 1),
                    const SizedBox(height: 12),
                    _buildReadOnlyRow(
                      'Lease End Date',
                      tenant != null
                          ? DateFormat('MMM d, yyyy').format(tenant.leaseEnd)
                          : 'N/A',
                      Icons.event_available_outlined,
                    ),
                    const SizedBox(height: 12),
                    const Divider(height: 1),
                    const SizedBox(height: 12),
                    _buildReadOnlyRow(
                      'Monthly Rent',
                      tenant != null
                          ? currencyFormatter.format(tenant.monthlyRent)
                          : '₱0.00',
                      Icons.payments_outlined,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: RampTheme.spacing24),

              // 4. EMERGENCY CONTACT DETAILS (Convex Neumorphic Card)
              Text(
                'EMERGENCY CONTACT DETAILS',
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
                  children: [
                    _buildContactRow(
                      'Name',
                      (tenant?.emergencyName != null && tenant!.emergencyName!.isNotEmpty)
                          ? tenant.emergencyName!
                          : 'Not specified',
                      Icons.person_outline_rounded,
                    ),
                    const SizedBox(height: 12),
                    const Divider(height: 1),
                    const SizedBox(height: 12),
                    _buildContactRow(
                      'Relationship',
                      (tenant?.emergencyRelationship != null && tenant!.emergencyRelationship!.isNotEmpty)
                          ? tenant.emergencyRelationship!
                          : 'Not specified',
                      Icons.family_restroom_outlined,
                    ),
                    const SizedBox(height: 12),
                    const Divider(height: 1),
                    const SizedBox(height: 12),
                    _buildContactRow(
                      'Emergency Phone',
                      (tenant?.emergencyPhone != null && tenant!.emergencyPhone!.isNotEmpty)
                          ? tenant.emergencyPhone!
                          : 'Not specified',
                      Icons.phone_in_talk_outlined,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: RampTheme.spacing28),

              // 5. DOCUMENT VAULT
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'DOCUMENT VAULT',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                      color: RampTheme.textSecondary,
                    ),
                  ),
                  Text(
                    '${documents.length} Files',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: RampTheme.primaryBlue,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: RampTheme.spacing12),

              if (documents.isEmpty)
                NeumorphicContainer(
                  isInset: true,
                  borderRadius: 16,
                  padding: const EdgeInsets.all(20),
                  child: const Center(
                    child: Text('No tenant documents available in vault.', style: TextStyle(color: RampTheme.textSecondary)),
                  ),
                )
              else
                Column(
                  children: documents.map((doc) {
                    final isPdf = doc.fileName?.toLowerCase().endsWith('.pdf') ?? true;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: NeumorphicContainer(
                        borderRadius: 16.0,
                        onTap: () => _handleDocumentTap(doc, tenant, unit),
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: NeumorphicDecoration.inset(
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                isPdf ? Icons.picture_as_pdf_outlined : Icons.insert_drive_file_outlined,
                                color: RampTheme.primaryBlue,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    doc.title,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: RampTheme.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${doc.fileName ?? doc.type} • ${doc.fileSize ?? "PDF"}',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: RampTheme.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.open_in_new_rounded,
                              color: RampTheme.primaryBlue,
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),

              const SizedBox(height: RampTheme.spacing28),

              // ACTIVE NOW SESSION & SECURITY
              Text(
                'ACTIVE NOW SESSION & SECURITY',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                  color: RampTheme.textSecondary,
                ),
              ),
              const SizedBox(height: RampTheme.spacing12),

              NeumorphicContainer(
                borderRadius: 20.0,
                onTap: () => context.push('/sessions'),
                padding: const EdgeInsets.all(18.0),
                child: Row(
                  children: [
                    NeumorphicContainer(
                      borderRadius: 12,
                      width: 42,
                      height: 42,
                      backgroundColor: RampTheme.successGreen.withValues(alpha: 0.12),
                      child: const Icon(Icons.phone_android_rounded, color: RampTheme.successGreen, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  nowSession?.deviceName ?? 'Current Device Session',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: RampTheme.textPrimary,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: RampTheme.successGreen.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'Active Now',
                                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: RampTheme.successGreen),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${nowSession?.osVersion ?? "Active OS"} • Tap to manage sessions',
                            style: const TextStyle(
                              fontSize: 12,
                              color: RampTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: RampTheme.textSecondary),
                  ],
                ),
              ),

              const SizedBox(height: RampTheme.spacing28),

              // 6. ACCOUNT SETTINGS
              Text(
                'ACCOUNT SETTINGS',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                  color: RampTheme.textSecondary,
                ),
              ),
              const SizedBox(height: RampTheme.spacing12),

              if (tenant != null)
                NeumorphicButton(
                  label: 'Update Contact Number',
                  icon: Icons.phone_android_outlined,
                  backgroundColor: NeumorphicDecoration.baseColor,
                  textColor: RampTheme.textPrimary,
                  onPressed: () => _showUpdateContactDialog(tenant),
                ),

              const SizedBox(height: 14),

              // Soft-Red Sign Out Button
              NeumorphicButton(
                label: 'Sign Out',
                icon: Icons.logout_rounded,
                backgroundColor: RampTheme.errorRed.withValues(alpha: 0.12),
                textColor: RampTheme.errorRed,
                onPressed: () async {
                  await authService.signOut();
                  if (context.mounted) {
                    context.go('/login');
                  }
                },
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarPlaceholder(String name) {
    final initials = name.isNotEmpty
        ? name.trim().split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase()
        : 'T';

    return Center(
      child: Text(
        initials,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: RampTheme.primaryBlue,
        ),
      ),
    );
  }

  Widget _buildReadOnlyRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: RampTheme.primaryBlue),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 11, color: RampTheme.textSecondary, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: RampTheme.textPrimary),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContactRow(String label, String value, IconData icon) {
    final isPhone = label.toLowerCase().contains('phone') && value.replaceAll(RegExp(r'\D'), '').isNotEmpty;

    return GestureDetector(
      onTap: isPhone
          ? () async {
              final digits = value.replaceAll(RegExp(r'\D'), '');
              final uri = Uri.parse('tel:$digits');
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri);
              }
            }
          : null,
      child: Row(
        children: [
          Icon(icon, size: 18, color: RampTheme.primaryBlue),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 11, color: RampTheme.textSecondary, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isPhone ? RampTheme.primaryBlue : RampTheme.textPrimary,
                    decoration: isPhone ? TextDecoration.underline : TextDecoration.none,
                  ),
                ),
              ],
            ),
          ),
          if (isPhone)
            const Icon(Icons.call_outlined, color: RampTheme.primaryBlue, size: 18),
        ],
      ),
    );
  }
}
