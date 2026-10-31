part of '../personalization_flow_screen.dart';

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
