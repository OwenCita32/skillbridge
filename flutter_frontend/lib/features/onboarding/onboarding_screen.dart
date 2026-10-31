import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../shared/widgets/skillbridge_logo.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({
    required this.onCompleted,
    this.onSkipToAuth,
    this.enableLoopingAnimation,
    super.key,
  });

  /// Called when the user finishes slide 3 ("Mulai Perjalananmu") to enter personalization.
  final VoidCallback onCompleted;

  /// Optional callback if "Lewati" should jump straight to login or personalization.
  final VoidCallback? onSkipToAuth;

  final bool? enableLoopingAnimation;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  late final AnimationController _floatController;
  int _currentPage = 0;

  bool get _shouldLoop {
    if (widget.enableLoopingAnimation != null) {
      return widget.enableLoopingAnimation!;
    }
    final bindingName = WidgetsBinding.instance.runtimeType.toString();
    return !bindingName.contains('AutomatedTest');
  }

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3600),
    );
    if (_shouldLoop) {
      _floatController.repeat();
    } else {
      _floatController.value = 0.25;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final disableAnimations =
        MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (disableAnimations && _floatController.isAnimating) {
      _floatController.stop();
    } else if (!disableAnimations &&
        _shouldLoop &&
        !_floatController.isAnimating) {
      _floatController.repeat();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeOutCubic,
      );
    } else {
      widget.onCompleted();
    }
  }

  void _handleSkip() {
    (widget.onSkipToAuth ?? widget.onCompleted).call();
  }

  @override
  Widget build(BuildContext context) {
    final isLastSlide = _currentPage == 2;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) => setState(() => _currentPage = index),
                children: [
                  // SLIDE 1
                  _OnboardingSlidePage(
                    floatAnimation: _floatController,
                    showSkip: true,
                    onSkip: _handleSkip,
                    heroGradientColors: const [
                      Color(0xFFF2F6FF),
                      Color(0xFFE6EEFF),
                    ],
                    heroIllustration: _Slide1HeroIllustration(
                      animation: _floatController,
                    ),
                    floatingMiddleAccessory: _FloatingMotion(
                      animation: _floatController,
                      phase: 2.3,
                      verticalAmplitude: 5.5,
                      horizontalAmplitude: 1.5,
                      child: const _StatusPillBadge(
                        iconBgColor: Color(0xFFF59E0B),
                        label: 'Jalur freelance dipilih',
                      ),
                    ),
                    eyebrow: 'LANGKAH PERTAMA',
                    headlineTop: 'Tentukan',
                    headlineUnderlined: 'Target Kariermu',
                    description:
                        'Pilih jalur freelance impianmu dan biarkan platform menyesuaikan perjalanannya.',
                  ),

                  // SLIDE 2
                  _OnboardingSlidePage(
                    floatAnimation: _floatController,
                    showSkip: true,
                    onSkip: _handleSkip,
                    heroGradientColors: const [
                      Color(0xFFF2F6FF),
                      Color(0xFFE6EEFF),
                    ],
                    heroIllustration: _Slide2HeroIllustration(
                      animation: _floatController,
                    ),
                    floatingMiddleAccessory: _FloatingMotion(
                      animation: _floatController,
                      phase: 2.8,
                      verticalAmplitude: 5.0,
                      horizontalAmplitude: 1.2,
                      child: const _RoadmapStepperCard(),
                    ),
                    eyebrow: 'DIDUKUNG AI',
                    headlineTop: 'Analisis Skill &',
                    headlineUnderlined: 'Roadmap Cerdas',
                    description:
                        'Dapatkan analisis kesenjangan keterampilan (skill gap analysis) dan ikuti peta jalan belajar yang dirancang khusus oleh AI untukmu.',
                  ),

                  // SLIDE 3 (Exact match to uploaded screenshot 1)
                  _OnboardingSlidePage(
                    floatAnimation: _floatController,
                    showSkip: false,
                    onSkip: _handleSkip,
                    heroGradientColors: const [
                      Color(0xFFEDFBF5),
                      Color(0xFFDDF5EA),
                    ],
                    heroIllustration: _Slide3HeroIllustration(
                      animation: _floatController,
                    ),
                    floatingMiddleAccessory: _FloatingMotion(
                      animation: _floatController,
                      phase: 1.9,
                      verticalAmplitude: 5.5,
                      horizontalAmplitude: 1.5,
                      child: const _StatusPillBadge(
                        iconBgColor: Color(0xFF10B981),
                        label: 'Dibagikan ke LinkedIn',
                      ),
                    ),
                    eyebrow: 'SIAP DILIRIK KLIEN',
                    headlineTop: 'Bangun Portofolio',
                    headlineUnderlined: '& Mulai Melamar',
                    description:
                        'Kumpulkan bukti kompetensi, tautkan proyek eksternal, dan bagikan pencapaianmu langsung ke LinkedIn untuk menarik klien.',
                  ),
                ],
              ),
            ),

            // Bottom Navigation Area:
            // Slides 1 & 2 show Dots + Circular Arrow Button.
            // Slide 3 shows Full-Width "Mulai Perjalananmu ->" CTA Button.
            Padding(
              padding: const EdgeInsets.fromLTRB(26, 8, 26, 22),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 260),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                child: isLastSlide
                    ? _FullWidthStartButton(
                        key: const ValueKey('start-journey-btn'),
                        onTap: widget.onCompleted,
                      )
                    : Row(
                        key: const ValueKey('dots-and-next-row'),
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: List.generate(3, (index) {
                              final isSelected = _currentPage == index;
                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 260),
                                curve: Curves.easeOutCubic,
                                margin: const EdgeInsets.only(right: 8),
                                width: isSelected ? 28 : 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? const Color(0xFF0057FF)
                                      : const Color(0xFFCBD5E1),
                                  borderRadius: BorderRadius.circular(99),
                                ),
                              );
                            }),
                          ),
                          _NextCircleButton(
                            onTap: _nextPage,
                            tooltip: 'Selanjutnya',
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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

/// Reusable sinusoidal floating wrapper that gives cards an organic, 3D hovering feel.
class _FloatingMotion extends StatelessWidget {
  const _FloatingMotion({
    required this.animation,
    required this.child,
    this.phase = 0.0,
    this.verticalAmplitude = 7.0,
    this.horizontalAmplitude = 2.0,
    this.baseRotation = 0.0,
    this.rotationAmplitude = 0.012,
  });

  final Animation<double> animation;
  final Widget child;
  final double phase;
  final double verticalAmplitude;
  final double horizontalAmplitude;
  final double baseRotation;
  final double rotationAmplitude;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, cachedChild) {
        final angle = (animation.value * 2 * math.pi) + phase;
        final dy = math.sin(angle) * verticalAmplitude;
        final dx = math.cos(angle * 0.7) * horizontalAmplitude;
        final rot = baseRotation + (math.sin(angle * 0.85) * rotationAmplitude);

        return Transform.translate(
          offset: Offset(dx, dy),
          child: Transform.rotate(
            angle: rot,
            child: cachedChild,
          ),
        );
      },
      child: child,
    );
  }
}

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

class _StatusPillBadge extends StatelessWidget {
  const _StatusPillBadge({
    required this.iconBgColor,
    required this.label,
  });

  final Color iconBgColor;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(99),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.07),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_rounded,
              color: Colors.white,
              size: 14,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF1E293B),
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

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
