import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:latlong2/latlong.dart';
import '../core/widgets/location_picker_map.dart';
import '../providers/providers.dart';
import '../core/widgets/core_widgets.dart';
import '../core/navigation/custom_page_transitions.dart';
import '../core/theme/ramp_theme.dart';
import '../core/validation/app_validators.dart';
import 'unit_detail.dart';

class PropertiesScreen extends ConsumerStatefulWidget {
  const PropertiesScreen({super.key});

  @override
  ConsumerState<PropertiesScreen> createState() => _PropertiesScreenState();
}

class _PropertiesScreenState extends ConsumerState<PropertiesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  final List<String> _statusFilters = [
    'All',
    'Occupied',
    'Vacant',
    'Maintenance'
  ];
  RangeValues _priceRange = const RangeValues(5000, 20000);
  String _sortBy = 'default'; // 'default', 'rent_asc', 'rent_desc', 'name'

  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) setState(() => _isLoading = false);
    });
  }

  static final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'en_PH',
    symbol: '₱',
    decimalDigits: 2,
  );

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openUnitDetails(Unit unit) {
    Navigator.of(context, rootNavigator: true).push(
      SlideUpFadeRoute(page: UnitDetailScreen(unitId: unit.id)),
    );
  }

  void _showMasterUtilityRates() {
    final rates = ref.read(utilityRateProvider);
    final waterController =
        TextEditingController(text: rates.waterRate.toStringAsFixed(2));
    final electricityController =
        TextEditingController(text: rates.electricityRate.toStringAsFixed(2));
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Master Utility Rates'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
                'Units using the master rate update automatically. Individual overrides remain unchanged.'),
            const SizedBox(height: 16),
            RampTextField(
              controller: waterController,
              label: 'Water Rate (₱/m³)',
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 12),
            RampTextField(
              controller: electricityController,
              label: 'Electricity Rate (₱/kWh)',
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              final water = double.tryParse(waterController.text.trim());
              final electricity =
                  double.tryParse(electricityController.text.trim());
              if (water == null ||
                  water <= 0 ||
                  electricity == null ||
                  electricity <= 0) {
                return;
              }
              final notifier = ref.read(utilityRateProvider.notifier);
              notifier.updateRate(
                  utility: 'Water',
                  newRate: water,
                  note: 'Updated from Properties');
              notifier.updateRate(
                  utility: 'Electricity',
                  newRate: electricity,
                  note: 'Updated from Properties');
              Navigator.pop(dialogContext);
            },
            child: const Text('Update master rates'),
          ),
        ],
      ),
    ).whenComplete(() {
      waterController.dispose();
      electricityController.dispose();
    });
  }

  void _showFilterBottomSheet() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor:
          isDark ? Theme.of(context).colorScheme.surface : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          final activeFilter = ref.watch(unitFilterProvider);

          return Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.filter_list_rounded,
                            color: RampColors.primary),
                        const SizedBox(width: 8),
                        Text(
                          'Filter Properties',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : RampColors.slate,
                          ),
                        ),
                      ],
                    ),
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _priceRange = const RangeValues(5000, 20000);
                          _sortBy = 'default';
                          _searchQuery = '';
                          _searchController.clear();
                        });
                        ref.read(unitFilterProvider.notifier).state = 'All';
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.refresh_rounded,
                          color: RampColors.danger, size: 16),
                      label: Text(
                        'Reset All',
                        style: GoogleFonts.poppins(
                          color: RampColors.danger,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                Divider(
                    color:
                        isDark ? const Color(0xFF334155) : RampColors.border),
                const SizedBox(height: 12),

                // Status Filter
                Text(
                  'Status',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: isDark ? Colors.white : RampColors.slate,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: _statusFilters.map((filter) {
                    final isSelected =
                        activeFilter.toLowerCase() == filter.toLowerCase();
                    return ChoiceChip(
                      label: Text(
                        filter,
                        style: GoogleFonts.poppins(
                          color: isSelected
                              ? Colors.white
                              : (isDark ? Colors.white : RampColors.slate),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: RampColors.primary,
                      backgroundColor: isDark
                          ? Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest
                          : RampColors.background,
                      onSelected: (selected) {
                        if (selected) {
                          ref.read(unitFilterProvider.notifier).state = filter;
                          setModalState(() {});
                          setState(() {});
                        }
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                // Price Range Slider
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Monthly Rent Range',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: isDark ? Colors.white : RampColors.slate,
                      ),
                    ),
                    Text(
                      '${_currencyFormat.format(_priceRange.start)} - ${_currencyFormat.format(_priceRange.end)}',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        color: RampColors.primary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                RangeSlider(
                  values: _priceRange,
                  min: 5000,
                  max: 20000,
                  divisions: 30,
                  activeColor: RampColors.primary,
                  inactiveColor:
                      isDark ? const Color(0xFF334155) : Colors.grey[300],
                  labels: RangeLabels(
                    _currencyFormat.format(_priceRange.start),
                    _currencyFormat.format(_priceRange.end),
                  ),
                  onChanged: (values) {
                    setModalState(() => _priceRange = values);
                    setState(() => _priceRange = values);
                  },
                ),
                const SizedBox(height: 16),

                // Sort By
                Text(
                  'Sort By',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: isDark ? Colors.white : RampColors.slate,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: _sortBy,
                  dropdownColor: isDark
                      ? Theme.of(context).colorScheme.surface
                      : Colors.white,
                  style: GoogleFonts.poppins(
                    color: isDark ? Colors.white : RampColors.slate,
                    fontSize: 14,
                  ),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: isDark
                        ? Theme.of(context).colorScheme.surfaceContainerHighest
                        : Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: isDark
                            ? const Color(0xFF334155)
                            : RampColors.border,
                      ),
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: const [
                    DropdownMenuItem(
                        value: 'default', child: Text('Default Order')),
                    DropdownMenuItem(
                        value: 'rent_asc', child: Text('Rent: Low to High')),
                    DropdownMenuItem(
                        value: 'rent_desc', child: Text('Rent: High to Low')),
                    DropdownMenuItem(value: 'name', child: Text('Unit Name')),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setModalState(() => _sortBy = val);
                      setState(() => _sortBy = val);
                    }
                  },
                ),
                const SizedBox(height: 20),

                // Apply Button
                BouncePillButton(
                  text: 'APPLY FILTERS',
                  onPressed: () => Navigator.pop(context),
                  height: 48,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showAddEditDialog({Unit? existingUnit}) {
    final formKey = GlobalKey<FormState>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEditing = existingUnit != null;
    final nameCtrl = TextEditingController(text: existingUnit?.name ?? '');
    final locationCtrl =
        TextEditingController(text: existingUnit?.location ?? '');
    final rentCtrl =
        TextEditingController(text: existingUnit?.rent.toString() ?? '8500.00');
    final areaCtrl =
        TextEditingController(text: existingUnit?.area.toString() ?? '30.0');
    final dueDayCtrl = TextEditingController(
        text: (existingUnit?.rentDueDay ?? ref.read(dueDateDayProvider))
            .toString());
    final lateFeeCtrl = TextEditingController(
        text: (existingUnit?.lateFee ?? ref.read(lateFeeAmountProvider))
            .toString());
    final imageCtrl = TextEditingController(text: existingUnit?.imageUrl ?? '');
    final masterRates = ref.read(utilityRateProvider);
    final waterRateCtrl = TextEditingController(
        text: (existingUnit?.waterRateOverride ?? masterRates.waterRate)
            .toStringAsFixed(2));
    final electricityRateCtrl = TextEditingController(
        text: (existingUnit?.electricityRateOverride ??
                masterRates.electricityRate)
            .toStringAsFixed(2));
    bool waterEnabled = existingUnit?.waterUtilityEnabled ?? false;
    bool electricityEnabled = existingUnit?.electricityUtilityEnabled ?? false;
    bool useMasterWaterRate = existingUnit?.waterRateOverride == null;
    bool useMasterElectricityRate =
        existingUnit?.electricityRateOverride == null;
    XFile? selectedImage;
    String status = existingUnit?.status ?? 'Vacant';
    double? selectedLat = existingUnit?.latitude;
    double? selectedLng = existingUnit?.longitude;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor:
              isDark ? Theme.of(context).colorScheme.surface : Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            isEditing ? 'Add / Edit Unit Details' : 'Add Unit',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : RampColors.slate,
            ),
          ),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RampTextField(
                    controller: nameCtrl,
                    label: 'Unit Name',
                    hintText: 'e.g. Unit 6',
                    prefixIcon: const Icon(Icons.home_outlined,
                        color: RampColors.primary),
                    validator: (value) => AppValidators.requiredText(value,
                        label: 'a unit name', minLength: 2, maxLength: 40),
                  ),
                  const SizedBox(height: 12),
                  RampTextField(
                    controller: locationCtrl,
                    label: 'Location',
                    hintText: 'e.g. Pagsanjan Main Building, 2nd Floor',
                    prefixIcon: const Icon(Icons.location_on_outlined,
                        color: RampColors.primary),
                    validator: (value) => AppValidators.requiredText(value,
                        label: 'a unit location', minLength: 2, maxLength: 100),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () async {
                      final result = await LocationPickerMapDialog.show(
                        context,
                        initialLocation:
                            selectedLat != null && selectedLng != null
                                ? LatLng(selectedLat!, selectedLng!)
                                : null,
                        initialAddress: locationCtrl.text,
                      );
                      if (result != null) {
                        setState(() {
                          selectedLat = result.coordinates.latitude;
                          selectedLng = result.coordinates.longitude;
                          locationCtrl.text = result.formattedLocation;
                        });
                      }
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: RampColors.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: RampColors.primary.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.pin_drop_outlined,
                            size: 18,
                            color: RampColors.primary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              selectedLat != null && selectedLng != null
                                  ? 'GPS: ${selectedLat!.toStringAsFixed(4)}, ${selectedLng!.toStringAsFixed(4)}'
                                  : 'Pin Exact Location on Map',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: RampColors.primary,
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.chevron_right,
                            size: 16,
                            color: RampColors.primary,
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (isEditing) ...[
                    const SizedBox(height: 12),
                    RampTextField(
                      controller: rentCtrl,
                      label: 'Monthly Rent (₱)',
                      hintText: '8500.00',
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      prefixIcon: const Icon(Icons.payments_outlined,
                          color: RampColors.primary),
                      validator: (value) =>
                          AppValidators.amount(value, label: 'monthly rent'),
                    ),
                    const SizedBox(height: 12),
                    RampTextField(
                      controller: areaCtrl,
                      label: 'Area (sqm)',
                      hintText: '30.0',
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      prefixIcon: const Icon(Icons.aspect_ratio_outlined,
                          color: RampColors.primary),
                      validator: (value) => AppValidators.amount(value,
                          label: 'floor area', maximum: 10000),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: RampTextField(
                            controller: dueDayCtrl,
                            label: 'Rent Due Day (1-31)',
                            keyboardType: TextInputType.number,
                            prefixIcon: const Icon(Icons.event_note_outlined,
                                color: RampColors.primary),
                            validator: (value) => AppValidators.wholeNumber(
                                value,
                                label: 'rent due day',
                                minimum: 1,
                                maximum: 31),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: RampTextField(
                            controller: lateFeeCtrl,
                            label: 'Late Fee (₱, 0 allowed)',
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            prefixIcon: const Icon(
                                Icons.money_off_csred_outlined,
                                color: RampColors.primary),
                            validator: (value) => AppValidators.amount(value,
                                label: 'late fee', allowZero: true),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    RampTextField(
                      controller: imageCtrl,
                      label: 'Unit Image URL',
                      hintText: 'https://...',
                      prefixIcon: const Icon(Icons.image_outlined,
                          color: RampColors.primary),
                      validator: AppValidators.url,
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final picked = await ImagePicker().pickImage(
                            source: ImageSource.gallery,
                            maxWidth: 1400,
                            maxHeight: 1000,
                            imageQuality: 82,
                          );
                          if (picked != null) {
                            setState(() => selectedImage = picked);
                          }
                        },
                        icon: const Icon(Icons.attach_file_rounded),
                        label: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(selectedImage == null
                              ? 'Attach unit image'
                              : 'Change attached image'),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Status',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : RampColors.slate,
                          ),
                        ),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<String>(
                          initialValue: status,
                          dropdownColor: isDark
                              ? Theme.of(context).colorScheme.surface
                              : Colors.white,
                          style: GoogleFonts.poppins(
                            color: isDark ? Colors.white : RampColors.slate,
                            fontSize: 14,
                          ),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: isDark
                                ? Theme.of(context)
                                    .colorScheme
                                    .surfaceContainerHighest
                                : RampColors.surface,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: isDark
                                    ? const Color(0xFF334155)
                                    : RampColors.border,
                              ),
                            ),
                          ),
                          items:
                              ['Vacant', 'Occupied', 'Maintenance'].map((val) {
                            return DropdownMenuItem(
                                value: val, child: Text(val));
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => status = val);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      value: waterEnabled,
                      title: const Text('Bill water utility for this unit'),
                      subtitle: const Text('Enable water readings and charges'),
                      onChanged: (value) =>
                          setState(() => waterEnabled = value ?? false),
                    ),
                    if (waterEnabled) ...[
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        value: useMasterWaterRate,
                        title: Text(
                            'Use master water rate (₱${masterRates.waterRate.toStringAsFixed(2)}/m³)'),
                        onChanged: (value) =>
                            setState(() => useMasterWaterRate = value),
                      ),
                      if (!useMasterWaterRate)
                        RampTextField(
                          controller: waterRateCtrl,
                          label: 'Unit Water Rate (₱/m³)',
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          validator: (value) =>
                              AppValidators.amount(value, label: 'water rate'),
                        ),
                    ],
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      value: electricityEnabled,
                      title:
                          const Text('Bill electricity utility for this unit'),
                      subtitle:
                          const Text('Enable electricity readings and charges'),
                      onChanged: (value) =>
                          setState(() => electricityEnabled = value ?? false),
                    ),
                    if (electricityEnabled) ...[
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        value: useMasterElectricityRate,
                        title: Text(
                            'Use master electricity rate (₱${masterRates.electricityRate.toStringAsFixed(2)}/kWh)'),
                        onChanged: (value) =>
                            setState(() => useMasterElectricityRate = value),
                      ),
                      if (!useMasterElectricityRate)
                        RampTextField(
                          controller: electricityRateCtrl,
                          label: 'Unit Electricity Rate (₱/kWh)',
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          validator: (value) => AppValidators.amount(value,
                              label: 'electricity rate'),
                        ),
                    ],
                  ],
                ],
              ),
            ),
          ),
          actions: [
            TextButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close_rounded, size: 16),
              label: Text(
                'CANCEL',
                style: GoogleFonts.poppins(color: RampColors.mutedText),
              ),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: RampColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.save_rounded, size: 16),
              onPressed: () {
                if (!(formKey.currentState?.validate() ?? false)) return;
                final name = nameCtrl.text.trim();
                final rent = double.tryParse(rentCtrl.text.trim());
                final area = double.tryParse(areaCtrl.text.trim());
                final dueDay = int.tryParse(dueDayCtrl.text.trim());
                final lateFee = double.tryParse(lateFeeCtrl.text.trim());
                final duplicateName = ref.read(unitProvider).any((unit) =>
                    unit.id != existingUnit?.id &&
                    unit.name.trim().toLowerCase() == name.toLowerCase());
                if (duplicateName) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('A unit with this name already exists.'),
                      backgroundColor: RampColors.danger,
                    ),
                  );
                  return;
                }
                final imageUrl = selectedImage?.path ??
                    (imageCtrl.text.trim().isEmpty
                        ? existingUnit?.imageUrl
                        : imageCtrl.text.trim());
                final waterOverride = waterEnabled && !useMasterWaterRate
                    ? double.tryParse(waterRateCtrl.text.trim())
                    : null;
                final electricityOverride =
                    electricityEnabled && !useMasterElectricityRate
                        ? double.tryParse(electricityRateCtrl.text.trim())
                        : null;
                final newUnit = isEditing
                    ? existingUnit.copyWith(
                        name: name,
                        title: name,
                        unitNumber: name,
                        location: locationCtrl.text.trim(),
                        latitude: selectedLat,
                        longitude: selectedLng,
                        rent: rent ?? 8500.0,
                        monthlyRent: rent ?? 8500.0,
                        area: area ?? 28.0,
                        areaSqm: area ?? 28.0,
                        status: status,
                        imageUrl: imageUrl,
                        rentDueDay: dueDay ?? 5,
                        lateFee: lateFee ?? 500.0,
                        vacantDays:
                            status == 'Vacant' ? existingUnit.vacantDays : 0,
                        detailsCompleted: true,
                        waterUtilityEnabled: waterEnabled,
                        electricityUtilityEnabled: electricityEnabled,
                        waterRateOverride: (!waterEnabled || useMasterWaterRate)
                            ? null
                            : waterOverride,
                        electricityRateOverride:
                            (!electricityEnabled || useMasterElectricityRate)
                                ? null
                                : electricityOverride,
                      )
                    : Unit(
                        id: 'u_${DateTime.now().millisecondsSinceEpoch}',
                        name: name,
                        location: locationCtrl.text.trim(),
                        latitude: selectedLat,
                        longitude: selectedLng,
                        rent: rent ?? 8500.0,
                        monthlyRent: rent ?? 8500.0,
                        area: area ?? 28.0,
                        areaSqm: area ?? 28.0,
                        status: status,
                        imageUrl: imageUrl,
                        rentDueDay: dueDay ?? 5,
                        lateFee: lateFee ?? 500.0,
                        vacantDays: 0,
                        inclusions: const [],
                        detailsCompleted: true,
                        waterUtilityEnabled: waterEnabled,
                        electricityUtilityEnabled: electricityEnabled,
                        waterRateOverride: (!waterEnabled || useMasterWaterRate)
                            ? null
                            : waterOverride,
                        electricityRateOverride: (!electricityEnabled || useMasterElectricityRate)
                            ? null
                            : electricityOverride,
                      );

                if (isEditing) {
                  ref.read(unitProvider.notifier).updateUnit(newUnit);
                } else {
                  ref.read(unitProvider.notifier).addUnit(newUnit);
                }
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(isEditing
                        ? 'Unit details updated!'
                        : 'New unit created successfully.'),
                    backgroundColor: RampColors.success,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              label: Text(isEditing ? 'SAVE DETAILS' : 'SAVE UNIT',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(Unit unit) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor:
            isDark ? Theme.of(context).colorScheme.surface : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Delete Property',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : RampColors.slate,
          ),
        ),
        content: Text(
          'Are you sure you want to delete ${unit.name}? This action cannot be undone.',
          style: GoogleFonts.poppins(
            color: isDark ? const Color(0xFF94A3B8) : RampColors.mutedText,
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close_rounded, size: 16),
            label: Text('CANCEL',
                style: GoogleFonts.poppins(color: RampColors.mutedText)),
          ),
          TextButton.icon(
            onPressed: () {
              ref.read(unitProvider.notifier).deleteUnit(unit.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Property deleted'),
                  backgroundColor: RampColors.danger,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            icon: const Icon(Icons.delete_rounded,
                color: RampColors.danger, size: 16),
            label: Text('DELETE',
                style: GoogleFonts.poppins(
                    color: RampColors.danger, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final allUnits = ref.watch(unitProvider);
    final tenants = ref.watch(tenantProvider);
    final activeFilter = ref.watch(unitFilterProvider);

    List<Unit> displayUnits = allUnits;

    if (activeFilter != 'All') {
      displayUnits = allUnits
          .where((u) => u.status.toLowerCase() == activeFilter.toLowerCase())
          .toList();
    }

    // Apply Price Range Filter
    displayUnits = displayUnits.where((u) {
      return !u.detailsCompleted ||
          (u.rent >= _priceRange.start && u.rent <= _priceRange.end);
    }).toList();

    // Apply Search Query
    if (_searchQuery.isNotEmpty) {
      displayUnits = displayUnits.where((u) {
        final query = _searchQuery.toLowerCase();
        final tenant = tenants.where((t) => t.unitId == u.id).firstOrNull;
        final tenantName = u.tenantName ?? tenant?.name ?? '';

        return u.name.toLowerCase().contains(query) ||
            u.location.toLowerCase().contains(query) ||
            tenantName.toLowerCase().contains(query) ||
            u.status.toLowerCase().contains(query) ||
            u.inclusions.any((i) => i.toLowerCase().contains(query));
      }).toList();
    }

    // Apply Sorting
    displayUnits = List.from(displayUnits);
    if (_sortBy == 'rent_asc') {
      displayUnits.sort((a, b) => a.rent.compareTo(b.rent));
    } else if (_sortBy == 'rent_desc') {
      displayUnits.sort((a, b) => b.rent.compareTo(a.rent));
    } else if (_sortBy == 'name') {
      displayUnits.sort((a, b) => a.name.compareTo(b.name));
    }

    final occupiedCount = allUnits.where((u) => u.isOccupied).length;
    final vacantCount = allUnits.where((u) => u.isVacant).length;
    final maintenanceCount = allUnits.where((u) => u.isMaintenance).length;

    return Scaffold(
      backgroundColor: isDark
          ? Theme.of(context).scaffoldBackgroundColor
          : RampColors.background,
      appBar: AppBar(
        title: Text(
          'Properties',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : RampColors.slate,
          ),
        ),
        backgroundColor:
            isDark ? Theme.of(context).scaffoldBackgroundColor : Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.water_drop_outlined,
                color: RampColors.primary),
            tooltip: 'Master utility rates',
            onPressed: _showMasterUtilityRates,
          ),
          IconButton(
            icon: const Icon(Icons.filter_list, color: RampColors.primary),
            tooltip: 'Sort properties',
            onPressed: _showFilterBottomSheet,
          ),
        ],
      ),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: RefreshIndicator(
              onRefresh: () async {
                setState(() {
                  _hasError = false;
                  _isLoading = true;
                });
                await Future<void>.delayed(const Duration(milliseconds: 500));
                if (mounted) setState(() => _isLoading = false);
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                padding: const EdgeInsets.only(
                    left: 16.0, right: 16.0, top: 12.0, bottom: 100.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _searchController,
                      style: GoogleFonts.poppins(
                        color: isDark ? Colors.white : RampColors.slate,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Search unit, tenant, status, or inclusion',
                        prefixIcon: const Icon(
                          Icons.search_rounded,
                          color: RampColors.primary,
                        ),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                tooltip: 'Clear search',
                                icon: const Icon(Icons.clear_rounded, size: 18),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _searchQuery = '');
                                },
                              )
                            : null,
                      ),
                      onChanged: (value) =>
                          setState(() => _searchQuery = value),
                    ),
                    const SizedBox(height: 16),
                    // Status Filter Chips
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: _statusFilters.map((filter) {
                          final isSelected = activeFilter.toLowerCase() ==
                              filter.toLowerCase();
                          int count = allUnits.length;
                          if (filter == 'Occupied') count = occupiedCount;
                          if (filter == 'Vacant') count = vacantCount;
                          if (filter == 'Maintenance') {
                            count = maintenanceCount;
                          }

                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: FilterChip(
                              visualDensity: VisualDensity.compact,
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              label: Text(
                                '$filter ($count)',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: isSelected
                                          ? Theme.of(context)
                                              .colorScheme
                                              .onPrimary
                                          : Theme.of(context)
                                              .colorScheme
                                              .onSurface,
                                    ),
                              ),
                              selected: isSelected,
                              onSelected: (_) {
                                ref.read(unitFilterProvider.notifier).state =
                                    filter;
                              },
                              selectedColor:
                                  Theme.of(context).colorScheme.primary,
                              backgroundColor:
                                  Theme.of(context).colorScheme.surface,
                              checkmarkColor:
                                  Theme.of(context).colorScheme.onPrimary,
                              side: BorderSide(
                                color: Theme.of(context)
                                    .colorScheme
                                    .outlineVariant,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '${displayUnits.length} ${displayUnits.length == 1 ? 'property' : 'properties'}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 16),

                    // Property Units List, Shimmer Loading, Error, or Empty State
                    if (_isLoading)
                      const ShimmerList(
                          itemCount: 5, height: 110, padding: EdgeInsets.zero)
                    else if (_hasError)
                      ErrorStateWidget(
                        message:
                            'Failed to load property units data. Please try again.',
                        onRetry: () {
                          setState(() {
                            _hasError = false;
                            _isLoading = true;
                          });
                          Future.delayed(const Duration(milliseconds: 600), () {
                            if (mounted) setState(() => _isLoading = false);
                          });
                        },
                      )
                    else if (displayUnits.isEmpty)
                      EmptyStateWidget(
                        title: _searchQuery.isNotEmpty || activeFilter != 'All'
                            ? 'No Properties Match Filters'
                            : 'No Property Units Available',
                        message:
                            'Try adjusting your search keywords or reset the filters to view your units.',
                        icon: Icons.apartment_rounded,
                        buttonText:
                            _searchQuery.isNotEmpty || activeFilter != 'All'
                                ? 'Reset Filters'
                                : 'Add Unit',
                        buttonIcon:
                            _searchQuery.isNotEmpty || activeFilter != 'All'
                                ? Icons.refresh_rounded
                                : Icons.add_rounded,
                        onButtonPressed: () {
                          if (_searchQuery.isNotEmpty ||
                              activeFilter != 'All') {
                            setState(() {
                              _searchQuery = '';
                              _searchController.clear();
                              _priceRange = const RangeValues(5000, 20000);
                            });
                            ref.read(unitFilterProvider.notifier).state = 'All';
                          } else {
                            _showAddEditDialog();
                          }
                        },
                      )
                    else
                      Column(
                        children: List.generate(displayUnits.length, (index) {
                          final unit = displayUnits[index];
                          final tenant = tenants
                              .where((t) => t.unitId == unit.id)
                              .firstOrNull;

                          return StaggeredListItem(
                            index: index,
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: _PropertyUnitCard(
                                unit: unit,
                                tenant: tenant,
                                onTap: () => _openUnitDetails(unit),
                                onEdit: () =>
                                    _showAddEditDialog(existingUnit: unit),
                                onDelete: () => _showDeleteConfirmation(unit),
                              ),
                            ),
                          );
                        }),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton.extended(
        heroTag: null,
        onPressed: () => _showAddEditDialog(),
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Add Unit',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class _PropertyUnitCard extends StatefulWidget {
  final Unit unit;
  final Tenant? tenant;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _PropertyUnitCard({
    Key? key,
    required this.unit,
    this.tenant,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  State<_PropertyUnitCard> createState() => _PropertyUnitCardState();
}

class _PropertyUnitCardState extends State<_PropertyUnitCard> {
  bool _isExpanded = false;

  final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'en_PH',
    symbol: '₱',
    decimalDigits: 0,
  );

  Widget _buildFullUnitImage(String path, {double height = 160}) {
    final fallback = Container(
      height: height,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1E293B), Color(0xFF334155)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.apartment_rounded, color: Colors.white70, size: 48),
          SizedBox(height: 6),
          Text(
            'RAMP Property Unit',
            style: TextStyle(color: Colors.white54, fontSize: 12),
          ),
        ],
      ),
    );

    if (path.isEmpty) return fallback;

    if (path.startsWith('/') || path.contains(':\\')) {
      final file = File(path);
      if (!file.existsSync()) return fallback;
      return Image.file(
        file,
        width: double.infinity,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => fallback,
      );
    } else if (path.startsWith('http://') || path.startsWith('https://')) {
      return Image.network(
        path,
        width: double.infinity,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => fallback,
      );
    } else if (path.startsWith('assets/')) {
      return Image.asset(
        path,
        width: double.infinity,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => fallback,
      );
    }

    return fallback;
  }

  Widget _buildTenantAvatar(Tenant? tenant, String name) {
    final avatarUrl = tenant?.avatarUrl;
    if (avatarUrl != null && avatarUrl.isNotEmpty) {
      ImageProvider? provider;
      if (avatarUrl.startsWith('http')) {
        provider = NetworkImage(avatarUrl);
      } else if (File(avatarUrl).existsSync()) {
        provider = FileImage(File(avatarUrl));
      }
      if (provider != null) {
        return CircleAvatar(
          radius: 20,
          backgroundImage: provider,
        );
      }
    }
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'T';
    return CircleAvatar(
      radius: 20,
      backgroundColor: RampColors.primary.withValues(alpha: 0.15),
      child: Text(
        initial,
        style: const TextStyle(
          color: RampColors.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    final s = status.toLowerCase();
    if (s == 'occupied') return RampColors.primary;
    if (s == 'maintenance') return RampColors.warning;
    return RampColors.success;
  }

  IconData _getStatusIcon(String status) {
    final s = status.toLowerCase();
    if (s == 'occupied') return Icons.person_rounded;
    if (s == 'maintenance') return Icons.engineering_rounded;
    return Icons.meeting_room_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final unit = widget.unit;
    final tenant = widget.tenant;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final statusColor = _getStatusColor(unit.status);
    final statusIcon = _getStatusIcon(unit.status);

    final unitNumDisplay = (unit.unitNumber != null && unit.unitNumber!.isNotEmpty)
        ? unit.unitNumber!
        : (unit.name.toLowerCase().contains('unit')
            ? unit.name
            : 'Unit ${unit.name}');

    return Container(
      decoration: BoxDecoration(
        color: isDark ? Theme.of(context).colorScheme.surface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Full Image Header with Top-Left Unit Number & Top-Right Status Indication
            Stack(
              children: [
                _buildFullUnitImage(unit.imageUrl ?? '', height: 160),

                // Subtle bottom gradient overlay on image for contrast
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.4),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ),

                // Top Left: Unit / Room Indication Pill Badge
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.75),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white24, width: 1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.meeting_room_outlined,
                          color: Colors.white,
                          size: 14,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          unitNumDisplay,
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Top Right: Room Status Indication Badge
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: statusColor.withValues(alpha: 0.4),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(statusIcon, color: Colors.white, size: 14),
                        const SizedBox(width: 5),
                        Text(
                          unit.isVacant && unit.vacantDays > 0
                              ? 'Vacant (${unit.vacantDays}d)'
                              : unit.status,
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // 2. Card Body Content Below Image
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title, Location, and Options Menu
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              unit.name,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on_outlined,
                                  size: 13,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                                const SizedBox(width: 3),
                                Expanded(
                                  child: Text(
                                    '${unit.floor} • ${unit.location}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurfaceVariant,
                                          fontSize: 12,
                                        ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      PopupMenuButton<String>(
                        icon: Icon(
                          Icons.more_vert_rounded,
                          size: 20,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        onSelected: (val) {
                          if (val == 'edit') {
                            widget.onEdit();
                          } else if (val == 'delete') {
                            widget.onDelete();
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit_rounded, size: 18),
                                SizedBox(width: 8),
                                Text('Add / Edit Details'),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete_rounded,
                                    size: 18,
                                    color: Theme.of(context).colorScheme.error),
                                const SizedBox(width: 8),
                                Text('Delete',
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .error)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Summary Bar with Interactive Dropdown Toggle Button
                  InkWell(
                    onTap: () {
                      setState(() {
                        _isExpanded = !_isExpanded;
                      });
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Theme.of(context).colorScheme.surfaceContainerHigh
                            : RampColors.softBlueTint.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.payments_outlined,
                                size: 16,
                                color: RampColors.primary,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _currencyFormat.format(unit.rent),
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: RampColors.primary,
                                ),
                              ),
                              Text(
                                ' / mo',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      fontSize: 11,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                    ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Text(
                                _isExpanded ? 'Hide Specs' : 'Show Details',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                _isExpanded
                                    ? Icons.keyboard_arrow_up_rounded
                                    : Icons.keyboard_arrow_down_rounded,
                                size: 18,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 3. Dropdown Expandable Data Section
                  AnimatedCrossFade(
                    firstChild:
                        const SizedBox(width: double.infinity, height: 0),
                    secondChild: Padding(
                      padding: const EdgeInsets.only(top: 12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Divider(height: 1),
                          const SizedBox(height: 12),

                          // STATUS CONDITION 1: VACANT
                          if (unit.isVacant) ...[
                            Row(
                              children: [
                                Expanded(
                                  child: _buildInfoSpecTile(
                                    context,
                                    icon: Icons.payments_outlined,
                                    label: 'Monthly Rent',
                                    value: _currencyFormat.format(unit.rent),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _buildInfoSpecTile(
                                    context,
                                    icon: Icons.aspect_ratio_outlined,
                                    label: 'Area Size',
                                    value: '${unit.area.toStringAsFixed(0)} sqm',
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Inclusions:',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                            ),
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: unit.inclusions.map((inclusion) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .surfaceContainerHigh,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        _getInclusionIcon(inclusion),
                                        size: 12,
                                        color: RampColors.primary,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        inclusion,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w500,
                                            ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                            if (unit.isLongVacant) ...[
                              const SizedBox(height: 10),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .errorContainer,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'Attention: Vacant for ${unit.vacantDays} days',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        fontSize: 11,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onErrorContainer,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ),
                            ],
                          ]

                          // STATUS CONDITION 2: OCCUPIED
                          else if (unit.isOccupied) ...[
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Theme.of(context)
                                        .colorScheme
                                        .surfaceContainerHigh
                                    : RampColors.softBlueTint
                                        .withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: RampColors.primary
                                      .withValues(alpha: 0.15),
                                ),
                              ),
                              child: Row(
                                children: [
                                  _buildTenantAvatar(
                                    tenant,
                                    unit.tenantName ??
                                        tenant?.name ??
                                        'Tenant',
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          unit.tenantName ??
                                              tenant?.name ??
                                              'Assigned Tenant',
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          tenant?.phone.isNotEmpty == true
                                              ? tenant!.phone
                                              : (tenant?.email.isNotEmpty ==
                                                      true
                                                  ? tenant!.email
                                                  : 'Active Lease'),
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                fontSize: 11,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onSurfaceVariant,
                                              ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color:
                                          (tenant != null && tenant.balance > 0)
                                              ? Theme.of(context)
                                                  .colorScheme
                                                  .errorContainer
                                              : RampColors.success
                                                  .withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      tenant != null && tenant.balance > 0
                                          ? '₱${tenant.balance.toStringAsFixed(0)} Due'
                                          : 'Rent Clear',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color:
                                            tenant != null && tenant.balance > 0
                                                ? Theme.of(context)
                                                    .colorScheme
                                                    .onErrorContainer
                                                : RampColors.success,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      Icon(Icons.calendar_today_rounded,
                                          size: 13,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurfaceVariant),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          'Due: ${unit.formattedRentDueDay}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(fontSize: 11),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Row(
                                    children: [
                                      Icon(Icons.aspect_ratio_outlined,
                                          size: 13,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurfaceVariant),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          'Area: ${unit.area.toStringAsFixed(0)} sqm',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(fontSize: 11),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ]

                          // STATUS CONDITION 3: MAINTENANCE
                          else ...[
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: RampColors.warning.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color:
                                      RampColors.warning.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.engineering_rounded,
                                    color: RampColors.warning,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Under Maintenance',
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                            color: RampColors.warning,
                                          ),
                                        ),
                                        Text(
                                          'Areas: ${unit.maintenanceAreas.join(", ")}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                fontSize: 11,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Rent: ${_currencyFormat.format(unit.rent)}/mo',
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    'Area: ${unit.area.toStringAsFixed(0)} sqm',
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    crossFadeState: _isExpanded
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                    duration: const Duration(milliseconds: 250),
                  ),

                  const SizedBox(height: 12),

                  // Bottom Action Button
                  InkWell(
                    onTap: widget.onTap,
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Manage Unit & Utility Details',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.arrow_forward_rounded,
                            size: 14,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSpecTile(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: RampColors.primary),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: 10,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getInclusionIcon(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('water')) return Icons.water_drop_outlined;
    if (lower.contains('electric')) return Icons.bolt_outlined;
    if (lower.contains('wifi') || lower.contains('internet'))
      return Icons.wifi_rounded;
    if (lower.contains('aircon') || lower.contains('ac'))
      return Icons.ac_unit_rounded;
    if (lower.contains('parking')) return Icons.local_parking_rounded;
    if (lower.contains('kitchen')) return Icons.kitchen_rounded;
    return Icons.check_circle_outline_rounded;
  }
}

typedef UnitsScreen = PropertiesScreen;
