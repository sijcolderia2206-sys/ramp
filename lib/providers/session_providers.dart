// lib/providers/session_providers.dart
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/session_service.dart';
import '../core/services/cache_and_storage_service.dart';

class SessionState {
  final List<SessionInfo> activeSessions;
  final SessionInfo? nowSession;
  final CacheSummary? cacheSummary;
  final bool isLoading;
  final bool isActionInProgress;
  final String? statusMessage;
  final String? errorMessage;

  const SessionState({
    this.activeSessions = const [],
    this.nowSession,
    this.cacheSummary,
    this.isLoading = false,
    this.isActionInProgress = false,
    this.statusMessage,
    this.errorMessage,
  });

  SessionState copyWith({
    List<SessionInfo>? activeSessions,
    SessionInfo? nowSession,
    CacheSummary? cacheSummary,
    bool? isLoading,
    bool? isActionInProgress,
    String? statusMessage,
    String? errorMessage,
  }) {
    return SessionState(
      activeSessions: activeSessions ?? this.activeSessions,
      nowSession: nowSession ?? this.nowSession,
      cacheSummary: cacheSummary ?? this.cacheSummary,
      isLoading: isLoading ?? this.isLoading,
      isActionInProgress: isActionInProgress ?? this.isActionInProgress,
      statusMessage: statusMessage ?? this.statusMessage,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class SessionNotifier extends StateNotifier<SessionState> {
  final SessionService _sessionService = SessionService();
  final CacheAndStorageService _cacheService = CacheAndStorageService();

  SessionNotifier() : super(const SessionState()) {
    loadSessionData();
  }

  Future<void> loadSessionData() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final sessions = await _sessionService.getActiveSessions();
      final nowSess = await _sessionService.getNowSession();
      final summary = await _cacheService.getCacheSummary();

      state = SessionState(
        activeSessions: sessions,
        nowSession: nowSess,
        cacheSummary: summary,
        isLoading: false,
      );
    } catch (e) {
      debugPrint('SessionNotifier.loadSessionData error: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load session details: $e',
      );
    }
  }

  Future<bool> refreshCurrentSession() async {
    state = state.copyWith(isActionInProgress: true, errorMessage: null);
    try {
      final success = await _sessionService.refreshSession();
      if (success) {
        await loadSessionData();
        state = state.copyWith(
          isActionInProgress: false,
          statusMessage: 'Active session token refreshed successfully.',
        );
        return true;
      } else {
        state = state.copyWith(
          isActionInProgress: false,
          errorMessage: 'Unable to refresh session token.',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isActionInProgress: false,
        errorMessage: 'Session refresh failed: $e',
      );
      return false;
    }
  }

  Future<bool> revokeOtherSessions() async {
    state = state.copyWith(isActionInProgress: true, errorMessage: null);
    try {
      final success = await _sessionService.revokeOtherSessions();
      if (success) {
        await loadSessionData();
        state = state.copyWith(
          isActionInProgress: false,
          statusMessage: 'All other device sessions have been revoked.',
        );
        return true;
      } else {
        state = state.copyWith(
          isActionInProgress: false,
          errorMessage: 'Failed to revoke other device sessions.',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isActionInProgress: false,
        errorMessage: 'Revoke error: $e',
      );
      return false;
    }
  }

  Future<bool> clearAppCache() async {
    state = state.copyWith(isActionInProgress: true, errorMessage: null);
    try {
      await _cacheService.clearDatabaseCache();
      await _cacheService.clearImageAndHttpCache();
      await loadSessionData();
      state = state.copyWith(
        isActionInProgress: false,
        statusMessage: 'Local database cache and memory cleared successfully.',
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isActionInProgress: false,
        errorMessage: 'Clear cache error: $e',
      );
      return false;
    }
  }
}

final sessionProvider = StateNotifierProvider<SessionNotifier, SessionState>(
  (ref) => SessionNotifier(),
);
