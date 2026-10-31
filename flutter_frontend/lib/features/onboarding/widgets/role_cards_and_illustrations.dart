part of '../personalization_flow_screen.dart';

class _FeaturedRoleCard extends StatelessWidget {
  const _FeaturedRoleCard({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.floatAnimation,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final bool selected;
  final Animation<double> floatAnimation;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: selected
                ? const Color(0xFF0057FF)
                : const Color(0xFFE2E8F0),
            width: selected ? 2.0 : 1.0,
          ),
          boxShadow: [
            if (selected)
              BoxShadow(
                color: const Color(0xFF0057FF).withValues(alpha: 0.14),
                blurRadius: 18,
                spreadRadius: 2,
                offset: const Offset(0, 6),
              )
            else
              BoxShadow(
                color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Illustration panel
            Container(
              height: 118,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFEAF1FF),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Stack(
                children: [
                  Center(
                    child: AnimatedBuilder(
                      animation: floatAnimation,
                      builder: (context, child) {
                        final dy =
                            math.sin(floatAnimation.value * 2 * math.pi) * 3.5;
                        return Transform.translate(
                          offset: Offset(0, dy),
                          child: child,
                        );
                      },
                      child: const SizedBox(
                        width: 130,
                        height: 76,
                        child: CustomPaint(
                          painter: _UiUxWireframeIllustrationPainter(),
                        ),
                      ),
                    ),
                  ),
                  if (selected)
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: const BoxDecoration(
                          color: Color(0xFF0057FF),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 15,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 15.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GridRoleCard extends StatelessWidget {
  const _GridRoleCard({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.illustrationBg,
    required this.illustration,
    required this.floatAnimation,
    required this.phase,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final bool selected;
  final Color illustrationBg;
  final Widget illustration;
  final Animation<double> floatAnimation;
  final double phase;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: selected
                ? const Color(0xFF0057FF)
                : Colors.transparent,
            width: selected ? 2.0 : 1.0,
          ),
          boxShadow: [
            if (selected)
              BoxShadow(
                color: const Color(0xFF0057FF).withValues(alpha: 0.14),
                blurRadius: 18,
                spreadRadius: 1,
                offset: const Offset(0, 6),
              )
            else
              BoxShadow(
                color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 102,
              width: double.infinity,
              decoration: BoxDecoration(
                color: illustrationBg,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Stack(
                children: [
                  Center(
                    child: AnimatedBuilder(
                      animation: floatAnimation,
                      builder: (context, child) {
                        final dy = math.sin(
                              (floatAnimation.value * 2 * math.pi) + phase,
                            ) *
                            3.0;
                        return Transform.translate(
                          offset: Offset(0, dy),
                          child: child,
                        );
                      },
                      child: illustration,
                    ),
                  ),
                  if (selected)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        width: 22,
                        height: 22,
                        decoration: const BoxDecoration(
                          color: Color(0xFF0057FF),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 14,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 14.5,
                fontWeight: FontWeight.w800,
                height: 1.22,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UiUxWireframeIllustrationPainter extends CustomPainter {
  const _UiUxWireframeIllustrationPainter();

  @override
  void paint(Canvas canvas, Size size) {
    // White wireframe card on left
    final cardRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(6, 8, size.width * 0.66, size.height - 14),
      const Radius.circular(12),
    );
    canvas.drawRRect(
      cardRect,
      Paint()..color = Colors.white,
    );
    canvas.drawRRect(
      cardRect,
      Paint()
        ..color = const Color(0xFFCBD5E1)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4,
    );

    // Blue top pill inside wireframe
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(16, 18, 36, 6),
        const Radius.circular(99),
      ),
      Paint()..color = const Color(0xFF0057FF),
    );

    // Light blue bar inside wireframe
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(16, 29, 58, 5),
        const Radius.circular(99),
      ),
      Paint()..color = const Color(0xFFDBEAFE),
    );

    // Yellow & green blocks at bottom of wireframe
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(16, 40, 27, 18),
        const Radius.circular(5),
      ),
      Paint()..color = const Color(0xFFFBBF24),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(48, 40, 27, 18),
        const Radius.circular(5),
      ),
      Paint()..color = const Color(0xFF34D399),
    );

    // Blue circle on the right overlapping the card
    final circleCenter = Offset(size.width * 0.78, size.height * 0.44);
    canvas.drawCircle(
      circleCenter,
      19,
      Paint()..color = const Color(0xFF0057FF),
    );

    // Dark cursor pointer arrow below the circle
    final cursorPath = Path()
      ..moveTo(circleCenter.dx - 2, circleCenter.dy + 9)
      ..lineTo(circleCenter.dx + 12, circleCenter.dy + 20)
      ..lineTo(circleCenter.dx + 4, circleCenter.dy + 21)
      ..lineTo(circleCenter.dx - 2, circleCenter.dy + 27)
      ..close();
    canvas.drawPath(
      cursorPath,
      Paint()..color = const Color(0xFF0F172A),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _FrontendTerminalIllustration extends StatelessWidget {
  const _FrontendTerminalIllustration();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 78,
      height: 54,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(11),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _dot(const Color(0xFFEF4444)),
              const SizedBox(width: 4),
              _dot(const Color(0xFFF59E0B)),
              const SizedBox(width: 4),
              _dot(const Color(0xFF10B981)),
            ],
          ),
          const Expanded(
            child: Center(
              child: Text(
                '</>',
                style: TextStyle(
                  color: Color(0xFF34D399),
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dot(Color color) {
    return Container(
      width: 5,
      height: 5,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

class _DataAnalystChartIllustration extends StatelessWidget {
  const _DataAnalystChartIllustration();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 76,
      height: 58,
      child: CustomPaint(
        painter: _DataChartPainter(),
      ),
    );
  }
}

class _DataChartPainter extends CustomPainter {
  const _DataChartPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final yellowPaint = Paint()..color = const Color(0xFFFBBF24);
    final bluePaint = Paint()..color = const Color(0xFF0057FF);

    // 3 vertical bars
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(8, size.height - 24, 13, 22),
        const Radius.circular(4),
      ),
      yellowPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(28, size.height - 34, 13, 32),
        const Radius.circular(4),
      ),
      yellowPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(48, size.height - 46, 13, 44),
        const Radius.circular(4),
      ),
      bluePaint,
    );

    // Trend line above bars
    final linePaint = Paint()
      ..color = const Color(0xFF0F172A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path()
      ..moveTo(8, size.height - 32)
      ..lineTo(28, size.height - 42)
      ..lineTo(44, size.height - 38)
      ..lineTo(66, size.height - 52);
    canvas.drawPath(path, linePaint);

    canvas.drawCircle(
      Offset(66, size.height - 52),
      3.5,
      Paint()..color = const Color(0xFF0F172A),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CopywriterDocIllustration extends StatelessWidget {
  const _CopywriterDocIllustration();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 68,
      height: 58,
      child: Stack(
        children: [
          Container(
            width: 50,
            height: 56,
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: const Color(0xFFDDD6FE),
                width: 1.4,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 4.5,
                  width: 24,
                  decoration: BoxDecoration(
                    color: const Color(0xFFC4B5FD),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  height: 4.5,
                  width: 30,
                  decoration: BoxDecoration(
                    color: const Color(0xFFDDD6FE),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  height: 4.5,
                  width: 18,
                  decoration: BoxDecoration(
                    color: const Color(0xFFDDD6FE),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            right: 2,
            bottom: 2,
            child: Transform.rotate(
              angle: -0.6,
              child: Container(
                width: 34,
                height: 12,
                decoration: BoxDecoration(
                  color: const Color(0xFF0057FF),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MegaphoneIllustration extends StatelessWidget {
  const _MegaphoneIllustration();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 74,
      height: 54,
      child: CustomPaint(
        painter: _MegaphonePainter(),
      ),
    );
  }
}

class _MegaphonePainter extends CustomPainter {
  const _MegaphonePainter();

  @override
  void paint(Canvas canvas, Size size) {
    // Handle
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(16, size.height * 0.56, 8, 16),
        const Radius.circular(3),
      ),
      Paint()..color = const Color(0xFF0F172A),
    );

    // Blue cone body
    final conePath = Path()
      ..moveTo(10, size.height * 0.36)
      ..lineTo(24, size.height * 0.36)
      ..lineTo(48, size.height * 0.14)
      ..lineTo(48, size.height * 0.76)
      ..lineTo(24, size.height * 0.56)
      ..lineTo(10, size.height * 0.56)
      ..close();
    canvas.drawPath(conePath, Paint()..color = const Color(0xFF0057FF));

    // Coral sound arcs on right
    final wavePaint = Paint()
      ..color = const Color(0xFFF87171)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.6
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: Offset(48, size.height * 0.45), radius: 10),
      -0.6,
      1.2,
      false,
      wavePaint,
    );
    canvas.drawArc(
      Rect.fromCircle(center: Offset(48, size.height * 0.45), radius: 17),
      -0.65,
      1.3,
      false,
      wavePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
