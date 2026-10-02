import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import '../core/widgets/location_picker_map.dart';
import '../providers/providers.dart';
import '../core/widgets/core_widgets.dart';
import '../core/theme/ramp_theme.dart';

class UnitDetailScreen extends ConsumerStatefulWidget {
  final String unitId;
  const UnitDetailScreen({super.key, required this.unitId});

  @override
  ConsumerState<UnitDetailScreen> createState() => _UnitDetailScreenState();
}

class _UnitDetailScreenState extends ConsumerState<UnitDetailScreen> {
  String _financialHistoryFilter = 'All';
  static final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'en_PH',
    symbol: '₱',
    decimalDigits: 2,
  );

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'occupied':
        return RampColors.success;
      case 'maintenance':
        return RampColors.warning;
      case 'vacant':
      default:
        return RampColors.primary;
    }
  }

  void _showUtilityHistoryModal(BuildContext context, Unit unit) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final rateNotifier = ref.read(utilityRateProvider.notifier);
    final rates = ref.read(utilityRateProvider);
    final currentWaterRate = unit.effectiveWaterRate(rates.waterRate);
    final currentElectricityRate =
        unit.effectiveElectricityRate(rates.electricityRate);
    final previousMonth = DateTime.now().subtract(const Duration(days: 30));

    // Build historical readings list from current and past readings
    final readings = [
      UtilityReading(
        id: 'ur_1',
        unitId: unit.id,
        type: 'Water',
        previousReading: unit.waterReadingPrev,
        currentReading: unit.waterReadingCurr,
        rate: currentWaterRate,
        readingDate: DateTime.now(),
      ),
      UtilityReading(
        id: 'ur_2',
        unitId: unit.id,
        type: 'Electricity',
        previousReading: unit.electricReadingPrev,
        currentReading: unit.electricReadingCurr,
        rate: currentElectricityRate,
        readingDate: DateTime.now(),
      ),
      UtilityReading(
        id: 'ur_3',
        unitId: unit.id,
        type: 'Water',
        previousReading: (unit.waterReadingPrev - 12.0).clamp(0, 9999),
        currentReading: unit.waterReadingPrev,
        rate: rateNotifier.rateAt('Water', previousMonth),
        readingDate: previousMonth,
      ),
      UtilityReading(
        id: 'ur_4',
        unitId: unit.id,
        type: 'Electricity',
        previousReading: (unit.electricReadingPrev - 180.0).clamp(0, 9999),
        currentReading: unit.electricReadingPrev,
        rate: rateNotifier.rateAt('Electricity', previousMonth),
        readingDate: previousMonth,
      ),
    ]
        .where((reading) => reading.type == 'Water'
            ? unit.waterUtilityEnabled
            : unit.electricityUtilityEnabled)
        .toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.65,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.history_rounded,
                          color: RampColors.primary, size: 24),
                      const SizedBox(width: 8),
                      Text(
                        'Utility Readings History',
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
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              Divider(
                  color: isDark ? const Color(0xFF334155) : RampColors.border),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  itemCount: readings.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final r = readings[index];
                    final isWater = r.type == 'Water';
                    return RampCard(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: isWater
                                ? const Color(0x200284C7)
                                : const Color(0x20F59E0B),
                            child: Icon(
                              isWater
                                  ? Icons.water_drop_rounded
                                  : Icons.bolt_rounded,
                              color: isWater
                                  ? const Color(0xFF0284C7)
                                  : const Color(0xFFF59E0B),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${r.type} • ${r.formattedReadingDate}',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold,
                                    color: isDark
                                        ? Colors.white
                                        : RampColors.slate,
                                  ),
                                ),
                                Text(
                                  'Prev: ${r.previousReading.toStringAsFixed(1)} → Curr: ${r.currentReading.toStringAsFixed(1)} (${r.consumption.toStringAsFixed(1)} ${isWater ? 'm³' : 'kWh'})',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: isDark
                                        ? const Color(0xFF94A3B8)
                                        : RampColors.mutedText,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            _currencyFormat.format(r.charge),
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: isWater
                                  ? const Color(0xFF0284C7)
                                  : const Color(0xFFF59E0B),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showManageUnitAreasModal(BuildContext context, Unit unit) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final List<String> currentAreas = List<String>.from(unit.maintenanceAreas);
    final areaInputCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? Theme.of(context).colorScheme.surface : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
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
                              const Icon(Icons.tune_rounded, color: RampColors.primary, size: 24),
                              const SizedBox(width: 8),
                              Text(
                                'Manage Maintenance Areas',
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
                            onPressed: () => Navigator.pop(sheetContext),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Customize areas available for maintenance reporting in ${unit.name}:',
                        style: GoogleFonts.poppins(fontSize: 12, color: RampColors.mutedText),
                      ),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: areaInputCtrl,
                              decoration: InputDecoration(
                                hintText: 'e.g. Balcony, Kitchen, Master Bath',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: RampColors.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            ),
                            onPressed: () {
                              final text = areaInputCtrl.text.trim();
                              if (text.isNotEmpty && !currentAreas.contains(text)) {
                                setSheetState(() {
                                  currentAreas.add(text);
                                  areaInputCtrl.clear();
                                });
                              }
                            },
                            child: const Text('Add'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: currentAreas.map((area) {
                          return Chip(
                            label: Text(area, style: GoogleFonts.poppins(fontSize: 12)),
                            deleteIcon: const Icon(Icons.close_rounded, size: 16),
                            onDeleted: () {
                              setSheetState(() {
                                currentAreas.remove(area);
                              });
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),

                      BouncePillButton(
                        text: 'SAVE UNIT AREAS',
                        icon: Icons.check_circle_rounded,
                        backgroundColor: RampColors.primary,
                        onPressed: () {
                          final updated = unit.copyWith(maintenanceAreas: currentAreas);
                          ref.read(unitProvider.notifier).updateUnit(updated);
                          Navigator.pop(sheetContext);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Updated maintenance areas for ${unit.name}!'),
                              backgroundColor: RampColors.success,
                            ),
                          );
                        },
                      ),
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

  void _showUpdateMeterReadingModal(BuildContext context, Unit unit) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final waterPrevCtrl =
        TextEditingController(text: unit.waterReadingPrev.toString());
    final waterCurrCtrl =
        TextEditingController(text: unit.waterReadingCurr.toString());
    final elecPrevCtrl =
        TextEditingController(text: unit.electricReadingPrev.toString());
    final elecCurrCtrl =
        TextEditingController(text: unit.electricReadingCurr.toString());

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor:
          isDark ? Theme.of(context).colorScheme.surface : Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
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
                      Expanded(
                        child: Row(
                          children: [
                            const Icon(Icons.speed_rounded,
                                color: RampColors.primary, size: 24),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Record Submeter Readings',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      isDark ? Colors.white : RampColors.slate,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (unit.waterUtilityEnabled) ...[
                    Text(
                      'Water Submeter (m³)',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: isDark ? Colors.white : RampColors.slate,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: RampTextField(
                            controller: waterPrevCtrl,
                            label: 'Prev Reading',
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: RampTextField(
                            controller: waterCurrCtrl,
                            label: 'Curr Reading',
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 16),
                  if (unit.electricityUtilityEnabled) ...[
                    Text(
                      'Electricity Submeter (kWh)',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: isDark ? Colors.white : RampColors.slate,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: RampTextField(
                            controller: elecPrevCtrl,
                            label: 'Prev Reading',
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: RampTextField(
                            controller: elecCurrCtrl,
                            label: 'Curr Reading',
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 20),
                  BouncePillButton(
                    text: 'SAVE METER READINGS',
                    icon: Icons.save_rounded,
                    onPressed: () {
                      final updatedUnit = unit.copyWith(
                        waterReadingPrev: double.tryParse(waterPrevCtrl.text) ??
                            unit.waterReadingPrev,
                        waterReadingCurr: double.tryParse(waterCurrCtrl.text) ??
                            unit.waterReadingCurr,
                        electricReadingPrev:
                            double.tryParse(elecPrevCtrl.text) ??
                                unit.electricReadingPrev,
                        electricReadingCurr:
                            double.tryParse(elecCurrCtrl.text) ??
                                unit.electricReadingCurr,
                      );

                      ref.read(unitProvider.notifier).updateUnit(updatedUnit);
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Submeter readings saved to history!'),
                          backgroundColor: RampColors.success,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showMarkOccupiedModal(BuildContext context, Unit unit) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tenants = ref
        .read(tenantProvider)
        .where((tenant) => !tenant.isArchived && !tenant.isAssigned)
        .toList();
    String? selectedTenantId = tenants.firstOrNull?.id;

    showModalBottomSheet(
      context: context,
      backgroundColor:
          isDark ? Theme.of(context).colorScheme.surface : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Assign Tenant & Mark Occupied',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : RampColors.slate,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (tenants.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                        'No unassigned tenant profiles are available. Add a tenant profile first.'),
                  )
                else
                  DropdownButtonFormField<String>(
                    initialValue: selectedTenantId,
                    dropdownColor:
                        isDark ? const Color(0xFF1E293B) : Colors.white,
                    style: GoogleFonts.poppins(
                      color: isDark ? Colors.white : RampColors.slate,
                      fontSize: 14,
                    ),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor:
                          isDark ? const Color(0xFF0F172A) : RampColors.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: isDark
                              ? const Color(0xFF334155)
                              : RampColors.border,
                        ),
                      ),
                    ),
                    items: tenants
                        .map((t) =>
                            DropdownMenuItem(value: t.id, child: Text(t.name)))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) selectedTenantId = val;
                    },
                  ),
                const SizedBox(height: 20),
                BouncePillButton(
                  text: 'CONFIRM OCCUPIED',
                  icon: Icons.check_circle_rounded,
                  backgroundColor: RampColors.success,
                  onPressed: tenants.isEmpty
                      ? null
                      : () {
                          final tObj = tenants
                              .where((t) => t.id == selectedTenantId)
                              .firstOrNull;
                          if (tObj == null) return;
                          final updated = unit.copyWith(
                            status: 'Occupied',
                            tenantName: tObj.name,
                            tenantId: tObj.id,
                            vacantDays: 0,
                          );
                          ref.read(unitProvider.notifier).updateUnit(updated);
                          ref
                              .read(tenantProvider.notifier)
                              .updateTenant(tObj.copyWith(
                                unitId: unit.id,
                                unitNumber: unit.unitNumber ?? 'Unknown Unit',
                                monthlyRent: unit.monthlyRent,
                                status: 'Active',
                              ));
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  '${unit.name} marked as Occupied by ${tObj.name}!'),
                              backgroundColor: RampColors.success,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final unit =
        ref.watch(unitProvider).where((u) => u.id == widget.unitId).firstOrNull;

    if (unit == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Unit Details')),
        body: SafeArea(
          child: RampEmptyState(
            title: 'Unit Not Found',
            description:
                'The requested unit details could not be found or has been removed.',
            icon: Icons.apartment_outlined,
            actionLabel: 'Go Back',
            onActionPressed: () => Navigator.pop(context),
          ),
        ),
      );
    }

    final tenant = ref.watch(tenantProvider).where((t) => t.unitId == unit.id && !t.isArchived && t.status != 'Former' && t.status != 'Pending').firstOrNull;
    final waitlistTenant = ref.watch(tenantProvider).where((t) => t.unitId == unit.id && (t.status == 'Pending' || t.status == 'Pending Renewal')).firstOrNull;

    // Auto-update logic
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (unit.isOccupied && tenant != null) {
        if (DateTime.now().isAfter(tenant.effectiveLeaseEnd)) {
          if (waitlistTenant != null) {
            if (unit.status != 'Pending') {
              ref.read(unitProvider.notifier).updateUnit(unit.copyWith(status: 'Pending'));
            }
          } else {
            if (unit.status != 'Vacant') {
              ref.read(unitProvider.notifier).markVacant(unit.id);
            }
          }
        }
      }
    });

    final isLeaseEndingSoon = tenant != null && 
        tenant.effectiveLeaseEnd.difference(DateTime.now()).inDays <= 30 && 
        tenant.effectiveLeaseEnd.difference(DateTime.now()).inDays >= 0;

    final unitLedger =
        ref.watch(paymentProvider).where((p) => p.unitId == unit.id).toList();
    final payments = unitLedger.where((p) {
      if (_financialHistoryFilter == 'Rent') return p.isRent;
      if (_financialHistoryFilter == 'Maintenance') return p.isMaintenance;
      return true;
    }).toList();
    final utilityRates = ref.watch(utilityRateProvider);
    final waterRate = unit.effectiveWaterRate(utilityRates.waterRate);
    final electricityRate =
        unit.effectiveElectricityRate(utilityRates.electricityRate);

    return Scaffold(
      backgroundColor: isDark
          ? Theme.of(context).scaffoldBackgroundColor
          : RampColors.background,
      appBar: AppBar(
        title: Text(
          unit.name,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : RampColors.slate,
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (status) {
              if (status == 'Occupied') {
                _showMarkOccupiedModal(context, unit);
              } else if (status == 'Vacant') {
                ref.read(unitProvider.notifier).markVacant(unit.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${unit.name} status changed to Vacant!'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              } else {
                ref
                    .read(unitProvider.notifier)
                    .updateUnit(unit.copyWith(status: status));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${unit.name} status changed to $status!'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'Occupied', child: Text('Mark as Occupied')),
              PopupMenuItem(value: 'Vacant', child: Text('Mark as Vacant')),
              PopupMenuItem(
                  value: 'Maintenance', child: Text('Mark as Maintenance')),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(
              left: 16.0, right: 16.0, top: 12.0, bottom: 100.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Banner Image
              SizedBox(
                width: double.infinity,
                height: 200,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Image.network(
                    unit.imageUrl ?? '',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.apartment,
                          size: 64, color: Colors.grey),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Title & Status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    unit.unitNumber ?? 'Unit 1',
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : RampColors.slate,
                    ),
                  ),
                  StatusPill(
                      status: unit.status,
                      customTextColor: _getStatusColor(unit.status)),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.location_on_outlined,
                      size: 16, color: RampColors.mutedText),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(unit.location,
                        style: GoogleFonts.poppins(
                            fontSize: 13, color: RampColors.mutedText)),
                  ),
                  InkWell(
                    onTap: () {
                      LocationPickerMapDialog.show(
                        context,
                        initialLocation:
                            unit.latitude != null && unit.longitude != null
                                ? LatLng(unit.latitude!, unit.longitude!)
                                : null,
                        initialAddress: unit.location,
                      );
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: RampColors.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.map_outlined,
                              size: 14, color: RampColors.primary),
                          SizedBox(width: 4),
                          Text(
                            'Map & Distance',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: RampColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                unit.detailsCompleted
                    ? '${_currencyFormat.format(unit.rent)} / mo'
                    : 'Additional details pending',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  color: RampColors.success,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 14),

              if (unit.isOccupied && isLeaseEndingSoon)
                Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: RampColors.warning.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: RampColors.warning.withValues(alpha: 0.5)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded, color: RampColors.warning),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Reminder: Lease ends in ${tenant.effectiveLeaseEnd.difference(DateTime.now()).inDays} days (${DateFormat('MMM dd, yyyy').format(tenant.effectiveLeaseEnd)}).',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: isDark ? Colors.orange[200] : Colors.orange[800],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              if (unit.isOccupied)
                CompactInfoGrid(
                  items: [
                    CompactInfoItem(
                      label: 'Tenant',
                      value: unit.tenantName ?? 'Vacant',
                      icon: Icons.person_outline_rounded,
                    ),
                    if (tenant != null)
                      CompactInfoItem(
                        label: 'Lease Start',
                        value: DateFormat('MMM dd, yyyy').format(tenant.effectiveLeaseStart),
                        icon: Icons.date_range_rounded,
                      ),
                  ],
                )
              else
                CompactInfoGrid(
                  items: [
                    CompactInfoItem(
                      label: 'Inclusions',
                      value: unit.inclusions.isNotEmpty ? unit.inclusions.join(', ') : 'None',
                      icon: Icons.wifi_rounded,
                    ),
                  ],
                ),

              if (!unit.isOccupied) ...[
                const SizedBox(height: 16),
                Text(
                  'Additional Details',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : RampColors.slate,
                  ),
                ),
                const SizedBox(height: 8),
                RampCard(
                  child: Row(
                    children: [
                      const Icon(Icons.square_foot_rounded, color: RampColors.primary),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Floor Area (SQM)',
                              style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold, fontSize: 13)),
                          Text('${unit.area.toStringAsFixed(1)} sqm',
                              style: GoogleFonts.poppins(
                                  fontSize: 12, color: RampColors.mutedText)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 16),
              RampCard(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Maintenance Areas (${unit.maintenanceAreas.length})',
                              style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13)),
                          const SizedBox(height: 4),
                          Text(unit.maintenanceAreas.join(', '),
                              style: GoogleFonts.poppins(fontSize: 12, color: RampColors.mutedText),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.edit_rounded, size: 14),
                      label: const FittedBox(fit: BoxFit.scaleDown, child: Text('EDIT AREAS', style: TextStyle(fontSize: 11))),
                      onPressed: () => _showManageUnitAreasModal(context, unit),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Utility Reading Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Utility Submeters',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : RampColors.slate,
                    ),
                  ),
                  Row(
                    children: [
                      if (unit.waterUtilityEnabled ||
                          unit.electricityUtilityEnabled)
                        TextButton.icon(
                          icon: const Icon(Icons.history_rounded, size: 18),
                          label: const Text('History'),
                          onPressed: () =>
                              _showUtilityHistoryModal(context, unit),
                        ),
                      if (unit.waterUtilityEnabled ||
                          unit.electricityUtilityEnabled)
                        IconButton(
                          icon: const Icon(Icons.edit_note,
                              color: RampColors.primary),
                          tooltip: 'Update Meters',
                          onPressed: () =>
                              _showUpdateMeterReadingModal(context, unit),
                        ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              RampCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Water Submeter
                    if (unit.waterUtilityEnabled) ...[
                      Row(
                        children: [
                          const CircleAvatar(
                            backgroundColor: Color(0x200284C7),
                            child: Icon(Icons.water_drop_rounded,
                                color: Color(0xFF0284C7)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Water Submeter',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: isDark
                                        ? Colors.white
                                        : RampColors.slate,
                                  ),
                                ),
                                Text(
                                  'Prev: ${unit.waterReadingPrev.toStringAsFixed(1)} m³ • Curr: ${unit.waterReadingCurr.toStringAsFixed(1)} m³',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: isDark
                                        ? const Color(0xFF94A3B8)
                                        : RampColors.mutedText,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            _currencyFormat.format(unit.waterUsage * waterRate),
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: const Color(0xFF0284C7),
                            ),
                          ),
                        ],
                      ),
                      Divider(
                          height: 24,
                          color: isDark
                              ? const Color(0xFF334155)
                              : RampColors.border),
                    ],

                    // Electricity Submeter
                    if (unit.electricityUtilityEnabled) ...[
                      Row(
                        children: [
                          const CircleAvatar(
                            backgroundColor: Color(0x20F59E0B),
                            child: Icon(Icons.bolt_rounded,
                                color: Color(0xFFF59E0B)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Electricity Submeter',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: isDark
                                        ? Colors.white
                                        : RampColors.slate,
                                  ),
                                ),
                                Text(
                                  'Prev: ${unit.electricReadingPrev.toStringAsFixed(0)} kWh • Curr: ${unit.electricReadingCurr.toStringAsFixed(0)} kWh',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: isDark
                                        ? const Color(0xFF94A3B8)
                                        : RampColors.mutedText,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            _currencyFormat
                                .format(unit.electricUsage * electricityRate),
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: const Color(0xFFF59E0B),
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (!unit.waterUtilityEnabled &&
                        !unit.electricityUtilityEnabled)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                            'Utility billing is not enabled for this unit.'),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Payment History Section
              Text(
                'Unit Financial History',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : RampColors.slate,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: ['All', 'Rent', 'Maintenance'].map((filter) {
                  final isSelected = _financialHistoryFilter == filter;
                  return ChoiceChip(
                    label: Text(
                      filter,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isSelected
                            ? Colors.white
                            : (isDark ? Colors.white : RampColors.slate),
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: RampColors.primary,
                    backgroundColor: isDark
                        ? Theme.of(context).colorScheme.surfaceContainerHighest
                        : RampColors.background,
                    onSelected: (_) =>
                        setState(() => _financialHistoryFilter = filter),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
              payments.isEmpty
                  ? RampEmptyState(
                      title: 'No $_financialHistoryFilter History',
                      description:
                          'There are no recorded ${_financialHistoryFilter.toLowerCase()} transactions for ${unit.name} yet.',
                      icon: Icons.history_toggle_off_rounded,
                    )
                  : Column(
                      children: List.generate(payments.length, (index) {
                        final p = payments[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: RampCard(
                            padding: const EdgeInsets.all(12),
                            child: ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: CircleAvatar(
                                backgroundColor: p.isMaintenance
                                    ? RampColors.warning.withValues(alpha: 0.14)
                                    : RampColors.successTint,
                                child: Icon(
                                  p.isMaintenance
                                      ? Icons.home_repair_service_rounded
                                      : Icons.check_circle_rounded,
                                  color: p.isMaintenance
                                      ? RampColors.warning
                                      : RampColors.success,
                                ),
                              ),
                              title: Text(
                                p.isMaintenance
                                    ? 'Maintenance Estimate'
                                    : '${p.month} Rent Payment',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                  color:
                                      isDark ? Colors.white : RampColors.slate,
                                ),
                              ),
                              subtitle: Text(
                                p.isMaintenance
                                    ? '${p.remarks ?? 'Repair estimate'}\nTicket: ${p.ticketId ?? 'Unlinked'} • ${DateFormat('MMM dd, yyyy').format(p.effectivePaymentDate)}'
                                    : 'Ref: ${p.referenceNumber} • ${DateFormat('MMM dd, yyyy').format(p.effectivePaymentDate)}',
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  color: isDark
                                      ? const Color(0xFF94A3B8)
                                      : RampColors.mutedText,
                                ),
                              ),
                              trailing: Text(
                                p.formattedAmount,
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                  color: p.isMaintenance
                                      ? RampColors.warning
                                      : RampColors.success,
                                  fontSize: 14,
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
    );
  }
}
