import 'package:flutter_test/flutter_test.dart';
import 'package:ramp/core/supabase_auth_service.dart';

void main() {
  final authService = SupabaseAuthService();

  group('SupabaseAuthService OTP Unit Tests', () {
    test('sendTenantOtp handles valid email dispatch', () async {
      final result = await authService.sendTenantOtp('test@example.com');
      expect(result.containsKey('success'), isTrue);
      expect(result.containsKey('message'), isTrue);
    });

    test('verifyTenantOtp rejects invalid code when client uninitialized', () async {
      const email = 'tenant@example.com';
      final isVerified = await authService.verifyTenantOtp(
        email,
        '123456',
      );
      expect(isVerified, isFalse);
    });

    test('confirmPasswordReset handles uninitialized client safely', () async {
      const email = 'user@example.com';
      final isSuccess = await authService.confirmPasswordReset(
        email: email,
        otpCode: '123456',
        newPassword: 'newpassword123',
      );
      expect(isSuccess, isFalse);
    });
  });
}
