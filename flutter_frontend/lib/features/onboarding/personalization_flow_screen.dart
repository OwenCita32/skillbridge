import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

class PersonalizationFlowScreen extends StatefulWidget {
  const PersonalizationFlowScreen({
    required this.onCompleted,
    this.onBackToOnboarding,
    this.enableLoopingAnimation,
    super.key,
  });

  final void Function(String selectedRole, String selectedLevel) onCompleted;
  final VoidCallback? onBackToOnboarding;
  final bool? enableLoopingAnimation;

  @override
  State<PersonalizationFlowScreen> createState() =>
      _PersonalizationFlowScreenState();
}

enum _FlowStep {
  chooseRole,
  chooseLevel,
  aiProcessing,
}

class _PersonalizationFlowScreenState extends State<PersonalizationFlowScreen> {
  _FlowStep _step = _FlowStep.chooseRole;
  String _selectedRole = 'UI/UX Designer';
  String _selectedLevel = 'Menengah';

  void _goToChooseLevel() {
    setState(() => _step = _FlowStep.chooseLevel);
  }

  void _goToAiProcessing() {
    setState(() => _step = _FlowStep.aiProcessing);
  }

  void _handleBackFromLevel() {
    setState(() => _step = _FlowStep.chooseRole);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 320),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      child: switch (_step) {
        _FlowStep.chooseRole => _ChooseRoleStepScreen(
          key: const ValueKey('step-choose-role'),
          selectedRole: _selectedRole,
          onSelectRole: (role) => setState(() => _selectedRole = role),
          onContinue: _goToChooseLevel,
          enableLoopingAnimation: widget.enableLoopingAnimation,
        ),
        _FlowStep.chooseLevel => _ChooseLevelStepScreen(
          key: const ValueKey('step-choose-level'),
          selectedRole: _selectedRole,
          selectedLevel: _selectedLevel,
          onSelectLevel: (level) => setState(() => _selectedLevel = level),
          onBack: _handleBackFromLevel,
          onContinue: _goToAiProcessing,
        ),
        _FlowStep.aiProcessing => _AiProcessingStepScreen(
          key: const ValueKey('step-ai-processing'),
          selectedRole: _selectedRole,
          selectedLevel: _selectedLevel,
          enableLoopingAnimation: widget.enableLoopingAnimation,
          onFinished: () =>
              widget.onCompleted(_selectedRole, _selectedLevel),
        ),
      },
    );
  }
}

// ============================================================================
// STEP 1/2: PILIH PERAN FREELANCE (Matching Screenshot 2)
// ============================================================================
class _ChooseRoleStepScreen extends StatefulWidget {
  const _ChooseRoleStepScreen({
    required this.selectedRole,
    required this.onSelectRole,
    required this.onContinue,
    this.enableLoopingAnimation,
    super.key,
  });

  final String selectedRole;
  final ValueChanged<String> onSelectRole;
  final VoidCallback onContinue;
  final bool? enableLoopingAnimation;

  @override
  State<_ChooseRoleStepScreen> createState() => _ChooseRoleStepScreenState();
}

class _ChooseRoleStepScreenState extends State<_ChooseRoleStepScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _floatController;

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
      duration: const Duration(milliseconds: 3200),
    );
    if (_shouldLoop) {
      _floatController.repeat();
    } else {
      _floatController.value = 0.25;
    }
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isUiUxSelected = widget.selectedRole == 'UI/UX Designer';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Stack(
          children: [
            ListView(
              padding: const EdgeInsets.fromLTRB(22, 18, 22, 116),
              children: [
                // Top progress bar (1/2)
                const _StepProgressHeader(currentStep: 1, totalSteps: 2),
                const SizedBox(height: 28),
                const Text(
                  'Apa peran freelance yang\ningin kamu capai?',
                  style: TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 25,
                    fontWeight: FontWeight.w800,
                    height: 1.22,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Pilih satu. Kamu bisa menggantinya nanti.',
                  style: TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 13.5,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 22),

                // Featured Full-Width Card: UI/UX Designer
                _FeaturedRoleCard(
                  title: 'UI/UX Designer',
                  subtitle: 'Paling diminati',
                  selected: isUiUxSelected,
                  floatAnimation: _floatController,
                  onTap: () => widget.onSelectRole('UI/UX Designer'),
                ),
                const SizedBox(height: 14),

                // 2-Column Grid for remaining roles
                Row(
                  children: [
                    Expanded(
                      child: _GridRoleCard(
                        title: 'Frontend\nDeveloper',
                        subtitle: 'React · Web',
                        selected:
                            widget.selectedRole == 'Frontend Developer',
                        illustrationBg: const Color(0xFFE8F8F2),
                        illustration: const _FrontendTerminalIllustration(),
                        floatAnimation: _floatController,
                        phase: 1.2,
                        onTap: () =>
                            widget.onSelectRole('Frontend Developer'),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: _GridRoleCard(
                        title: 'Data Analyst',
                        subtitle: 'SQL · Python',
                        selected: widget.selectedRole == 'Data Analyst',
                        illustrationBg: const Color(0xFFFEF6E0),
                        illustration: const _DataAnalystChartIllustration(),
                        floatAnimation: _floatController,
                        phase: 2.4,
                        onTap: () => widget.onSelectRole('Data Analyst'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _GridRoleCard(
                        title: 'Content\nWriter',
                        subtitle: 'Copy · SEO',
                        selected: widget.selectedRole == 'Content Writer',
                        illustrationBg: const Color(0xFFF3EEFF),
                        illustration: const _CopywriterDocIllustration(),
                        floatAnimation: _floatController,
                        phase: 3.5,
                        onTap: () => widget.onSelectRole('Content Writer'),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: _GridRoleCard(
                        title: 'Digital\nMarketer',
                        subtitle: 'Ads · Growth',
                        selected: widget.selectedRole == 'Digital Marketer',
                        illustrationBg: const Color(0xFFFDECEB),
                        illustration: const _MegaphoneIllustration(),
                        floatAnimation: _floatController,
                        phase: 4.6,
                        onTap: () => widget.onSelectRole('Digital Marketer'),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // Fixed Bottom CTA Button
            Positioned(
              left: 22,
              right: 22,
              bottom: 18,
              child: _PrimaryCtaButton(
                label: 'Lanjutkan',
                onTap: widget.onContinue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepProgressHeader extends StatelessWidget {
  const _StepProgressHeader({
    required this.currentStep,
    required this.totalSteps,
    this.onBack,
  });

  final int currentStep;
  final int totalSteps;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (onBack != null) ...[
          GestureDetector(
            onTap: onBack,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0F172A).withValues(alpha: 0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_back_rounded,
                color: Color(0xFF334155),
                size: 19,
              ),
            ),
          ),
          const SizedBox(width: 16),
        ] else
          const SizedBox(width: 48),
        Expanded(
          child: Row(
            children: List.generate(totalSteps, (index) {
              final active = index < currentStep;
              return Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 280),
                  margin: EdgeInsets.only(
                    right: index < totalSteps - 1 ? 8 : 0,
                  ),
                  height: 6,
                  decoration: BoxDecoration(
                    color: active
                        ? const Color(0xFF0057FF)
                        : const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(width: 18),
        Text(
          '$currentStep/$totalSteps',
          style: const TextStyle(
            color: Color(0xFF64748B),
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

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

// ============================================================================
// STEP 2/2: PILIH LEVEL PENGALAMAN (Matching Screenshot 3)
// ============================================================================
class _ChooseLevelStepScreen extends StatelessWidget {
  const _ChooseLevelStepScreen({
    required this.selectedRole,
    required this.selectedLevel,
    required this.onSelectLevel,
    required this.onBack,
    required this.onContinue,
    super.key,
  });

  final String selectedRole;
  final String selectedLevel;
  final ValueChanged<String> onSelectLevel;
  final VoidCallback onBack;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Stack(
          children: [
            ListView(
              padding: const EdgeInsets.fromLTRB(22, 18, 22, 116),
              children: [
                _StepProgressHeader(
                  currentStep: 2,
                  totalSteps: 2,
                  onBack: onBack,
                ),
                const SizedBox(height: 26),
                const Text(
                  'Sejauh mana\npengalamanmu di bidang\nini?',
                  style: TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 25,
                    fontWeight: FontWeight.w800,
                    height: 1.22,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Bidang: $selectedRole',
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 13.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 24),

                // Option 1: Pemula
                _ExperienceLevelCard(
                  title: 'Pemula',
                  subtitle: 'Baru mau belajar dari nol',
                  activeBars: 1,
                  selected: selectedLevel == 'Pemula',
                  onTap: () => onSelectLevel('Pemula'),
                ),
                const SizedBox(height: 14),

                // Option 2: Menengah
                _ExperienceLevelCard(
                  title: 'Menengah',
                  subtitle: 'Sudah tahu dasar, butuh portfolio',
                  activeBars: 2,
                  selected: selectedLevel == 'Menengah',
                  onTap: () => onSelectLevel('Menengah'),
                ),
                const SizedBox(height: 14),

                // Option 3: Mahir
                _ExperienceLevelCard(
                  title: 'Mahir',
                  subtitle: 'Siap cari proyek klien',
                  activeBars: 3,
                  selected: selectedLevel == 'Mahir',
                  onTap: () => onSelectLevel('Mahir'),
                ),
                const SizedBox(height: 22),

                // Pale Yellow AI Callout Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFBEB),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: const Color(0xFFFDE68A),
                      width: 1.2,
                    ),
                  ),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: 2),
                        child: Icon(
                          Icons.auto_awesome_rounded,
                          color: Color(0xFFD97706),
                          size: 18,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Jujur saja ya. AI akan memakai jawabanmu untuk menghitung skill gap dan menentukan titik awal roadmap.',
                          style: TextStyle(
                            color: Color(0xFF92400E),
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                            height: 1.48,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Fixed Bottom CTA Button
            Positioned(
              left: 22,
              right: 22,
              bottom: 18,
              child: _PrimaryCtaButton(
                label: 'Lanjutkan',
                onTap: onContinue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExperienceLevelCard extends StatelessWidget {
  const _ExperienceLevelCard({
    required this.title,
    required this.subtitle,
    required this.activeBars,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final int activeBars;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF0057FF) : Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            if (selected)
              BoxShadow(
                color: const Color(0xFF0057FF).withValues(alpha: 0.28),
                blurRadius: 22,
                offset: const Offset(0, 10),
              )
            else
              BoxShadow(
                color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
          ],
        ),
        child: Row(
          children: [
            // 3-Bar Level Icon Container
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: selected
                    ? Colors.white.withValues(alpha: 0.16)
                    : const Color(0xFFEEF4FF),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: List.generate(3, (index) {
                    final barActive = index < activeBars;
                    final heights = [10.0, 16.0, 22.0];
                    final barColor = selected
                        ? (barActive
                              ? Colors.white
                              : Colors.white.withValues(alpha: 0.38))
                        : (barActive
                              ? const Color(0xFF0057FF)
                              : const Color(0xFFCBD5E1));
                    return Container(
                      width: 5.5,
                      height: heights[index],
                      margin: EdgeInsets.only(right: index < 2 ? 4 : 0),
                      decoration: BoxDecoration(
                        color: barColor,
                        borderRadius: BorderRadius.circular(99),
                      ),
                    );
                  }),
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Title & Subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: selected ? Colors.white : const Color(0xFF0F172A),
                      fontSize: 15.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: selected
                          ? Colors.white.withValues(alpha: 0.85)
                          : const Color(0xFF64748B),
                      fontSize: 12.5,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),

            // Radio Indicator
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? Colors.white : Colors.transparent,
                border: Border.all(
                  color: selected ? Colors.white : const Color(0xFFCBD5E1),
                  width: 1.8,
                ),
              ),
              child: selected
                  ? Center(
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFF0057FF),
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

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

// ============================================================================
// SHARED PRIMARY CTA BUTTON FOR PERSONALIZATION STEPS
// ============================================================================
class _PrimaryCtaButton extends StatelessWidget {
  const _PrimaryCtaButton({
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        color: const Color(0xFF0057FF),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0057FF).withValues(alpha: 0.30),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Center(
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

