class AppValidators {
  AppValidators._();

  /// Validates required text fields with min and max character limits
  static String? requiredText(
    String? value, {
    required String label,
    int minLength = 2,
    int maxLength = 120,
    bool requireLetters = false,
  }) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'This field is required.';
    if (text.length < minLength) {
      return '$label must be at least $minLength characters.';
    }
    if (text.length > maxLength) {
      return '$label must be $maxLength characters or fewer.';
    }
    if (requireLetters && RegExp(r'^([\W_]|\d)*$').hasMatch(text)) {
      return '$label must include letters.';
    }
    return null;
  }

  /// Validates person names (min 2, max 50 chars, blocks single letters like "A" or "B")
  static String? personName(String? value, {String label = 'full name'}) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'This field is required.';
    if (text.length < 2) {
      return 'Please enter at least 2 characters for $label.';
    }
    if (text.length > 50) {
      return '$label cannot exceed 50 characters.';
    }
    if (!RegExp(r"^[A-Za-zÀ-ÖØ-öø-ÿÑñ .'-]+$").hasMatch(text)) {
      return 'Use letters, spaces, apostrophes, periods, or hyphens only.';
    }
    return null;
  }

  /// Validates description and notes fields (up to 500 chars)
  static String? notes(String? value,
      {int maxLength = 500, String label = 'Notes'}) {
    final text = value?.trim() ?? '';
    if (text.length > maxLength) {
      return '$label cannot exceed $maxLength characters.';
    }
    return null;
  }

  /// Validates email addresses (e.g. name@domain.com)
  static String? email(String? value, {bool required = true}) {
    final text = value?.trim().toLowerCase() ?? '';
    if (text.isEmpty) return required ? 'This field is required.' : null;
    if (text.length > 254 ||
        !RegExp(r"^[a-z0-9.!#$%&'*+/=?^_`{|}~-]+@(?:[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])?\.)+[a-z]{2,24}$")
            .hasMatch(text)) {
      return 'Please enter a valid email address (e.g. name@domain.com).';
    }
    return null;
  }

  /// Validates passwords (min 8 chars, 1 uppercase, 1 number, 1 special character)
  static String? password(String? value, {int minLength = 8}) {
    final text = value ?? '';
    if (text.isEmpty) return 'This field is required.';
    if (text.length < minLength) {
      return 'Password must be at least $minLength characters.';
    }
    if (!text.contains(RegExp(r'[A-Z]'))) {
      return 'Password must include at least 1 uppercase letter (A-Z).';
    }
    if (!text.contains(RegExp(r'[0-9]'))) {
      return 'Password must include at least 1 number (0-9).';
    }
    if (!text.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>\-_=+]'))) {
      return 'Password must include at least 1 special character (!@#\$%^&*).';
    }
    return null;
  }

  /// Validates user roles
  static String? userRole(String? value) {
    final text = value?.trim().toLowerCase() ?? '';
    if (text.isEmpty) return 'This field is required.';
    if (!['superadmin', 'super_admin', 'landlord', 'tenant'].contains(text)) {
      return 'Role must be Super Admin, Landlord, or Tenant.';
    }
    return null;
  }

  /// Validates Philippine contact numbers (11 digits: 09XXXXXXXXX or +639XXXXXXXXX)
  static String? philippinePhone(String? value, {bool required = true}) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return required ? 'This field is required.' : null;
    final compact = text.replaceAll(RegExp(r'[\s()-]'), '');
    final normalized = compact.startsWith('+63')
        ? '0${compact.substring(3)}'
        : compact.startsWith('63')
            ? '0${compact.substring(2)}'
            : compact;
    if (!RegExp(r'^09\d{9}$').hasMatch(normalized)) {
      return 'Please enter a valid 11-digit PH mobile number (09XXXXXXXXX).';
    }
    if (RegExp(r'^(\d)\1+$').hasMatch(normalized) ||
        normalized == '09000000000') {
      return 'Please enter a real mobile number; repeated or zero numbers are invalid.';
    }
    return null;
  }

  /// Validates positive monetary amounts (e.g. Rent, Balance)
  static String? amount(
    String? value, {
    required String label,
    bool allowZero = false,
    double? maximum,
  }) {
    final text = value?.trim().replaceAll(',', '') ?? '';
    if (text.isEmpty) return 'This field is required.';
    final parsed = double.tryParse(text);
    if (parsed == null || !parsed.isFinite) {
      return 'Please enter a valid number for $label.';
    }
    if (allowZero ? parsed < 0 : parsed <= 0) {
      return allowZero
          ? '$label cannot be negative.'
          : '$label must be a positive number greater than zero.';
    }
    if (maximum != null && parsed > maximum) {
      return '$label cannot exceed ${maximum.toStringAsFixed(0)}.';
    }
    return null;
  }

  /// Validates whole numbers
  static String? wholeNumber(
    String? value, {
    required String label,
    int minimum = 0,
    int? maximum,
  }) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'This field is required.';
    final parsed = int.tryParse(text);
    if (parsed == null) return 'Please enter a whole number for $label.';
    if (parsed < minimum) return '$label must be at least $minimum.';
    if (maximum != null && parsed > maximum) {
      return '$label cannot exceed $maximum.';
    }
    return null;
  }

  /// Validates web URLs
  static String? url(String? value, {bool required = false}) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return required ? 'This field is required.' : null;
    final uri = Uri.tryParse(text);
    if (uri == null ||
        !uri.hasAuthority ||
        (uri.scheme != 'https' && uri.scheme != 'http')) {
      return 'Please enter a valid URL (e.g. https://example.com).';
    }
    return null;
  }

  /// Validates payment reference numbers
  static String? paymentReference(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'This field is required.';
    if (text.length < 6 || text.length > 40) {
      return 'Reference number must contain 6–40 characters.';
    }
    if (!RegExp(r'^[A-Za-z0-9][A-Za-z0-9._/-]*$').hasMatch(text)) {
      return 'Use letters, numbers, dots, slashes, underscores, or hyphens only.';
    }
    if (RegExp(r'^0+$').hasMatch(text)) {
      return 'Reference number cannot contain only zeros.';
    }
    return null;
  }

  /// Validates billing month format (e.g. September 2026)
  static String? billingMonth(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'This field is required.';
    if (!RegExp(
            r'^(Jan(?:uary)?|Feb(?:ruary)?|Mar(?:ch)?|Apr(?:il)?|May|June?|July?|Aug(?:ust)?|Sep(?:tember)?|Oct(?:ober)?|Nov(?:ember)?|Dec(?:ember)?)\s+20\d{2}$',
            caseSensitive: false)
        .hasMatch(text)) {
      return 'Please enter a valid month and year (e.g. September 2026).';
    }
    return null;
  }

  /// Validates due date is not in the past
  static String? dueDateNotPast(DateTime? date, {String label = 'Due date'}) {
    if (date == null) return 'This field is required.';
    final today = DateTime.now();
    final startOfToday = DateTime(today.year, today.month, today.day);
    if (date.isBefore(startOfToday)) {
      return '$label cannot be in the past.';
    }
    return null;
  }

  /// Validates lease dates (move-in / lease start must be before move-out / lease end)
  static String? leaseDates(DateTime? start, DateTime? end) {
    if (start == null || end == null) {
      return 'Please select both lease start and end dates.';
    }
    if (!end.isAfter(start)) {
      return 'Lease end date must be after the lease start date.';
    }
    return null;
  }
}
