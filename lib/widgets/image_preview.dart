// lib/widgets/image_preview.dart
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../theme.dart';

class RampImagePreview extends StatelessWidget {
  final String? imagePath;
  final double height;
  final double width;
  final BoxFit fit;
  final Widget? fallbackIcon;

  const RampImagePreview({
    super.key,
    required this.imagePath,
    this.height = 140,
    this.width = double.infinity,
    this.fit = BoxFit.cover,
    this.fallbackIcon,
  });

  @override
  Widget build(BuildContext context) {
    if (imagePath == null || imagePath!.trim().isEmpty) {
      return _buildFallback();
    }

    final path = imagePath!.trim();

    if (path.startsWith('http://') || path.startsWith('https://')) {
      return Image.network(
        path,
        height: height,
        width: width,
        fit: fit,
        errorBuilder: (_, __, ___) => _buildFallback(),
      );
    }

    if (!kIsWeb) {
      final file = File(path);
      if (file.existsSync()) {
        return Image.file(
          file,
          height: height,
          width: width,
          fit: fit,
          errorBuilder: (_, __, ___) => _buildFallback(),
        );
      }
    }

    return _buildFallback();
  }

  Widget _buildFallback() {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: RampTheme.primaryBlue.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: fallbackIcon ??
            const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.image_not_supported, color: RampTheme.textSecondary, size: 28),
                SizedBox(height: 4),
                Text('Image Preview Available', style: TextStyle(fontSize: 11, color: RampTheme.textSecondary)),
              ],
            ),
      ),
    );
  }
}
