part of '../splash_screen.dart';

class _SplashWavePainter extends CustomPainter {
  const _SplashWavePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final thinLinePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.10)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final softerLinePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.07)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1;

    // Top-right concentric decorative circles
    final topCircleCenter = Offset(size.width * 0.85, size.height * 0.07);
    canvas.drawCircle(topCircleCenter, size.width * 0.30, softerLinePaint);
    canvas.drawCircle(topCircleCenter, size.width * 0.42, thinLinePaint);

    // Upper sweeping curve
    final topWave = Path()
      ..moveTo(0, size.height * 0.26)
      ..cubicTo(
        size.width * 0.28,
        size.height * 0.31,
        size.width * 0.62,
        size.height * 0.17,
        size.width,
        size.height * 0.21,
      );
    canvas.drawPath(topWave, thinLinePaint);

    // Lower wave 1
    final bottomWave1 = Path()
      ..moveTo(0, size.height * 0.67)
      ..cubicTo(
        size.width * 0.34,
        size.height * 0.61,
        size.width * 0.68,
        size.height * 0.72,
        size.width,
        size.height * 0.63,
      );
    canvas.drawPath(bottomWave1, thinLinePaint);

    // Lower wave 2
    final bottomWave2 = Path()
      ..moveTo(0, size.height * 0.75)
      ..cubicTo(
        size.width * 0.36,
        size.height * 0.69,
        size.width * 0.68,
        size.height * 0.80,
        size.width,
        size.height * 0.71,
      );
    canvas.drawPath(bottomWave2, softerLinePaint);

    // Bottom-left subtle rounded contour
    final bottomLeftArc = Path()
      ..moveTo(0, size.height * 0.78)
      ..cubicTo(
        size.width * 0.36,
        size.height * 0.81,
        size.width * 0.46,
        size.height * 0.86,
        size.width * 0.34,
        size.height,
      );
    canvas.drawPath(bottomLeftArc, softerLinePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
