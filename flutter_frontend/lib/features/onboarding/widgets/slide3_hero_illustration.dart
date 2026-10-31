part of '../onboarding_screen.dart';

// ============================================================================
// SLIDE 3 ILLUSTRATION: Level 2 Unlocked Medal + Portofolio Folder + LinkedIn
// ============================================================================
class _Slide3HeroIllustration extends StatelessWidget {
  const _Slide3HeroIllustration({required this.animation});

  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Left Main Tilted Card: Level 2 Unlocked Medal
        Align(
          alignment: Alignment.centerLeft,
          child: _FloatingMotion(
            animation: animation,
            phase: 0.3,
            verticalAmplitude: 7.0,
            horizontalAmplitude: 1.6,
            baseRotation: -0.045,
            rotationAmplitude: 0.012,
            child: Container(
              width: 184,
              height: 224,
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
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 82,
                    height: 98,
                    child: CustomPaint(
                      painter: _LevelMedalPainter(),
                    ),
                  ),
                  SizedBox(height: 14),
                  Text(
                    'Level 2 Unlocked',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF1E293B),
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Top-Right Floating Card: Portofolio (12 proyek)
        Positioned(
          top: 2,
          right: 2,
          child: _FloatingMotion(
            animation: animation,
            phase: 1.7,
            verticalAmplitude: 8.5,
            horizontalAmplitude: 2.2,
            baseRotation: 0.05,
            rotationAmplitude: 0.015,
            child: Container(
              width: 144,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0F172A).withValues(alpha: 0.09),
                    blurRadius: 22,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 44,
                    height: 34,
                    child: CustomPaint(
                      painter: _GreenFolderPainter(),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Portofolio',
                    style: TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    '12 proyek',
                    style: TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 10.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Bottom-Right Floating Card: LinkedIn "in" Square
        Positioned(
          bottom: 4,
          right: 12,
          child: _FloatingMotion(
            animation: animation,
            phase: 3.2,
            verticalAmplitude: 8.0,
            horizontalAmplitude: 2.0,
            rotationAmplitude: 0.012,
            child: Container(
              width: 118,
              height: 118,
              decoration: BoxDecoration(
                color: const Color(0xFF0A66C2),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0A66C2).withValues(alpha: 0.32),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: const Text(
                'in',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1.0,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _LevelMedalPainter extends CustomPainter {
  const _LevelMedalPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final medalCenter = Offset(centerX, size.height * 0.36);
    final outerRadius = size.width * 0.34;
    final innerRadius = size.width * 0.23;

    // Blue ribbon below medal
    final ribbonPaint = Paint()
      ..color = const Color(0xFF0057FF)
      ..style = PaintingStyle.fill;

    final ribbonPath = Path()
      ..moveTo(centerX - 15, medalCenter.dy + outerRadius * 0.65)
      ..lineTo(centerX - 19, size.height * 0.94)
      ..lineTo(centerX, size.height * 0.80)
      ..lineTo(centerX + 19, size.height * 0.94)
      ..lineTo(centerX + 15, medalCenter.dy + outerRadius * 0.65)
      ..close();
    canvas.drawPath(ribbonPath, ribbonPaint);

    // Outer gold circle
    final outerGoldPaint = Paint()
      ..color = const Color(0xFFF59E0B)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(medalCenter, outerRadius, outerGoldPaint);

    // Inner bright yellow circle
    final innerGoldPaint = Paint()
      ..color = const Color(0xFFFBBF24)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(medalCenter, innerRadius, innerGoldPaint);

    // Inner subtle ring
    final ringPaint = Paint()
      ..color = const Color(0xFFFDE68A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(medalCenter, innerRadius, ringPaint);

    // White 5-point star in the center
    final starPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final starPath = Path();
    const points = 5;
    final starOuterR = innerRadius * 0.56;
    final starInnerR = starOuterR * 0.45;
    for (int i = 0; i < points * 2; i++) {
      final r = i.isEven ? starOuterR : starInnerR;
      final angle = (i * math.pi / points) - (math.pi / 2);
      final x = medalCenter.dx + math.cos(angle) * r;
      final y = medalCenter.dy + math.sin(angle) * r;
      if (i == 0) {
        starPath.moveTo(x, y);
      } else {
        starPath.lineTo(x, y);
      }
    }
    starPath.close();
    canvas.drawPath(starPath, starPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _GreenFolderPainter extends CustomPainter {
  const _GreenFolderPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF34D399)
      ..style = PaintingStyle.fill;

    // Folder tab + body
    final folderPath = Path()
      ..moveTo(0, 6)
      ..quadraticBezierTo(0, 0, 6, 0)
      ..lineTo(size.width * 0.42, 0)
      ..lineTo(size.width * 0.52, 5)
      ..lineTo(size.width - 5, 5)
      ..quadraticBezierTo(size.width, 5, size.width, 10)
      ..lineTo(size.width, size.height - 5)
      ..quadraticBezierTo(size.width, size.height, size.width - 5, size.height)
      ..lineTo(5, size.height)
      ..quadraticBezierTo(0, size.height, 0, size.height - 5)
      ..close();
    canvas.drawPath(folderPath, paint);

    // Two white horizontal lines inside the folder
    final linePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.85)
      ..strokeWidth = 2.6
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(size.width * 0.20, size.height * 0.48),
      Offset(size.width * 0.78, size.height * 0.48),
      linePaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.20, size.height * 0.68),
      Offset(size.width * 0.56, size.height * 0.68),
      linePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
