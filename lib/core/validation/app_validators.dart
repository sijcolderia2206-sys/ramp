class AppValidators {
  AppValidators._();

  static String? requiredText(
    String? value, {
    required String label,
    int minLength = 2,
    int maxLength = 120,
    bool requireLetters = false,
  }) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Enter $label.';
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

  static String? personName(String? value, {String label = 'full name'}) {
    final required = requiredText(
      value,
      label: label,
      minLength: 2,
      maxLength: 80,
    );
    if (required != null) return required;
    final text = value!.trim();
    if (!RegExp(r"^[A-Za-zÀ-ÖØ-öø-ÿÑñ .'-]+$").hasMatch(text)) {
      return 'Use letters, spaces, apostrophes, periods, or hyphens only.';
    }
    return null;
  }

  static String? email(String? value, {bool required = true}) {
    final text = value?.trim().toLowerCase() ?? '';
    if (text.isEmpty) return required ? 'Enter an email address.' : null;
    if (text.length > 254 ||
        !RegExp(r"^[a-z0-9.!#$%&'*+/=?^_`{|}~-]+@(?:[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])?\.)+[a-z]{2,24}$")
            .hasMatch(text)) {
      return 'Enter a valid email, such as name@gmail.com.';
    }
    return null;
  }

  static String? philippinePhone(String? value, {bool required = true}) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return required ? 'Enter a phone number.' : null;
    final compact = text.replaceAll(RegExp(r'[\s()-]'), '');
    final normalized = compact.startsWith('+63')
        ? '0${compact.substring(3)}'
        : compact.startsWith('63')
            ? '0${compact.substring(2)}'
            : compact;
    if (!RegExp(r'^09\d{9}$').hasMatch(normalized)) {
      return 'Enter an 11-digit PH mobile number, such as 09171234567.';
    }
    if (RegExp(r'^(\d)\1+$').hasMatch(normalized) ||
        normalized == '09000000000') {
      return 'Enter a real mobile number; repeated or all-zero numbers are invalid.';
    }
    return null;
  }

  static String? amount(
    String? value, {
    required String label,
    bool allowZero = false,
    double? maximum,
  }) {
    final text = value?.trim().replaceAll(',', '') ?? '';
    if (text.isEmpty) return 'Enter $label.';
    final parsed = double.tryParse(text);
    if (parsed == null || !parsed.isFinite) return 'Enter a valid $label.';
    if (allowZero ? parsed < 0 : parsed <= 0) {
      return allowZero
          ? '$label cannot be negative.'
          : '$label must be above zero.';
    }
    if (maximum != null && parsed > maximum) {
      return '$label cannot exceed ${maximum.toStringAsFixed(0)}.';
    }
    return null;
  }

  static String? wholeNumber(
    String? value, {
    required String label,
    int minimum = 0,
    int? maximum,
  }) {
    final parsed = int.tryParse(value?.trim() ?? '');
    if (parsed == null) return 'Enter a whole number for $label.';
    if (parsed < minimum) return '$label must be at least $minimum.';
    if (maximum != null && parsed > maximum) {
      return '$label cannot exceed $maximum.';
    }
    return null;
  }

  static String? url(String? value, {bool required = false}) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return required ? 'Enter a URL.' : null;
    final uri = Uri.tryParse(text);
    if (uri == null ||
        !uri.hasAuthority ||
        (uri.scheme != 'https' && uri.scheme != 'http')) {
      return 'Enter a complete http:// or https:// URL.';
    }
    return null;
  }

  static String? paymentReference(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Enter the payment reference number.';
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

  static String? billingMonth(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Enter the payment month.';
    if (!RegExp(
            r'^(Jan(?:uary)?|Feb(?:ruary)?|Mar(?:ch)?|Apr(?:il)?|May|Jun(?:e)?|Jul(?:y)?|Aug(?:ust)?|Sep(?:tember)?|Oct(?:ober)?|Nov(?:ember)?|Dec(?:ember)?)\s+20\d{2}$',
            caseSensitive: false)
        .hasMatch(text)) {
      return 'Use a month and year, such as September 2026.';
    }
    return null;
  }
}
