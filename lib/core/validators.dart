// lib/core/validators.dart
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../models/tenant_model.dart';
import '../models/unit_model.dart';

/// Formatter for Philippine mobile numbers (09xx xxx xxxx)
class PhilippinePhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String digits = newValue.text.replaceAll(RegExp(r'\D'), '');

    if (digits.length > 11) {
      digits = digits.substring(0, 11);
    }

    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i == 4 || i == 7) {
        buffer.write(' ');
      }
      buffer.write(digits[i]);
    }

    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

/// Global Form Validators class enforcing RAMP strict input validation rules
class FormValidators {
  /// Required Fields: Cannot be left blank
  static String? required(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName cannot be left blank.';
    }
    return null;
  }

  /// Name Validation: Must reject inputs that contain only 1 character
  static String? name(
    String? value,
    String fieldName, {
    int minLength = 2,
    int maxLength = 50,
    bool isRequired = true,
  }) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      if (isRequired) return '$fieldName cannot be left blank.';
      return null;
    }
    if (trimmed.length == 1) {
      return '$fieldName must be at least 2 characters long.';
    }
    if (trimmed.length < minLength) {
      return '$fieldName must be at least $minLength characters.';
    }
    if (trimmed.length > maxLength) {
      return '$fieldName cannot exceed $maxLength characters.';
    }
    final namePattern = RegExp(r"^[a-zA-Z\s\-\.\']+$");
    if (!namePattern.hasMatch(trimmed)) {
      return '$fieldName must only contain letters, spaces, -, ., or \'.';
    }
    return null;
  }

  /// Text Field Character Limits
  static String? textLength(
    String? value,
    String fieldName, {
    required int minLength,
    required int maxLength,
    bool isRequired = true,
  }) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      if (isRequired) return '$fieldName cannot be left blank.';
      return null;
    }
    if (trimmed.length < minLength) {
      return '$fieldName must be at least $minLength characters long.';
    }
    if (trimmed.length > maxLength) {
      return '$fieldName cannot exceed $maxLength characters.';
    }
    return null;
  }

  /// Sanitizes numeric strings by removing commas, currency symbols (₱, $), and whitespace
  static String sanitizeNumericInput(String? value) {
    if (value == null) return '';
    return value
        .replaceAll(',', '')
        .replaceAll('₱', '')
        .replaceAll('\$', '')
        .replaceAll('PHP', '')
        .replaceAll('Php', '')
        .trim();
  }

  /// Number Validation: Ensures numeric fields accept only valid numbers
  static String? number(
    String? value,
    String fieldName, {
    bool isRequired = true,
    double? min,
    double? max,
    bool allowZero = false,
  }) {
    final sanitized = sanitizeNumericInput(value);
    if (sanitized.isEmpty) {
      if (isRequired) return '$fieldName cannot be left blank.';
      return null;
    }
    final numberPattern = RegExp(r'^-?\d+(\.\d+)?$');
    if (!numberPattern.hasMatch(sanitized)) {
      return '$fieldName must be a valid number.';
    }
    final parsed = double.tryParse(sanitized);
    if (parsed == null) {
      return '$fieldName must be a valid number.';
    }
    if (!allowZero && parsed <= 0) {
      return '$fieldName must be greater than 0.';
    }
    if (allowZero && parsed < 0) {
      return '$fieldName cannot be negative.';
    }
    if (min != null && parsed < min) {
      return '$fieldName must be at least ${min.toStringAsFixed(0)}.';
    }
    if (max != null && parsed > max) {
      return '$fieldName cannot exceed ${max.toStringAsFixed(0)}.';
    }
    return null;
  }

  /// Email Validation using strict Regex
  static String? email(String? value, {bool isRequired = true}) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      if (isRequired) return 'Email address cannot be left blank.';
      return null;
    }
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(trimmed)) {
      return 'Please enter a valid email address (e.g. user@example.com).';
    }
    return null;
  }

  /// Email Validation alias for backward compatibility (accepts any valid email domain)
  static String? gmail(String? value, {bool isRequired = true}) {
    return email(value, isRequired: isRequired);
  }

  /// Contact Number Validation: Strict local format (e.g., exactly 11 digits starting with 09)
  static String? phone(String? value, {bool isRequired = true}) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      if (isRequired) return 'Contact number cannot be left blank.';
      return null;
    }
    final digits = trimmed.replaceAll(RegExp(r'\D'), '');
    if (!digits.startsWith('09') || digits.length != 11) {
      return 'Contact number must start with 09 and contain exactly 11 digits.';
    }
    return null;
  }

  /// Age / Date of Birth Validation: DOB must calculate to >= 18 years old (Birth year <= 1970 logic based on current date)
  static String? age(DateTime? dob) {
    if (dob == null) {
      return 'Date of birth is required.';
    }
    if (dob.year < 1970) {
      return 'Birth year cannot be earlier than 1970.';
    }
    final now = DateTime.now();
    final calculatedAge = now.year - dob.year - ((now.month < dob.month || (now.month == dob.month && now.day < dob.day)) ? 1 : 0);
    if (calculatedAge < 18) {
      return 'Tenant must be at least 18 years old.';
    }
    return null;
  }

  /// Facebook / Messenger Account Link Validation
  static String? facebookUrl(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return null;
    var normalized = trimmed.toLowerCase();
    if (!normalized.startsWith('http://') && !normalized.startsWith('https://')) {
      normalized = 'https://$normalized';
    }
    if (!normalized.contains('facebook.com') &&
        !normalized.contains('m.facebook.com') &&
        !normalized.contains('m.me') &&
        !normalized.contains('fb.com') &&
        !normalized.contains('fb.watch')) {
      return 'Facebook link must be a valid Facebook profile, page, or Messenger link.';
    }
    return null;
  }

  /// Meter Reading Validation
  static String? meterReading(
    String? value,
    String fieldName, {
    bool isRequired = true,
    double? previousReading,
  }) {
    final numErr = number(value, fieldName, isRequired: isRequired, allowZero: true);
    if (numErr != null) return numErr;

    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return null;

    final parsed = double.parse(trimmed);
    if (previousReading != null && parsed < previousReading) {
      return '$fieldName (${parsed.toStringAsFixed(1)}) cannot be less than previous reading (${previousReading.toStringAsFixed(1)}).';
    }
    return null;
  }
}

class RampValidators {
  /// Name Validation (Letters, spaces, -, ., ' only)
  static String? validateName(
    String? value,
    String fieldName, {
    int minLength = 2,
    int maxLength = 20,
    bool required = true,
  }) {
    return FormValidators.name(value, fieldName, minLength: minLength, maxLength: maxLength, isRequired: required);
  }

  /// Email Validation (Accepts any valid email)
  static String? validateGmail(String? value) {
    return FormValidators.email(value);
  }

  /// Unique Email Check
  static String? validateUniqueEmail(String? email, List<TenantRecord> tenants) {
    final trimmed = (email ?? '').trim().toLowerCase();
    if (trimmed.isEmpty) return null;
    final exists = tenants.any((t) => (t.email ?? '').trim().toLowerCase() == trimmed);
    if (exists) {
      return 'Email address is already registered to another tenant.';
    }
    return null;
  }

  /// Generic Email Validation
  static String? validateEmail(String? value) {
    return FormValidators.email(value);
  }

  /// Phone Number Validation (09xx xxx xxxx, 11 digits, starts with 09)
  static String? validatePhone(String? value) {
    return FormValidators.phone(value);
  }

  /// Unique Phone Number Check
  static String? validateUniquePhone(String? phone, List<TenantRecord> tenants) {
    final cleaned = (phone ?? '').replaceAll(RegExp(r'\D'), '');
    if (cleaned.isEmpty) return null;
    final exists = tenants.any((t) => t.phone.replaceAll(RegExp(r'\D'), '') == cleaned);
    if (exists) {
      return 'Phone number is already registered to another tenant.';
    }
    return null;
  }

  /// Facebook Account Link Validation
  static String? validateFacebookUrl(String? value) {
    return FormValidators.facebookUrl(value);
  }

  /// Positive Numeric Amount Validation
  static String? validatePositiveAmount(String? value, String fieldName) {
    return FormValidators.number(value, fieldName, isRequired: true, allowZero: false);
  }

  /// Date of Birth Validation (Year >= 1970 and Age >= 18)
  static String? validateBirthDate(DateTime? dob) {
    if (dob == null) {
      return 'Select Date of Birth';
    }
    if (dob.year < 1970) {
      return 'Birth year cannot be earlier than 1970.';
    }
    final now = DateTime.now();
    final min18Date = DateTime(now.year - 18, now.month, now.day);
    if (dob.isAfter(min18Date)) {
      return 'Tenant must be at least 18 years old.';
    }
    return null;
  }

  /// Validate Rental Unit Number
  static String? validateUnitNumber(
    String? value,
    List<RentalUnit> existingUnits, {
    String? currentUnitId,
  }) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return 'Unit number is required.';
    }
    if (trimmed.length > 20) {
      return 'Unit number must not exceed 20 characters.';
    }
    final unitPattern = RegExp(r'^[a-zA-Z0-9\s\-]+$');
    if (!unitPattern.hasMatch(trimmed)) {
      return 'Unit number can only contain letters, digits, spaces, or hyphens.';
    }
    final isDuplicate = existingUnits.any(
      (u) =>
          u.id != currentUnitId &&
          u.unitNumber.trim().toLowerCase() == trimmed.toLowerCase(),
    );
    if (isDuplicate) {
      return 'Unit number "$trimmed" already exists.';
    }
    return null;
  }

  /// Validate Optional Unit Title
  static String? validateUnitTitle(String? value) {
    return FormValidators.textLength(value, 'Title', minLength: 2, maxLength: 60, isRequired: false);
  }

  /// Validate Positive Number
  static String? validatePositiveNumber(
    String? value,
    String fieldName, {
    bool required = true,
    double min = 0.0,
    double max = 10000000.0,
  }) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      if (required) return '$fieldName is required.';
      return null;
    }
    final parsed = double.tryParse(trimmed);
    if (parsed == null) {
      return 'Please enter a valid number for $fieldName.';
    }
    if (parsed <= 0) {
      return '$fieldName must be at least ₱${min.toInt()}.';
    }
    if (parsed > max) {
      return '$fieldName cannot exceed ₱${max.toInt()}.';
    }
    return null;
  }

  /// Validate Non-Negative Number
  static String? validateNonNegativeNumber(
    String? value,
    String fieldName, {
    bool required = false,
    double max = 1000000.0,
  }) {
    return FormValidators.number(value, fieldName, isRequired: required, max: max, allowZero: true);
  }

  /// Validate Rent Due Day (1-28)
  static String? validateRentDueDay(String? value, {bool required = true}) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      if (required) return 'Rent Due Day is required (1-28).';
      return null;
    }
    final parsed = int.tryParse(trimmed);
    if (parsed == null || parsed < 1 || parsed > 28) {
      return 'Rent Due Day must be between 1 and 28.';
    }
    return null;
  }

  /// Validate Floor Area in sqm
  static String? validateFloorArea(String? value, {bool required = false}) {
    final err = FormValidators.number(value, 'Floor Area', isRequired: required, min: 0.1, max: 10000, allowZero: false);
    if (err != null && value != null && value.trim().isNotEmpty) {
      return 'Floor area must be greater than 0 sqm.';
    }
    return err;
  }

  /// Validate Custom Area Name
  static String? validateCustomAreaName(
    String? value,
    List<String> existingAreas,
  ) {
    if (value == null || value.trim().isEmpty) {
      return 'Area name cannot be empty.';
    }
    final lenErr = FormValidators.textLength(value, 'Area name', minLength: 2, maxLength: 30, isRequired: true);
    if (lenErr != null) return lenErr;

    final trimmed = value.trim();
    final exists = existingAreas.any(
      (a) => a.trim().toLowerCase() == trimmed.toLowerCase(),
    );
    if (exists) {
      return 'Maintenance area "$trimmed" already exists.';
    }
    return null;
  }

  /// Password Validation: Minimum 6 characters required
  static String? validatePassword(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return 'Password cannot be left blank.';
    }
    if (trimmed.length < 6) {
      return 'Password must be at least 6 characters long.';
    }
    return null;
  }

  /// Payment Reference Number Validation
  static String? validateReferenceNumber(String? value, String paymentMethod) {
    final trimmed = value?.trim() ?? '';
    final method = paymentMethod.trim().toLowerCase();

    // Cash payments do not require reference numbers
    if (method == 'cash') {
      return null;
    }

    if (trimmed.isEmpty) {
      return 'Reference number is required for $paymentMethod payments.';
    }

    if (method.contains('gcash')) {
      final digits = trimmed.replaceAll(RegExp(r'\D'), '');
      if (digits.length != 13) {
        return 'GCash reference number must be exactly 13 digits.';
      }
    } else {
      if (trimmed.length < 6) {
        return 'Reference number must be at least 6 characters long.';
      }
    }
    return null;
  }
}

class RampFormatters {
  static final NumberFormat _currencyFormat = NumberFormat.currency(symbol: '₱', decimalDigits: 2);

  static String formatCurrency(double amount) {
    return _currencyFormat.format(amount);
  }

  static String formatSlaRemaining(DateTime slaDueDate) {
    final now = DateTime.now();
    final difference = slaDueDate.difference(now);

    if (difference.isNegative) {
      final hoursOverdue = difference.inHours.abs();
      return '🔴 Overdue by $hoursOverdue hrs';
    }

    if (difference.inHours < 24) {
      return '🟡 ${difference.inHours}h remaining';
    }

    return '🟢 ${difference.inDays}d remaining';
  }
}
