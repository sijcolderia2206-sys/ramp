library;

/// Utility functions for safe JSON parsing across Supabase & Local Database services.
/// Prevents runtime TypeErrors and NoSuchMethodErrors when DB columns return dynamic types.

double parseDouble(dynamic val, [double defaultValue = 0.0]) {
  if (val == null) return defaultValue;
  if (val is num) return val.toDouble();
  if (val is String) return double.tryParse(val) ?? defaultValue;
  return defaultValue;
}

double? parseNullableDouble(dynamic val) {
  if (val == null) return null;
  if (val is num) return val.toDouble();
  if (val is String) return double.tryParse(val);
  return null;
}

int parseInt(dynamic val, [int defaultValue = 0]) {
  if (val == null) return defaultValue;
  if (val is int) return val;
  if (val is num) return val.toInt();
  if (val is String) return int.tryParse(val) ?? defaultValue;
  return defaultValue;
}

int? parseNullableInt(dynamic val) {
  if (val == null) return null;
  if (val is int) return val;
  if (val is num) return val.toInt();
  if (val is String) return int.tryParse(val);
  return null;
}

String parseString(dynamic val, [String defaultValue = '']) {
  if (val == null) return defaultValue;
  final str = val.toString();
  return str.isNotEmpty ? str : defaultValue;
}

String? parseNullableString(dynamic val) {
  if (val == null) return null;
  final str = val.toString().trim();
  return str.isNotEmpty ? str : null;
}

bool parseBool(dynamic val, [bool defaultValue = false]) {
  if (val == null) return defaultValue;
  if (val is bool) return val;
  if (val is num) return val != 0;
  if (val is String) {
    final lower = val.toLowerCase().trim();
    if (lower == 'true' || lower == '1' || lower == 'yes') return true;
    if (lower == 'false' || lower == '0' || lower == 'no') return false;
  }
  return defaultValue;
}

DateTime parseDateTime(dynamic val, [DateTime? defaultValue]) {
  if (val == null) return defaultValue ?? DateTime.now();
  if (val is DateTime) return val;
  if (val is String && val.trim().isNotEmpty) {
    final parsed = DateTime.tryParse(val.trim());
    if (parsed != null) return parsed;
  }
  return defaultValue ?? DateTime.now();
}

DateTime? parseNullableDateTime(dynamic val) {
  if (val == null) return null;
  if (val is DateTime) return val;
  if (val is String && val.trim().isNotEmpty) {
    return DateTime.tryParse(val.trim());
  }
  return null;
}

List<String> parseStringList(dynamic val, [List<String> defaultValue = const []]) {
  if (val == null) return defaultValue;
  if (val is List) {
    return val.map((e) => e.toString()).toList();
  }
  if (val is String && val.trim().isNotEmpty) {
    var s = val.trim();
    if (s.startsWith('{') && s.endsWith('}')) {
      s = s.substring(1, s.length - 1);
    }
    if (s.isEmpty) return defaultValue;
    return s.split(',').map((e) => e.trim().replaceAll('"', '')).where((e) => e.isNotEmpty).toList();
  }
  return defaultValue;
}
