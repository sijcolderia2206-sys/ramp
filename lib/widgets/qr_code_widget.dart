// lib/widgets/qr_code_widget.dart
import 'dart:math';
import 'package:flutter/material.dart';
import '../theme.dart';

/// Custom Vector Neumorphic QR Code Generator
class QrCodeWidget extends StatelessWidget {
  final String data;
  final double size;
  final Color moduleColor;
  final Color backgroundColor;

  const QrCodeWidget({
    super.key,
    required this.data,
    this.size = 140.0,
    this.moduleColor = RampTheme.textPrimary,
    this.backgroundColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(size * 0.08),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0xFFA3B1C6),
            offset: Offset(2, 2),
            blurRadius: 4,
          ),
          BoxShadow(
            color: Colors.white,
            offset: Offset(-2, -2),
            blurRadius: 4,
          ),
        ],
      ),
      child: CustomPaint(
        size: Size(size, size),
        painter: _QrCodePainter(data: data, moduleColor: moduleColor),
      ),
    );
  }
}

class _QrCodePainter extends CustomPainter {
  final String data;
  final Color moduleColor;

  _QrCodePainter({required this.data, required this.moduleColor});

  @override
  void paint(Canvas canvas, Size size) {
    const int gridCount = 17;
    final double cellSize = size.width / gridCount;
    final Paint fillPaint = Paint()
      ..color = moduleColor
      ..style = PaintingStyle.fill;

    // Deterministic module generation using input string hash
    final random = Random(data.hashCode);

    // Grid matrix (17x17)
    List<List<bool>> matrix = List.generate(
      gridCount,
      (_) => List.generate(gridCount, (_) => false),
    );

    // 1. Draw Finder Patterns (Top-Left, Top-Right, Bottom-Left: 5x5 cells)
    _setFinderPattern(matrix, 0, 0);
    _setFinderPattern(matrix, gridCount - 5, 0);
    _setFinderPattern(matrix, 0, gridCount - 5);

    // 2. Fill Data Cells based on seed
    for (int r = 0; r < gridCount; r++) {
      for (int c = 0; c < gridCount; c++) {
        // Skip finder areas
        if (_isFinderArea(r, c, gridCount)) continue;

        // Skip timing lines
        if (r == 2 || c == 2) {
          matrix[r][c] = (r + c) % 2 == 0;
          continue;
        }

        matrix[r][c] = random.nextDouble() > 0.45;
      }
    }

    // Render modules
    for (int r = 0; r < gridCount; r++) {
      for (int c = 0; c < gridCount; c++) {
        if (matrix[r][c]) {
          final rect = Rect.fromLTWH(
            c * cellSize,
            r * cellSize,
            cellSize,
            cellSize,
          );
          canvas.drawRRect(
            RRect.fromRectAndRadius(rect, Radius.circular(cellSize * 0.2)),
            fillPaint,
          );
        }
      }
    }
  }

  void _setFinderPattern(List<List<bool>> matrix, int startR, int startC) {
    for (int r = 0; r < 5; r++) {
      for (int c = 0; c < 5; c++) {
        bool isBorder = r == 0 || r == 4 || c == 0 || c == 4;
        bool isCenter = r >= 1 && r <= 3 && c >= 1 && c <= 3;
        bool isInnerFill = r == 2 && c == 2;
        matrix[startR + r][startC + c] = isBorder || isInnerFill || (isCenter && !isBorder && isInnerFill);
      }
    }
  }

  bool _isFinderArea(int r, int c, int gridCount) {
    bool inTopLeft = r < 5 && c < 5;
    bool inTopRight = r < 5 && c >= gridCount - 5;
    bool inBottomLeft = r >= gridCount - 5 && c < 5;
    return inTopLeft || inTopRight || inBottomLeft;
  }

  @override
  bool shouldRepaint(covariant _QrCodePainter oldDelegate) =>
      oldDelegate.data != data || oldDelegate.moduleColor != moduleColor;
}
