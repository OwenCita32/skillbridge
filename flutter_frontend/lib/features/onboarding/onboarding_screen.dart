import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../shared/widgets/skillbridge_logo.dart';

part 'controllers/onboarding_controller.dart';
part 'screens/onboarding_slide_page.dart';
part 'widgets/floating_motion.dart';
part 'widgets/slide1_hero_illustration.dart';
part 'widgets/slide2_hero_illustration.dart';
part 'widgets/slide3_hero_illustration.dart';

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
