// ignore_for_file: invalid_use_of_protected_member
part of '../dashboard_screen.dart';

extension _DashboardScreenLogic on _DashboardScreenState {
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
      Map<String, dynamic>? latestUser;
      try {
        latestUser = await widget.apiClient.me();
      } catch (_) {}

      int unread = 0;
      try {
        final notifRes = await widget.apiClient.getNotifications();
        unread = (notifRes['unread_count'] as num?)?.toInt() ?? 0;
      } catch (_) {}

      if (mounted) {
        setState(() {
          _gapData = gaps;
          _roadmap = roadmap;
          if (latestUser != null) {
            _freshUser = latestUser;
          }
          _unreadNotifications = unread;
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

  void _openNotificationsSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => _NotificationsSheet(
        apiClient: widget.apiClient,
        onUnreadCountChanged: (count) {
          if (mounted) {
            setState(() => _unreadNotifications = count);
          }
        },
        onActionTriggered: (actionType, payload) {
          Navigator.of(sheetContext).pop();
          if (actionType == 'roadmap') {
            widget.onOpenRoadmap();
          } else if (actionType == 'quiz') {
            _openQuiz();
          } else if (actionType == 'tracker') {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) =>
                    ApplicationTrackerScreen(apiClient: widget.apiClient),
              ),
            );
          } else if (actionType == 'certificates' || actionType == 'profile') {
            widget.onOpenProfile?.call();
          }
        },
      ),
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
}
