// lib/core/services/local_database_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../supabase_auth_service.dart';
import '../../models/unit_model.dart';
import '../../models/tenant_model.dart';
import '../../models/payment_model.dart';
import '../../models/maintenance_ticket_model.dart';
import '../../models/pending_sync_action.dart';

/// Local Database Service acting as an account-scoped offline persistent cache layer.
/// Uses SharedPreferences with JSON serialization for fast, zero-dependency offline storage.
class LocalDatabaseService {
  static const String _keyUnits = 'ramp_local_units_v1';
  static const String _keyTenants = 'ramp_local_tenants_v1';
  static const String _keyPayments = 'ramp_local_payments_v1';
  static const String _keyTickets = 'ramp_local_tickets_v1';
  static const String _keyPendingActions = 'ramp_local_pending_actions_v1';

  static SharedPreferences? _prefs;

  static Future<SharedPreferences> _getPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  String _scopedKey(String baseKey, [String? userId]) {
    String? uid = userId;
    if (uid == null || uid.trim().isEmpty) {
      try {
        final user = Supabase.instance.client.auth.currentUser;
        uid = user?.id ?? user?.email;
      } catch (_) {}
    }
    if (uid == null || uid.trim().isEmpty) {
      try {
        final authService = SupabaseAuthService();
        uid = authService.activeEmail;
      } catch (_) {}
    }
    final activeUid = (uid != null && uid.trim().isNotEmpty)
        ? uid.trim().toLowerCase().replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_')
        : 'guest_account';
    return '${baseKey}_$activeUid';
  }

  // ==========================================
  // UNITS CACHE
  // ==========================================
  Future<void> saveUnits(List<RentalUnit> units, [String? userId]) async {
    try {
      final prefs = await _getPrefs();
      final jsonList = units.map((u) => u.toJson()).toList();
      await prefs.setString(_scopedKey(_keyUnits, userId), jsonEncode(jsonList));
    } catch (e) {
      debugPrint('LocalDatabaseService.saveUnits error: $e');
    }
  }

  Future<List<RentalUnit>> getUnits([String? userId]) async {
    try {
      final prefs = await _getPrefs();
      final raw = prefs.getString(_scopedKey(_keyUnits, userId));
      if (raw == null || raw.isEmpty) return [];
      final List decoded = jsonDecode(raw);
      return decoded.map((json) => RentalUnit.fromJson(Map<String, dynamic>.from(json))).toList();
    } catch (e) {
      debugPrint('LocalDatabaseService.getUnits error: $e');
      return [];
    }
  }

  // ==========================================
  // TENANTS CACHE
  // ==========================================
  Future<void> saveTenants(List<TenantRecord> tenants, [String? userId]) async {
    try {
      final prefs = await _getPrefs();
      final jsonList = tenants.map((t) => t.toJson()).toList();
      await prefs.setString(_scopedKey(_keyTenants, userId), jsonEncode(jsonList));
    } catch (e) {
      debugPrint('LocalDatabaseService.saveTenants error: $e');
    }
  }

  Future<List<TenantRecord>> getTenants([String? userId]) async {
    try {
      final prefs = await _getPrefs();
      final raw = prefs.getString(_scopedKey(_keyTenants, userId));
      if (raw == null || raw.isEmpty) return [];
      final List decoded = jsonDecode(raw);
      return decoded.map((json) => TenantRecord.fromJson(Map<String, dynamic>.from(json))).toList();
    } catch (e) {
      debugPrint('LocalDatabaseService.getTenants error: $e');
      return [];
    }
  }

  // ==========================================
  // PAYMENTS CACHE
  // ==========================================
  Future<void> savePayments(List<PaymentRecord> payments, [String? userId]) async {
    try {
      final prefs = await _getPrefs();
      final jsonList = payments.map((p) => p.toJson()).toList();
      await prefs.setString(_scopedKey(_keyPayments, userId), jsonEncode(jsonList));
    } catch (e) {
      debugPrint('LocalDatabaseService.savePayments error: $e');
    }
  }

  Future<List<PaymentRecord>> getPayments([String? userId]) async {
    try {
      final prefs = await _getPrefs();
      final raw = prefs.getString(_scopedKey(_keyPayments, userId));
      if (raw == null || raw.isEmpty) return [];
      final List decoded = jsonDecode(raw);
      return decoded.map((json) => PaymentRecord.fromJson(Map<String, dynamic>.from(json))).toList();
    } catch (e) {
      debugPrint('LocalDatabaseService.getPayments error: $e');
      return [];
    }
  }

  // ==========================================
  // MAINTENANCE TICKETS CACHE
  // ==========================================
  Future<void> saveTickets(List<MaintenanceTicket> tickets, [String? userId]) async {
    try {
      final prefs = await _getPrefs();
      final jsonList = tickets.map((t) => t.toJson()).toList();
      await prefs.setString(_scopedKey(_keyTickets, userId), jsonEncode(jsonList));
    } catch (e) {
      debugPrint('LocalDatabaseService.saveTickets error: $e');
    }
  }

  Future<List<MaintenanceTicket>> getTickets([String? userId]) async {
    try {
      final prefs = await _getPrefs();
      final raw = prefs.getString(_scopedKey(_keyTickets, userId));
      if (raw == null || raw.isEmpty) return [];
      final List decoded = jsonDecode(raw);
      return decoded.map((json) => MaintenanceTicket.fromJson(Map<String, dynamic>.from(json))).toList();
    } catch (e) {
      debugPrint('LocalDatabaseService.getTickets error: $e');
      return [];
    }
  }

  // ==========================================
  // PENDING OFFLINE SYNC QUEUE CACHE
  // ==========================================
  Future<void> savePendingActions(List<PendingSyncAction> actions, [String? userId]) async {
    try {
      final prefs = await _getPrefs();
      final jsonList = actions.map((a) => a.toJson()).toList();
      await prefs.setString(_scopedKey(_keyPendingActions, userId), jsonEncode(jsonList));
    } catch (e) {
      debugPrint('LocalDatabaseService.savePendingActions error: $e');
    }
  }

  Future<List<PendingSyncAction>> getPendingActions([String? userId]) async {
    try {
      final prefs = await _getPrefs();
      final raw = prefs.getString(_scopedKey(_keyPendingActions, userId));
      if (raw == null || raw.isEmpty) return [];
      final List decoded = jsonDecode(raw);
      return decoded.map((json) => PendingSyncAction.fromJson(Map<String, dynamic>.from(json))).toList();
    } catch (e) {
      debugPrint('LocalDatabaseService.getPendingActions error: $e');
      return [];
    }
  }

  // ==========================================
  // PROPERTY SETTINGS CACHE
  // ==========================================
  Future<void> savePropertySettings(Map<String, dynamic> settingsMap) async {
    try {
      final prefs = await _getPrefs();
      await prefs.setString('ramp_local_settings_v1', jsonEncode(settingsMap));
    } catch (e) {
      debugPrint('LocalDatabaseService.savePropertySettings error: $e');
    }
  }

  Future<Map<String, dynamic>?> getPropertySettings() async {
    try {
      final prefs = await _getPrefs();
      final raw = prefs.getString('ramp_local_settings_v1');
      if (raw == null || raw.isEmpty) return null;
      return Map<String, dynamic>.from(jsonDecode(raw));
    } catch (e) {
      debugPrint('LocalDatabaseService.getPropertySettings error: $e');
      return null;
    }
  }

  // ==========================================
  // CLEAR ALL LOCAL CACHE
  // ==========================================
  Future<void> clearAllCache([String? userId]) async {
    try {
      final prefs = await _getPrefs();
      await prefs.remove(_scopedKey(_keyUnits, userId));
      await prefs.remove(_scopedKey(_keyTenants, userId));
      await prefs.remove(_scopedKey(_keyPayments, userId));
      await prefs.remove(_scopedKey(_keyTickets, userId));
      await prefs.remove(_scopedKey(_keyPendingActions, userId));
    } catch (e) {
      debugPrint('LocalDatabaseService.clearAllCache error: $e');
    }
  }
}
