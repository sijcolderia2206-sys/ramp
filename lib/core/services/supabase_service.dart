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

  Future<bool> testDatabaseConnection() async {
    try {
      final response = await _client.from('units').select().limit(1);
      debugPrint('✅ Supabase Database Connected! (Returned ${response.length} rows)');
      return true;
    } catch (e) {
      debugPrint('❌ Supabase Connection Check Failed: $e');
      return false;
    }
  }

  Future<Result<List<Map<String, dynamic>>>> loadTable(String tableName) async {
    final targetTable = mapTableName(tableName);
    try {
      final response = await _client.from(targetTable).select();
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

  Future<Result<void>> upsertRecord(String tableName, Map<String, dynamic> data) async {
    final targetTable = mapTableName(tableName);
    final payload = toSnakeCaseMap(data);
    try {
      await _client.from(targetTable).upsert(payload);
      return Result.success(null);
    } catch (e) {
      debugPrint('❌ Supabase upsertRecord error for [$targetTable]: $e');
      return Result.failure('Failed to upsert record in $targetTable', e);
    }
  }

  Future<Result<void>> deleteRecord(String tableName, String id) async {
    final targetTable = mapTableName(tableName);
    try {
      await _client.from(targetTable).delete().eq('id', id);
      return Result.success(null);
    } catch (e) {
      debugPrint('❌ Supabase deleteRecord error for [$targetTable]: $e');
      return Result.failure('Failed to delete record in $targetTable', e);
    }
  }

  Future<Map<String, List<Map<String, dynamic>>>> loadCoreData() async {
    final collections = <String, List<Map<String, dynamic>>>{};
    for (final table in ['units', 'tenants', 'payments', 'maintenanceTickets']) {
      final result = await loadTable(table);
      collections[table] = result.dataOrNull ?? [];
    }
    return collections;
  }
}
