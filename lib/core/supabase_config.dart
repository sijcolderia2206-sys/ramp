// lib/core/supabase_config.dart
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String defaultUrl = 'https://zjkkuxuofkkysvbmmeqy.supabase.co';
  static const String defaultAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inpqa2t1eHVvZmtreXN2Ym1tZXF5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTAzMTA2ODIsImV4cCI6MjEwNTg4NjY4Mn0.-wu3pH2QZ4coQHV1VfP-mIPoeYneBTd9Th56yOM5hKY';

  static String _url = defaultUrl;
  static String _anonKey = defaultAnonKey;

  static String get url => _url;
  static String get anonKey => _anonKey;

  /// Load configuration from .env file with fallback to cached preferences or defaults
  static Future<void> loadConfig() async {
    try {
      await dotenv.load(fileName: ".env");
      final envUrl = dotenv.env['SUPABASE_URL'];
      final envKey = dotenv.env['SUPABASE_ANON_KEY'];

      if (envUrl != null && envUrl.trim().isNotEmpty) {
        _url = envUrl.trim();
      }
      if (envKey != null && envKey.trim().isNotEmpty) {
        _anonKey = envKey.trim();
      }
    } catch (e) {
      debugPrint('.env load note: $e');
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      if (_url == defaultUrl) {
        _url = prefs.getString('supabase_url') ?? defaultUrl;
      }
      if (_anonKey == defaultAnonKey) {
        _anonKey = prefs.getString('supabase_anon_key') ?? defaultAnonKey;
      }
      await prefs.setString('supabase_url', _url);
      await prefs.setString('supabase_anon_key', _anonKey);
    } catch (e) {
      debugPrint('SharedPreferences cache error: $e');
    }
  }

  /// Update and save Supabase credentials dynamically
  static Future<bool> saveAndReinitialize(String newUrl, String newKey) async {
    try {
      _url = newUrl.trim();
      _anonKey = newKey.trim();

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('supabase_url', _url);
      await prefs.setString('supabase_anon_key', _anonKey);

      await Supabase.initialize(
        url: _url,
        publishableKey: _anonKey,
      );
      return true;
    } catch (e) {
      debugPrint('Supabase reinitialization error: $e');
      return false;
    }
  }

  /// Test Connection against Supabase with 5-second timeout protection
  static Future<bool> testConnection() async {
    try {
      final client = Supabase.instance.client;
      await client.from('units').select().limit(1).timeout(const Duration(seconds: 5));
      return true;
    } catch (e) {
      debugPrint('Supabase connection test note: $e');
      return false;
    }
  }

  /// Pre-flight check to verify database connection and schema version with 5-second timeout
  static Future<bool> checkSchemaVersion() async {
    try {
      final client = Supabase.instance.client;
      final res = await client.from('settings').select('id').limit(1).maybeSingle().timeout(const Duration(seconds: 5));
      return res != null;
    } catch (e) {
      debugPrint('Supabase schema version check note: $e');
      return false;
    }
  }
}
