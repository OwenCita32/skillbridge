part of '../dashboard_screen.dart';

// ============================================================================
// 3. ROYAL BLUE AI SKILL GAP ANALYSIS CARD
// ============================================================================
class _AiSkillGapBlueCard extends StatelessWidget {
  const _AiSkillGapBlueCard({
    required this.careerTitle,
    required this.skills,
    required this.hasAssessment,
    required this.isGeneratingRoadmap,
    required this.onTapOriginInfo,
    required this.onTapPrimaryAction,
    this.onTapSkill,
  });

  final String careerTitle;
  final List<Map<String, dynamic>> skills;
  final bool hasAssessment;
  final bool isGeneratingRoadmap;
  final VoidCallback onTapOriginInfo;
  final VoidCallback onTapPrimaryAction;
  final void Function(String skillName, int currentScore)? onTapSkill;

  @override
  Widget build(BuildContext context) {
    // Calculate readiness percentage from backend skills if assessed, otherwise 71%
    int readinessPct = 71;
    if (hasAssessment && skills.isNotEmpty) {
      double sumRatio = 0;
      for (final s in skills) {
        final cur = (s['current_level'] as num?)?.toDouble() ?? 0;
        final tgt = (s['target_level'] as num?)?.toDouble() ?? 3;
        sumRatio += (tgt > 0 ? (cur / tgt).clamp(0.0, 1.0) : 1.0);
      }
      final computed = ((sumRatio / skills.length) * 100).round();
      if (computed > 0) readinessPct = computed;
    }

    // Build display rows dynamically from backend assessment data
    final displayRows = <_SkillBarRowData>[];
    if (skills.isNotEmpty) {
      for (final s in skills.take(3)) {
        final skillObj = s['skill'] as Map?;
        final name = skillObj?['name'] as String? ?? 'Skill';
        final cur = (s['current_level'] as num?)?.toDouble() ?? 0;
        final tgt = (s['target_level'] as num?)?.toDouble() ?? 4;
        final gap = (s['gap'] as num?)?.toInt() ?? 0;
        final isAssessed = s['is_assessed'] == true || cur > 0;
        final pct = (tgt > 0 && isAssessed)
            ? ((cur / tgt) * 100).round().clamp(0, 100)
            : 0;

        final String badgeLabel;
        final Color badgeBg;
        final Color badgeText;
        final Color barColor;

        if (pct >= 80 || (cur >= tgt && isAssessed && cur > 0)) {
          badgeLabel = 'Kuat';
          badgeBg = const Color(0xFF10B981);
          badgeText = Colors.white;
          barColor = Colors.white;
        } else if (pct >= 60 || gap == 1) {
          badgeLabel = 'Cukup';
          badgeBg = const Color(0xFF60A5FA);
          badgeText = Colors.white;
          barColor = Colors.white;
        } else {
          badgeLabel = 'Gap';
          badgeBg = const Color(0xFFFBBF24);
          badgeText = const Color(0xFF0F172A);
          barColor = const Color(0xFFFBBF24);
        }

        displayRows.add(
          _SkillBarRowData(
            name: name,
            badgeLabel: badgeLabel,
            badgeBg: badgeBg,
            badgeText: badgeText,
            barColor: barColor,
            percentage: pct,
          ),
        );
      }
    }

    if (displayRows.isEmpty) {
      displayRows.addAll(const [
        _SkillBarRowData(
          name: 'Visual Design',
          badgeLabel: 'Kuat',
          badgeBg: Color(0xFF10B981),
          badgeText: Colors.white,
          barColor: Colors.white,
          percentage: 90,
        ),
        _SkillBarRowData(
          name: 'Prototyping',
          badgeLabel: 'Cukup',
          badgeBg: Color(0xFF60A5FA),
          badgeText: Colors.white,
          barColor: Colors.white,
          percentage: 78,
        ),
        _SkillBarRowData(
          name: 'UX Research',
          badgeLabel: 'Gap',
          badgeBg: Color(0xFFFBBF24),
          badgeText: Color(0xFF0F172A),
          barColor: Color(0xFFFBBF24),
          percentage: 45,
        ),
      ]);
    }

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0A60FF), Color(0xFF0051E6)],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0057FF).withValues(alpha: 0.30),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Top-right subtle translucent circle decoration
          Positioned(
            right: -45,
            top: -45,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.06),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Pill badge: ✦ AI Skill Gap Analysis
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(99),
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
                        'AI Skill Gap Analysis',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Seberapa cocok skill-mu dengan kebutuhan lowongan freelance UI/UX.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w400,
                    height: 1.42,
                  ),
                ),
                const SizedBox(height: 20),

                // Middle Row: 71% Donut Gauge + 3 Skill Progress Bars
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Circular Gauge
                    SizedBox(
                      width: 108,
                      height: 108,
                      child: CustomPaint(
                        painter: _ReadinessRingPainter(
                          progress: readinessPct / 100.0,
                        ),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '$readinessPct%',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 26,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.6,
                                ),
                              ),
                              Text(
                                'siap kerja',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.80),
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 18),

                    // Right Skill Bars
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (int i = 0; i < displayRows.length; i++) ...[
                            _SkillGapBarItem(
                              data: displayRows[i],
                              onTap: () => onTapSkill?.call(
                                displayRows[i].name,
                                displayRows[i].percentage,
                              ),
                            ),
                            if (i < displayRows.length - 1)
                              const SizedBox(height: 12),
                          ],
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Container(
                                width: 2,
                                height: 9,
                                color: Colors.white.withValues(alpha: 0.7),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                'Standar klien: 80%',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.78),
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Underlined "Dari mana angka ini?" button
                GestureDetector(
                  onTap: onTapOriginInfo,
                  child: Container(
                    padding: const EdgeInsets.only(bottom: 1.5),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.white.withValues(alpha: 0.75),
                          width: 1,
                        ),
                      ),
                    ),
                    child: const Text(
                      'Dari mana angka ini?',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Streak & 7-Day Activity Bar
                const _WeeklyStreakBar(),
                const SizedBox(height: 16),

                // Bottom White CTA Button: "Lihat gap & rekomendasi ->"
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: Material(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    child: InkWell(
                      onTap: isGeneratingRoadmap ? null : onTapPrimaryAction,
                      borderRadius: BorderRadius.circular(16),
                      child: Center(
                        child: isGeneratingRoadmap
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.2,
                                  color: Color(0xFF0057FF),
                                ),
                              )
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Lihat gap & rekomendasi',
                                    style: TextStyle(
                                      color: Color(0xFF0057FF),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Icon(
                                    Icons.arrow_forward_rounded,
                                    color: Color(0xFF0057FF),
                                    size: 17,
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SkillGapBarItem extends StatelessWidget {
  const _SkillGapBarItem({required this.data, this.onTap});

  final _SkillBarRowData data;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    data.name,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: data.badgeBg,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    data.badgeLabel,
                    style: TextStyle(
                      color: data.badgeText,
                      fontSize: 9.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '${data.percentage}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                const barHeight = 8.5;
                final fillWidth = data.percentage <= 0
                    ? 0.0
                    : (width * (data.percentage / 100.0)).clamp(
                        barHeight,
                        width,
                      );
                final markerX = width * 0.80;

                return SizedBox(
                  height: 14,
                  child: Stack(
                    alignment: Alignment.centerLeft,
                    children: [
                      // Full-width track with clearly rounded pill ends
                      Container(
                        height: barHeight,
                        width: width,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.28),
                          borderRadius: BorderRadius.circular(99),
                        ),
                      ),
                      // Progress fill with prominent rounded ends (capsule/pill)
                      Container(
                        height: barHeight,
                        width: fillWidth,
                        decoration: BoxDecoration(
                          color: data.barColor,
                          borderRadius: BorderRadius.circular(99),
                          boxShadow: [
                            BoxShadow(
                              color: data.barColor.withValues(alpha: 0.25),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                      ),
                      // 80% client standard marker
                      Positioned(
                        left: markerX - 1,
                        child: Container(
                          width: 2,
                          height: 13,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.85),
                            borderRadius: BorderRadius.circular(1),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ReadinessRingPainter extends CustomPainter {
  const _ReadinessRingPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - 6;
    const strokeWidth = 9.5;

    final trackPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.20)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, trackPaint);

    final arcPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress.clamp(0.05, 1.0),
      false,
      arcPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ReadinessRingPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
