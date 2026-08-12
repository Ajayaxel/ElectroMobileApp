import 'package:flutter/material.dart';

class BottomNavPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = const Color(0xFF1E1E1E)
      ..style = PaintingStyle.fill;

    Path path = Path();
    path.moveTo(0, 0);

    // Left straight line
    double cornerRadius = 20;
    double notchWidth = 80;
    double depth = 40;

    double leftStartNotch = (size.width - notchWidth) / 2;

    path.lineTo(leftStartNotch - cornerRadius, 0);

    // Start of the curve
    path.quadraticBezierTo(leftStartNotch, 0, leftStartNotch + 5, depth * 0.3);

    path.quadraticBezierTo(
      size.width / 2,
      depth * 1.5,
      leftStartNotch + notchWidth - 5,
      depth * 0.3,
    );

    path.quadraticBezierTo(
      leftStartNotch + notchWidth,
      0,
      leftStartNotch + notchWidth + cornerRadius,
      0,
    );

    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
