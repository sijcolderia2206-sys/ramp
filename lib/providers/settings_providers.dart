// lib/providers/settings_providers.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/supabase_auth_service.dart';
import '../core/supabase_db_service.dart';
import '../core/services/local_database_service.dart';

// ==========================================
// 1. USER PROFILE PROVIDER
// ==========================================
class UserProfileState {
  final String name;
  final String email;
  final String role;
  final String avatarInitials;
  final bool isLoading;
  final String? error;

  const UserProfileState({
    required this.name,
    required this.email,
    required this.role,
    required this.avatarInitials,
    this.isLoading = false,
    this.error,
  });

  UserProfileState copyWith({
    String? name,
    String? email,
    String? role,
    String? avatarInitials,
    bool? isLoading,
    String? error,
  }) {
    return UserProfileState(
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      avatarInitials: avatarInitials ?? this.avatarInitials,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class UserProfileNotifier extends StateNotifier<UserProfileState> {
  final SupabaseAuthService _authService = SupabaseAuthService();

  UserProfileNotifier()
      : super(const UserProfileState(
          name: 'Apex Landlord Owner',
          email: 'landlord@ramp.com',
          role: 'Portfolio Admin',
          avatarInitials: 'AO',
          isLoading: true,
        )) {
    loadProfile();
  }

  Future<void> loadProfile() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final email = _authService.activeEmail;
      final user = _authService.currentUser;
      String name = 'Apex Landlord Owner';
      String role = 'Portfolio Admin';

      if (user != null) {
        final meta = user.userMetadata;
        if (meta != null) {
          if (meta['display_name'] != null && (meta['display_name'] as String).isNotEmpty) {
            name = meta['display_name'] as String;
          }
          if (meta['role'] != null && (meta['role'] as String).isNotEmpty) {
            role = meta['role'] as String;
          }
        }
      }

      final parts = name.trim().split(' ');
      String initials = 'AO';
      if (parts.isNotEmpty && parts.first.isNotEmpty) {
        if (parts.length > 1 && parts.last.isNotEmpty) {
          initials = '${parts.first[0]}${parts.last[0]}'.toUpperCase();
        } else {
          initials = parts.first.substring(0, parts.first.length >= 2 ? 2 : 1).toUpperCase();
        }
      }

      state = UserProfileState(
        name: name,
        email: email,
        role: role.contains('Admin') || role.contains('admin') ? role : '$role Admin',
        avatarInitials: initials,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
}

final userProfileProvider = StateNotifierProvider<UserProfileNotifier, UserProfileState>(
  (ref) => UserProfileNotifier(),
);

// ==========================================
// 2. SYNC STATUS PROVIDER
// ==========================================
class SyncStatusState {
  final DateTime? lastSyncedAt;
  final bool isSyncing;
  final int pendingCount;
  final String? lastError;

  const SyncStatusState({
    this.lastSyncedAt,
    this.isSyncing = false,
    this.pendingCount = 0,
    this.lastError,
  });

  SyncStatusState copyWith({
    DateTime? lastSyncedAt,
    bool? isSyncing,
    int? pendingCount,
    String? lastError,
  }) {
    return SyncStatusState(
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      isSyncing: isSyncing ?? this.isSyncing,
      pendingCount: pendingCount ?? this.pendingCount,
      lastError: lastError ?? this.lastError,
    );
  }
}

class SyncStatusNotifier extends StateNotifier<SyncStatusState> {
  final LocalDatabaseService _localDb = LocalDatabaseService();
  final SupabaseDbService _dbService = SupabaseDbService();

  SyncStatusNotifier()
      : super(SyncStatusState(
          lastSyncedAt: DateTime.now().subtract(const Duration(minutes: 12)),
          pendingCount: 0,
        )) {
    _checkPendingCount();
  }

  Future<void> _checkPendingCount() async {
    try {
      final actions = await _localDb.getPendingActions();
      state = state.copyWith(pendingCount: actions.length);
    } catch (e) {
      debugPrint('SyncStatusNotifier._checkPendingCount error: $e');
    }
  }

  Future<bool> forceCloudSync() async {
    state = state.copyWith(isSyncing: true, lastError: null);
    try {
      await Future.delayed(const Duration(milliseconds: 1500));
      await _dbService.processPendingSyncQueue();
      
      final now = DateTime.now();
      state = SyncStatusState(
        lastSyncedAt: now,
        isSyncing: false,
        pendingCount: 0,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isSyncing: false,
        lastError: 'Cloud synchronization error: $e',
      );
      return false;
    }
  }

  Future<bool> clearLocalCache() async {
    state = state.copyWith(isSyncing: true, lastError: null);
    try {
      await _localDb.clearAllCache();
      state = SyncStatusState(
        lastSyncedAt: null,
        isSyncing: false,
        pendingCount: 0,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isSyncing: false,
        lastError: 'Failed to clear local database cache: $e',
      );
      return false;
    }
  }
}

final syncStatusProvider = StateNotifierProvider<SyncStatusNotifier, SyncStatusState>(
  (ref) => SyncStatusNotifier(),
);

// ==========================================
// 4. NOTIFICATION SETTINGS PROVIDER
// ==========================================
class NotificationSettingsState {
  final bool overdueSmsAlerts;
  final bool urgentPushNotifications;

  const NotificationSettingsState({
    this.overdueSmsAlerts = true,
    this.urgentPushNotifications = true,
  });

  NotificationSettingsState copyWith({
    bool? overdueSmsAlerts,
    bool? urgentPushNotifications,
  }) {
    return NotificationSettingsState(
      overdueSmsAlerts: overdueSmsAlerts ?? this.overdueSmsAlerts,
      urgentPushNotifications: urgentPushNotifications ?? this.urgentPushNotifications,
    );
  }
}

class NotificationSettingsNotifier extends StateNotifier<NotificationSettingsState> {
  static const String _keySms = 'ramp_notif_overdue_sms';
  static const String _keyPush = 'ramp_notif_urgent_push';

  NotificationSettingsNotifier() : super(const NotificationSettingsState()) {
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sms = prefs.getBool(_keySms) ?? true;
      final push = prefs.getBool(_keyPush) ?? true;
      state = NotificationSettingsState(
        overdueSmsAlerts: sms,
        urgentPushNotifications: push,
      );
    } catch (e) {
      debugPrint('NotificationSettingsNotifier._loadFromPrefs error: $e');
    }
  }

  Future<void> toggleOverdueSms(bool val) async {
    state = state.copyWith(overdueSmsAlerts: val);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keySms, val);
    } catch (e) {
      debugPrint('Error persisting SMS toggle: $e');
    }
  }

  Future<void> toggleUrgentPush(bool val) async {
    state = state.copyWith(urgentPushNotifications: val);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyPush, val);
    } catch (e) {
      debugPrint('Error persisting Push toggle: $e');
    }
  }
}

final notificationSettingsProvider = StateNotifierProvider<NotificationSettingsNotifier, NotificationSettingsState>(
  (ref) => NotificationSettingsNotifier(),
);
