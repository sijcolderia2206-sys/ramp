import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class ReminderLauncherService {
  /// Launches native SMS messaging app with target recipient and pre-filled message text.
  static Future<bool> launchSms({
    String? phone,
    String? phoneNumber,
    required String message,
  }) async {
    final rawPhone = phoneNumber ?? phone ?? '';
    final cleanPhone = rawPhone.replaceAll(RegExp(r'[^\d+]'), '');

    final Uri smsUri = Uri(
      scheme: 'sms',
      path: cleanPhone,
      queryParameters: message.isNotEmpty ? <String, String>{'body': message} : null,
    );

    try {
      if (await canLaunchUrl(smsUri)) {
        final success = await launchUrl(smsUri, mode: LaunchMode.externalApplication);
        if (success) return true;
      }
      final directSuccess = await launchUrl(smsUri, mode: LaunchMode.externalApplication);
      if (directSuccess) return true;
    } catch (_) {}

    // Fallback try rawUri with encoded body string
    try {
      final encodedBody = Uri.encodeComponent(message);
      final fallbackUri = Uri.parse('sms:$cleanPhone?body=$encodedBody');
      final fallbackSuccess = await launchUrl(fallbackUri, mode: LaunchMode.externalApplication);
      if (fallbackSuccess) return true;
    } catch (_) {}

    // Final fallback: launch base SMS app with phone number
    try {
      final basicSmsUri = Uri.parse('sms:$cleanPhone');
      return await launchUrl(basicSmsUri, mode: LaunchMode.externalApplication);
    } catch (_) {
      return false;
    }
  }

  /// Opens the Facebook Messenger app or web link for the tenant.
  /// Automatically copies the reminder message to clipboard so it can be pasted in chat.
  static Future<bool> launchMessenger({
    String? username,
    String? messengerHandle,
    String? message,
  }) async {
    final rawHandle = messengerHandle ?? username ?? '';
    final cleanHandle = rawHandle
        .trim()
        .replaceAll(RegExp(r'^@+'), '')
        .replaceAll(RegExp(r'^https?://(www\.)?m\.me/'), '')
        .replaceAll(RegExp(r'^https?://(www\.)?facebook\.com/'), '');

    // Copy message text to clipboard for convenient pasting in Messenger
    if (message != null && message.isNotEmpty) {
      await Clipboard.setData(ClipboardData(text: message));
    }

    if (cleanHandle.isNotEmpty) {
      final Uri mMeUri = Uri.parse('https://m.me/$cleanHandle');
      try {
        if (await canLaunchUrl(mMeUri)) {
          final launched = await launchUrl(mMeUri, mode: LaunchMode.externalApplication);
          if (launched) return true;
        } else {
          final launched = await launchUrl(mMeUri, mode: LaunchMode.externalApplication);
          if (launched) return true;
        }
      } catch (_) {}

      final Uri fbMessengerUri = Uri.parse('fb-messenger://user/$cleanHandle');
      try {
        final launched = await launchUrl(fbMessengerUri, mode: LaunchMode.externalApplication);
        if (launched) return true;
      } catch (_) {}
    }

    // Generic fallback: Open Messenger app or site
    try {
      final Uri baseMessengerUri = Uri.parse('https://m.me');
      final launched = await launchUrl(baseMessengerUri, mode: LaunchMode.externalApplication);
      if (launched) return true;
    } catch (_) {}

    try {
      final Uri fbScheme = Uri.parse('fb-messenger://');
      return await launchUrl(fbScheme, mode: LaunchMode.externalApplication);
    } catch (_) {
      return false;
    }
  }
}
