import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/tenant_model.dart';
import '../models/unit_model.dart';
import '../core/supabase_auth_service.dart';
import '../core/supabase_db_service.dart';
import '../core/services/local_database_service.dart';
import 'landlord_providers.dart';

/// State Provider for current onboarding stage (1-4)
final tenantOnboardingStageProvider = StateProvider<int>((ref) => 1);

/// Timer StateNotifier for 300-second OTP countdown (5:00)
class OtpTimerNotifier extends StateNotifier<int> {
  Timer? _timer;

  OtpTimerNotifier() : super(300);

  void startTimer() {
    _timer?.cancel();
    state = 300;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (state > 0) {
        state = state - 1;
      } else {
        t.cancel();
      }
    });
  }

  void resetTimer() {
    _timer?.cancel();
    state = 300;
  }

  void stopTimer() {
    _timer?.cancel();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final otpTimerProvider = StateNotifierProvider<OtpTimerNotifier, int>((ref) {
  return OtpTimerNotifier();
});

/// Data payload model for 4-Stage Tenant Onboarding
class TenantOnboardingData {
  // Stage 1: Basic Information
  final String firstName;
  final String middleName;
  final String lastName;
  final String suffix;
  final DateTime? dateOfBirth;
  final String phone;
  final String email;
  final String facebookUrl;

  // Stage 2: Emergency Contact
  final String emergencyName;
  final String emergencyRelationship;
  final String emergencyPhone;
  final String emergencyFacebookUrl;

  // Stage 3: Email OTP Verification
  final List<String> otpDigits;
  final bool isOtpVerified;
  final bool isOtpSending;
  final bool isOtpVerifying;
  final String? otpErrorMessage;

  // Stage 4: Contract, Lease & Unit Assignment
  final String? selectedUnitId;
  final double? selectedUnitRent;
  final double securityDeposit;
  final DateTime leaseStart;
  final DateTime leaseEnd;
  final String? uploadedContractFileName;
  final String? uploadedContractFilePath;

  // Submission Status
  final bool isSubmitting;
  final String? submitError;

  TenantOnboardingData({
    this.firstName = '',
    this.middleName = '',
    this.lastName = '',
    this.suffix = '',
    this.dateOfBirth,
    this.phone = '',
    this.email = '',
    this.facebookUrl = '',
    this.emergencyName = '',
    this.emergencyRelationship = 'Parent',
    this.emergencyPhone = '',
    this.emergencyFacebookUrl = '',
    List<String>? otpDigits,
    this.isOtpVerified = false,
    this.isOtpSending = false,
    this.isOtpVerifying = false,
    this.otpErrorMessage,
    this.selectedUnitId,
    this.selectedUnitRent,
    this.securityDeposit = 0.0,
    DateTime? leaseStart,
    DateTime? leaseEnd,
    this.uploadedContractFileName,
    this.uploadedContractFilePath,
    this.isSubmitting = false,
    this.submitError,
  })  : otpDigits = otpDigits ?? List.filled(8, ''),
        leaseStart = leaseStart ?? DateTime.now(),
        leaseEnd = leaseEnd ?? DateTime.now().add(const Duration(days: 365));

  TenantOnboardingData copyWith({
    String? firstName,
    String? middleName,
    String? lastName,
    String? suffix,
    DateTime? dateOfBirth,
    String? phone,
    String? email,
    String? facebookUrl,
    String? emergencyName,
    String? emergencyRelationship,
    String? emergencyPhone,
    String? emergencyFacebookUrl,
    List<String>? otpDigits,
    bool? isOtpVerified,
    bool? isOtpSending,
    bool? isOtpVerifying,
    String? otpErrorMessage,
    String? selectedUnitId,
    double? selectedUnitRent,
    double? securityDeposit,
    DateTime? leaseStart,
    DateTime? leaseEnd,
    String? uploadedContractFileName,
    String? uploadedContractFilePath,
    bool? isSubmitting,
    String? submitError,
  }) {
    return TenantOnboardingData(
      firstName: firstName ?? this.firstName,
      middleName: middleName ?? this.middleName,
      lastName: lastName ?? this.lastName,
      suffix: suffix ?? this.suffix,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      facebookUrl: facebookUrl ?? this.facebookUrl,
      emergencyName: emergencyName ?? this.emergencyName,
      emergencyRelationship: emergencyRelationship ?? this.emergencyRelationship,
      emergencyPhone: emergencyPhone ?? this.emergencyPhone,
      emergencyFacebookUrl: emergencyFacebookUrl ?? this.emergencyFacebookUrl,
      otpDigits: otpDigits ?? List.from(this.otpDigits),
      isOtpVerified: isOtpVerified ?? this.isOtpVerified,
      isOtpSending: isOtpSending ?? this.isOtpSending,
      isOtpVerifying: isOtpVerifying ?? this.isOtpVerifying,
      otpErrorMessage: otpErrorMessage,
      selectedUnitId: selectedUnitId ?? this.selectedUnitId,
      selectedUnitRent: selectedUnitRent ?? this.selectedUnitRent,
      securityDeposit: securityDeposit ?? this.securityDeposit,
      leaseStart: leaseStart ?? this.leaseStart,
      leaseEnd: leaseEnd ?? this.leaseEnd,
      uploadedContractFileName: uploadedContractFileName ?? this.uploadedContractFileName,
      uploadedContractFilePath: uploadedContractFilePath ?? this.uploadedContractFilePath,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      submitError: submitError,
    );
  }

  String get fullName {
    return [firstName, middleName, lastName, suffix]
        .where((part) => part.trim().isNotEmpty)
        .join(' ');
  }

  String get fullOtpCode => otpDigits.join().trim();
}

/// StateNotifier handling the onboarding payload across all 4 stages
class TenantOnboardingNotifier extends StateNotifier<TenantOnboardingData> {
  final Ref _ref;
  final SupabaseAuthService _authService = SupabaseAuthService();
  final SupabaseDbService _dbService = SupabaseDbService();
  final LocalDatabaseService _localDb = LocalDatabaseService();

  TenantOnboardingNotifier(this._ref) : super(TenantOnboardingData());

  void updateBasicInfo({
    String? firstName,
    String? middleName,
    String? lastName,
    String? suffix,
    DateTime? dateOfBirth,
    String? phone,
    String? email,
    String? facebookUrl,
  }) {
    state = state.copyWith(
      firstName: firstName,
      middleName: middleName,
      lastName: lastName,
      suffix: suffix,
      dateOfBirth: dateOfBirth,
      phone: phone,
      email: email,
      facebookUrl: facebookUrl,
    );
  }

  void updateEmergencyContact({
    String? emergencyName,
    String? emergencyRelationship,
    String? emergencyPhone,
    String? emergencyFacebookUrl,
  }) {
    state = state.copyWith(
      emergencyName: emergencyName,
      emergencyRelationship: emergencyRelationship,
      emergencyPhone: emergencyPhone,
      emergencyFacebookUrl: emergencyFacebookUrl,
    );
  }

  void updateOtpDigit(int index, String digit) {
    if (index < 0 || index >= 8) return;
    final updatedDigits = List<String>.from(state.otpDigits);
    updatedDigits[index] = digit;
    state = state.copyWith(
      otpDigits: updatedDigits,
      otpErrorMessage: null,
    );
  }

  void setPastedOtp(String full8DigitCode) {
    final digits = full8DigitCode.replaceAll(RegExp(r'\D'), '');
    final updatedDigits = List<String>.filled(8, '');
    for (int i = 0; i < 8 && i < digits.length; i++) {
      updatedDigits[i] = digits[i];
    }
    state = state.copyWith(
      otpDigits: updatedDigits,
      otpErrorMessage: null,
    );
  }

  Future<bool> sendOtpEmail() async {
    final email = state.email.trim().toLowerCase();
    if (email.isEmpty) return false;

    state = state.copyWith(isOtpSending: true, otpErrorMessage: null);
    try {
      final res = await _authService.sendTenantOtp(email);
      _ref.read(otpTimerProvider.notifier).startTimer();
      state = state.copyWith(
        isOtpSending: false,
        otpDigits: List.filled(8, ''),
        isOtpVerified: false,
      );
      return res['success'] == true;
    } catch (e) {
      state = state.copyWith(
        isOtpSending: false,
        otpErrorMessage: e.toString(),
      );
      return false;
    }
  }

  Future<bool> verifyOtpCode() async {
    final email = state.email.trim().toLowerCase();
    final code = state.fullOtpCode;

    if (code.length < 8) {
      state = state.copyWith(
        otpErrorMessage: 'Please enter all 8 digits of the OTP code.',
      );
      return false;
    }

    state = state.copyWith(isOtpVerifying: true, otpErrorMessage: null);

    try {
      final res = await _authService.verifyTenantOtpDetailed(email, code);
      if (res['verified'] == true) {
        state = state.copyWith(
          isOtpVerifying: false,
          isOtpVerified: true,
          otpErrorMessage: null,
        );
        return true;
      } else {
        final err = res['error'] ?? 'Verification failed';
        state = state.copyWith(
          isOtpVerifying: false,
          isOtpVerified: false,
          otpErrorMessage: err,
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isOtpVerifying: false,
        isOtpVerified: false,
        otpErrorMessage: e.toString(),
      );
      return false;
    }
  }

  void updateLeaseInfo({
    String? selectedUnitId,
    double? selectedUnitRent,
    double? securityDeposit,
    DateTime? leaseStart,
    DateTime? leaseEnd,
    String? uploadedContractFileName,
    String? uploadedContractFilePath,
  }) {
    state = state.copyWith(
      selectedUnitId: selectedUnitId,
      selectedUnitRent: selectedUnitRent,
      securityDeposit: securityDeposit,
      leaseStart: leaseStart,
      leaseEnd: leaseEnd,
      uploadedContractFileName: uploadedContractFileName,
      uploadedContractFilePath: uploadedContractFilePath,
    );
  }

  /// Automated Post-Onboarding Execution
  /// 1. Insert local DB cache
  /// 2. Insert public.tenants in Supabase
  /// 3. Update public.units (status='Occupied', tenant_id=[new_tenant_id])
  /// 4. Insert public.audit_logs (Action: 'ADD_TENANT')
  /// 5. Call create-tenant-user auth function
  Future<bool> finalizeTenantOnboarding(RentalUnit selectedUnit) async {
    state = state.copyWith(isSubmitting: true, submitError: null);

    final tenantId = 't_${DateTime.now().millisecondsSinceEpoch}';
    final cleanedPhone = state.phone.replaceAll(RegExp(r'\D'), '');
    final cleanedEmergencyPhone = state.emergencyPhone.replaceAll(RegExp(r'\D'), '');
    final cleanedEmail = state.email.trim().toLowerCase();

    final tenantRecord = TenantRecord(
      id: tenantId,
      name: state.fullName,
      firstName: state.firstName.trim(),
      middleName: state.middleName.trim(),
      lastName: state.lastName.trim(),
      suffix: state.suffix.trim(),
      dateOfBirth: state.dateOfBirth,
      phone: cleanedPhone,
      email: cleanedEmail,
      facebookUrl: state.facebookUrl.trim(),
      emergencyName: state.emergencyName.trim(),
      emergencyRelationship: state.emergencyRelationship,
      emergencyPhone: cleanedEmergencyPhone,
      emergencyFacebookUrl: state.emergencyFacebookUrl.trim(),
      unitId: selectedUnit.id,
      unitNumber: selectedUnit.unitNumber,
      monthlyRent: selectedUnit.monthlyRent,
      balance: 0.0,
      securityDeposit: state.securityDeposit,
      leaseStart: state.leaseStart,
      leaseEnd: state.leaseEnd,
      dueDate: DateTime.now().add(const Duration(days: 30)),
      healthStatus: 'green',
      messengerHandle: state.facebookUrl.trim(),
    );

    try {
      // 1. Insert into local DB cache
      final currentLocalTenants = await _localDb.getTenants();
      await _localDb.saveTenants([tenantRecord, ...currentLocalTenants]);

      // 2. Insert into public.tenants & 3. Audit log in Supabase
      await _ref.read(tenantsProvider.notifier).addTenant(tenantRecord);

      // 3. Update selected unit status in public.units
      await _ref.read(unitsProvider.notifier).updateUnitStatus(
            selectedUnit.id,
            'Occupied',
            tenantRecord.id,
            tenantRecord.name,
          );

      // 4. Log audit action
      await _dbService.logAuditAction(
        'ADD_TENANT',
        'Added tenant ${tenantRecord.name} (${tenantRecord.email}) to Unit ${selectedUnit.unitNumber}',
      );

      // Note: Auth account creation is automatically performed inside addTenant (upsertTenant)
      // and auto-confirmed via Supabase database triggers.

      state = state.copyWith(isSubmitting: false, submitError: null);
      return true;
    } catch (e) {
      debugPrint('Error in finalizeTenantOnboarding: $e');
      state = state.copyWith(isSubmitting: false, submitError: e.toString());
      return false;
    }
  }

  void reset() {
    _ref.read(otpTimerProvider.notifier).stopTimer();
    state = TenantOnboardingData();
    _ref.read(tenantOnboardingStageProvider.notifier).state = 1;
  }
}

final tenantOnboardingProvider =
    StateNotifierProvider<TenantOnboardingNotifier, TenantOnboardingData>((ref) {
  return TenantOnboardingNotifier(ref);
});
