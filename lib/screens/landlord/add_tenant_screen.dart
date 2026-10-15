import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';

import '../../theme.dart';
import '../../models/unit_model.dart';
import '../../models/tenant_model.dart';

import '../../providers/landlord_providers.dart';
import '../../providers/tenant_onboarding_provider.dart';
import '../../core/validators.dart';
import '../../widgets/neumorphic_widgets.dart';
import '../../widgets/dashed_border_container.dart';

/// Comprehensive 4-Stage "Add Tenant" Onboarding Flow
/// Features Front-End Validation, OTP Email Verification, Lease Assignment,
/// Neumorphic Soft UI Design System & Automated Backend Execution.
class AddTenantScreen extends ConsumerStatefulWidget {
  final TenantRecord? tenantToEdit;

  const AddTenantScreen({super.key, this.tenantToEdit});

  @override
  ConsumerState<AddTenantScreen> createState() => _AddTenantScreenState();
}

class _AddTenantScreenState extends ConsumerState<AddTenantScreen> {
  final _stage1FormKey = GlobalKey<FormState>();
  final _stage2FormKey = GlobalKey<FormState>();

  // ===========================================================================
  // STAGE 1 CONTROLLERS
  // ===========================================================================
  final _firstNameCtrl = TextEditingController();
  final _middleNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _suffixCtrl = TextEditingController();
  DateTime? _dateOfBirth;
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _facebookCtrl = TextEditingController();

  // ===========================================================================
  // STAGE 2 CONTROLLERS
  // ===========================================================================
  final _emergencyNameCtrl = TextEditingController();
  String _emergencyRelationship = 'Parent';
  final _emergencyPhoneCtrl = TextEditingController();
  final _emergencyFbCtrl = TextEditingController();

  // ===========================================================================
  // STAGE 3 CONTROLLERS & FOCUS NODES
  // ===========================================================================
  final List<TextEditingController> _otpDigitCtrls = List.generate(8, (_) => TextEditingController());
  final List<FocusNode> _otpFocusNodes = List.generate(8, (_) => FocusNode());

  // ===========================================================================
  // STAGE 4 CONTROLLERS
  // ===========================================================================
  String? _selectedUnitId;
  DateTime _leaseStart = DateTime.now();
  late DateTime _leaseEnd = DateTime.now().add(const Duration(days: 365));
  String? _uploadedContractFileName;
  String? _uploadedContractFilePath;

  @override
  void initState() {
    super.initState();
    if (widget.tenantToEdit != null) {
      final t = widget.tenantToEdit!;
      _firstNameCtrl.text = t.firstName ?? (t.name.contains(' ') ? t.name.split(' ').first : t.name);
      _middleNameCtrl.text = t.middleName ?? '';
      _lastNameCtrl.text = t.lastName ?? (t.name.contains(' ') ? t.name.split(' ').last : '');
      _suffixCtrl.text = t.suffix ?? '';
      _phoneCtrl.text = t.phone;
      _emailCtrl.text = t.email ?? '';
      _facebookCtrl.text = t.facebookUrl ?? '';
      _emergencyNameCtrl.text = t.emergencyName ?? '';
      _emergencyRelationship = t.emergencyRelationship ?? 'Parent';
      _emergencyPhoneCtrl.text = t.emergencyPhone ?? '';
      _emergencyFbCtrl.text = t.emergencyFacebookUrl ?? '';
      _selectedUnitId = t.unitId;
      _dateOfBirth = t.dateOfBirth;
      _leaseStart = t.leaseStart;
      _leaseEnd = t.leaseEnd;
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(tenantOnboardingProvider.notifier).reset();
      });
    }
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _middleNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _suffixCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _facebookCtrl.dispose();
    _emergencyNameCtrl.dispose();
    _emergencyPhoneCtrl.dispose();
    _emergencyFbCtrl.dispose();
    for (final c in _otpDigitCtrls) {
      c.dispose();
    }
    for (final f in _otpFocusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  // ===========================================================================
  // DATE OF BIRTH PICKER
  // ===========================================================================
  Future<void> _selectDateOfBirth() async {
    final now = DateTime.now();
    final minBirthDate = DateTime(1970, 1, 1);
    final maxBirthDate = DateTime(now.year - 18, now.month, now.day);

    final picked = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth ?? DateTime(2000, 1, 1),
      firstDate: minBirthDate,
      lastDate: maxBirthDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: RampTheme.primaryBlue,
              onPrimary: Colors.white,
              surface: Color(0xFFE0E5EC),
              onSurface: RampTheme.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _dateOfBirth = picked;
      });
      ref.read(tenantOnboardingProvider.notifier).updateBasicInfo(dateOfBirth: picked);
    }
  }

  // ===========================================================================
  // LEASE START & END DATE PICKERS
  // ===========================================================================
  Future<void> _selectLeaseStart() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _leaseStart,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (picked != null) {
      setState(() {
        _leaseStart = picked;
        // Default End Date to exactly 1 year after Start Date
        _leaseEnd = picked.add(const Duration(days: 365));
      });
      ref.read(tenantOnboardingProvider.notifier).updateLeaseInfo(
            leaseStart: _leaseStart,
            leaseEnd: _leaseEnd,
          );
    }
  }

  Future<void> _selectLeaseEnd() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _leaseEnd,
      firstDate: _leaseStart.add(const Duration(days: 1)),
      lastDate: _leaseStart.add(const Duration(days: 365 * 5)),
    );
    if (picked != null) {
      setState(() {
        _leaseEnd = picked;
      });
      ref.read(tenantOnboardingProvider.notifier).updateLeaseInfo(
            leaseEnd: _leaseEnd,
          );
    }
  }

  // ===========================================================================
  // PICK CONTRACT FILE
  // ===========================================================================
  Future<void> _pickContractFile() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );
    if (result.isNotEmpty) {
      final file = result.first;
      setState(() {
        _uploadedContractFileName = file.name;
        _uploadedContractFilePath = file.path;
      });
      ref.read(tenantOnboardingProvider.notifier).updateLeaseInfo(
            uploadedContractFileName: file.name,
            uploadedContractFilePath: file.path,
          );
      if (mounted) {
        NeumorphicFeedback.showSnackBar(
          context,
          message: 'Contract document attached: ${file.name}',
        );
      }
    }
  }

  // ===========================================================================
  // STAGE 1 VALIDATION & PROCEED
  // ===========================================================================
  void _validateAndProceedToStage2() {
    if (!_stage1FormKey.currentState!.validate()) return;

    final dobErr = FormValidators.age(_dateOfBirth);
    if (dobErr != null) {
      NeumorphicFeedback.showSnackBar(context, message: dobErr, isError: true);
      return;
    }

    final tenants = ref.read(tenantsProvider);
    final emailErr = RampValidators.validateUniqueEmail(_emailCtrl.text, tenants);
    if (emailErr != null) {
      NeumorphicFeedback.showSnackBar(context, message: emailErr, isError: true);
      return;
    }

    final phoneErr = RampValidators.validateUniquePhone(_phoneCtrl.text, tenants);
    if (phoneErr != null) {
      NeumorphicFeedback.showSnackBar(context, message: phoneErr, isError: true);
      return;
    }

    ref.read(tenantOnboardingProvider.notifier).updateBasicInfo(
          firstName: _firstNameCtrl.text.trim(),
          middleName: _middleNameCtrl.text.trim(),
          lastName: _lastNameCtrl.text.trim(),
          suffix: _suffixCtrl.text.trim(),
          dateOfBirth: _dateOfBirth,
          phone: _phoneCtrl.text.replaceAll(RegExp(r'\D'), ''),
          email: _emailCtrl.text.trim().toLowerCase(),
          facebookUrl: _facebookCtrl.text.trim(),
        );

    ref.read(tenantOnboardingStageProvider.notifier).state = 2;
  }

  // ===========================================================================
  // STAGE 2 VALIDATION & DISPATCH OTP
  // ===========================================================================
  Future<void> _validateAndProceedToStage3() async {
    if (!_stage2FormKey.currentState!.validate()) return;

    ref.read(tenantOnboardingProvider.notifier).updateEmergencyContact(
          emergencyName: _emergencyNameCtrl.text.trim(),
          emergencyRelationship: _emergencyRelationship,
          emergencyPhone: _emergencyPhoneCtrl.text.replaceAll(RegExp(r'\D'), ''),
          emergencyFacebookUrl: _emergencyFbCtrl.text.trim(),
        );

    // Clear digit controllers
    for (final c in _otpDigitCtrls) {
      c.clear();
    }

    // Trigger Supabase OTP Dispatch
    final success = await ref.read(tenantOnboardingProvider.notifier).sendOtpEmail();

    if (!mounted) return;

    if (success) {
      NeumorphicFeedback.showSnackBar(
        context,
        message: '8-digit OTP code dispatched to ${_emailCtrl.text.trim()}. Check your inbox.',
      );
      ref.read(tenantOnboardingStageProvider.notifier).state = 3;
    } else {
      final stateData = ref.read(tenantOnboardingProvider);
      NeumorphicFeedback.showSnackBar(
        context,
        message: 'Failed to send OTP: ${stateData.otpErrorMessage ?? "Please try again"}',
        isError: true,
      );
      // Still advance to Stage 3 so user can enter OTP or retry sending
      ref.read(tenantOnboardingStageProvider.notifier).state = 3;
    }
  }

  // ===========================================================================
  // STAGE 3 OTP VERIFICATION
  // ===========================================================================
  Future<void> _verifyOtpCode() async {
    final success = await ref.read(tenantOnboardingProvider.notifier).verifyOtpCode();

    if (!mounted) return;

    if (success) {
      NeumorphicFeedback.showSnackBar(
        context,
        message: 'Email Verified Successfully! Tap Proceed to Contract.',
      );
    } else {
      final stateData = ref.read(tenantOnboardingProvider);
      NeumorphicFeedback.showSnackBar(
        context,
        message: 'Verification failed: ${stateData.otpErrorMessage ?? "Invalid code"}',
        isError: true,
      );
    }
  }

  // ===========================================================================
  // STAGE 4 POST-ONBOARDING AUTOMATED SUBMIT EXECUTION
  // ===========================================================================
  Future<void> _finalizeTenant(RentalUnit selectedUnit) async {
    if (_leaseEnd.isBefore(_leaseStart) || _leaseEnd.difference(_leaseStart).inDays < 30) {
      NeumorphicFeedback.showSnackBar(
        context,
        message: 'Lease end date must be at least 30 days after lease start date.',
        isError: true,
      );
      return;
    }

    if (_uploadedContractFileName == null && _uploadedContractFilePath == null) {
      NeumorphicFeedback.showSnackBar(
        context,
        message: 'Please upload a signed lease contract document (.pdf, .jpg, .png).',
        isError: true,
      );
      return;
    }

    // Show Loading Dialog Overlay
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => PopScope(
        canPop: false,
        child: AlertDialog(
          backgroundColor: const Color(0xFFE0E5EC),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 48,
                  height: 48,
                  child: CircularProgressIndicator(
                    strokeWidth: 3.5,
                    valueColor: AlwaysStoppedAnimation<Color>(RampTheme.primaryBlue),
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'Finalizing Tenant Onboarding...',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: RampTheme.textPrimary),
                ),
                SizedBox(height: 6),
                Text(
                  'Syncing database, updating unit & creating auth profile.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: RampTheme.textSecondary),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    // Execute automated onboarding sequence
    final success = await ref
        .read(tenantOnboardingProvider.notifier)
        .finalizeTenantOnboarding(selectedUnit);

    if (!mounted) return;

    // Dismiss Loading Dialog
    Navigator.of(context, rootNavigator: true).pop();

    if (success) {
      final stateData = ref.read(tenantOnboardingProvider);
      _showTenantCredentialsSuccessModal(
        fullName: stateData.fullName,
        email: stateData.email,
        unitNumber: selectedUnit.unitNumber,
      );
    } else {
      final stateData = ref.read(tenantOnboardingProvider);
      NeumorphicFeedback.showErrorDialog(
        context,
        title: 'Onboarding Error',
        message: stateData.submitError ?? 'Failed to finalize tenant onboarding. Please try again.',
      );
    }
  }

  // ===========================================================================
  // SUCCESS CREDENTIALS BOTTOM SHEET MODAL
  // ===========================================================================
  void _showTenantCredentialsSuccessModal({
    required String fullName,
    required String email,
    required String unitNumber,
  }) {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFFE0E5EC),
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            boxShadow: [
              BoxShadow(
                color: Color(0x1A000000),
                blurRadius: 20,
                offset: Offset(0, -4),
              ),
            ],
          ),
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 24,
            bottom: MediaQuery.of(modalContext).padding.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Success Neumorphic Badge
                NeumorphicContainer(
                  shape: BoxShape.circle,
                  padding: const EdgeInsets.all(16),
                  backgroundColor: RampTheme.successGreen,
                  child: const Icon(Icons.check_rounded, color: Colors.white, size: 36),
                ),
                const SizedBox(height: 16),

                Text(
                  'Tenant Onboarded Successfully!',
                  textAlign: TextAlign.center,
                  style: Theme.of(modalContext).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: RampTheme.textPrimary,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$fullName is now assigned to Unit $unitNumber',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14, color: RampTheme.textSecondary),
                ),

                const SizedBox(height: 16),

                // Credentials Container
                NeumorphicContainer(
                  isInset: true,
                  borderRadius: 20,
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.email_outlined, color: RampTheme.primaryBlue, size: 22),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Tenant Portal Email', style: TextStyle(fontSize: 12, color: RampTheme.textSecondary)),
                                Text(email, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: RampTheme.textPrimary)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 20, color: RampTheme.dividerColor),
                      Row(
                        children: [
                          const Icon(Icons.lock_outline, color: RampTheme.primaryBlue, size: 22),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Default Access Password', style: TextStyle(fontSize: 12, color: RampTheme.textSecondary)),
                                const Text('Password123!', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: RampTheme.primaryBlue)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Share Credentials Button
                NeumorphicButton(
                  label: 'Share Credentials via SMS / Messenger',
                  icon: Icons.share_rounded,
                  onPressed: () {
                    final message =
                        'Hi $fullName! Welcome to RAMP. Access your Tenant Portal with Email: $email and Password: Password123!';
                    Clipboard.setData(ClipboardData(text: message));
                    NeumorphicFeedback.showSnackBar(
                      modalContext,
                      message: 'Copied credentials to clipboard!',
                    );
                  },
                ),

                const SizedBox(height: 12),

                // Return to Dashboard Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(modalContext);
                      ref.read(tenantOnboardingProvider.notifier).reset();
                      context.pop();
                    },
                    child: const Text(
                      'Return to Dashboard',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: RampTheme.textSecondary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ===========================================================================
  // BUILD SCREEN METHOD
  // ===========================================================================
  @override
  Widget build(BuildContext context) {
    final currentStage = ref.watch(tenantOnboardingStageProvider);
    final units = ref.watch(unitsProvider);

    return PopScope(
      canPop: currentStage == 1,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && currentStage > 1) {
          ref.read(tenantOnboardingStageProvider.notifier).state = currentStage - 1;
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFE0E5EC),
        appBar: AppBar(
          backgroundColor: const Color(0xFFE0E5EC),
          elevation: 0,
          title: const Text('Add Tenant'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: RampTheme.textPrimary),
            onPressed: () {
              if (currentStage > 1) {
                ref.read(tenantOnboardingStageProvider.notifier).state = currentStage - 1;
              } else {
                context.pop();
              }
            },
          ),
        ),
        body: Column(
          children: [
            // Segmented Neumorphic Progress Bar
            _NeumorphicSegmentedProgressBar(
              currentStage: currentStage,
              onStageTapped: (stage) {
                if (stage < currentStage) {
                  ref.read(tenantOnboardingStageProvider.notifier).state = stage;
                }
              },
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: KeyedSubtree(
                    key: ValueKey<int>(currentStage),
                    child: _buildCurrentStageView(currentStage, units),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentStageView(int stage, List<RentalUnit> units) {
    switch (stage) {
      case 1:
        return _buildStage1BasicInfo();
      case 2:
        return _buildStage2EmergencyContact();
      case 3:
        return _buildStage3EmailOtp();
      case 4:
      default:
        return _buildStage4ContractAndLease(units);
    }
  }

  // ===========================================================================
  // STAGE 1: BASIC INFORMATION
  // ===========================================================================
  Widget _buildStage1BasicInfo() {
    return Form(
      key: _stage1FormKey,
      child: NeumorphicContainer(
        borderRadius: 20,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.person_outline_rounded, color: RampTheme.primaryBlue),
                SizedBox(width: 8),
                Text(
                  'Basic Information',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: RampTheme.primaryBlue),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // First Name
            NeumorphicTextField(
              controller: _firstNameCtrl,
              label: 'First Name',
              hintText: 'e.g. Juan',
              prefixIcon: Icons.badge_outlined,
              validator: (val) => FormValidators.name(val, 'First Name'),
            ),
            const SizedBox(height: 12),

            // Middle Name (Optional)
            NeumorphicTextField(
              controller: _middleNameCtrl,
              label: 'Middle Name (Optional)',
              hintText: 'e.g. Santos',
              prefixIcon: Icons.person_outline_rounded,
              validator: (val) => FormValidators.name(val, 'Middle Name', isRequired: false),
            ),
            const SizedBox(height: 12),

            // Last Name
            NeumorphicTextField(
              controller: _lastNameCtrl,
              label: 'Last Name',
              hintText: 'e.g. Dela Cruz',
              prefixIcon: Icons.badge_outlined,
              validator: (val) => FormValidators.name(val, 'Last Name'),
            ),
            const SizedBox(height: 12),

            // Suffix (Optional)
            NeumorphicTextField(
              controller: _suffixCtrl,
              label: 'Suffix (Optional)',
              hintText: 'e.g. Jr., III',
              prefixIcon: Icons.title_rounded,
              validator: (val) => FormValidators.name(val, 'Suffix', isRequired: false),
            ),
            const SizedBox(height: 12),

            // Date of Birth Read-only Field
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 4, bottom: 6),
                  child: Text(
                    'Date of Birth',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: RampTheme.textPrimary),
                  ),
                ),
                GestureDetector(
                  onTap: _selectDateOfBirth,
                  child: NeumorphicContainer(
                    isInset: true,
                    borderRadius: 14,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today_rounded, color: RampTheme.primaryBlue, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _dateOfBirth == null
                                ? 'Select Date of Birth (Age >= 18)'
                                : DateFormat('MMMM d, yyyy').format(_dateOfBirth!),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: _dateOfBirth == null ? RampTheme.textSecondary : RampTheme.textPrimary,
                            ),
                          ),
                        ),
                        const Icon(Icons.arrow_drop_down_rounded, color: RampTheme.textSecondary),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Phone Number
            NeumorphicTextField(
              controller: _phoneCtrl,
              label: 'Phone Number',
              hintText: '0917 123 4567',
              keyboardType: TextInputType.phone,
              inputFormatters: [PhilippinePhoneInputFormatter()],
              prefixIcon: Icons.phone_android_rounded,
              validator: (val) => FormValidators.phone(val),
            ),
            const SizedBox(height: 12),

            // Gmail Address
            NeumorphicTextField(
              controller: _emailCtrl,
              label: 'Gmail Address',
              hintText: 'tenant@gmail.com',
              keyboardType: TextInputType.emailAddress,
              prefixIcon: Icons.email_outlined,
              validator: (val) => FormValidators.gmail(val),
            ),
            const SizedBox(height: 12),

            // Facebook / Messenger Link (Optional)
            NeumorphicTextField(
              controller: _facebookCtrl,
              label: 'Facebook / Messenger Link (Optional)',
              hintText: 'https://facebook.com/username',
              keyboardType: TextInputType.url,
              prefixIcon: Icons.link_rounded,
              validator: (val) => FormValidators.facebookUrl(val),
            ),

            const SizedBox(height: 24),

            NeumorphicButton(
              label: 'Proceed to Emergency Contact',
              icon: Icons.arrow_forward_rounded,
              onPressed: _validateAndProceedToStage2,
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // STAGE 2: EMERGENCY CONTACT
  // ===========================================================================
  Widget _buildStage2EmergencyContact() {
    return Form(
      key: _stage2FormKey,
      child: NeumorphicContainer(
        borderRadius: 20,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.contact_phone_outlined, color: RampTheme.primaryBlue),
                SizedBox(width: 8),
                Text(
                  'Emergency Contact Details',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: RampTheme.primaryBlue),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Emergency Contact Name
            NeumorphicTextField(
              controller: _emergencyNameCtrl,
              label: 'Emergency Contact Name',
              hintText: 'e.g. Maria Dela Cruz',
              prefixIcon: Icons.person_pin_rounded,
              validator: (val) => FormValidators.name(val, 'Emergency Contact Name'),
            ),
            const SizedBox(height: 12),

            // Relationship Dropdown
            NeumorphicDropdown<String>(
              label: 'Relationship',
              value: _emergencyRelationship,
              prefixIcon: Icons.family_restroom_rounded,
              items: const [
                DropdownMenuItem(value: 'Parent', child: Text('Parent')),
                DropdownMenuItem(value: 'Spouse', child: Text('Spouse')),
                DropdownMenuItem(value: 'Sibling', child: Text('Sibling')),
                DropdownMenuItem(value: 'Child', child: Text('Child')),
                DropdownMenuItem(value: 'Relative', child: Text('Relative')),
                DropdownMenuItem(value: 'Friend', child: Text('Friend')),
                DropdownMenuItem(value: 'Other', child: Text('Other')),
              ],
              onChanged: (val) {
                if (val != null) {
                  setState(() => _emergencyRelationship = val);
                }
              },
            ),
            const SizedBox(height: 12),

            // Emergency Phone Number
            NeumorphicTextField(
              controller: _emergencyPhoneCtrl,
              label: 'Emergency Contact Phone',
              hintText: '0917 987 6543',
              keyboardType: TextInputType.phone,
              inputFormatters: [PhilippinePhoneInputFormatter()],
              prefixIcon: Icons.phone_in_talk_rounded,
              validator: (val) => FormValidators.phone(val),
            ),
            const SizedBox(height: 12),

            // Emergency FB / Messenger Link (Optional)
            NeumorphicTextField(
              controller: _emergencyFbCtrl,
              label: 'Emergency FB/Messenger Link (Optional)',
              hintText: 'https://facebook.com/username',
              keyboardType: TextInputType.url,
              prefixIcon: Icons.link_rounded,
              validator: (val) => FormValidators.facebookUrl(val),
            ),

            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: RampTheme.dividerColor),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: () {
                        ref.read(tenantOnboardingStageProvider.notifier).state = 1;
                      },
                      child: const Text('Back', style: TextStyle(fontWeight: FontWeight.bold, color: RampTheme.textPrimary)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: NeumorphicButton(
                    label: 'Proceed to Email OTP',
                    icon: Icons.mark_email_read_rounded,
                    onPressed: _validateAndProceedToStage3,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // STAGE 3: EMAIL OTP VERIFICATION
  // ===========================================================================
  Widget _buildStage3EmailOtp() {
    final stateData = ref.watch(tenantOnboardingProvider);
    final timerSeconds = ref.watch(otpTimerProvider);
    final minutes = (timerSeconds / 60).floor().toString().padLeft(2, '0');
    final seconds = (timerSeconds % 60).toString().padLeft(2, '0');
    final formattedTimer = '$minutes:$seconds';

    return NeumorphicContainer(
      borderRadius: 20,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Email OTP Verification',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: RampTheme.primaryBlue),
          ),
          const SizedBox(height: 6),
          Text(
            'An 8-digit OTP verification code was sent to your email:',
            style: TextStyle(fontSize: 13, color: RampTheme.textSecondary),
          ),
          const SizedBox(height: 2),
          Text(
            _emailCtrl.text.trim(),
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: RampTheme.textPrimary),
          ),

          const SizedBox(height: 20),

          // 8 Individual Inset Neumorphic Boxes for OTP Digits
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(8, (index) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: 38,
                  height: 48,
                  child: NeumorphicContainer(
                    isInset: true,
                    borderRadius: 10,
                    child: Center(
                      child: TextField(
                        controller: _otpDigitCtrls[index],
                        focusNode: _otpFocusNodes[index],
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        maxLength: 8, // Allows multi-digit paste
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: RampTheme.primaryBlue,
                        ),
                        decoration: const InputDecoration(
                          counterText: '',
                          contentPadding: EdgeInsets.zero,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          fillColor: Colors.transparent,
                        ),
                        onChanged: (val) {
                          final digits = val.replaceAll(RegExp(r'\D'), '');

                          // Multi-digit paste handling
                          if (digits.length > 1) {
                            ref.read(tenantOnboardingProvider.notifier).setPastedOtp(digits);
                            for (int i = 0; i < 8; i++) {
                              _otpDigitCtrls[i].text = i < digits.length ? digits[i] : '';
                            }
                            if (digits.length >= 8) {
                              _otpFocusNodes[7].unfocus();
                              _verifyOtpCode();
                            } else {
                              FocusScope.of(context).requestFocus(_otpFocusNodes[digits.length.clamp(0, 7)]);
                            }
                            return;
                          }

                          // Single digit entry
                          if (digits.isNotEmpty) {
                            _otpDigitCtrls[index].text = digits.substring(0, 1);
                            _otpDigitCtrls[index].selection = const TextSelection.collapsed(offset: 1);
                            ref.read(tenantOnboardingProvider.notifier).updateOtpDigit(index, digits.substring(0, 1));

                            if (index < 7) {
                              FocusScope.of(context).requestFocus(_otpFocusNodes[index + 1]);
                            } else {
                              _otpFocusNodes[index].unfocus();
                              _verifyOtpCode();
                            }
                          } else if (val.isEmpty) {
                            ref.read(tenantOnboardingProvider.notifier).updateOtpDigit(index, '');
                            if (index > 0) {
                              FocusScope.of(context).requestFocus(_otpFocusNodes[index - 1]);
                            }
                          }
                        },
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),

          const SizedBox(height: 20),

          // Countdown Timer displayed in soft red text
          Center(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.timer_outlined, color: RampTheme.errorRed, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      timerSeconds > 0 ? 'Resend code in $formattedTimer' : 'OTP Code Expired',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: RampTheme.errorRed,
                      ),
                    ),
                  ],
                ),
                if (timerSeconds == 0) ...[
                  const SizedBox(height: 8),
                  TextButton.icon(
                    icon: const Icon(Icons.refresh_rounded, size: 16),
                    label: const Text('Resend 8-Digit OTP'),
                    onPressed: () {
                      ref.read(tenantOnboardingProvider.notifier).sendOtpEmail();
                    },
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 16),

          if (stateData.isOtpVerified)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: NeumorphicDecoration.inset(
                borderRadius: 14,
                color: RampTheme.successGreen.withValues(alpha: 0.12),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_rounded, color: RampTheme.successGreen, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Email Verified Successfully!',
                    style: TextStyle(fontWeight: FontWeight.bold, color: RampTheme.successGreen),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 24),

          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: RampTheme.dividerColor),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: () {
                      ref.read(tenantOnboardingStageProvider.notifier).state = 2;
                    },
                    child: const Text('Back', style: TextStyle(fontWeight: FontWeight.bold, color: RampTheme.textPrimary)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: NeumorphicButton(
                  label: 'Proceed to Contract',
                  icon: Icons.arrow_forward_rounded,
                  isLoading: stateData.isOtpVerifying,
                  onPressed: stateData.isOtpVerified
                      ? () {
                          ref.read(tenantOnboardingStageProvider.notifier).state = 4;
                        }
                      : null, // Keeps button disabled until _isOtpVerified = true
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // STAGE 4: CONTRACT, LEASE & UNIT ASSIGNMENT
  // ===========================================================================
  Widget _buildStage4ContractAndLease(List<RentalUnit> units) {
    // Populate only units where status == 'Vacant' or 'Available'
    final vacantUnits = units.where((u) {
      final status = u.status.trim().toLowerCase();
      return status == 'vacant' || status == 'available';
    }).toList();

    if (_selectedUnitId == null && vacantUnits.isNotEmpty) {
      _selectedUnitId = vacantUnits.first.id;
    }

    final selectedUnit = vacantUnits.firstWhere(
      (u) => u.id == _selectedUnitId,
      orElse: () => vacantUnits.isNotEmpty
          ? vacantUnits.first
          : RentalUnit(id: 'none', title: 'No Vacant Units', unitNumber: 'N/A', monthlyRent: 0.0),
    );

    return NeumorphicContainer(
      borderRadius: 20,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.assignment_outlined, color: RampTheme.primaryBlue),
              SizedBox(width: 8),
              Text(
                'Contract & Lease Assignment',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: RampTheme.primaryBlue),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Unit Dropdown (Vacant Units Only)
          NeumorphicDropdown<String>(
            label: 'Assign Vacant Rental Unit',
            value: vacantUnits.any((u) => u.id == _selectedUnitId) ? _selectedUnitId : null,
            prefixIcon: Icons.home_work_outlined,
            hintText: vacantUnits.isEmpty ? 'No Vacant Units Available' : 'Select Unit',
            items: vacantUnits.map((u) {
              return DropdownMenuItem(
                value: u.id,
                child: Text('Unit ${u.unitNumber} - ${u.title} (₱${u.monthlyRent.toStringAsFixed(2)}/mo)'),
              );
            }).toList(),
            onChanged: (val) {
              if (val != null) {
                setState(() => _selectedUnitId = val);
                final unit = vacantUnits.firstWhere((u) => u.id == val);
                ref.read(tenantOnboardingProvider.notifier).updateLeaseInfo(
                      selectedUnitId: val,
                      selectedUnitRent: unit.monthlyRent,
                    );
              }
            },
          ),
          const SizedBox(height: 12),

          // Read-only Monthly Rent Auto-fill Field
          NeumorphicTextField(
            label: 'Monthly Rent Amount',
            controller: TextEditingController(
              text: '₱${selectedUnit.monthlyRent.toStringAsFixed(2)}',
            ),
            readOnly: true,
            prefixIcon: Icons.payments_outlined,
          ),
          const SizedBox(height: 12),

          // Security Deposit Input Field
          NeumorphicTextField(
            label: 'Security Deposit Held (PHP)',
            hintText: 'e.g. 15000',
            keyboardType: TextInputType.number,
            prefixIcon: Icons.security_outlined,
            onChanged: (val) {
              final parsed = double.tryParse(val.replaceAll(',', '').trim()) ?? 0.0;
              ref.read(tenantOnboardingProvider.notifier).updateLeaseInfo(
                    securityDeposit: parsed,
                  );
            },
          ),
          const SizedBox(height: 16),

          // Lease Dates
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 4, bottom: 6),
                      child: Text('Lease Start Date', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: RampTheme.textPrimary)),
                    ),
                    GestureDetector(
                      onTap: _selectLeaseStart,
                      child: NeumorphicContainer(
                        isInset: true,
                        borderRadius: 14,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        child: Row(
                          children: [
                            const Icon(Icons.date_range_rounded, color: RampTheme.primaryBlue, size: 18),
                            const SizedBox(width: 8),
                            Text(DateFormat('MMM d, yyyy').format(_leaseStart), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 4, bottom: 6),
                      child: Text('Lease End Date', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: RampTheme.textPrimary)),
                    ),
                    GestureDetector(
                      onTap: _selectLeaseEnd,
                      child: NeumorphicContainer(
                        isInset: true,
                        borderRadius: 14,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        child: Row(
                          children: [
                            const Icon(Icons.event_available_rounded, color: RampTheme.primaryBlue, size: 18),
                            const SizedBox(width: 8),
                            Text(DateFormat('MMM d, yyyy').format(_leaseEnd), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Inset Dashed Neumorphic Container for Document Upload
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 4, bottom: 6),
                child: Text('Upload Signed Lease Contract', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: RampTheme.textPrimary)),
              ),
              DashedBorderContainer(
                height: 120,
                onTap: _pickContractFile,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _uploadedContractFileName != null ? Icons.check_circle_rounded : Icons.cloud_upload_outlined,
                      color: _uploadedContractFileName != null ? RampTheme.successGreen : RampTheme.primaryBlue,
                      size: 32,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _uploadedContractFileName ?? 'Tap to upload signed contract (.pdf, .jpg, .png)',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _uploadedContractFileName != null ? RampTheme.successGreen : RampTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 28),

          // Large Prominent Convex Action Button
          NeumorphicButton(
            label: 'Finalize Tenant',
            icon: Icons.check_circle_outline_rounded,
            height: 52,
            backgroundColor: RampTheme.primaryBlue,
            onPressed: vacantUnits.isEmpty || selectedUnit.id == 'none'
                ? null
                : () => _finalizeTenant(selectedUnit),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// NEUMORPHIC SEGMENTED PROGRESS BAR WIDGET
// =============================================================================
class _NeumorphicSegmentedProgressBar extends StatelessWidget {
  final int currentStage;
  final ValueChanged<int>? onStageTapped;

  const _NeumorphicSegmentedProgressBar({
    required this.currentStage,
    this.onStageTapped,
  });

  @override
  Widget build(BuildContext context) {
    return NeumorphicContainer(
      isInset: true,
      borderRadius: 20,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(6),
      child: Row(
        children: [
          _buildSegment(1, 'Basic', Icons.person_outline_rounded),
          _buildDivider(1),
          _buildSegment(2, 'Emergency', Icons.contact_phone_outlined),
          _buildDivider(2),
          _buildSegment(3, 'Email OTP', Icons.mark_email_read_outlined),
          _buildDivider(3),
          _buildSegment(4, 'Contract', Icons.assignment_outlined),
        ],
      ),
    );
  }

  Widget _buildDivider(int stageIndex) {
    final isPassed = currentStage > stageIndex;
    return Expanded(
      child: Container(
        height: 3,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: isPassed ? RampTheme.successGreen : RampTheme.dividerColor,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildSegment(int stageNumber, String label, IconData icon) {
    final isActive = currentStage == stageNumber;
    final isDone = currentStage > stageNumber;

    return GestureDetector(
      onTap: isDone && onStageTapped != null ? () => onStageTapped!(stageNumber) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: isActive
            ? NeumorphicDecoration.convex(
                borderRadius: 14,
                color: RampTheme.primaryBlue,
              )
            : isDone
                ? NeumorphicDecoration.convex(
                    borderRadius: 14,
                    color: RampTheme.successGreen.withValues(alpha: 0.15),
                  )
                : NeumorphicDecoration.inset(
                    borderRadius: 14,
                    color: NeumorphicDecoration.baseColor,
                  ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isDone ? Icons.check_circle_rounded : icon,
              size: 14,
              color: isActive
                  ? Colors.white
                  : isDone
                      ? RampTheme.successGreen
                      : RampTheme.textSecondary,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isActive || isDone ? FontWeight.bold : FontWeight.w500,
                color: isActive
                    ? Colors.white
                    : isDone
                        ? RampTheme.successGreen
                        : RampTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
