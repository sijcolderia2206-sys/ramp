import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../theme.dart';
import '../../models/tenant_model.dart';
import '../../models/unit_model.dart';
import '../../core/pdf_exporter.dart';
import '../../providers/landlord_providers.dart';
import '../../widgets/neumorphic_widgets.dart';
import '../../core/supabase_auth_service.dart';
import 'add_tenant_screen.dart';

class LandlordTenantsScreen extends ConsumerWidget {
  const LandlordTenantsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: RampTheme.scaffoldBackground,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12.0),
            // Header Title
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Tenant Management',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: RampTheme.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 12.0),
            // Inset Search Bar
            const _TenantSearchBar(),
            const SizedBox(height: 12.0),
            // Filter Chips Row
            const _TenantFilterRow(),
            const SizedBox(height: 12.0),
            // Tenants List with Slidable Action Cards
            const Expanded(child: _TenantListView()),
          ],
        ),
      ),
      floatingActionButton: _AddTenantFab(),
    );
  }
}

class _TenantSearchBar extends ConsumerWidget {
  const _TenantSearchBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = ref.watch(tenantSearchQueryProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: NeumorphicSearchBar(
        hintText: 'Search by full name, unit #, or email...',
        initialValue: query,
        onChanged: (val) {
          ref.read(tenantSearchQueryProvider.notifier).updateQuery(val);
        },
        onClear: () {
          ref.read(tenantSearchQueryProvider.notifier).clear();
        },
      ),
    );
  }
}

class _TenantFilterRow extends ConsumerWidget {
  const _TenantFilterRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeFilter = ref.watch(tenantFilterProvider);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          NeumorphicFilterChip(
            label: 'All Tenants',
            isSelected: activeFilter == TenantFilter.all,
            onTap: () => ref.read(tenantFilterProvider.notifier).updateFilter(TenantFilter.all),
          ),
          const SizedBox(width: 10.0),
          NeumorphicFilterChip(
            label: 'Active',
            isSelected: activeFilter == TenantFilter.active,
            onTap: () => ref.read(tenantFilterProvider.notifier).updateFilter(TenantFilter.active),
          ),
          const SizedBox(width: 10.0),
          NeumorphicFilterChip(
            label: 'Overdue',
            isSelected: activeFilter == TenantFilter.overdue,
            onTap: () => ref.read(tenantFilterProvider.notifier).updateFilter(TenantFilter.overdue),
          ),
          const SizedBox(width: 10.0),
          NeumorphicFilterChip(
            label: 'Inactive',
            isSelected: activeFilter == TenantFilter.inactive,
            onTap: () => ref.read(tenantFilterProvider.notifier).updateFilter(TenantFilter.inactive),
          ),
        ],
      ),
    );
  }
}

class _TenantListView extends ConsumerWidget {
  const _TenantListView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tenants = ref.watch(filteredTenantsProvider);

    if (tenants.isEmpty) {
      return const _EmptyTenantState();
    }

    return ListView.separated(
      padding: const EdgeInsets.only(
        left: 16.0,
        right: 16.0,
        top: 8.0,
        bottom: 80.0,
      ),
      itemCount: tenants.length,
      separatorBuilder: (_, __) => const SizedBox(height: 14.0),
      itemBuilder: (context, index) {
        return _TenantSlidableCard(tenant: tenants[index]);
      },
    );
  }
}

class _TenantSlidableCard extends ConsumerWidget {
  final TenantRecord tenant;

  const _TenantSlidableCard({required this.tenant});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOverdue = tenant.balanceDue > 0;
    final initials = tenant.fullName.isNotEmpty
        ? tenant.fullName.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join()
        : 'T';

    return Slidable(
      key: ValueKey(tenant.id),
      // Swipe Right (Start Action) -> Record Payment
      startActionPane: ActionPane(
        motion: const BehindMotion(),
        children: [
          SlidableAction(
            onPressed: (_) {
              context.push('/record-payment');
            },
            backgroundColor: RampTheme.successGreen,
            foregroundColor: Colors.white,
            icon: Icons.payments_outlined,
            label: 'Record Payment',
            borderRadius: const BorderRadius.horizontal(left: Radius.circular(18)),
          ),
        ],
      ),
      // Swipe Left (End Action) -> Log Overdue
      endActionPane: ActionPane(
        motion: const BehindMotion(),
        children: [
          SlidableAction(
            onPressed: (ctx) async {
              // Add late fee penalty or mark overdue balance
              final newBalance = tenant.balanceDue > 0 ? tenant.balanceDue + 500.0 : tenant.monthlyRent;
              await ref.read(tenantsProvider.notifier).updateTenantBalance(tenant.id, newBalance);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Logged overdue balance ${formatCurrency(newBalance)} for ${tenant.fullName}'),
                  ),
                );
              }
            },
            backgroundColor: RampTheme.errorRed,
            foregroundColor: Colors.white,
            icon: Icons.warning_amber_rounded,
            label: 'Log Overdue',
            borderRadius: const BorderRadius.horizontal(right: Radius.circular(18)),
          ),
        ],
      ),
      child: NeumorphicContainer(
        borderRadius: 18.0,
        onTap: () => _showTenantDetailsModal(context, ref, tenant),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Circular Neumorphic frame around Profile Image / Initials
              NeumorphicContainer(
                shape: BoxShape.circle,
                width: 48,
                height: 48,
                child: Center(
                  child: Text(
                    initials.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: RampTheme.primaryBlue,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14.0),
              // Name and Unit # Subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tenant.fullName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: RampTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      'Unit ${tenant.unitNumber} • ${tenant.contactNumber}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: RampTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8.0),
              // Recessed Neumorphic Pill Badges for Payment Status & Balance
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  NeumorphicPill(
                    text: isOverdue ? 'Overdue' : 'Paid',
                    textColor: isOverdue ? RampTheme.errorRed : RampTheme.successGreen,
                  ),
                  const SizedBox(height: 4.0),
                  NeumorphicPill(
                    text: tenant.isConfirmed ? 'Confirmed' : 'Pending',
                    textColor: tenant.isConfirmed ? RampTheme.primaryBlue : RampTheme.warningYellow,
                  ),
                  if (isOverdue) ...[
                    const SizedBox(height: 4.0),
                    Text(
                      formatCurrency(tenant.balanceDue),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: RampTheme.errorRed,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTenantDetailsModal(BuildContext context, WidgetRef ref, TenantRecord tenant) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: RampTheme.scaffoldBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
      ),
      builder: (context) => _TenantDetailsModalSheet(tenant: tenant),
    );
  }
}

class _TenantDetailsModalSheet extends StatelessWidget {
  final TenantRecord tenant;

  const _TenantDetailsModalSheet({required this.tenant});

  Future<void> _makeCall(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _showRentReminderCustomizerModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: RampTheme.scaffoldBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
      ),
      builder: (context) {
        return _RentReminderCustomizerSheet(tenant: tenant);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag handle
            Center(
              child: NeumorphicContainer(
                isInset: true,
                width: 48.0,
                height: 6.0,
                borderRadius: 3.0,
                child: const SizedBox.shrink(),
              ),
            ),
            const SizedBox(height: 20.0),

            // Tenant Name Title
            Text(
              tenant.fullName,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: RampTheme.textPrimary,
              ),
            ),
            Text(
              'Unit ${tenant.unitNumber} • ${tenant.email ?? "No email address"}',
              style: const TextStyle(fontSize: 13, color: RampTheme.textSecondary),
            ),
            const SizedBox(height: 20.0),

            // Financial Summary Card
            NeumorphicContainer(
              borderRadius: 16.0,
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Monthly Rent', style: TextStyle(color: RampTheme.textSecondary, fontSize: 13)),
                      Text(formatCurrency(tenant.monthlyRent), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    ],
                  ),
                  const Divider(height: 20, color: RampTheme.dividerColor),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Security Deposit Held', style: TextStyle(color: RampTheme.textSecondary, fontSize: 13)),
                      Text(
                        formatCurrency(tenant.securityDeposit),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: RampTheme.primaryBlue),
                      ),
                    ],
                  ),
                  const Divider(height: 20, color: RampTheme.dividerColor),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Amount Due', style: TextStyle(color: RampTheme.textSecondary, fontSize: 13)),
                      Text(
                        formatCurrency(tenant.totalAmountDue),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: tenant.totalAmountDue > 0 ? RampTheme.errorRed : RampTheme.successGreen,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20.0),

            // Neumorphic Circular Icon Buttons for Call & SMS
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    NeumorphicContainer(
                      shape: BoxShape.circle,
                      width: 56,
                      height: 56,
                      onTap: () => _makeCall(tenant.contactNumber),
                      child: const Icon(Icons.phone, color: RampTheme.primaryBlue, size: 24),
                    ),
                    const SizedBox(height: 6),
                    const Text('Call', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: RampTheme.textPrimary)),
                  ],
                ),
                Column(
                  children: [
                    NeumorphicContainer(
                      shape: BoxShape.circle,
                      width: 56,
                      height: 56,
                      onTap: () => _showRentReminderCustomizerModal(context),
                      child: const Icon(Icons.message, color: RampTheme.primaryBlue, size: 24),
                    ),
                    const SizedBox(height: 6),
                    const Text('Reminder', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: RampTheme.textPrimary)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24.0),

            // Toggle Account Confirmation Button
            Consumer(
              builder: (context, ref, child) {
                return NeumorphicButton(
                  label: tenant.isConfirmed ? 'Account Confirmed (Tap to Revoke)' : 'Confirm Tenant Account',
                  icon: tenant.isConfirmed ? Icons.verified_user : Icons.check_circle_outline,
                  onPressed: () async {
                    final newConfirmedStatus = !tenant.isConfirmed;
                    await ref.read(tenantsProvider.notifier).toggleTenantConfirmation(tenant.id);
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(newConfirmedStatus ? 'Tenant account confirmed successfully!' : 'Tenant confirmation revoked.'),
                          backgroundColor: newConfirmedStatus ? RampTheme.successGreen : RampTheme.warningYellow,
                        ),
                      );
                    }
                  },
                );
              },
            ),
            const SizedBox(height: 12.0),

            // Edit Tenant Profile Button
            NeumorphicButton(
              label: 'Edit Tenant Profile',
              icon: Icons.edit_outlined,
              onPressed: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => AddTenantScreen(tenantToEdit: tenant),
                  ),
                );
              },
            ),
            const SizedBox(height: 12.0),

            // View Full Profile Button
            NeumorphicButton(
              label: 'View Full Profile',
              icon: Icons.person_outline,
              onPressed: () {
                Navigator.pop(context);
                _showTenantFullProfileModal(context, tenant);
              },
            ),
            const SizedBox(height: 8.0),
          ],
        ),
      ),
    );
  }
}

void _showTenantFullProfileModal(BuildContext context, TenantRecord tenant) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: RampTheme.scaffoldBackground,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28.0)),
    ),
    builder: (context) {
      return Consumer(
        builder: (context, ref, child) {
          final units = ref.watch(unitsProvider);
          final assignedUnit = units.firstWhere(
            (u) => u.id == tenant.unitId || u.unitNumber == tenant.unitNumber,
            orElse: () => RentalUnit(
              id: tenant.unitId,
              title: 'Unit ${tenant.unitNumber}',
              unitNumber: tenant.unitNumber,
              monthlyRent: tenant.monthlyRent,
            ),
          );

          return DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.85,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            builder: (context, scrollController) {
              return SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Handle
                    Center(
                      child: NeumorphicContainer(
                        isInset: true,
                        width: 48.0,
                        height: 6.0,
                        borderRadius: 3.0,
                        child: const SizedBox.shrink(),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Header Avatar & Name
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: RampTheme.primaryBlue.withValues(alpha: 0.15),
                          child: Text(
                            tenant.fullName.isNotEmpty ? tenant.fullName[0].toUpperCase() : 'T',
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: RampTheme.primaryBlue),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                tenant.fullName,
                                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: RampTheme.textPrimary),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Unit ${tenant.unitNumber} • ${tenant.isArchived ? "Archived" : "Active"}',
                                style: const TextStyle(fontSize: 13, color: RampTheme.textSecondary, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // SECTION 1: Personal Information Card
                    NeumorphicContainer(
                      borderRadius: 20,
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.person_outline, color: RampTheme.primaryBlue, size: 20),
                              SizedBox(width: 8),
                              Text('Personal Information', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: RampTheme.primaryBlue)),
                            ],
                          ),
                          const Divider(height: 20, color: RampTheme.dividerColor),
                          _buildProfileRow('Email Address', tenant.email ?? 'Not provided'),
                          _buildProfileRow('Contact Phone', tenant.phone.isEmpty ? 'Not provided' : tenant.phone),
                          if (tenant.dateOfBirth != null)
                            _buildProfileRow('Date of Birth', DateFormat.yMMMMd().format(tenant.dateOfBirth!)),
                          if (tenant.facebookUrl != null && tenant.facebookUrl!.isNotEmpty)
                            _buildProfileRow('Facebook / Messenger', tenant.facebookUrl!),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // SECTION 2: Lease & Financial Terms
                    NeumorphicContainer(
                      borderRadius: 20,
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.home_work_outlined, color: RampTheme.primaryBlue, size: 20),
                              SizedBox(width: 8),
                              Text('Lease & Financial Terms', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: RampTheme.primaryBlue)),
                            ],
                          ),
                          const Divider(height: 20, color: RampTheme.dividerColor),
                          _buildProfileRow('Monthly Rent', formatCurrency(tenant.monthlyRent)),
                          _buildProfileRow('Current Balance', formatCurrency(tenant.balanceDue)),
                          _buildProfileRow('Lease Start Date', DateFormat.yMMMMd().format(tenant.leaseStart)),
                          _buildProfileRow('Lease End Date', DateFormat.yMMMMd().format(tenant.leaseEnd)),
                          _buildProfileRow('Next Due Date', DateFormat.yMMMMd().format(tenant.dueDate)),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // SECTION 3: Emergency Contact Details
                    NeumorphicContainer(
                      borderRadius: 20,
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.emergency_outlined, color: RampTheme.errorRed, size: 20),
                              SizedBox(width: 8),
                              Text('Emergency Contact Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: RampTheme.errorRed)),
                            ],
                          ),
                          const Divider(height: 20, color: RampTheme.dividerColor),
                          _buildProfileRow('Contact Person', tenant.emergencyName ?? 'Not provided'),
                          _buildProfileRow('Relationship', tenant.emergencyRelationship ?? 'Not specified'),
                          _buildProfileRow('Emergency Phone', tenant.emergencyPhone ?? 'Not provided'),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Actions Row: Download Statement PDF & Close
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              side: const BorderSide(color: RampTheme.primaryBlue),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            icon: const Icon(Icons.picture_as_pdf, color: RampTheme.primaryBlue),
                            label: const Text('Lease PDF', style: TextStyle(color: RampTheme.primaryBlue, fontWeight: FontWeight.bold)),
                            onPressed: () {
                              RampPdfExporter.printTenantStatement(
                                tenant: tenant,
                                unit: assignedUnit,
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: RampTheme.primaryBlue,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Close Profile', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      );
    },
  );
}

Widget _buildProfileRow(String label, String value) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: RampTheme.textSecondary)),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: RampTheme.textPrimary),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    ),
  );
}

class _AddTenantFab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    if (SupabaseAuthService().activeRole == 'tenant') {
      return const SizedBox.shrink();
    }
    return GestureDetector(
      onTap: () => context.push('/add-tenant'),
      child: NeumorphicContainer(
        borderRadius: 28.0,
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
        backgroundColor: RampTheme.primaryBlue,
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.person_add, color: Colors.white, size: 20),
            SizedBox(width: 8.0),
            Text(
              'Add Tenant',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyTenantState extends StatelessWidget {
  const _EmptyTenantState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            NeumorphicContainer(
              shape: BoxShape.circle,
              padding: const EdgeInsets.all(24.0),
              child: const Icon(
                Icons.people_outline,
                size: 48,
                color: RampTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 20.0),
            const Text(
              'No Tenants Found',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: RampTheme.textPrimary),
            ),
            const SizedBox(height: 8.0),
            const Text(
              'Try adjusting your search query or filter chip.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: RampTheme.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _RentReminderCustomizerSheet extends StatefulWidget {
  final TenantRecord tenant;

  const _RentReminderCustomizerSheet({required this.tenant});

  @override
  State<_RentReminderCustomizerSheet> createState() => _RentReminderCustomizerSheetState();
}

class _RentReminderCustomizerSheetState extends State<_RentReminderCustomizerSheet> {
  int _selectedPresetIndex = 0;
  late TextEditingController _messageCtrl;

  @override
  void initState() {
    super.initState();
    _messageCtrl = TextEditingController(text: _getPresetText(0));
  }

  @override
  void dispose() {
    _messageCtrl.dispose();
    super.dispose();
  }

  String _getPresetText(int index) {
    final name = widget.tenant.fullName;
    final unit = widget.tenant.unitNumber;
    final balance = formatCurrency(widget.tenant.balanceDue);

    switch (index) {
      case 0:
        return 'Hello $name, this is a friendly reminder that your rent balance $balance for Unit $unit is upcoming. Thank you!';
      case 1:
        return 'Hello $name, your monthly rent payment $balance for Unit $unit is due today. Please send payment via GCash/Maya/Bank. Thank you!';
      case 2:
        return 'URGENT: Hello $name, your rent payment for Unit $unit ($balance) is past due. Please settle immediately to avoid late fees. Thank you.';
      default:
        return '';
    }
  }

  void _selectPreset(int index) {
    setState(() {
      _selectedPresetIndex = index;
      _messageCtrl.text = _getPresetText(index);
    });
  }

  Future<void> _sendSms() async {
    final msg = Uri.encodeComponent(_messageCtrl.text.trim());
    final uri = Uri.parse('sms:${widget.tenant.contactNumber}?body=$msg');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _openMessenger() async {
    if (widget.tenant.facebookUrl != null && widget.tenant.facebookUrl!.isNotEmpty) {
      var urlStr = widget.tenant.facebookUrl!.trim();
      if (!urlStr.startsWith('http')) urlStr = 'https://$urlStr';
      final uri = Uri.parse(urlStr);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return;
      }
    }
    await _sendSms();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: const [
                    Icon(Icons.message_rounded, color: RampTheme.primaryBlue),
                    SizedBox(width: 8),
                    Text('Send Rent Reminder', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 8),

            const Text('Preset Templates:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: RampTheme.textSecondary)),
            const SizedBox(height: 8),

            Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('Friendly Notice'),
                  selected: _selectedPresetIndex == 0,
                  onSelected: (_) => _selectPreset(0),
                ),
                ChoiceChip(
                  label: const Text('Due Today'),
                  selected: _selectedPresetIndex == 1,
                  onSelected: (_) => _selectPreset(1),
                ),
                ChoiceChip(
                  label: const Text('Overdue Urgency'),
                  selected: _selectedPresetIndex == 2,
                  selectedColor: RampTheme.errorRed.withValues(alpha: 0.2),
                  onSelected: (_) => _selectPreset(2),
                ),
              ],
            ),

            const SizedBox(height: 16),

            TextField(
              controller: _messageCtrl,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: 'Reminder Message',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.sms_rounded),
                    label: const Text('Send SMS'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: RampTheme.primaryBlue,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      _sendSms();
                    },
                  ),
                ),
                if (widget.tenant.facebookUrl != null && widget.tenant.facebookUrl!.isNotEmpty) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.chat_bubble_rounded),
                      label: const Text('Messenger'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: RampTheme.primaryBlue,
                        side: const BorderSide(color: RampTheme.primaryBlue),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        _openMessenger();
                      },
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
