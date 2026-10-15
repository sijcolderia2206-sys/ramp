// lib/screens/landlord/add_unit_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../widgets/dashed_border_container.dart';
import '../../models/unit_model.dart';
import '../../core/db_result.dart';
import '../../providers/landlord_providers.dart';
import '../../providers/tenant_providers.dart';
import '../../core/validators.dart';

// =============================================================================
// 1. RIVERPOD STATE MANAGEMENT PROVIDERS
// =============================================================================

/// Global FormKey Provider
final addUnitFormKeyProvider = Provider<GlobalKey<FormState>>((ref) {
  return GlobalKey<FormState>();
});

/// Wizard Step State Provider (0: Identity, 1: Financials & Utilities, 2: Media & Inclusions)
final currentWizardStepProvider = StateProvider<int>((ref) => 0);

/// Property Selection State Providers
final selectedPropertyTypeProvider = StateProvider<String>((ref) => 'Apartment');
final selectedFurnishingStatusProvider = StateProvider<String>((ref) => 'Unfurnished');
final advanceRentMonthsProvider = StateProvider<int>((ref) => 1);
final minimumLeaseMonthsProvider = StateProvider<int>((ref) => 12);

/// Unit Inclusions Provider
class InclusionsNotifier extends StateNotifier<Set<String>> {
  InclusionsNotifier()
      : super({
          'Air Conditioning',
          'Refrigerator',
          'Bed Frame',
        });

  void toggleInclusion(String inclusion) {
    final updated = Set<String>.from(state);
    if (updated.contains(inclusion)) {
      updated.remove(inclusion);
    } else {
      updated.add(inclusion);
    }
    state = updated;
  }
}

final inclusionsProvider = StateNotifierProvider<InclusionsNotifier, Set<String>>((ref) {
  return InclusionsNotifier();
});

/// Maintenance Areas Provider: Manages list of available maintenance chips.
class MaintenanceAreasNotifier extends StateNotifier<List<String>> {
  MaintenanceAreasNotifier()
      : super([
          'Bathroom',
          'Bedroom',
          'Kitchen',
          'Living Area',
          'Balcony',
          'Outdoor Area',
        ]);

  void addArea(String area) {
    final trimmed = area.trim();
    if (trimmed.isNotEmpty && !state.contains(trimmed)) {
      state = [...state, trimmed];
    }
  }
}

final maintenanceAreasProvider =
    StateNotifierProvider<MaintenanceAreasNotifier, List<String>>((ref) {
  return MaintenanceAreasNotifier();
});

/// Selected Areas Provider: Tracks which maintenance chips are currently toggled ON.
class SelectedAreasNotifier extends StateNotifier<Set<String>> {
  SelectedAreasNotifier()
      : super({
          'Bathroom',
          'Bedroom',
          'Kitchen',
          'Living Area',
        });

  void toggleArea(String area) {
    final updated = Set<String>.from(state);
    if (updated.contains(area)) {
      updated.remove(area);
    } else {
      updated.add(area);
    }
    state = updated;
  }

  void selectArea(String area) {
    state = {...state, area};
  }

  void setAllAreas(Set<String> areas) {
    state = areas;
  }
}

final selectedAreasProvider =
    StateNotifierProvider<SelectedAreasNotifier, Set<String>>((ref) {
  return SelectedAreasNotifier();
});

/// Gallery Images Provider: Tracks uploaded photos (Max 10).
class GalleryImagesNotifier extends StateNotifier<List<File>> {
  GalleryImagesNotifier() : super([]);

  void addImages(List<File> files) {
    final spaceLeft = 10 - state.length;
    if (spaceLeft > 0) {
      final toAdd = files.take(spaceLeft).toList();
      state = [...state, ...toAdd];
    }
  }

  void removeImage(int index) {
    if (index >= 0 && index < state.length) {
      final updated = List<File>.from(state)..removeAt(index);
      state = updated;
    }
  }

  void clear() {
    state = [];
  }
}

final galleryImagesProvider =
    StateNotifierProvider<GalleryImagesNotifier, List<File>>((ref) {
  return GalleryImagesNotifier();
});

/// Loading State Provider
final addUnitLoadingProvider = StateProvider<bool>((ref) => false);

/// Counter Selection State Providers
final bedroomsCountProvider = StateProvider<int>((ref) => 1);
final bathroomsCountProvider = StateProvider<int>((ref) => 1);
final rentDueDayValueProvider = StateProvider<int>((ref) => 5);

// =============================================================================
// 2. REUSABLE NEUMORPHIC (SOFT UI) COMPONENTS
// =============================================================================

class NeumorphicStyle {
  static const Color baseColor = Color(0xFFE0E5EC);
  static const Color darkShadow = Color(0xFFA3B1C6);
  static const Color lightShadow = Colors.white;
  static const Color primaryBlue = Color(0xFF0052CC);
  static const Color textDark = Color(0xFF0F172A);
  static const Color textMuted = Color(0xFF64748B);

  static BoxDecoration convex({double borderRadius = 16.0}) {
    return BoxDecoration(
      color: baseColor,
      borderRadius: BorderRadius.circular(borderRadius),
      boxShadow: const [
        BoxShadow(
          color: lightShadow,
          offset: Offset(-4, -4),
          blurRadius: 8,
        ),
        BoxShadow(
          color: darkShadow,
          offset: Offset(4, 4),
          blurRadius: 8,
        ),
      ],
    );
  }

  static BoxDecoration inset({double borderRadius = 14.0}) {
    return BoxDecoration(
      color: baseColor,
      borderRadius: BorderRadius.circular(borderRadius),
      boxShadow: const [
        BoxShadow(
          color: darkShadow,
          offset: Offset(2, 2),
          blurRadius: 4,
          spreadRadius: 1,
        ),
        BoxShadow(
          color: lightShadow,
          offset: Offset(-2, -2),
          blurRadius: 4,
          spreadRadius: 1,
        ),
      ],
    );
  }
}

class _NeumorphicConvexCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _NeumorphicConvexCard({
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24.0),
      padding: const EdgeInsets.all(20.0),
      decoration: NeumorphicStyle.convex(borderRadius: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: NeumorphicStyle.textDark,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _NeumorphicInsetInput extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? hintText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final Widget? prefix;
  final Widget? suffix;
  final bool isRequired;
  final ValueChanged<String>? onChanged;

  const _NeumorphicInsetInput({
    required this.label,
    required this.controller,
    this.hintText,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.prefix,
    this.suffix,
    this.isRequired = false,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return FormField<String>(
      validator: (stateVal) {
        final val = controller.text;
        return validator?.call(val);
      },
      initialValue: controller.text,
      builder: (formFieldState) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 6),
              child: Row(
                children: [
                  Flexible(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: NeumorphicStyle.textDark,
                      ),
                    ),
                  ),
                  if (isRequired)
                    const Text(
                      ' *',
                      style: TextStyle(
                        color: Color(0xFFDC2626),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            ),
            Container(
              decoration: NeumorphicStyle.inset(borderRadius: 14.0),
              padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 2.0),
              child: Row(
                children: [
                  if (prefix != null) ...[
                    prefix!,
                    const SizedBox(width: 8),
                  ],
                  Expanded(
                    child: TextFormField(
                      controller: controller,
                      keyboardType: keyboardType,
                      style: const TextStyle(
                        fontSize: 14,
                        color: NeumorphicStyle.textDark,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: InputDecoration(
                        hintText: hintText,
                        hintStyle: const TextStyle(
                          color: NeumorphicStyle.textMuted,
                          fontSize: 13,
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        focusedErrorBorder: InputBorder.none,
                        fillColor: Colors.transparent,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onChanged: (val) {
                        formFieldState.didChange(val);
                        if (onChanged != null) onChanged!(val);
                      },
                    ),
                  ),
                  if (suffix != null) suffix!,
                ],
              ),
            ),
            if (formFieldState.hasError)
              Padding(
                padding: const EdgeInsets.only(left: 8, top: 4),
                child: Text(
                  formFieldState.errorText ?? '',
                  style: const TextStyle(
                    color: Color(0xFFDC2626),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _NeumorphicInsetDropdown<T> extends StatelessWidget {
  final String label;
  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  const _NeumorphicInsetDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: NeumorphicStyle.textDark,
            ),
          ),
        ),
        Container(
          decoration: NeumorphicStyle.inset(borderRadius: 14.0),
          padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 2.0),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              items: items,
              onChanged: onChanged,
              isExpanded: true,
              dropdownColor: NeumorphicStyle.baseColor,
              icon: const Icon(Icons.arrow_drop_down, color: NeumorphicStyle.primaryBlue),
              style: const TextStyle(
                fontSize: 14,
                color: NeumorphicStyle.textDark,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _NeumorphicChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NeumorphicChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
        decoration: isSelected
            ? NeumorphicStyle.inset(borderRadius: 18.0)
            : NeumorphicStyle.convex(borderRadius: 18.0),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? NeumorphicStyle.primaryBlue : NeumorphicStyle.textMuted,
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// 3. MAIN SCREEN WIDGET WITH 3-STEP GUIDED WIZARD
// =============================================================================

class AddUnitScreen extends ConsumerStatefulWidget {
  final RentalUnit? unitToEdit;

  const AddUnitScreen({super.key, this.unitToEdit});

  @override
  ConsumerState<AddUnitScreen> createState() => _AddUnitScreenState();
}

class _AddUnitScreenState extends ConsumerState<AddUnitScreen> {
  final _titleCtrl = TextEditingController();
  final _unitNumberCtrl = TextEditingController();
  final _floorLevelCtrl = TextEditingController();
  final _buildingNameCtrl = TextEditingController();
  final _floorAreaCtrl = TextEditingController(text: '35.0');
  final _rentCtrl = TextEditingController();
  final _securityDepositCtrl = TextEditingController();
  final _latePenaltyCtrl = TextEditingController(text: '500');
  final _waterReadingCtrl = TextEditingController(text: '0.0');
  final _electricReadingCtrl = TextEditingController(text: '0.0');
  final _waterSerialCtrl = TextEditingController();
  final _electricSerialCtrl = TextEditingController();
  final _customAreaCtrl = TextEditingController();

  List<String> _existingImageUrls = [];
  bool _isDuplicateUnit = false;

  @override
  void initState() {
    super.initState();
    if (widget.unitToEdit != null) {
      final u = widget.unitToEdit!;
      _titleCtrl.text = u.title;
      _unitNumberCtrl.text = u.unitNumber;
      _floorLevelCtrl.text = u.floor;
      _buildingNameCtrl.text = u.location;
      _floorAreaCtrl.text = u.areaSqm > 0 ? u.areaSqm.toStringAsFixed(1) : '35.0';
      _rentCtrl.text = u.monthlyRent > 0 ? u.monthlyRent.toStringAsFixed(0) : '';
      _securityDepositCtrl.text = u.securityDeposit > 0 ? u.securityDeposit.toStringAsFixed(0) : '';
      _latePenaltyCtrl.text = u.lateFee.toStringAsFixed(0);
      _waterReadingCtrl.text = u.waterReadingCurr.toStringAsFixed(1);
      _electricReadingCtrl.text = u.electricReadingCurr.toStringAsFixed(1);
      _waterSerialCtrl.text = u.waterMeterSerialNumber;
      _electricSerialCtrl.text = u.electricMeterSerialNumber;
      _existingImageUrls = List<String>.from(u.images);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(bedroomsCountProvider.notifier).state = u.bedrooms;
        ref.read(bathroomsCountProvider.notifier).state = u.bathrooms;
        ref.read(rentDueDayValueProvider.notifier).state = u.rentDueDay;
        if (u.propertyType.isNotEmpty) ref.read(selectedPropertyTypeProvider.notifier).state = u.propertyType;
        if (u.furnishingStatus.isNotEmpty) ref.read(selectedFurnishingStatusProvider.notifier).state = u.furnishingStatus;
        if (u.maintenanceAreas.isNotEmpty) {
          final setAreas = u.maintenanceAreas.toSet();
          for (final area in setAreas) {
            ref.read(maintenanceAreasProvider.notifier).addArea(area);
          }
          ref.read(selectedAreasProvider.notifier).setAllAreas(setAreas);
        }
      });
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _unitNumberCtrl.dispose();
    _floorLevelCtrl.dispose();
    _buildingNameCtrl.dispose();
    _floorAreaCtrl.dispose();
    _rentCtrl.dispose();
    _securityDepositCtrl.dispose();
    _latePenaltyCtrl.dispose();
    _waterReadingCtrl.dispose();
    _electricReadingCtrl.dispose();
    _waterSerialCtrl.dispose();
    _electricSerialCtrl.dispose();
    _customAreaCtrl.dispose();
    super.dispose();
  }

  void _checkUnitDuplicate(String value) {
    final existingUnits = ref.read(unitsProvider);
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      setState(() => _isDuplicateUnit = false);
      return;
    }
    final isDup = existingUnits.any((u) => u.unitNumber.toLowerCase() == trimmed.toLowerCase());
    setState(() => _isDuplicateUnit = isDup);
  }

  void _onRentChanged(String value) {
    final rent = double.tryParse(value.trim()) ?? 0.0;
    if (rent > 0) {
      // Auto calculate security deposit = rent * 2
      _securityDepositCtrl.text = (rent * 2.0).toStringAsFixed(0);
    }
  }

  Future<void> _pickGalleryImages() async {
    final galleryImages = ref.read(galleryImagesProvider);
    if (galleryImages.length >= 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Maximum 10 photos allowed.'),
          backgroundColor: Color(0xFFDC2626),
        ),
      );
      return;
    }

    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage(
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 85,
    );

    if (pickedFiles.isNotEmpty) {
      final imageFiles = pickedFiles.map((x) => File(x.path)).toList();
      ref.read(galleryImagesProvider.notifier).addImages(imageFiles);
    }
  }

  Future<void> _saveRentalUnit() async {
    FocusScope.of(context).unfocus();

    final formKey = ref.read(addUnitFormKeyProvider);
    if (formKey.currentState == null || !formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please correct validation errors before saving.'),
          backgroundColor: Color(0xFFDC2626),
        ),
      );
      return;
    }

    final unitNumber = _unitNumberCtrl.text.trim();
    final rentText = _rentCtrl.text.trim();

    if (unitNumber.isEmpty || rentText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unit Number and Monthly Base Rent are required.'),
          backgroundColor: Color(0xFFDC2626),
        ),
      );
      return;
    }

    if (_isDuplicateUnit) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unit number "$unitNumber" already exists.'),
          backgroundColor: const Color(0xFFDC2626),
        ),
      );
      return;
    }

    ref.read(addUnitLoadingProvider.notifier).state = true;

    final bedrooms = ref.read(bedroomsCountProvider);
    final bathrooms = ref.read(bathroomsCountProvider);
    final rentDueDay = ref.read(rentDueDayValueProvider);
    final propertyType = ref.read(selectedPropertyTypeProvider);
    final furnishingStatus = ref.read(selectedFurnishingStatusProvider);
    final advanceMonths = ref.read(advanceRentMonthsProvider);
    final leaseMonths = ref.read(minimumLeaseMonthsProvider);
    final selectedInclusions = ref.read(inclusionsProvider).toList();
    final selectedAreas = ref.read(selectedAreasProvider).toList();
    final galleryImages = ref.read(galleryImagesProvider);

    final title = _titleCtrl.text.trim().isEmpty ? 'Unit $unitNumber' : _titleCtrl.text.trim();
    final floorLevel = _floorLevelCtrl.text.trim().isEmpty ? '1st Floor' : _floorLevelCtrl.text.trim();
    final buildingName = _buildingNameCtrl.text.trim().isEmpty ? 'Main Building' : _buildingNameCtrl.text.trim();
    final floorArea = double.tryParse(_floorAreaCtrl.text.trim()) ?? 35.0;
    final baseRent = double.tryParse(rentText) ?? 0.0;
    final secDeposit = double.tryParse(_securityDepositCtrl.text.trim()) ?? (baseRent * 2.0);
    final lateFee = double.tryParse(_latePenaltyCtrl.text.trim()) ?? 500.0;
    final initialWater = double.tryParse(_waterReadingCtrl.text.trim()) ?? 0.0;
    final initialElectric = double.tryParse(_electricReadingCtrl.text.trim()) ?? 0.0;
    final waterSerial = _waterSerialCtrl.text.trim();
    final electricSerial = _electricSerialCtrl.text.trim();

    final List<String> imageUrls = List<String>.from(_existingImageUrls);
    for (final file in galleryImages) {
      final uploadedUrl = await uploadToRampMedia(XFile(file.path), 'units');
      if (uploadedUrl != null) {
        imageUrls.add(uploadedUrl);
      }
    }

    final isEditing = widget.unitToEdit != null;
    final unitId = isEditing ? widget.unitToEdit!.id : 'u_${DateTime.now().millisecondsSinceEpoch}';

    final targetUnit = RentalUnit(
      id: unitId,
      title: title,
      unitNumber: unitNumber,
      floor: floorLevel,
      location: buildingName,
      monthlyRent: baseRent,
      rentDueDay: rentDueDay,
      lateFee: lateFee,
      status: isEditing ? widget.unitToEdit!.status : 'Vacant',
      tenantId: isEditing ? widget.unitToEdit!.tenantId : null,
      tenantName: isEditing ? widget.unitToEdit!.tenantName : null,
      waterReadingPrev: isEditing ? widget.unitToEdit!.waterReadingPrev : initialWater,
      waterReadingCurr: initialWater,
      electricReadingPrev: isEditing ? widget.unitToEdit!.electricReadingPrev : initialElectric,
      electricReadingCurr: initialElectric,
      maintenanceAreas: selectedAreas,
      bedrooms: bedrooms,
      bathrooms: bathrooms,
      areaSqm: floorArea,
      images: imageUrls,
      propertyType: propertyType,
      furnishingStatus: furnishingStatus,
      securityDeposit: secDeposit,
      advanceRentMonths: advanceMonths,
      minimumLeaseMonths: leaseMonths,
      waterMeterSerialNumber: waterSerial,
      electricMeterSerialNumber: electricSerial,
      inclusions: selectedInclusions,
    );

    DbResult res = const DbResult.failure('Save operation aborted');
    try {
      if (isEditing) {
        res = await ref.read(unitsProvider.notifier).updateUnit(targetUnit);
      } else {
        res = await ref.read(unitsProvider.notifier).addUnit(targetUnit);
      }
      if (res.isSuccess) {
        ref.read(notificationsProvider.notifier).addNotification(
              isEditing ? 'Unit Updated' : 'Unit Created',
              '${isEditing ? "Updated" : "Created"} rental unit $unitNumber ($title)',
              'system',
            );
      }
    } catch (e) {
      debugPrint('Error saving unit: $e');
    } finally {
      ref.read(addUnitLoadingProvider.notifier).state = false;
    }

    if (!mounted) return;

    if (res.isOfflineQueued) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Offline Mode: Unit $unitNumber saved locally & queued for sync.'),
          backgroundColor: Colors.amber.shade800,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      Navigator.of(context).pop();
    } else if (res.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unit $unitNumber successfully created!'),
          backgroundColor: const Color(0xFF16A34A),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save unit: ${res.errorMessage ?? "Database write rejected."}'),
          backgroundColor: const Color(0xFFDC2626),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final formKey = ref.watch(addUnitFormKeyProvider);
    final currentStep = ref.watch(currentWizardStepProvider);
    final isLoading = ref.watch(addUnitLoadingProvider);

    return Scaffold(
      backgroundColor: NeumorphicStyle.baseColor,
      appBar: AppBar(
        backgroundColor: NeumorphicStyle.baseColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: NeumorphicStyle.textDark, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Add Rental Unit',
          style: TextStyle(
            color: NeumorphicStyle.textDark,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Form(
          key: formKey,
          child: Column(
            children: [
              // Step Progress Bar Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  children: [
                    _buildStepIndicator(0, 'Identity', currentStep),
                    _buildStepConnector(0, currentStep),
                    _buildStepIndicator(1, 'Terms & Meters', currentStep),
                    _buildStepConnector(1, currentStep),
                    _buildStepIndicator(2, 'Media & Extras', currentStep),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20.0),
                  child: IndexedStack(
                    index: currentStep,
                    children: [
                      _buildStep1Identity(),
                      _buildStep2FinancialsAndUtilities(),
                      _buildStep3MediaAndInclusions(),
                    ],
                  ),
                ),
              ),

              // Bottom Navigation Action Bar
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: NeumorphicStyle.baseColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white,
                      offset: Offset(0, -2),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    if (currentStep > 0) ...[
                      Expanded(
                        child: GestureDetector(
                          onTap: isLoading ? null : () => ref.read(currentWizardStepProvider.notifier).state--,
                          child: Container(
                            alignment: Alignment.center,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: NeumorphicStyle.convex(borderRadius: 16),
                            child: const Text(
                              'Back',
                              style: TextStyle(color: NeumorphicStyle.textDark, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      flex: 2,
                      child: GestureDetector(
                        onTap: isLoading
                            ? null
                            : () {
                                if (currentStep == 0) {
                                  final unitErr = RampValidators.validateUnitNumber(_unitNumberCtrl.text, ref.read(unitsProvider));
                                  if (unitErr != null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(unitErr), backgroundColor: const Color(0xFFDC2626)),
                                    );
                                    return;
                                  }
                                } else if (currentStep == 1) {
                                  final rentErr = RampValidators.validatePositiveNumber(_rentCtrl.text, 'Monthly Base Rent', required: true);
                                  if (rentErr != null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(rentErr), backgroundColor: const Color(0xFFDC2626)),
                                    );
                                    return;
                                  }
                                }

                                if (currentStep < 2) {
                                  ref.read(currentWizardStepProvider.notifier).state++;
                                } else {
                                  _saveRentalUnit();
                                }
                              },
                        child: Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: NeumorphicStyle.convex(borderRadius: 16).copyWith(
                            color: NeumorphicStyle.primaryBlue,
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                )
                              : Text(
                                  currentStep == 2 ? 'Save Unit' : 'Next Step',
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepIndicator(int stepIndex, String label, int currentStep) {
    final isActive = currentStep >= stepIndex;
    final isCurrent = currentStep == stepIndex;

    return Expanded(
      child: Column(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: isActive
                ? NeumorphicStyle.inset(borderRadius: 14)
                : NeumorphicStyle.convex(borderRadius: 14),
            alignment: Alignment.center,
            child: Text(
              '${stepIndex + 1}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isCurrent ? NeumorphicStyle.primaryBlue : (isActive ? NeumorphicStyle.textDark : NeumorphicStyle.textMuted),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
              color: isCurrent ? NeumorphicStyle.primaryBlue : NeumorphicStyle.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepConnector(int stepIndex, int currentStep) {
    final isActive = currentStep > stepIndex;
    return Container(
      width: 20,
      height: 2,
      margin: const EdgeInsets.only(bottom: 14),
      color: isActive ? NeumorphicStyle.primaryBlue : NeumorphicStyle.darkShadow,
    );
  }

  // STEP 1: IDENTITY & LAYOUT
  Widget _buildStep1Identity() {
    final selectedType = ref.watch(selectedPropertyTypeProvider);
    final selectedFurnishing = ref.watch(selectedFurnishingStatusProvider);
    final bedrooms = ref.watch(bedroomsCountProvider);
    final bathrooms = ref.watch(bathroomsCountProvider);

    return Column(
      children: [
        _NeumorphicConvexCard(
          title: 'Property Specifications',
          child: Column(
            children: [
              _NeumorphicInsetInput(
                label: 'Unit Number',
                controller: _unitNumberCtrl,
                hintText: 'e.g. 101, 2B, Unit A',
                isRequired: true,
                prefix: const Icon(Icons.numbers_outlined, size: 20, color: NeumorphicStyle.primaryBlue),
                onChanged: _checkUnitDuplicate,
                suffix: _isDuplicateUnit
                    ? const Padding(
                        padding: EdgeInsets.only(right: 8),
                        child: Text('Exists', style: TextStyle(color: Color(0xFFDC2626), fontSize: 11, fontWeight: FontWeight.bold)),
                      )
                    : null,
                validator: (val) => RampValidators.validateUnitNumber(val, ref.read(unitsProvider)),
              ),
              const SizedBox(height: 16),
              _NeumorphicInsetInput(
                label: 'Title / Listing Name',
                controller: _titleCtrl,
                hintText: 'e.g. Modern Studio Unit 101',
                prefix: const Icon(Icons.title, size: 20, color: NeumorphicStyle.primaryBlue),
                validator: (val) => RampValidators.validateUnitTitle(val),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _NeumorphicInsetInput(
                      label: 'Building / Block',
                      controller: _buildingNameCtrl,
                      hintText: 'Building A',
                      prefix: const Icon(Icons.location_city_outlined, size: 20, color: NeumorphicStyle.primaryBlue),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _NeumorphicInsetInput(
                      label: 'Floor Level',
                      controller: _floorLevelCtrl,
                      hintText: '2nd Floor',
                      prefix: const Icon(Icons.layers_outlined, size: 20, color: NeumorphicStyle.primaryBlue),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _NeumorphicInsetDropdown<String>(
                      label: 'Property Type',
                      value: selectedType,
                      items: const [
                        DropdownMenuItem(value: 'Apartment', child: Text('Apartment')),
                        DropdownMenuItem(value: 'Studio', child: Text('Studio Unit')),
                        DropdownMenuItem(value: 'Condo', child: Text('Condo Unit')),
                        DropdownMenuItem(value: 'Commercial', child: Text('Commercial Space')),
                        DropdownMenuItem(value: 'Parking', child: Text('Parking Slot')),
                      ],
                      onChanged: (val) {
                        if (val != null) ref.read(selectedPropertyTypeProvider.notifier).state = val;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _NeumorphicInsetDropdown<String>(
                      label: 'Furnishing Status',
                      value: selectedFurnishing,
                      items: const [
                        DropdownMenuItem(value: 'Unfurnished', child: Text('Unfurnished')),
                        DropdownMenuItem(value: 'Semi-Furnished', child: Text('Semi-Furnished')),
                        DropdownMenuItem(value: 'Fully Furnished', child: Text('Fully Furnished')),
                      ],
                      onChanged: (val) {
                        if (val != null) ref.read(selectedFurnishingStatusProvider.notifier).state = val;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildCounterSelector('Bedrooms', bedrooms, (val) => ref.read(bedroomsCountProvider.notifier).state = val),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildCounterSelector('Bathrooms', bathrooms, (val) => ref.read(bathroomsCountProvider.notifier).state = val),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _NeumorphicInsetInput(
                label: 'Floor Area (sqm)',
                controller: _floorAreaCtrl,
                hintText: '35.0',
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                prefix: const Icon(Icons.square_foot_outlined, size: 20, color: NeumorphicStyle.primaryBlue),
                validator: (val) => RampValidators.validateFloorArea(val),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // STEP 2: FINANCIALS & UTILITY SUBMETERS
  Widget _buildStep2FinancialsAndUtilities() {
    final rentDueDay = ref.watch(rentDueDayValueProvider);
    final advanceMonths = ref.watch(advanceRentMonthsProvider);
    final leaseMonths = ref.watch(minimumLeaseMonthsProvider);

    return Column(
      children: [
        _NeumorphicConvexCard(
          title: 'Financial & Lease Terms',
          child: Column(
            children: [
              _NeumorphicInsetInput(
                label: 'Monthly Base Rent (PHP)',
                controller: _rentCtrl,
                hintText: '15000',
                isRequired: true,
                keyboardType: TextInputType.number,
                prefix: const Text('₱', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: NeumorphicStyle.primaryBlue)),
                onChanged: _onRentChanged,
                validator: (val) => RampValidators.validatePositiveNumber(val, 'Monthly Base Rent', required: true),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _NeumorphicInsetInput(
                      label: 'Security Deposit (PHP)',
                      controller: _securityDepositCtrl,
                      hintText: '30000',
                      keyboardType: TextInputType.number,
                      prefix: const Icon(Icons.lock_clock_outlined, size: 20, color: NeumorphicStyle.primaryBlue),
                      validator: (val) => RampValidators.validateNonNegativeNumber(val, 'Security Deposit'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _NeumorphicInsetInput(
                      label: 'Late Fee (PHP)',
                      controller: _latePenaltyCtrl,
                      hintText: '500',
                      keyboardType: TextInputType.number,
                      prefix: const Icon(Icons.warning_amber_outlined, size: 20, color: NeumorphicStyle.primaryBlue),
                      validator: (val) => RampValidators.validateNonNegativeNumber(val, 'Late Fee'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _NeumorphicInsetDropdown<int>(
                      label: 'Rent Due Day',
                      value: rentDueDay,
                      items: List.generate(
                        28,
                        (index) => DropdownMenuItem(value: index + 1, child: Text('Day ${index + 1}')),
                      ),
                      onChanged: (val) {
                        if (val != null) ref.read(rentDueDayValueProvider.notifier).state = val;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _NeumorphicInsetDropdown<int>(
                      label: 'Advance Rent',
                      value: advanceMonths,
                      items: const [
                        DropdownMenuItem(value: 1, child: Text('1 Month')),
                        DropdownMenuItem(value: 2, child: Text('2 Months')),
                      ],
                      onChanged: (val) {
                        if (val != null) ref.read(advanceRentMonthsProvider.notifier).state = val;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _NeumorphicInsetDropdown<int>(
                label: 'Minimum Lease Term',
                value: leaseMonths,
                items: const [
                  DropdownMenuItem(value: 6, child: Text('6 Months Minimum')),
                  DropdownMenuItem(value: 12, child: Text('12 Months (1 Year)')),
                  DropdownMenuItem(value: 24, child: Text('24 Months (2 Years)')),
                ],
                onChanged: (val) {
                  if (val != null) ref.read(minimumLeaseMonthsProvider.notifier).state = val;
                },
              ),
            ],
          ),
        ),

        _NeumorphicConvexCard(
          title: 'Submeters & Initial Readings',
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _NeumorphicInsetInput(
                      label: 'Water Submeter Serial',
                      controller: _waterSerialCtrl,
                      hintText: 'WM-101-A',
                      prefix: const Icon(Icons.water_drop_outlined, size: 20, color: NeumorphicStyle.primaryBlue),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _NeumorphicInsetInput(
                      label: 'Initial Water Reading',
                      controller: _waterReadingCtrl,
                      hintText: '0.0',
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (val) => FormValidators.number(val, 'Initial Water Reading', isRequired: false, allowZero: true),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _NeumorphicInsetInput(
                      label: 'Electric Submeter Serial',
                      controller: _electricSerialCtrl,
                      hintText: 'EM-101-A',
                      prefix: const Icon(Icons.bolt_outlined, size: 20, color: NeumorphicStyle.primaryBlue),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _NeumorphicInsetInput(
                      label: 'Initial Electric Reading',
                      controller: _electricReadingCtrl,
                      hintText: '0.0',
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (val) => FormValidators.number(val, 'Initial Electric Reading', isRequired: false, allowZero: true),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // STEP 3: MEDIA, INCLUSIONS & MAINTENANCE
  Widget _buildStep3MediaAndInclusions() {
    final inclusions = ref.watch(inclusionsProvider);
    final allAreas = ref.watch(maintenanceAreasProvider);
    final selectedAreas = ref.watch(selectedAreasProvider);
    final galleryImages = ref.watch(galleryImagesProvider);

    final defaultInclusionsList = [
      'Air Conditioning',
      'Refrigerator',
      'Bed Frame',
      'Wi-Fi Router',
      'Water Heater',
      'Balcony Access',
      'Parking Space',
    ];

    return Column(
      children: [
        _NeumorphicConvexCard(
          title: 'Unit Inclusions & Furnishings',
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: defaultInclusionsList.map((item) {
              final isSelected = inclusions.contains(item);
              return _NeumorphicChip(
                label: item,
                isSelected: isSelected,
                onTap: () => ref.read(inclusionsProvider.notifier).toggleInclusion(item),
              );
            }).toList(),
          ),
        ),

        _NeumorphicConvexCard(
          title: 'Maintenance Inspection Areas',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: allAreas.map((area) {
                  final isSelected = selectedAreas.contains(area);
                  return _NeumorphicChip(
                    label: area,
                    isSelected: isSelected,
                    onTap: () => ref.read(selectedAreasProvider.notifier).toggleArea(area),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _NeumorphicInsetInput(
                      label: 'Add Custom Area',
                      controller: _customAreaCtrl,
                      hintText: 'e.g. Laundry Room',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Padding(
                    padding: const EdgeInsets.only(top: 22),
                    child: GestureDetector(
                      onTap: () {
                        final text = _customAreaCtrl.text.trim();
                        final err = RampValidators.validateCustomAreaName(text, allAreas);
                        if (err != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(err),
                              backgroundColor: const Color(0xFFDC2626),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                          return;
                        }
                        ref.read(maintenanceAreasProvider.notifier).addArea(text);
                        ref.read(selectedAreasProvider.notifier).selectArea(text);
                        _customAreaCtrl.clear();
                      },
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: NeumorphicStyle.convex(borderRadius: 14),
                        child: const Icon(Icons.add, color: NeumorphicStyle.primaryBlue, size: 24),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        _NeumorphicConvexCard(
          title: 'Property Photos (${_existingImageUrls.length + galleryImages.length}/10)',
          child: Column(
            children: [
              DashedBorderContainer(
                onTap: _pickGalleryImages,
                height: 100,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.add_a_photo_outlined, color: NeumorphicStyle.primaryBlue, size: 32),
                    const SizedBox(height: 6),
                    Text(
                      'Upload Unit Photos (${_existingImageUrls.length + galleryImages.length}/10)',
                      style: const TextStyle(fontSize: 13, color: NeumorphicStyle.textMuted, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              if (_existingImageUrls.isNotEmpty || galleryImages.isNotEmpty) ...[
                const SizedBox(height: 16),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 1.0,
                  ),
                  itemCount: _existingImageUrls.length + galleryImages.length,
                  itemBuilder: (context, index) {
                    final isExisting = index < _existingImageUrls.length;
                    return Container(
                      decoration: NeumorphicStyle.convex(borderRadius: 14),
                      padding: const EdgeInsets.all(4),
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: isExisting
                                  ? Image.network(
                                      _existingImageUrls[index],
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => const Icon(Icons.home, color: NeumorphicStyle.primaryBlue),
                                    )
                                  : Image.file(
                                      galleryImages[index - _existingImageUrls.length],
                                      fit: BoxFit.cover,
                                    ),
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: GestureDetector(
                              onTap: () {
                                if (isExisting) {
                                  setState(() {
                                    _existingImageUrls.removeAt(index);
                                  });
                                } else {
                                  ref.read(galleryImagesProvider.notifier).removeImage(index - _existingImageUrls.length);
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: NeumorphicStyle.convex(borderRadius: 12).copyWith(
                                  color: const Color(0xFFDC2626),
                                ),
                                child: const Icon(Icons.close, size: 14, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCounterSelector(String label, int value, ValueChanged<int> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: NeumorphicStyle.textDark)),
        ),
        Row(
          children: [
            GestureDetector(
              onTap: value > 1 ? () => onChanged(value - 1) : null,
              child: Container(
                width: 38,
                height: 38,
                decoration: NeumorphicStyle.convex(borderRadius: 12),
                child: const Icon(Icons.remove, size: 18, color: NeumorphicStyle.primaryBlue),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Container(
                height: 38,
                decoration: NeumorphicStyle.inset(borderRadius: 12),
                alignment: Alignment.center,
                child: Text('$value', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: NeumorphicStyle.textDark)),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => onChanged(value + 1),
              child: Container(
                width: 38,
                height: 38,
                decoration: NeumorphicStyle.convex(borderRadius: 12),
                child: const Icon(Icons.add, size: 18, color: NeumorphicStyle.primaryBlue),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
