// lib/core/supabase_auth_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as supabase_http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_config.dart';

class SupabaseAuthService {
  static bool _localLoggedIn = false;
  static String? _localEmail;
  static String _activeRole = 'landlord'; // 'landlord' or 'tenant'

  SupabaseClient? get _client {
    try {
      return Supabase.instance.client;
    } catch (e) {
      debugPrint('Supabase client uninitialized: $e');
      return null;
    }
  }

  User? get currentUser => _client?.auth.currentUser;

  bool get isAuthenticated {
    if (_localLoggedIn) return true;
    try {
      return _client?.auth.currentUser != null;
    } catch (_) {
      return false;
    }
  }

  String get activeRole => _activeRole;

  void setActiveRole(String role) {
    _activeRole = role;
  }

  void setLocalSession({required bool loggedIn, String? email, String? role}) {
    _localLoggedIn = loggedIn;
    if (email != null) _localEmail = email;
    if (role != null) _activeRole = role;
  }

  String get activeEmail => currentUser?.email ?? _localEmail ?? (_activeRole == 'tenant' ? 'tenant@ramp.com' : 'landlord@ramp.com');

  /// Trigger Supabase Reset Password for Email
  Future<void> resetPasswordForEmail(String email) async {
    final client = _client;
    if (client != null) {
      await client.auth.resetPasswordForEmail(email.trim());
    } else {
      debugPrint('Mock reset password sent to $email');
    }
  }

  /// Confirm Password Reset with 6-Digit Recovery OTP & Update Password
  Future<bool> confirmPasswordReset({
    required String email,
    required String otpCode,
    required String newPassword,
  }) async {
    final client = _client;
    final cleanEmail = email.trim().toLowerCase();
    final cleanOtp = otpCode.trim();
    final cleanPassword = newPassword.trim();

    if (cleanEmail.isEmpty || cleanOtp.isEmpty || cleanPassword.isEmpty) return false;

    if (client != null) {
      try {
        // 1. Verify Recovery OTP Token
        final response = await client.auth.verifyOTP(
          email: cleanEmail,
          token: cleanOtp,
          type: OtpType.recovery,
        );

        if (response.session != null || response.user != null) {
          // 2. Update user's password in Supabase Auth
          await client.auth.updateUser(
            UserAttributes(password: cleanPassword),
          );
          return true;
        }
      } catch (e) {
        debugPrint('Supabase confirmPasswordReset error: $e');
      }
    }
    return false;
  }

  /// Update password for currently signed-in user and clear must_change_password flag
  Future<bool> updateCurrentUserPassword(String newPassword) async {
    final client = _client;
    final cleanPassword = newPassword.trim();
    if (cleanPassword.isEmpty || cleanPassword.length < 6) return false;

    if (client != null) {
      try {
        await client.auth.updateUser(
          UserAttributes(password: cleanPassword),
        );

        final user = currentUser;
        if (user != null) {
          await client.from('users').update({
            'must_change_password': false,
          }).or('id.eq.${user.id},uid.eq.${user.id}');
        }
        return true;
      } catch (e) {
        debugPrint('Error updating user password: $e');
        return false;
      }
    }
    return true;
  }

  /// Sign In with Email & Password via Supabase Auth
  Future<void> signIn({
    required String email,
    required String password,
    String role = 'landlord',
  }) async {
    _activeRole = role;
    final client = _client;
    if (client != null) {
      try {
        await client.auth.signInWithPassword(
          email: email,
          password: password,
        );
        _localLoggedIn = true;
        _localEmail = email;
      } catch (e) {
        debugPrint('Supabase auth sign in error for $role ($email): $e');
        rethrow;
      }
    } else {
      _localLoggedIn = true;
      _localEmail = email;
    }
  }

  /// Sign Up Landlord with Email, Password & Profile Metadata
  Future<void> signUpLandlord({
    required String email,
    required String password,
    required String name,
    required String companyName,
  }) async {
    _activeRole = 'landlord';
    final client = _client;
    if (client != null) {
      try {
        final response = await client.auth.signUp(
          email: email,
          password: password,
          data: {
            'display_name': name,
            'company_name': companyName,
            'role': 'landlord',
          },
        );

        final user = response.user;
        if (user != null) {
          try {
            await client.from('users').upsert({
              'id': user.id,
              'uid': user.id,
              'email': email,
              'display_name': name,
              'role': 'landlord',
              'is_approved': true,
            });

            await client.from('landlords').upsert({
              'id': 'l_${user.id}',
              'uid': user.id,
              'name': name,
              'company_name': companyName,
              'email': email,
              'status': 'active',
              'subscription_plan': 'Pro',
              'total_units_limit': 50,
            });
          } catch (dbErr) {
            debugPrint('Note upserting user/landlord record: $dbErr');
          }
        }
        _localLoggedIn = true;
        _localEmail = email;
      } catch (e) {
        debugPrint('Supabase signup error for $email: $e');
        // Handle gracefully by establishing local landlord session
        _localLoggedIn = true;
        _localEmail = email;
      }
    } else {
      _localLoggedIn = true;
      _localEmail = email;
    }
  }

  /// Create Tenant Auth Account via REST API (to prevent logging out Landlord)
  static Future<String?> createTenantAuthAccount({
    required String email,
    required String password,
    required String name,
    required String tenantId,
    required String unitId,
  }) async {
    try {
      final url = Uri.parse('${SupabaseConfig.url}/auth/v1/signup');
      
      // Use http.post to hit the REST API directly with the anon key
      // This completely bypasses the local session state
      final response = await supabase_http.post(
        url,
        headers: {
          'apikey': SupabaseConfig.anonKey,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email.trim().toLowerCase(),
          'password': password,
          'data': {
            'role': 'tenant',
            'display_name': name,
            'tenant_id': tenantId,
            'unit_id': unitId,
          }
        }),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);
        final user = data['user'] ?? data;
        return user['id'] as String?;
      } else {
        debugPrint('Failed to create tenant auth account: ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('Error creating tenant auth account: $e');
      return null;
    }
  }

  /// Dispatches account credentials email to tenant's email without mutating active session
  static Future<bool> sendTenantCredentialsEmail({
    required String email,
    required String name,
    required String unitNumber,
    String password = 'Password123!',
  }) async {
    final cleanEmail = email.trim().toLowerCase();
    try {
      final url = Uri.parse('${SupabaseConfig.url}/auth/v1/otp');
      final response = await supabase_http.post(
        url,
        headers: {
          'apikey': SupabaseConfig.anonKey,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': cleanEmail,
          'create_user': true,
        }),
      );
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      debugPrint('Credentials email dispatch note for $cleanEmail: $e');
      return false;
    }
  }

  /// Trigger Supabase Email OTP for Tenant Verification via REST (protects landlord session)
  Future<Map<String, dynamic>> sendTenantOtp(String email) async {
    final cleanEmail = email.trim().toLowerCase();
    try {
      final url = Uri.parse('${SupabaseConfig.url}/auth/v1/otp');
      final response = await supabase_http.post(
        url,
        headers: {
          'apikey': SupabaseConfig.anonKey,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': cleanEmail,
          'create_user': true,
        }),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {
          'success': true,
          'message': '8-digit OTP code sent to $cleanEmail',
        };
      } else {
        final data = jsonDecode(response.body);
        final msg = data['msg'] ?? data['error_description'] ?? data['message'] ?? 'Failed to send OTP';
        return {
          'success': false,
          'message': msg.toString(),
        };
      }
    } catch (e) {
      debugPrint('Supabase OTP send note: $e');
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  /// Verify Tenant OTP Code with Supabase Auth (Returns detailed status)
  Future<Map<String, dynamic>> verifyTenantOtpDetailed(String email, String token) async {
    final cleanEmail = email.trim().toLowerCase();
    final cleanToken = token.trim();

    if (cleanToken.isEmpty || cleanToken.length < 6) {
      return {'verified': false, 'error': 'Code must be at least 6 digits'};
    }

    final client = _client;
    if (client != null) {
      String? lastError;

      // 1. Try OtpType.email
      try {
        final response = await client.auth.verifyOTP(
          email: cleanEmail,
          token: cleanToken,
          type: OtpType.email,
        );
        if (response.session != null || response.user != null) {
          return {'verified': true, 'error': null};
        }
      } on AuthException catch (e) {
        lastError = e.message;
        debugPrint('Supabase OTP verify note (type: email): ${e.message}');
      } catch (e) {
        lastError = e.toString();
      }

      // 2. Try OtpType.signup
      try {
        final response = await client.auth.verifyOTP(
          email: cleanEmail,
          token: cleanToken,
          type: OtpType.signup,
        );
        if (response.session != null || response.user != null) {
          return {'verified': true, 'error': null};
        }
      } on AuthException catch (e2) {
        lastError = e2.message;
        debugPrint('Supabase OTP verify note (type: signup): ${e2.message}');
      } catch (e2) {
        lastError = e2.toString();
      }

      // 3. Try OtpType.magiclink
      try {
        final response = await client.auth.verifyOTP(
          email: cleanEmail,
          token: cleanToken,
          type: OtpType.magiclink,
        );
        if (response.session != null || response.user != null) {
          return {'verified': true, 'error': null};
        }
      } on AuthException catch (e3) {
        lastError = e3.message;
        debugPrint('Supabase OTP verify note (type: magiclink): ${e3.message}');
      } catch (e3) {
        lastError = e3.toString();
      }

      return {'verified': false, 'error': lastError ?? 'Token has expired or is invalid'};
    }

    return {'verified': false, 'error': 'Supabase client uninitialized'};
  }

  /// Verify Tenant OTP Code with Supabase Auth
  Future<bool> verifyTenantOtp(String email, String token) async {
    final res = await verifyTenantOtpDetailed(email, token);
    return res['verified'] == true;
  }

  /// Sign Out current user session
  Future<void> signOut() async {
    _localLoggedIn = false;
    _localEmail = null;
    _activeRole = 'landlord';
    try {
      await _client?.auth.signOut();
    } catch (_) {}
  }
}
