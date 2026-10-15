// lib/core/utils/permission_helper.dart
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionHelper {
  /// Requests Camera permission with a pre-explanation Neumorphic dialog detailing the purpose.
  static Future<bool> requestCameraPermission(
    BuildContext context, {
    String purpose = 'RAMP needs camera access to capture unit maintenance photos or scan QR codes.',
  }) async {
    final status = await Permission.camera.status;
    if (status.isGranted) return true;

    if (!context.mounted) return false;

    // Show Neumorphic rationale dialog before asking OS permission
    final bool? proceed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFFE0E5EC),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: const [
            Icon(Icons.camera_alt_rounded, color: Color(0xFF2C3E50)),
            SizedBox(width: 10),
            Text('Camera Permission', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        content: Text(
          purpose,
          style: const TextStyle(fontSize: 14, color: Color(0xFF506070)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2196F3),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Allow Access', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (proceed != true) return false;

    final result = await Permission.camera.request();
    if (result.isPermanentlyDenied) {
      if (context.mounted) {
        _showSettingsPrompt(context, 'Camera permission is permanently denied. Please enable it in App Settings.');
      }
      return false;
    }
    return result.isGranted;
  }

  /// Requests Photos/Storage permission with a pre-explanation Neumorphic dialog.
  static Future<bool> requestStoragePermission(
    BuildContext context, {
    String purpose = 'RAMP needs storage/photos access to select lease documents, receipts, or property images.',
  }) async {
    final status = await Permission.photos.status;
    if (status.isGranted) return true;

    if (!context.mounted) return false;

    final bool? proceed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFFE0E5EC),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: const [
            Icon(Icons.folder_open_rounded, color: Color(0xFF2C3E50)),
            SizedBox(width: 10),
            Text('Storage Permission', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        content: Text(
          purpose,
          style: const TextStyle(fontSize: 14, color: Color(0xFF506070)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2196F3),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Allow Access', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (proceed != true) return false;

    final result = await Permission.photos.request();
    if (result.isDenied) {
      // Fallback for Android storage permission on older SDKs
      final storageResult = await Permission.storage.request();
      return storageResult.isGranted;
    }
    if (result.isPermanentlyDenied) {
      if (context.mounted) {
        _showSettingsPrompt(context, 'Storage permission is permanently denied. Please enable it in App Settings.');
      }
      return false;
    }
    return result.isGranted;
  }

  static void _showSettingsPrompt(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFFE0E5EC),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Permission Required'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }
}
