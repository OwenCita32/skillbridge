part of '../onboarding_screen.dart';

// ============================================================================
// SLIDE 1 ILLUSTRATION: Target Flag Card + UI/UX Designer + Web Developer
// ============================================================================
class _Slide1HeroIllustration extends StatelessWidget {
  const _Slide1HeroIllustration({required this.animation});

  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Left Main TARGET Card
        Align(
          alignment: Alignment.centerLeft,
          child: _FloatingMotion(
            animation: animation,
            phase: 0.0,
            verticalAmplitude: 6.5,
            horizontalAmplitude: 1.5,
            rotationAmplitude: 0.008,
            child: Container(
              width: 192,
              height: 232,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(26),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0F172A).withValues(alpha: 0.08),
                    blurRadius: 28,
                    offset: const Offset(0, 14),
                  ),
                ],
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TARGET',
                    style: TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.0,
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: SizedBox(
                        width: 96,
                        height: 112,
                        child: CustomPaint(
                          painter: _TargetFlagPainter(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Top-Right Floating Card: UI/UX Designer
        Positioned(
          top: 4,
          right: 0,
          child: _FloatingMotion(
            animation: animation,
            phase: 1.4,
            verticalAmplitude: 9.0,
            horizontalAmplitude: 2.5,
            baseRotation: 0.055,
            rotationAmplitude: 0.018,
            child: Container(
              width: 146,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0F172A).withValues(alpha: 0.10),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'UI',
                      style: TextStyle(
                        color: Color(0xFF0057FF),
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'UI/UX Designer',
                    style: TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 5.5,
                    width: 88,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0057FF),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Bottom-Right Floating Card: Web Developer
        Positioned(
          bottom: 14,
          right: 6,
          child: _FloatingMotion(
            animation: animation,
            phase: 3.1,
            verticalAmplitude: 8.0,
            horizontalAmplitude: 2.2,
            baseRotation: -0.04,
            rotationAmplitude: 0.016,
            child: Container(
              width: 142,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0F172A).withValues(alpha: 0.10),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: const Color(0xFFECFDF5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      '</>',
                      style: TextStyle(
                        color: Color(0xFF10B981),
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Web Developer',
                    style: TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _TargetFlagPainter extends CustomPainter {
  const _TargetFlagPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width * 0.42;
    final baseY = size.height * 0.84;
    final topY = size.height * 0.16;

    final outerOvalPaint = Paint()
      ..color = const Color(0xFFE0EAFF)
      ..style = PaintingStyle.fill;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(centerX, baseY),
        width: size.width * 0.78,
        height: 16,
      ),
      outerOvalPaint,
    );

    final innerOvalPaint = Paint()
      ..color = const Color(0xFFC7D9FF)
      ..style = PaintingStyle.fill;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(centerX, baseY),
        width: size.width * 0.44,
        height: 9,
      ),
      innerOvalPaint,
    );

    final flagPaint = Paint()
      ..color = const Color(0xFF0057FF)
      ..style = PaintingStyle.fill;
    final flagPath = Path()
      ..moveTo(centerX, topY + 4)
      ..lineTo(centerX + 42, topY + 4)
      ..lineTo(centerX + 33, topY + 17)
      ..lineTo(centerX + 42, topY + 30)
      ..lineTo(centerX, topY + 30)
      ..close();
    canvas.drawPath(flagPath, flagPaint);

    final polePaint = Paint()
      ..color = const Color(0xFF1E293B)
      ..strokeWidth = 3.8
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(centerX, topY + 2),
      Offset(centerX, baseY),
      polePaint,
    );

    final finialPaint = Paint()
      ..color = const Color(0xFFF59E0B)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(centerX, topY), 3.6, finialPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
