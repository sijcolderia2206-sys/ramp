// lib/core/services/cache_and_storage_service.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'local_database_service.dart';

class CacheSummary {
  final double databaseCacheKb;
  final double imageCacheKb;
  final double cookiesAndTokensKb;
  final double totalStorageKb;

  CacheSummary({
    required this.databaseCacheKb,
    required this.imageCacheKb,
    required this.cookiesAndTokensKb,
    required this.totalStorageKb,
  });

  String get databaseCacheFormatted => _formatSize(databaseCacheKb);
  String get imageCacheFormatted => _formatSize(imageCacheKb);
  String get cookiesAndTokensFormatted => _formatSize(cookiesAndTokensKb);
  String get totalStorageFormatted => _formatSize(totalStorageKb);

  static String _formatSize(double kb) {
    if (kb < 1024) {
      return '${kb.toStringAsFixed(1)} KB';
    }
    final mb = kb / 1024;
    return '${mb.toStringAsFixed(2)} MB';
  }
}

class CacheAndStorageService {
  final LocalDatabaseService _localDb = LocalDatabaseService();

  /// Inspect and calculate cache summary
  Future<CacheSummary> getCacheSummary() async {
    double dbKb = 0;
    double cookiesKb = 0;

    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();

      for (final key in keys) {
        final val = prefs.get(key);
        if (val == null) continue;
        final sizeInBytes = val.toString().length;
        final sizeInKb = sizeInBytes / 1024;

        if (key.contains('cache') || key.contains('units') || key.contains('tenants') || key.contains('payments') || key.contains('tickets')) {
          dbKb += sizeInKb;
        } else if (key.contains('token') || key.contains('session') || key.contains('auth') || key.contains('cookie')) {
          cookiesKb += sizeInKb;
        } else {
          dbKb += sizeInKb;
        }
      }
    } catch (e) {
      debugPrint('Error inspecting cache: $e');
    }

    // Image cache from PaintingBinding
    final imageCacheBytes = PaintingBinding.instance.imageCache.currentSizeBytes;
    final imageCacheKb = imageCacheBytes / 1024;

    final totalKb = dbKb + imageCacheKb + cookiesKb;

    return CacheSummary(
      databaseCacheKb: dbKb,
      imageCacheKb: imageCacheKb,
      cookiesAndTokensKb: cookiesKb,
      totalStorageKb: totalKb,
    );
  }

  /// Clear Local Offline Database Cache
  Future<void> clearDatabaseCache() async {
    await _localDb.clearAllCache();
  }

  /// Clear Image & HTTP Network Cache
  Future<void> clearImageAndHttpCache() async {
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();
  }

  /// Clear Stored Auth Cookies & Tokens
  Future<void> clearAuthCookiesAndTokens() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys().where((k) => k.contains('token') || k.contains('session') || k.contains('auth')).toList();
      for (final key in keys) {
        await prefs.remove(key);
      }
    } catch (e) {
      debugPrint('Error clearing auth tokens/cookies: $e');
    }
  }

  /// Complete Wipe of All Cache & Local Storage (preserves core Supabase endpoint config)
  Future<void> clearAllStorageAndCache() async {
    await clearDatabaseCache();
    await clearImageAndHttpCache();
    await clearAuthCookiesAndTokens();
    final prefs = await SharedPreferences.getInstance();
    final url = prefs.getString('supabase_url');
    final key = prefs.getString('supabase_anon_key');
    await prefs.clear();
    if (url != null) await prefs.setString('supabase_url', url);
    if (key != null) await prefs.setString('supabase_anon_key', key);
  }
}
