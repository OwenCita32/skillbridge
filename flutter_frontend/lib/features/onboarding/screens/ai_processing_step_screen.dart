part of '../personalization_flow_screen.dart';

// ============================================================================
// STEP 3: AI PROCESSING SCREEN (Matching Screenshot 4)
// ============================================================================
class _AiProcessingStepScreen extends StatefulWidget {
  const _AiProcessingStepScreen({
    required this.selectedRole,
    required this.selectedLevel,
    required this.onFinished,
    this.enableLoopingAnimation,
    super.key,
  });

  final String selectedRole;
  final String selectedLevel;
  final VoidCallback onFinished;
  final bool? enableLoopingAnimation;

  @override
  State<_AiProcessingStepScreen> createState() =>
      _AiProcessingStepScreenState();
}

class _AiProcessingStepScreenState extends State<_AiProcessingStepScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  Timer? _completionTimer;

  bool get _isAutomatedTest =>
      WidgetsBinding.instance.runtimeType.toString().contains('AutomatedTest');

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: _isAutomatedTest
          ? const Duration(milliseconds: 300)
          : const Duration(milliseconds: 2800),
    );

    _controller.forward().whenComplete(() {
      if (!mounted) return;
      _completionTimer = Timer(
        _isAutomatedTest
            ? const Duration(milliseconds: 80)
            : const Duration(milliseconds: 650),
        () {
          if (mounted) {
            widget.onFinished();
          }
        },
      );
    });
  }

  @override
  void dispose() {
    _completionTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  String _statusHeadline(double progress) {
    if (progress < 0.36) {
      return 'Menganalisis kesenjangan\nskill utamamu...';
    }
    if (progress < 0.72) {
      return 'Menyusun roadmap belajar\nyang dipersonalisasi...';
    }
    return 'Menetapkan target lamaran\nharian...';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0050E6),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Deep Royal Blue Gradient + Subtle Technical Grid
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF0A5BF0),
                  Color(0xFF004DE0),
                  Color(0xFF0342C4),
                ],
              ),
            ),
          ),
          const CustomPaint(
            painter: _TechnicalGridPainter(),
          ),
          SafeArea(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                final progress = Curves.easeInOutCubic.transform(
                  _controller.value,
                );
                final percentage = (progress * 100).round();

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(
                    children: [
                      const Spacer(flex: 3),

                      // Centered Radar + Orbiting Dot + Percentage Pill
                      SizedBox(
                        width: 244,
                        height: 244,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            CustomPaint(
                              size: const Size(244, 244),
                              painter: _AiRadarVisualPainter(
                                progress: progress,
                              ),
                            ),
                            Positioned(
                              bottom: 28,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.22),
                                  borderRadius: BorderRadius.circular(99),
                                ),
                                child: Text(
                                  '$percentage%',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 36),

                      // Status Heading
                      Text(
                        _statusHeadline(progress),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          height: 1.32,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Translucent Context Chips (Role + Experience Level)
                      Wrap(
                        spacing: 10,
                        runSpacing: 8,
                        alignment: WrapAlignment.center,
                        children: [
                          _TranslucentContextChip(label: widget.selectedRole),
                          _TranslucentContextChip(label: widget.selectedLevel),
                        ],
                      ),

                      const Spacer(flex: 4),

                      // Bottom Completed Processing Steps
                      Padding(
                        padding: const EdgeInsets.only(bottom: 34),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _ProcessingStepRow(
                              label: 'Skill gap',
                              completed: progress >= 0.25,
                            ),
                            const SizedBox(height: 12),
                            _ProcessingStepRow(
                              label: 'Roadmap',
                              completed: progress >= 0.60,
                            ),
                            const SizedBox(height: 12),
                            _ProcessingStepRow(
                              label: 'Target lamaran',
                              completed: progress >= 0.90,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _TranslucentContextChip extends StatelessWidget {
  const _TranslucentContextChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.28),
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _ProcessingStepRow extends StatelessWidget {
  const _ProcessingStepRow({
    required this.label,
    required this.completed,
  });

  final String label;
  final bool completed;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 240),
      opacity: completed ? 1.0 : 0.45,
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: completed
                  ? const Color(0xFF10B981)
                  : Colors.white.withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_rounded,
              color: Colors.white,
              size: 13,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.90),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _TechnicalGridPainter extends CustomPainter {
  const _TechnicalGridPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.04)
      ..strokeWidth = 1;

    const step = 36.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _AiRadarVisualPainter extends CustomPainter {
  const _AiRadarVisualPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outerOrbitRadius = size.width * 0.47;
    final circleRadius = size.width * 0.39;

    // 1. Outer dotted circle ring
    final dotPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.25)
      ..style = PaintingStyle.fill;
    const dotCount = 48;
    for (int i = 0; i < dotCount; i++) {
      final angle = (i * 2 * math.pi) / dotCount;
      final dx = center.dx + math.cos(angle) * outerOrbitRadius;
      final dy = center.dy + math.sin(angle) * outerOrbitRadius;
      canvas.drawCircle(Offset(dx, dy), 1.3, dotPaint);
    }

    // 2. Orbiting yellow planet dot (settles at top when 100%)
    final orbitAngle = (-math.pi / 2) + ((1.0 - progress) * 2 * math.pi);
    final planetOffset = Offset(
      center.dx + math.cos(orbitAngle) * outerOrbitRadius,
      center.dy + math.sin(orbitAngle) * outerOrbitRadius,
    );
    canvas.drawCircle(
      planetOffset,
      4.8,
      Paint()..color = const Color(0xFFFBBF24),
    );

    // 3. Soft translucent circle interior
    canvas.drawCircle(
      center,
      circleRadius,
      Paint()..color = Colors.white.withValues(alpha: 0.10),
    );

    // 4. White progress arc around circle
    final trackPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.22)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.2;
    canvas.drawCircle(center, circleRadius, trackPaint);

    final arcPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.5
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: circleRadius),
      -math.pi / 2,
      2 * math.pi * progress.clamp(0.05, 1.0),
      false,
      arcPaint,
    );

    // 5. Concentric hexagons + radial axes inside
    final webPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.22)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final maxHexR = circleRadius * 0.76;
    for (final factor in [0.35, 0.68, 1.0]) {
      final hexPath = Path();
      for (int i = 0; i < 6; i++) {
        final angle = (-math.pi / 2) + (i * math.pi / 3);
        final pt = Offset(
          center.dx + math.cos(angle) * maxHexR * factor,
          center.dy + math.sin(angle) * maxHexR * factor,
        );
        if (i == 0) {
          hexPath.moveTo(pt.dx, pt.dy);
        } else {
          hexPath.lineTo(pt.dx, pt.dy);
        }
      }
      hexPath.close();
      canvas.drawPath(hexPath, webPaint);
    }

    for (int i = 0; i < 6; i++) {
      final angle = (-math.pi / 2) + (i * math.pi / 3);
      final pt = Offset(
        center.dx + math.cos(angle) * maxHexR,
        center.dy + math.sin(angle) * maxHexR,
      );
      canvas.drawLine(center, pt, webPaint);
    }

    // 6. Animated Skill Radar Polygon
    final targetFactors = [0.95, 0.56, 0.68, 0.35, 0.76, 0.52];
    final radarPath = Path();
    final morph = 0.25 + (0.75 * progress);
    for (int i = 0; i < 6; i++) {
      final angle = (-math.pi / 2) + (i * math.pi / 3);
      final r = maxHexR * targetFactors[i] * morph;
      final pt = Offset(
        center.dx + math.cos(angle) * r,
        center.dy + math.sin(angle) * r,
      );
      if (i == 0) {
        radarPath.moveTo(pt.dx, pt.dy);
      } else {
        radarPath.lineTo(pt.dx, pt.dy);
      }
    }
    radarPath.close();

    canvas.drawPath(
      radarPath,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.20)
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(
      radarPath,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.6
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(covariant _AiRadarVisualPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
