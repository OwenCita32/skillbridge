part of '../personalization_flow_screen.dart';

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
