import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../network/result.dart';
import '../network/supabase/supabase_config.dart';

class SupabaseService {
  SupabaseService({SupabaseClient? client})
      : _client = client ?? SupabaseConfig.client;

  final SupabaseClient _client;

  /// Map collection names used in Flutter code to PostgreSQL table names
  static String mapTableName(String collectionName) {
    return collectionName.replaceAllMapped(
      RegExp(r'([A-Z])'),
      (match) => '_${match.group(1)!.toLowerCase()}',
    );
  }

  /// Converts a camelCase map to snake_case for PostgreSQL
  static Map<String, dynamic> toSnakeCaseMap(Map<String, dynamic> data) {
    final result = <String, dynamic>{};
    data.forEach((key, value) {
      final snakeKey = key.replaceAllMapped(
        RegExp(r'([A-Z])'),
        (match) => '_${match.group(1)!.toLowerCase()}',
      );
      if (value is DateTime) {
        result[snakeKey] = value.toIso8601String();
      } else {
        result[snakeKey] = value;
      }
    });
    return result;
  }

  /// Converts a snake_case map from PostgreSQL to camelCase for Flutter models
  static Map<String, dynamic> toCamelCaseMap(Map<String, dynamic> data) {
    final result = <String, dynamic>{};
    data.forEach((key, value) {
      final camelKey = key.replaceAllMapped(
        RegExp(r'_([a-z])'),
        (match) => match.group(1)!.toUpperCase(),
      );
      result[camelKey] = value;
    });
    return result;
  }

  /// Sanitizes, normalizes, and validates payload map before sending to PostgreSQL
  static Map<String, dynamic> sanitizeAndValidatePayload(
    String collectionName,
    Map<String, dynamic> data,
  ) {
    final sanitized = Map<String, dynamic>.from(data);

    // 1. Ensure ID is valid and non-empty
    var id = (sanitized['id'] as String?)?.trim() ?? '';
    if (id.isEmpty) {
      id =
          '${collectionName.toLowerCase()}_${DateTime.now().millisecondsSinceEpoch}';
    }
    sanitized['id'] = id;

    // 2. Sanitize and bound fields
    sanitized.forEach((key, value) {
      if (value is String) {
        var text = value.trim();
        // Lowercase emails
        if (key.toLowerCase().contains('email')) {
          text = text.toLowerCase();
        }
        // Normalize Philippine phone numbers
        if (key.toLowerCase().contains('phone') ||
            key.toLowerCase().contains('contact')) {
          text = _normalizePhone(text);
        }
        // Sanitize payment references (remove whitespace, uppercase)
        if (key == 'referenceNumber') {
          text = text.replaceAll(RegExp(r'\s'), '').toUpperCase();
        }
        sanitized[key] = text;
      } else if (value is num) {
        // Clamp financial and numerical amounts to non-negative upper bounds
        if (key == 'rentDueDay') {
          sanitized[key] = value.toInt().clamp(1, 31);
        } else if (key == 'rating') {
          sanitized[key] = value.toInt().clamp(1, 5);
        } else if (key.toLowerCase().contains('bedrooms') ||
            key.toLowerCase().contains('bathrooms') ||
            key.toLowerCase().contains('days')) {
          sanitized[key] = value.toInt().clamp(0, 100);
        } else if (key.toLowerCase().contains('rent') ||
            key.toLowerCase().contains('amount') ||
            key.toLowerCase().contains('cost') ||
            key.toLowerCase().contains('bill') ||
            key.toLowerCase().contains('fee') ||
            key.toLowerCase().contains('balance')) {
          sanitized[key] = value.toDouble().clamp(0.0, 50000000.0);
        } else if (value is double && value == value.truncateToDouble()) {
          sanitized[key] = value.toInt();
        }
      } else if (value is DateTime) {
        if (value.year < 1970 || value.year > 2150) {
          sanitized[key] = DateTime.now();
        }
      }
    });

    return sanitized;
  }

  static String _normalizePhone(String raw) {
    if (raw.isEmpty) return raw;
    final compact = raw.replaceAll(RegExp(r'[\s()-]'), '');
    if (compact.startsWith('+63')) return '0${compact.substring(3)}';
    if (compact.startsWith('63')) return '0${compact.substring(2)}';
    return compact;
  }

  Future<bool> testDatabaseConnection() async {
    try {
      final response = await _client
          .from('units')
          .select()
          .limit(1)
          .timeout(const Duration(seconds: 3));
      debugPrint(
          '✅ Supabase Database Connected! (Returned ${response.length} rows)');
      return true;
    } catch (e) {
      debugPrint('❌ Supabase Connection Check Failed: $e');
      return false;
    }
  }

  Future<Result<List<Map<String, dynamic>>>> loadTable(String tableName) async {
    final targetTable = mapTableName(tableName);
    try {
      final response = await _client
          .from(targetTable)
          .select()
          .timeout(const Duration(seconds: 10));
      final data = List<Map<String, dynamic>>.from(response)
          .map((row) => toCamelCaseMap(row))
          .toList();
      return Result.success(data);
    } catch (e) {
      debugPrint('⚠️ Supabase loadTable [$targetTable]: $e');
      return Result.failure('Failed to load table $targetTable', e);
    }
  }

  Stream<List<Map<String, dynamic>>> streamTable(String tableName) {
    final targetTable = mapTableName(tableName);
    try {
      return _client
          .from(targetTable)
          .stream(primaryKey: ['id'])
          .map((rows) => rows.map((r) => toCamelCaseMap(r)).toList())
          .handleError((e) {
            debugPrint('❌ Supabase streamTable error for [$targetTable]: $e');
            return <Map<String, dynamic>>[];
          });
    } catch (e) {
      debugPrint('❌ Supabase streamTable setup error for [$targetTable]: $e');
      return const Stream.empty();
    }
  }

  Future<Result<void>> upsertRecord(
      String tableName, Map<String, dynamic> data) async {
    final targetTable = mapTableName(tableName);
    final sanitizedData = sanitizeAndValidatePayload(tableName, data);
    final payload = toSnakeCaseMap(sanitizedData);
    try {
      await _client
          .from(targetTable)
          .upsert(payload)
          .timeout(const Duration(seconds: 10));
      return Result.success(null);
    } catch (e) {
      debugPrint('❌ Supabase upsertRecord error for [$targetTable]: $e');
      return Result.failure('Failed to upsert record in $targetTable', e);
    }
  }

  Future<Result<void>> deleteRecord(String tableName, String id) async {
    final targetTable = mapTableName(tableName);
    try {
      await _client
          .from(targetTable)
          .delete()
          .eq('id', id)
          .timeout(const Duration(seconds: 10));
      return Result.success(null);
    } catch (e) {
      debugPrint('❌ Supabase deleteRecord error for [$targetTable]: $e');
      return Result.failure('Failed to delete record in $targetTable', e);
    }
  }

  Future<Map<String, List<Map<String, dynamic>>>> loadCoreData() async {
    final collections = <String, List<Map<String, dynamic>>>{};
    for (final table in [
      'units',
      'tenants',
      'payments',
      'maintenanceTickets'
    ]) {
      final result = await loadTable(table);
      collections[table] = result.dataOrNull ?? [];
    }
    return collections;
  }
}
