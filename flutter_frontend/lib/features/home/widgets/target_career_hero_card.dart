part of '../dashboard_screen.dart';

// ============================================================================
// 2. TARGET KARIER HERO CARD
// ============================================================================
class _TargetCareerHeroCard extends StatelessWidget {
  const _TargetCareerHeroCard({required this.careerTitle, required this.onTap});

  final String careerTitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(26),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withValues(alpha: 0.05),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Soft pale blue curved background shape on the right
            Positioned(
              right: -35,
              top: -25,
              bottom: -25,
              child: Container(
                width: 175,
                decoration: const BoxDecoration(
                  color: Color(0xFFF1F6FF),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 18, 20),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 6.5,
                              height: 6.5,
                              decoration: const BoxDecoration(
                                color: Color(0xFF0057FF),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              'TARGET KARIER',
                              style: TextStyle(
                                color: Color(0xFF0057FF),
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.9,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Freelance',
                          style: TextStyle(
                            color: Color(0xFF0F172A),
                            fontSize: 21,
                            fontWeight: FontWeight.w800,
                            height: 1.15,
                            letterSpacing: -0.4,
                          ),
                        ),
                        Text(
                          careerTitle,
                          style: const TextStyle(
                            color: Color(0xFF0057FF),
                            fontSize: 21,
                            fontWeight: FontWeight.w800,
                            height: 1.2,
                            letterSpacing: -0.4,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFECFDF5),
                                borderRadius: BorderRadius.circular(99),
                              ),
                              child: const Text(
                                'On track',
                                style: TextStyle(
                                  color: Color(0xFF10B981),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Flexible(
                              child: Text(
                                'Est. siap: 6 minggu',
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Color(0xFF64748B),
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Right Miniature Kanban / UI Board Illustration
                  const SizedBox(
                    width: 114,
                    height: 112,
                    child: _MiniCareerBoardIllustration(),
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

class _MiniCareerBoardIllustration extends StatelessWidget {
  const _MiniCareerBoardIllustration();

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Base board container
        Positioned(
          left: 4,
          top: 12,
          right: 8,
          bottom: 8,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFE6EFFF),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFD2E2FF)),
            ),
            child: Column(
              children: [
                // Top header bars
                Row(
                  children: [
                    Container(
                      width: 24,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFF93B4FF),
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      width: 20,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFF93B4FF),
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 7),
                // 2x2 grid of mini task cards
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            Expanded(
                              child: _miniCard(
                                bgColor: Colors.white,
                                line1: const Color(0xFF475569),
                                line2: const Color(0xFFF59E0B),
                              ),
                            ),
                            const SizedBox(height: 5),
                            Expanded(
                              child: _miniCard(
                                bgColor: Colors.white,
                                line1: const Color(0xFF475569),
                                line2: const Color(0xFFF59E0B),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Column(
                          children: [
                            Expanded(
                              child: _miniCard(
                                bgColor: const Color(0xFF0057FF),
                                line1: Colors.white,
                                line2: Colors.white.withValues(alpha: 0.7),
                              ),
                            ),
                            const SizedBox(height: 5),
                            Expanded(
                              child: _miniCard(
                                bgColor: Colors.white,
                                line1: const Color(0xFF475569),
                                line2: const Color(0xFF10B981),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        // Top-right floating white badge with blue circle
        Positioned(
          top: 0,
          right: 0,
          child: Container(
            width: 42,
            height: 30,
            padding: const EdgeInsets.symmetric(horizontal: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0F172A).withValues(alpha: 0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 13,
                  height: 13,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF0057FF),
                      width: 3,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 9,
                      height: 2.5,
                      color: const Color(0xFF64748B),
                    ),
                    const SizedBox(height: 2.5),
                    Container(
                      width: 6,
                      height: 2.5,
                      color: const Color(0xFF94A3B8),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        // Bottom-right green check circle
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: const Color(0xFF22C55E),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: const Icon(
              Icons.check_rounded,
              color: Colors.white,
              size: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _miniCard({
    required Color bgColor,
    required Color line1,
    required Color line2,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 22,
            height: 3,
            decoration: BoxDecoration(
              color: line1,
              borderRadius: BorderRadius.circular(99),
            ),
          ),
          const SizedBox(height: 3.5),
          Container(
            width: 14,
            height: 3,
            decoration: BoxDecoration(
              color: line2,
              borderRadius: BorderRadius.circular(99),
            ),
          ),
        ],
      ),
    );
  }
}
