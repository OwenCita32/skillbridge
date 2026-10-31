part of '../onboarding_screen.dart';

// ============================================================================
// SLIDE 2 ILLUSTRATION: 72% Skill Match Ring + AI Analysis Pill + Skill Bars
// ============================================================================
class _Slide2HeroIllustration extends StatelessWidget {
  const _Slide2HeroIllustration({required this.animation});

  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Left Main 72% Skill Match Card
        Align(
          alignment: Alignment.topLeft,
          child: _FloatingMotion(
            animation: animation,
            phase: 0.2,
            verticalAmplitude: 6.5,
            horizontalAmplitude: 1.5,
            rotationAmplitude: 0.008,
            child: Container(
              width: 182,
              height: 192,
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
              child: Center(
                child: SizedBox(
                  width: 122,
                  height: 122,
                  child: CustomPaint(
                    painter: _SkillMatchRingPainter(),
                    child: const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '72%',
                            style: TextStyle(
                              color: Color(0xFF0F172A),
                              fontSize: 25,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'skill match',
                            style: TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),

        // Top-Right Floating Pill: ✦ AI Analysis
        Positioned(
          top: 6,
          right: 4,
          child: _FloatingMotion(
            animation: animation,
            phase: 1.5,
            verticalAmplitude: 8.5,
            horizontalAmplitude: 2.0,
            rotationAmplitude: 0.015,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF0057FF),
                borderRadius: BorderRadius.circular(99),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0057FF).withValues(alpha: 0.32),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.auto_awesome_rounded,
                    color: Colors.white,
                    size: 14,
                  ),
                  SizedBox(width: 6),
                  Text(
                    'AI Analysis',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Right Floating Skill Bars Card (Visual / Proto / Research)
        Positioned(
          bottom: 12,
          right: 0,
          child: _FloatingMotion(
            animation: animation,
            phase: 2.9,
            verticalAmplitude: 8.0,
            horizontalAmplitude: 2.2,
            rotationAmplitude: 0.012,
            child: Container(
              width: 148,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0F172A).withValues(alpha: 0.09),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _MiniSkillBarRow(label: 'Visual', progress: 0.84),
                  SizedBox(height: 9),
                  _MiniSkillBarRow(label: 'Proto', progress: 0.65),
                  SizedBox(height: 9),
                  _MiniSkillBarRow(label: 'Research', progress: 0.36),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SkillMatchRingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - 8;
    const strokeWidth = 11.5;

    final blueRingPaint = Paint()
      ..color = const Color(0xFF0057FF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, blueRingPaint);

    final greenArcPaint = Paint()
      ..color = const Color(0xFF22C55E)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final rect = Rect.fromCircle(center: center, radius: radius);
    const sweep = 0.28;
    for (final startAngle in [
      -math.pi / 2 - sweep / 2,
      0.0 - sweep / 2,
      math.pi / 2 - sweep / 2,
      math.pi - sweep / 2,
    ]) {
      canvas.drawArc(rect, startAngle, sweep, false, greenArcPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _MiniSkillBarRow extends StatelessWidget {
  const _MiniSkillBarRow({required this.label, required this.progress});

  final String label;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF64748B),
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          height: 5.5,
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(99),
          ),
          alignment: Alignment.centerLeft,
          child: FractionallySizedBox(
            widthFactor: progress,
            child: Container(
              height: 5.5,
              decoration: BoxDecoration(
                color: const Color(0xFF0057FF),
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _RoadmapStepperCard extends StatelessWidget {
  const _RoadmapStepperCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 332),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.06),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: const Row(
        children: [
          _StepNode(
            number: '1',
            label: 'Dasar',
            isActive: true,
            hasHalo: false,
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: Divider(
                color: Color(0xFF0057FF),
                thickness: 1.8,
                height: 2,
              ),
            ),
          ),
          _StepNode(
            number: '2',
            label: 'Proto',
            isActive: true,
            hasHalo: true,
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: Divider(
                color: Color(0xFFE2E8F0),
                thickness: 1.5,
                height: 2,
              ),
            ),
          ),
          _StepNode(
            number: '3',
            label: 'Riset',
            isActive: false,
            hasHalo: false,
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: Divider(
                color: Color(0xFFE2E8F0),
                thickness: 1.5,
                height: 2,
              ),
            ),
          ),
          _StepNode(
            number: '4',
            label: 'Karier',
            isActive: false,
            hasHalo: false,
          ),
        ],
      ),
    );
  }
}

class _StepNode extends StatelessWidget {
  const _StepNode({
    required this.number,
    required this.label,
    required this.isActive,
    required this.hasHalo,
  });

  final String number;
  final String label;
  final bool isActive;
  final bool hasHalo;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 30,
          height: 30,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: hasHalo ? const Color(0xFFDBEAFE) : Colors.transparent,
          ),
          child: Container(
            width: 24,
            height: 24,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive ? const Color(0xFF0057FF) : Colors.white,
              border: isActive
                  ? null
                  : Border.all(color: const Color(0xFFCBD5E1), width: 1.4),
            ),
            child: Text(
              number,
              style: TextStyle(
                color: isActive ? Colors.white : const Color(0xFF94A3B8),
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          style: TextStyle(
            color:
                isActive ? const Color(0xFF475569) : const Color(0xFF94A3B8),
            fontSize: 10.5,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
