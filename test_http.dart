// ignore_for_file: avoid_print
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ramp/core/supabase_config.dart';

void main() async {
  final url = Uri.parse('${SupabaseConfig.defaultUrl}/auth/v1/signup');
  final response = await http.post(
    url,
    headers: {
      'apikey': SupabaseConfig.defaultAnonKey,
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'email': 'test2_tenant@example.com',
      'password': 'password123',
      'data': {
        'role': 'tenant',
        'display_name': 'Test Tenant 2'
      }
    }),
  );
  print(response.statusCode);
  print(response.body);
}
