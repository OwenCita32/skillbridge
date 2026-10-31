part of '../onboarding_screen.dart';

class _OnboardingSlidePage extends StatelessWidget {
  const _OnboardingSlidePage({
    required this.floatAnimation,
    required this.showSkip,
    required this.onSkip,
    required this.heroGradientColors,
    required this.heroIllustration,
    required this.floatingMiddleAccessory,
    required this.eyebrow,
    required this.headlineTop,
    required this.headlineUnderlined,
    required this.description,
  });

  final Animation<double> floatAnimation;
  final bool showSkip;
  final VoidCallback onSkip;
  final List<Color> heroGradientColors;
  final Widget heroIllustration;
  final Widget floatingMiddleAccessory;
  final String eyebrow;
  final String headlineTop;
  final String headlineUnderlined;
  final String description;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxHeight < 680;
        final heroHeight = isCompact
            ? constraints.maxHeight * 0.44
            : constraints.maxHeight * 0.48;

        return SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Upper tinted stage with top bar + floating illustration
                Container(
                  height: heroHeight.clamp(270.0, 390.0),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: heroGradientColors,
                    ),
                  ),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // Subtle concentric white circle on the right
                      Positioned(
                        right: -55,
                        bottom: 18,
                        child: Container(
                          width: 210,
                          height: 210,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.55),
                              width: 26,
                            ),
                          ),
                        ),
                      ),
                      // Top Bar (Logo + SkillBridge + optional Lewati button)
                      Positioned(
                        top: 14,
                        left: 22,
                        right: 22,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Row(
                              children: [
                                SkillBridgeLogoMark(
                                  size: 36,
                                  borderRadius: 11,
                                  iconColor: Color(0xFF0057FF),
                                ),
                                SizedBox(width: 10),
                                Text(
                                  'SkillBridge',
                                  style: TextStyle(
                                    color: Color(0xFF0F172A),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                              ],
                            ),
                            if (showSkip)
                              Material(
                                color: Colors.white.withValues(alpha: 0.92),
                                borderRadius: BorderRadius.circular(99),
                                child: InkWell(
                                  onTap: onSkip,
                                  borderRadius: BorderRadius.circular(99),
                                  child: const Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 18,
                                      vertical: 8,
                                    ),
                                    child: Text(
                                      'Lewati',
                                      style: TextStyle(
                                        color: Color(0xFF64748B),
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      // Hero floating cards area
                      Positioned(
                        top: 66,
                        left: 22,
                        right: 22,
                        bottom: 16,
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 360),
                            child: heroIllustration,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Middle floating pill / stepper card
                SizedBox(height: isCompact ? 14 : 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Center(child: floatingMiddleAccessory),
                ),
                SizedBox(height: isCompact ? 18 : 24),

                // Lower text section: Eyebrow -> Headline with underline -> Description
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 26),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        eyebrow,
                        style: const TextStyle(
                          color: Color(0xFF0057FF),
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.1,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        headlineTop,
                        style: TextStyle(
                          color: const Color(0xFF0F172A),
                          fontSize: isCompact ? 28 : 31,
                          fontWeight: FontWeight.w800,
                          height: 1.15,
                          letterSpacing: -0.7,
                        ),
                      ),
                      _UnderlinedHeadlineText(
                        text: headlineUnderlined,
                        fontSize: isCompact ? 28 : 31,
                      ),
                      const SizedBox(height: 14),
                      Text(
                        description,
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 14.5,
                          fontWeight: FontWeight.w400,
                          height: 1.52,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ============================================================================
// SHARED UNDERLINED HEADLINE & CTA BUTTONS
// ============================================================================
class _UnderlinedHeadlineText extends StatelessWidget {
  const _UnderlinedHeadlineText({
    required this.text,
    required this.fontSize,
  });

  final String text;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          left: 0,
          right: 0,
          bottom: -3,
          height: 10,
          child: CustomPaint(
            painter: _BrushUnderlinePainter(),
          ),
        ),
        Text(
          text,
          style: TextStyle(
            color: const Color(0xFF0F172A),
            fontSize: fontSize,
            fontWeight: FontWeight.w800,
            height: 1.18,
            letterSpacing: -0.7,
          ),
        ),
      ],
    );
  }
}

class _BrushUnderlinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFBBD2FF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.5
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..moveTo(2, size.height * 0.65)
      ..quadraticBezierTo(
        size.width * 0.5,
        size.height * 0.20,
        size.width - 2,
        size.height * 0.55,
      );
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _NextCircleButton extends StatelessWidget {
  const _NextCircleButton({
    required this.onTap,
    required this.tooltip,
  });

  final VoidCallback onTap;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 64,
          height: 64,
          padding: const EdgeInsets.all(4.5),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFF3B82F6).withValues(alpha: 0.45),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0057FF).withValues(alpha: 0.28),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Container(
            decoration: const BoxDecoration(
              color: Color(0xFF0057FF),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.arrow_forward_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }
}

class _FullWidthStartButton extends StatelessWidget {
  const _FullWidthStartButton({
    required this.onTap,
    super.key,
  });

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 58,
      decoration: BoxDecoration(
        color: const Color(0xFF0057FF),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0057FF).withValues(alpha: 0.32),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Mulai Perjalananmu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.1,
                ),
              ),
              SizedBox(width: 10),
              Icon(
                Icons.arrow_forward_rounded,
                color: Colors.white,
                size: 19,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
