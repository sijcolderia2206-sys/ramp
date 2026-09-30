import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://zjkkuxuofkkysvbmmeqy.supabase.co',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inpqa2t1eHVvZmtreXN2Ym1tZXF5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTAzMTA2ODIsImV4cCI6MjEwNTg4NjY4Mn0.-wu3pH2QZ4coQHV1VfP-mIPoeYneBTd9Th56yOM5hKY',
  );

  static Future<void> initialize() async {
    if (supabaseUrl == 'YOUR_SUPABASE_URL_HERE' ||
        supabaseUrl.isEmpty ||
        supabaseAnonKey == 'YOUR_SUPABASE_ANON_KEY_HERE' ||
        supabaseAnonKey.isEmpty) {
      debugPrint(
          '⚠️ Supabase Config Warning: Placeholder URL or Anon Key detected. '
          'Please update SupabaseConfig with your project credentials.');
      return;
    }

    try {
      await Supabase.initialize(
        url: supabaseUrl,
        publishableKey: supabaseAnonKey,
      );
      debugPrint('✅ Supabase initialized successfully ($supabaseUrl)');
    } catch (e) {
      debugPrint('❌ Supabase Init Error: $e');
    }
  }

  static SupabaseClient get client => Supabase.instance.client;

  static Future<bool> testConnection() async {
    try {
      final response = client.auth.currentSession;
      debugPrint('⚡ Supabase Connection OK! (Session: ${response != null ? "Active" : "None"})');
      return true;
    } catch (e) {
      debugPrint('❌ Supabase Connection Test Error: $e');
      return false;
    }
  }
}
