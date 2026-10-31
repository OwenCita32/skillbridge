// ignore_for_file: invalid_use_of_protected_member
part of '../dashboard_screen.dart';

extension _DashboardAiRecommendationsModal on _DashboardScreenState {
  void _showAiRecommendationsModal(
    BuildContext context,
    String careerTitle,
    List<dynamic> skills,
  ) {
    // Siapkan data fallback secara instan sebelum modal dibuka agar tidak pernah berputar tanpa henti
    _explanationData ??= _buildFallbackExplanations();
    _isExplaining = false;
    _explanationError = null;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        bool requestedUpgrade = false;
        return StatefulBuilder(
          builder: (modalContext, setModalState) {
            if (!requestedUpgrade) {
              requestedUpgrade = true;
              Future.microtask(() async {
                try {
                  final fresh = await widget.apiClient
                      .explainSkillGaps()
                      .timeout(const Duration(seconds: 6));
                  if (mounted) {
                    setState(() => _explanationData = fresh);
                  }
                  if (modalContext.mounted) {
                    setModalState(() {});
                  }
                } catch (_) {
                  // Tetap gunakan fallback instan jika server/OpenAI lambat
                }
              });
            }

            return Container(
              height: MediaQuery.of(context).size.height * 0.88,
              decoration: const BoxDecoration(
                color: Color(0xFFF8FAFC),
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                children: [
                  // Grabber & Header
                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 14, 16, 14),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                      border: Border(
                        bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1),
                      ),
                    ),
                    child: Column(
                      children: [
                        Center(
                          child: Container(
                            width: 38,
                            height: 4,
                            decoration: BoxDecoration(
                              color: const Color(0xFFCBD5E1),
                              borderRadius: BorderRadius.circular(99),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEEF2FF),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.auto_awesome_rounded,
                                color: Color(0xFF0057FF),
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Analisis AI & Rekomendasi',
                                    style: TextStyle(
                                      color: Color(0xFF0F172A),
                                      fontSize: 17,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Kesenjangan kompetensi untuk $careerTitle',
                                    style: const TextStyle(
                                      color: Color(0xFF64748B),
                                      fontSize: 12.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () => Navigator.of(sheetContext).pop(),
                              icon: const Icon(
                                Icons.close_rounded,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Content Area
                  Expanded(
                    child: _isExplaining && _explanationData == null
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const CircularProgressIndicator(
                                  color: Color(0xFF0057FF),
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'AI sedang menganalisis skill gap...',
                                  style: TextStyle(
                                    color: Color(0xFF0F172A),
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                const Text(
                                  'Menyusun langkah rekomendasi taktis kariermu',
                                  style: TextStyle(
                                    color: Color(0xFF64748B),
                                    fontSize: 12.5,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : _explanationError != null && _explanationData == null
                            ? Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(24),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.error_outline_rounded,
                                        color: Color(0xFFEF4444),
                                        size: 40,
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        _explanationError!,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          color: Color(0xFF0F172A),
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 14),
                                      FilledButton.icon(
                                        onPressed: () async {
                                          await _explainGaps();
                                          setModalState(() {});
                                        },
                                        icon: const Icon(
                                          Icons.refresh_rounded,
                                          size: 16,
                                        ),
                                        label: const Text('Coba Lagi'),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : _buildAiModalContent(sheetContext, careerTitle),
                  ),

                  // Bottom Sticky CTA
                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      border: Border(
                        top: BorderSide(color: Color(0xFFE2E8F0), width: 1),
                      ),
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: FilledButton.icon(
                        onPressed: () {
                          Navigator.of(sheetContext).pop();
                          if (_roadmap == null) {
                            _generateRoadmap();
                          } else {
                            widget.onOpenRoadmap();
                          }
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF0057FF),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        icon: const Icon(Icons.school_rounded, size: 18),
                        label: const Text(
                          'Buka Roadmap Pembelajaran',
                          style: TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildAiModalContent(BuildContext sheetContext, String careerTitle) {
    final data = _explanationData ?? {};
    final source =
        data['explanation_source'] as String? ?? 'deterministic_fallback';
    final model = data['model'] as String? ?? 'gpt-4o-mini';
    final rawSkills = (data['skills'] as List<dynamic>? ?? []);
    final skillList = rawSkills
        .map((v) => Map<String, dynamic>.from(v as Map))
        .toList();

    final isOpenAi = source == 'openai_responses';

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      children: [
        // AI Engine Pill Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: isOpenAi ? const Color(0xFFECFDF5) : const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isOpenAi
                  ? const Color(0xFFA7F3D0)
                  : const Color(0xFFBFDBFE),
            ),
          ),
          child: Row(
            children: [
              Icon(
                isOpenAi
                    ? Icons.auto_awesome_rounded
                    : Icons.offline_bolt_rounded,
                color: isOpenAi
                    ? const Color(0xFF059669)
                    : const Color(0xFF2563EB),
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isOpenAi
                      ? 'Didukung oleh OpenAI ($model) • Analisis Real-Time'
                      : 'Analisis Cerdas SkillBridge Engine (Hybrid Fallback Aktif)',
                  style: TextStyle(
                    color: isOpenAi
                        ? const Color(0xFF065F46)
                        : const Color(0xFF1E40AF),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Highlight Info Banner
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFBEB),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFFDE68A)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.lightbulb_rounded,
                color: Color(0xFFD97706),
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Prioritas Rekomendasi AI',
                      style: TextStyle(
                        color: Color(0xFF92400E),
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Klien mencari bukti portofolio dan pemahaman alur kerja yang matang. Selesaikan rekomendasi aksi di bawah untuk menutup skill gap-mu.',
                      style: TextStyle(
                        color: const Color(0xFFB45309).withOpacity(0.9),
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Shortcut to open AI Chat
        InkWell(
          onTap: () {
            Navigator.of(sheetContext).pop();
            _openAiMentorChat(careerTitle);
          },
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFCBD5E1)),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.chat_bubble_outline_rounded,
                  size: 16,
                  color: Color(0xFF0057FF),
                ),
                SizedBox(width: 8),
                Text(
                  '💬 Ingin diskusi lebih lanjut? Tanya AI Mentor',
                  style: TextStyle(
                    color: Color(0xFF0057FF),
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // List of Skill Cards
        ...skillList.map((item) {
          final skillMap = Map<String, dynamic>.from(item['skill'] as Map? ?? {});
          final name = (skillMap['name'] as String?) ?? 'Skill';
          final cur = (item['current_level'] as num?)?.toDouble() ?? 2.0;
          final tgt = (item['target_level'] as num?)?.toDouble() ?? 4.0;
          final gap = (item['gap'] as num?)?.toInt() ?? 0;
          final pct = (item['percentage'] as num?)?.toInt() ??
              (tgt > 0 ? ((cur / tgt) * 100).round().clamp(0, 100) : 70);
          final explanation = (item['explanation'] as String?) ?? '';
          final nextAction = (item['suggested_next_action'] as String?) ?? '';
          final isGap = gap > 0 || pct < 80;

          return Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        style: const TextStyle(
                          color: Color(0xFF0F172A),
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isGap
                            ? const Color(0xFFFEF3C7)
                            : const Color(0xFFECFDF5),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        isGap ? 'Gap $pct%' : 'Cukup $pct%',
                        style: TextStyle(
                          color: isGap
                              ? const Color(0xFFD97706)
                              : const Color(0xFF059669),
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // AI Analysis section
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.psychology_outlined,
                            size: 15,
                            color: Color(0xFF475569),
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Kebutuhan Klien / Analisis Pasar:',
                            style: TextStyle(
                              color: Color(0xFF475569),
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        explanation,
                        style: const TextStyle(
                          color: Color(0xFF1E293B),
                          fontSize: 12.5,
                          height: 1.45,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // Actionable Next Step
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.track_changes_rounded,
                            size: 15,
                            color: Color(0xFF0057FF),
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Rekomendasi Langkah Nyata:',
                            style: TextStyle(
                              color: Color(0xFF0057FF),
                              fontSize: 11.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        nextAction,
                        style: const TextStyle(
                          color: Color(0xFF1E293B),
                          fontSize: 12.5,
                          height: 1.45,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // Quick action button to take quiz
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () {
                      Navigator.of(sheetContext).pop();
                      _openQuiz(name, pct);
                    },
                    icon: const Icon(Icons.quiz_outlined, size: 15),
                    label: const Text(
                      'Uji Pemahaman (Kuis)',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

class _SkillGapExplanationPanel extends StatelessWidget {
  const _SkillGapExplanationPanel({
    required this.data,
    required this.isLoading,
    required this.error,
    required this.onExplain,
  });

  final Map<String, dynamic>? data;
  final bool isLoading;
  final String? error;
  final VoidCallback onExplain;

  @override
  Widget build(BuildContext context) {
    if (data == null) {
      return Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Penjelasan AI Skill Gap',
              style: TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
            if (error != null) ...[
              const SizedBox(height: 6),
              Text(error!, style: const TextStyle(color: AppColors.error)),
            ],
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: isLoading ? null : onExplain,
              icon: const Icon(Icons.auto_awesome_rounded),
              label: Text(
                isLoading ? 'Sedang memuat...' : 'Muat penjelasan AI',
              ),
            ),
          ],
        ),
      );
    }

    final skills = (data!['skills'] as List<dynamic>? ?? [])
        .map((value) => Map<String, dynamic>.from(value as Map))
        .toList();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: skills
            .map(
              (skill) => ExpansionTile(
                dense: true,
                title: Text(skill['skill']['name'] as String? ?? ''),
                subtitle: Text('Gap ${skill['gap'] ?? 0}'),
                childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(skill['explanation'] as String? ?? ''),
                  ),
                ],
              ),
            )
            .toList(),
      ),
    );
  }
}
