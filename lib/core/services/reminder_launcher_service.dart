import 'package:url_launcher/url_launcher.dart';

class ReminderLauncherService {
  static Future<bool> launchSms({
    String? phone,
    String? phoneNumber,
    required String message,
  }) async {
    final targetPhone = phoneNumber ?? phone ?? '';
    final Uri smsUri = Uri(
      scheme: 'sms',
      path: targetPhone,
      queryParameters: <String, String>{
        'body': message,
      },
    );
    try {
      if (await canLaunchUrl(smsUri)) {
        return await launchUrl(smsUri);
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> launchMessenger({
    String? username,
    String? messengerHandle,
    String? message,
  }) async {
    final targetUser = messengerHandle ?? username ?? '';
    final Uri messengerUri = Uri.parse('https://m.me/$targetUser');
    try {
      if (await canLaunchUrl(messengerUri)) {
        return await launchUrl(messengerUri, mode: LaunchMode.externalApplication);
      }
      return false;
    } catch (_) {
      return false;
    }
  }
}
