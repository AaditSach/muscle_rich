import 'package:flutter/material.dart';
import '../theme/colors.dart';

// background pe subtle grid lines draw karta hai  CustomPainter use karke
class GridBackground extends StatelessWidget {
  final Widget child;
  const GridBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _GridPainter(), child: child);
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = MRColors.outline.withOpacity(0.25)
      ..strokeWidth = 0.5;

    const gap = 24.0; // har line ke beech ki distance

    // horizontal lines
    for (double y = 0; y < size.height; y += gap) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
    // vertical lines
    for (double x = 0; x < size.width; x += gap) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
  }

  // grid kabhi nahi badalta isliye repaint false
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}