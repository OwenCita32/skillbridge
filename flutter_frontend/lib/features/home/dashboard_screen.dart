import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/network/api_client.dart';
import '../../core/theme/app_theme.dart';
import '../assessment/assessment_screen.dart';
import '../mentor/ai_mentor_chat_screen.dart';
import '../quiz/quiz_intro_screen.dart';
import '../tracker/application_tracker_screen.dart';

part 'models/skill_bar_row_data.dart';
part 'controllers/dashboard_controller.dart';
part 'screens/ai_recommendations_modal.dart';
part 'screens/notifications_sheet.dart';
part 'widgets/top_greeting_header.dart';
part 'widgets/target_career_hero_card.dart';
part 'widgets/ai_skill_gap_blue_card.dart';
part 'widgets/weekly_streak_and_tracker_cards.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({
    required this.apiClient,
    required this.user,
    required this.onOpenRoadmap,
    this.onOpenProfile,
    super.key,
  });

  final ApiClient apiClient;
  final Map<String, dynamic> user;
  final VoidCallback onOpenRoadmap;
  final VoidCallback? onOpenProfile;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Map<String, dynamic>? _gapData;
  Map<String, dynamic>? _roadmap;
  Map<String, dynamic>? _explanationData;
  Map<String, dynamic>? _freshUser;
  int _unreadNotifications = 0;
  bool _isLoading = true;
  bool _isGenerating = false;
  bool _isExplaining = false;
  String? _explanationError;
  String? _error;

  @override
  void initState() {
    super.initState();
    _freshUser = Map<String, dynamic>.from(widget.user);
    _load();
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

    final activeUser = _freshUser ?? widget.user;
    final userName = (activeUser['name'] as String?)?.trim().isNotEmpty == true
        ? activeUser['name'] as String
        : 'Raka Pratama';
    final avatarUrl = (activeUser['avatar_url'] as String?)?.trim();
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
              _TopGreetingHeader(
                userName: userName,
                avatarUrl: avatarUrl,
                unreadCount: _unreadNotifications,
                onTapNotification: _openNotificationsSheet,
              ),
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
