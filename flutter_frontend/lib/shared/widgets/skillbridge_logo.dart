import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

class SkillBridgeLogoMark extends StatelessWidget {
  const SkillBridgeLogoMark({
    this.size = 84,
    this.borderRadius = 24,
    this.backgroundColor = Colors.white,
    this.iconColor = AppColors.primary,
    this.elevated = true,
    super.key,
  });

  final double size;
  final double borderRadius;
  final Color backgroundColor;
  final Color iconColor;
  final bool elevated;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: elevated
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ]
            : null,
      ),
      child: Center(
        child: SizedBox(
          width: size * 0.56,
          height: size * 0.42,
          child: CustomPaint(
            painter: _BridgeIconPainter(color: iconColor),
          ),
        ),
      ),
    );
  }
}

class _BridgeIconPainter extends CustomPainter {
  const _BridgeIconPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = size.width * 0.11;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final baseLineY = size.height * 0.84;

    // Arch from left base to right base
    final archPath = Path()
      ..moveTo(size.width * 0.08, baseLineY)
      ..quadraticBezierTo(
        size.width * 0.50,
        -size.height * 0.22,
        size.width * 0.92,
        baseLineY,
      );
    canvas.drawPath(archPath, paint);

    // Base horizontal deck
    canvas.drawLine(
      Offset(size.width * 0.05, baseLineY),
      Offset(size.width * 0.95, baseLineY),
      paint,
    );

    // Vertical suspension pillars inside the arch
    final pillarPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth * 0.82
      ..strokeCap = StrokeCap.round;

    // Left pillar
    canvas.drawLine(
      Offset(size.width * 0.33, size.height * 0.44),
      Offset(size.width * 0.33, baseLineY),
      pillarPaint,
    );
    // Center tallest pillar
    canvas.drawLine(
      Offset(size.width * 0.50, size.height * 0.26),
      Offset(size.width * 0.50, baseLineY),
      pillarPaint,
    );
    // Right pillar
    canvas.drawLine(
      Offset(size.width * 0.67, size.height * 0.44),
      Offset(size.width * 0.67, baseLineY),
      pillarPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _BridgeIconPainter oldDelegate) =>
      oldDelegate.color != color;
}

