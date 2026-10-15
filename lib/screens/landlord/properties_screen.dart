// lib/screens/landlord/properties_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../theme.dart';
import '../../models/unit_model.dart';
import '../../providers/unit_management_providers.dart';
import '../../widgets/neumorphic_widgets.dart';
import '../../core/supabase_auth_service.dart';
import 'add_unit_screen.dart';

class LandlordPropertiesScreen extends ConsumerWidget {
  const LandlordPropertiesScreen({super.key});

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
                'Unit Management',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: RampTheme.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 12.0),
            // Inset Neumorphic Search Bar
            const _UnitSearchBar(),
            const SizedBox(height: 12.0),
            // Scrollable Neumorphic Filter Chips
            const _FilterChipsRow(),
            const SizedBox(height: 12.0),
            // Unit List View
            const Expanded(child: _UnitListView()),
          ],
        ),
      ),
      floatingActionButton: _AddUnitFab(),
    );
  }
}

class _UnitSearchBar extends ConsumerWidget {
  const _UnitSearchBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = ref.watch(searchQueryProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: NeumorphicSearchBar(
        hintText: 'Search by unit # or building name...',
        initialValue: query,
        onChanged: (val) {
          ref.read(searchQueryProvider.notifier).updateQuery(val);
        },
        onClear: () {
          ref.read(searchQueryProvider.notifier).clear();
        },
      ),
    );
  }
}

class _FilterChipsRow extends ConsumerWidget {
  const _FilterChipsRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeFilter = ref.watch(unitFilterStateProvider);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          NeumorphicFilterChip(
            label: 'All Units',
            isSelected: activeFilter == UnitFilter.all,
            onTap: () => ref.read(unitFilterStateProvider.notifier).updateFilter(UnitFilter.all),
          ),
          const SizedBox(width: 10.0),
          NeumorphicFilterChip(
            label: 'Occupied',
            isSelected: activeFilter == UnitFilter.occupied,
            onTap: () => ref.read(unitFilterStateProvider.notifier).updateFilter(UnitFilter.occupied),
          ),
          const SizedBox(width: 10.0),
          NeumorphicFilterChip(
            label: 'Vacant',
            isSelected: activeFilter == UnitFilter.vacant,
            onTap: () => ref.read(unitFilterStateProvider.notifier).updateFilter(UnitFilter.vacant),
          ),
          const SizedBox(width: 10.0),
          NeumorphicFilterChip(
            label: 'Maintenance',
            isSelected: activeFilter == UnitFilter.maintenance,
            onTap: () => ref.read(unitFilterStateProvider.notifier).updateFilter(UnitFilter.maintenance),
          ),
        ],
      ),
    );
  }
}

class _UnitListView extends ConsumerWidget {
  const _UnitListView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final units = ref.watch(filteredUnitsProvider);

    if (units.isEmpty) {
      return const _EmptyUnitState();
    }

    return ListView.separated(
      padding: const EdgeInsets.only(
        left: 16.0,
        right: 16.0,
        top: 8.0,
        bottom: 80.0, // Ensures final card is fully visible above FAB
      ),
      itemCount: units.length,
      separatorBuilder: (_, __) => const SizedBox(height: 14.0),
      itemBuilder: (context, index) {
        return _UnitCard(unit: units[index]);
      },
    );
  }
}

class _UnitCard extends StatelessWidget {
  final RentalUnit unit;

  const _UnitCard({required this.unit});

  @override
  Widget build(BuildContext context) {
    // Format subtitle to wrap and NOT repeat the unit number
    String cleanSubtitle = unit.title.replaceAll(RegExp('Unit\\s*${unit.unitNumber}', caseSensitive: false), '').trim();
    if (cleanSubtitle.startsWith('-') || cleanSubtitle.startsWith(':')) {
      cleanSubtitle = cleanSubtitle.substring(1).trim();
    }
    if (cleanSubtitle.isEmpty) {
      cleanSubtitle = '${unit.bedrooms} Bed • ${unit.bathrooms} Bath • ${unit.buildingName}';
    } else {
      cleanSubtitle = '$cleanSubtitle • ${unit.buildingName}';
    }

    Color statusColor;
    switch (unit.status) {
      case 'Occupied':
        statusColor = RampTheme.successGreen;
        break;
      case 'Vacant':
        statusColor = RampTheme.primaryBlue;
        break;
      case 'Under Maintenance':
      default:
        statusColor = RampTheme.errorRed;
        break;
    }

    return NeumorphicContainer(
      borderRadius: 18.0,
      onTap: () => _showUnitDetailsModal(context, unit, cleanSubtitle),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Circular Neumorphic Icon Container
            NeumorphicContainer(
              shape: BoxShape.circle,
              isInset: false,
              padding: const EdgeInsets.all(12.0),
              child: const Icon(
                Icons.apartment,
                color: RampTheme.primaryBlue,
                size: 24,
              ),
            ),
            const SizedBox(width: 14.0),
            // Title and Wrapped Subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Unit ${unit.unitNumber}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: RampTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    cleanSubtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: RampTheme.textSecondary,
                      height: 1.3,
                    ),
                    softWrap: true,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8.0),
            // Price & Status Badge Column
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  formatCurrency(unit.monthlyRent),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: RampTheme.primaryBlue,
                  ),
                ),
                const SizedBox(height: 6.0),
                NeumorphicPill(
                  text: unit.status,
                  textColor: statusColor,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showUnitDetailsModal(BuildContext context, RentalUnit unit, String subtitle) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: RampTheme.scaffoldBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
      ),
      builder: (context) => _UnitDetailsModalSheet(unit: unit, subtitle: subtitle),
    );
  }
}

class _UnitDetailsModalSheet extends StatelessWidget {
  final RentalUnit unit;
  final String subtitle;

  const _UnitDetailsModalSheet({
    required this.unit,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Pill-shaped Neumorphic Drag Handle
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

            // Modal Header with Soft Wrap
            Text(
              'Unit ${unit.unitNumber} - $subtitle',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: RampTheme.textPrimary,
              ),
              softWrap: true,
            ),
            const SizedBox(height: 16.0),

            // Rent Details Matrix in Neumorphic Card
            NeumorphicContainer(
              borderRadius: 16.0,
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _ModalDetailRow(
                    label: 'Unit Status',
                    child: NeumorphicPill(
                      text: unit.status,
                      textColor: unit.status == 'Occupied'
                          ? RampTheme.successGreen
                          : (unit.status == 'Vacant' ? RampTheme.primaryBlue : RampTheme.errorRed),
                    ),
                  ),
                  const Divider(height: 20, color: RampTheme.dividerColor),
                  _ModalDetailRow(
                    label: 'Current Tenant',
                    child: Text(
                      unit.tenantName ?? 'Vacant / Unassigned',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: RampTheme.textPrimary),
                    ),
                  ),
                  const Divider(height: 20, color: RampTheme.dividerColor),
                  _ModalDetailRow(
                    label: 'Monthly Rent',
                    child: Text(
                      formatCurrency(unit.monthlyRent),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: RampTheme.primaryBlue),
                    ),
                  ),
                  const Divider(height: 20, color: RampTheme.dividerColor),
                  _ModalDetailRow(
                    label: 'Submeters Due',
                    child: Text(
                      formatCurrency(unit.submetersDue),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: RampTheme.textPrimary),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16.0),

            // Unit Photo Gallery
            if (unit.images.isNotEmpty) ...[
              const Text(
                'Unit Photos',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: RampTheme.textPrimary),
              ),
              const SizedBox(height: 10.0),
              SizedBox(
                height: 110,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: unit.images.length,
                  itemBuilder: (context, idx) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.network(
                          unit.images[idx],
                          width: 140,
                          height: 110,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 140,
                            height: 110,
                            color: RampTheme.scaffoldBackground,
                            child: const Icon(Icons.home, color: RampTheme.primaryBlue),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16.0),
            ],

            // Configured Maintenance Areas Section
            const Text(
              'Configured Maintenance Areas',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: RampTheme.textPrimary),
            ),
            const SizedBox(height: 10.0),
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: unit.maintenanceAreas.map((area) {
                return NeumorphicPill(
                  text: area,
                  textColor: RampTheme.primaryBlue,
                  icon: Icons.build_outlined,
                );
              }).toList(),
            ),
            const SizedBox(height: 24.0),

            // Convex "Edit Unit" Button
            NeumorphicButton(
              label: 'Edit Unit Details',
              icon: Icons.edit_outlined,
              onPressed: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => AddUnitScreen(unitToEdit: unit),
                  ),
                );
              },
            ),
            const SizedBox(height: 8.0),
          ],
        ),
      ),
    );
  }
}

class _ModalDetailRow extends StatelessWidget {
  final String label;
  final Widget child;

  const _ModalDetailRow({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: RampTheme.textSecondary, fontWeight: FontWeight.w500),
        ),
        child,
      ],
    );
  }
}

class _AddUnitFab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    if (SupabaseAuthService().activeRole == 'tenant') {
      return const SizedBox.shrink();
    }
    return GestureDetector(
      onTap: () => context.push('/add-unit'),
      child: NeumorphicContainer(
        borderRadius: 28.0,
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
        backgroundColor: RampTheme.primaryBlue,
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add, color: Colors.white, size: 20),
            SizedBox(width: 8.0),
            Text(
              'Add Unit',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyUnitState extends StatelessWidget {
  const _EmptyUnitState();

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
                Icons.apartment,
                size: 48,
                color: RampTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 20.0),
            const Text(
              'No Units Found',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: RampTheme.textPrimary),
            ),
            const SizedBox(height: 8.0),
            const Text(
              'Try adjusting your search query or unit status filter.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: RampTheme.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
