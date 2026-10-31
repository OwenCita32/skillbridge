import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/network/api_client.dart';
import '../../core/theme/app_theme.dart';
import '../assessment/assessment_screen.dart';
import '../mentor/ai_mentor_chat_screen.dart';
import '../quiz/quiz_intro_screen.dart';
import '../tracker/application_tracker_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({
    required this.apiClient,
    required this.user,
    required this.onOpenRoadmap,
    super.key,
  });

  final ApiClient apiClient;
  final Map<String, dynamic> user;
  final VoidCallback onOpenRoadmap;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Map<String, dynamic>? _gapData;
  Map<String, dynamic>? _roadmap;
  Map<String, dynamic>? _explanationData;
  bool _isLoading = true;
  bool _isGenerating = false;
  bool _isExplaining = false;
  String? _explanationError;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final gaps = await widget.apiClient.skillGaps();
      Map<String, dynamic>? roadmap;
      try {
        roadmap = await widget.apiClient.currentRoadmap();
      } on ApiException catch (error) {
        if (error.statusCode != 404) rethrow;
      }
      if (mounted) {
        setState(() {
          _gapData = gaps;
          _roadmap = roadmap;
          _isLoading = false;
        });
      }
    } on ApiException catch (error) {
      if (mounted) {
        setState(() {
          _error = error.message;
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _openAssessment() async {
    final careerGoal = widget.user['career_goal'] as Map?;
    final careerId = careerGoal?['career_id'];
    if (careerId is! int) return;

    final submitted = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) =>
            AssessmentScreen(apiClient: widget.apiClient, careerId: careerId),
      ),
    );
    if (submitted == true) await _load();
  }

  Future<void> _openQuiz([
    String skillName = 'UX Research',
    int currentScore = 45,
  ]) async {
    final result = await Navigator.of(context).push<int>(
      MaterialPageRoute(
        builder: (_) =>
            QuizIntroScreen(skillName: skillName, currentScore: currentScore),
      ),
    );
    if (result != null && mounted) {
      try {
        await widget.apiClient.submitQuizScore(
          scorePercentage: result,
          skillName: skillName,
        );
      } catch (_) {}
      await _load();
    }
  }

  Future<void> _generateRoadmap() async {
    setState(() => _isGenerating = true);
    try {
      await widget.apiClient.generateRoadmap();
      if (mounted) widget.onOpenRoadmap();
    } on ApiException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.message)));
      }
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  Future<void> _explainGaps([VoidCallback? onComplete]) async {
    setState(() {
      _isExplaining = true;
      _explanationError = null;
    });
    try {
      final explanation = await widget.apiClient.explainSkillGaps();
      if (mounted) setState(() => _explanationData = explanation);
    } on ApiException catch (error) {
      if (mounted) setState(() => _explanationError = error.message);
    } finally {
      if (mounted) {
        setState(() => _isExplaining = false);
        onComplete?.call();
      }
    }
  }

  void _showAiRecommendationsModal(
    BuildContext context,
    String careerTitle,
    List<dynamic> skills,
  ) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (modalContext, setModalState) {
            if (_explanationData == null &&
                !_isExplaining &&
                _explanationError == null) {
              _explainGaps(() {
                if (modalContext.mounted) {
                  setModalState(() {});
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
          final gap = (item['gap'] as num?)?.toInt() ?? 0;
          final pct = (item['percentage'] as num?)?.toInt() ?? 0;
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

  void _openAiMentorChat(String careerTitle) {
    final readiness = (_gapData?['readiness_score'] as num?)?.toInt() ?? 52;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AiMentorChatScreen(
        apiClient: widget.apiClient,
        careerTitle: careerTitle,
        readinessScore: readiness,
      ),
    );
  }

  void _showGapOriginModal(
    BuildContext context,
    bool hasAssessment,
    String careerTitle,
  ) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Dari mana angka ini?',
                  style: TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Persentase kesiapan dihitung secara deterministik oleh server dari perbandingan Self-Assessment kamu (skala 0–5) terhadap standar target kompetensi karier.',
                  style: TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 13.5,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.of(sheetContext).pop();
                          _openAssessment();
                        },
                        icon: const Icon(Icons.tune_rounded, size: 18),
                        label: Text(
                          hasAssessment
                              ? 'Perbarui Assessment'
                              : 'Isi Assessment',
                        ),
                      ),
                    ),
                    if (hasAssessment) ...[
                      const SizedBox(width: 10),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () {
                            Navigator.of(sheetContext).pop();
                            _openAiMentorChat(careerTitle);
                          },
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF0057FF),
                          ),
                          icon: const Icon(
                            Icons.auto_awesome_rounded,
                            size: 17,
                          ),
                          label: const Text('Tanya AI'),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(sheetContext).pop();
                      _openQuiz('UX Research', 45);
                    },
                    icon: const Icon(Icons.quiz_outlined, size: 18),
                    label: const Text('Kuis & Tes Skill (UX Research)'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const _DashboardLoading();
    }
    if (_error != null || _gapData == null) {
      return _DashboardError(
        message: _error ?? 'Belum dapat memuat ringkasan.',
        onRetry: _load,
      );
    }

    final career = Map<String, dynamic>.from(_gapData!['career'] as Map);
    final skills = (_gapData!['skills'] as List<dynamic>)
        .map((value) => Map<String, dynamic>.from(value as Map))
        .toList();
    final hasAssessment = _gapData!['assessment_id'] != null;

    final userName = (widget.user['name'] as String?)?.trim().isNotEmpty == true
        ? widget.user['name'] as String
        : 'Raka Pratama';
    final careerTitle = (career['title'] as String?)?.trim().isNotEmpty == true
        ? career['title'] as String
        : 'UI/UX Designer';

    final primaryAction = !hasAssessment
        ? _openAssessment
        : () => _showAiRecommendationsModal(context, careerTitle, skills);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: _load,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(22, 16, 22, 118),
            children: [
              // 1. Top Greeting Header + Notification Bell
              _TopGreetingHeader(userName: userName),
              const SizedBox(height: 20),

              // 2. White Target Karier Hero Card (Matching Screenshot 1)
              _TargetCareerHeroCard(
                careerTitle: careerTitle,
                onTap: _openAssessment,
              ),
              const SizedBox(height: 18),

              // 3. Royal Blue AI Skill Gap Analysis Card (Matching Screenshot 1)
              _AiSkillGapBlueCard(
                careerTitle: careerTitle,
                skills: skills,
                hasAssessment: hasAssessment,
                isGeneratingRoadmap: _isGenerating,
                onTapOriginInfo: () =>
                    _showGapOriginModal(context, hasAssessment, careerTitle),
                onTapPrimaryAction: primaryAction,
                onTapSkill: (name, score) => _openQuiz(name, score),
              ),

              // Optional AI Explanation Expandable Panel when requested
              if (_explanationData != null ||
                  _isExplaining ||
                  _explanationError != null) ...[
                const SizedBox(height: 16),
                _SkillGapExplanationPanel(
                  data: _explanationData,
                  isLoading: _isExplaining,
                  error: _explanationError,
                  onExplain: _explainGaps,
                ),
              ],

              const SizedBox(height: 18),

              // 4. White Tracker Lamaran Card (Matching Screenshot 1)
              _ApplicationTrackerCard(apiClient: widget.apiClient),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// 1. TOP GREETING HEADER
// ============================================================================
class _TopGreetingHeader extends StatelessWidget {
  const _TopGreetingHeader({required this.userName});

  final String userName;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Subtle soft avatar placeholder matching screenshot spacing
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFE0EAFF), Color(0xFFDBEAFE)],
            ),
            border: Border.all(color: Colors.white, width: 2),
          ),
          child: Center(
            child: Text(
              userName.characters.first.toUpperCase(),
              style: const TextStyle(
                color: Color(0xFF0057FF),
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Selamat pagi,',
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                userName,
                style: const TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 18.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
        ),
        // White Notification Button with Yellow Dot
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withValues(alpha: 0.06),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              const Icon(
                Icons.notifications_none_rounded,
                color: Color(0xFF1E293B),
                size: 22,
              ),
              Positioned(
                top: 10,
                right: 11,
                child: Container(
                  width: 7.5,
                  height: 7.5,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF59E0B),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.2),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

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

class _SkillBarRowData {
  const _SkillBarRowData({
    required this.name,
    required this.badgeLabel,
    required this.badgeBg,
    required this.badgeText,
    required this.barColor,
    required this.percentage,
  });

  final String name;
  final String badgeLabel;
  final Color badgeBg;
  final Color badgeText;
  final Color barColor;
  final int percentage;
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

class _WeeklyStreakBar extends StatelessWidget {
  const _WeeklyStreakBar();

  @override
  Widget build(BuildContext context) {
    const days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          // Flame icon + 12
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFFF59E0B).withValues(alpha: 0.24),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.local_fire_department_rounded,
              color: Color(0xFFFBBF24),
              size: 20,
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            '12',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const Spacer(),
          // 7 day pills
          Row(
            children: List.generate(days.length, (index) {
              final isDone = index < 4;
              final isToday = index == 4;
              return Padding(
                padding: EdgeInsets.only(left: index == 0 ? 0 : 6),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isDone)
                      Container(
                        width: 22,
                        height: 22,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFBBF24),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          color: Color(0xFF0F172A),
                          size: 13,
                        ),
                      )
                    else if (isToday)
                      Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFFFBBF24),
                            width: 2.2,
                          ),
                        ),
                        child: Center(
                          child: Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Color(0xFF0057FF),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      )
                    else
                      Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.20),
                          shape: BoxShape.circle,
                        ),
                      ),
                    const SizedBox(height: 4),
                    Text(
                      days[index],
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.78),
                        fontSize: 9.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// 4. WHITE TRACKER LAMARAN CARD
// ============================================================================
class _ApplicationTrackerCard extends StatelessWidget {
  const _ApplicationTrackerCard({this.apiClient});

  final ApiClient? apiClient;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ApplicationTrackerScreen(apiClient: apiClient),
          ),
        );
      },
      borderRadius: BorderRadius.circular(26),
      child: Container(
        padding: const EdgeInsets.all(20),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.work_outline_rounded,
                    color: Color(0xFF0057FF),
                    size: 21,
                  ),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tracker Lamaran',
                        style: TextStyle(
                          color: Color(0xFF0F172A),
                          fontSize: 15.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Kirim 5 proposal per hari supaya peluang dapat klien pertama makin besar.',
                        style: TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 12.5,
                          height: 1.45,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Color(0xFF94A3B8),
                  size: 14,
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Terkirim hari ini',
              style: TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '3',
                      style: TextStyle(
                        color: Color(0xFF0F172A),
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(width: 4),
                    Text(
                      '/ 5 proposal',
                      style: TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: const Text(
                    'Kurang 2 lagi',
                    style: TextStyle(
                      color: Color(0xFFD97706),
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
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

class _DashboardLoading extends StatelessWidget {
  const _DashboardLoading();

  @override
  Widget build(BuildContext context) => const Scaffold(
    backgroundColor: Color(0xFFF8FAFC),
    body: SafeArea(child: Center(child: CircularProgressIndicator())),
  );
}

class _DashboardError extends StatelessWidget {
  const _DashboardError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFF8FAFC),
    body: SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.large),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.cloud_off_rounded,
                color: AppColors.primary,
                size: 40,
              ),
              const SizedBox(height: AppSpacing.medium),
              Text(message, textAlign: TextAlign.center),
              const SizedBox(height: AppSpacing.medium),
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Muat ulang'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
