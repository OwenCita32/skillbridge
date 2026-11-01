import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/network/api_client.dart';
import '../../core/theme/app_theme.dart';
import 'article_lesson_screen.dart';
import 'practice_task_screen.dart';
import 'video_lesson_screen.dart';

part 'models/roadmap_stage_models.dart';
part 'controllers/roadmap_controller.dart';
part 'widgets/timeline_stage_row.dart';
part 'widgets/ai_learning_resources_sheet.dart';

class RoadmapScreen extends StatefulWidget {
  const RoadmapScreen({
    required this.apiClient,
    required this.onChanged,
    super.key,
  });

  final ApiClient apiClient;
  final VoidCallback onChanged;

  @override
  State<RoadmapScreen> createState() => _RoadmapScreenState();
}

class _RoadmapScreenState extends State<RoadmapScreen> {
  Map<String, dynamic>? _roadmap;
  bool _isLoading = true;
  bool _isGenerating = false;
  String? _error;
  bool _isEmpty = false;
  int _expandedIndex = 1;

  static const _brandBlue = Color(0xFF0057FF);

  static const List<_StagePreset> _defaultStages = [
    _StagePreset(
      stageLabel: 'Tahap 1 · 2 minggu',
      title: 'Dasar Desain Visual',
      badgeText: 'Selesai',
      state: _TimelineNodeState.completed,
      description:
          'Fondasi tipografi, warna, hierarki visual, dan komponen UI siap pakai untuk proyek klien.',
      sourceName: 'Figma Learn',
      sourceType: 'Artikel & Latihan',
      progressValue: 1.0,
    ),
    _StagePreset(
      stageLabel: 'Tahap 2 · 2 minggu',
      title: 'Prototyping Interaktif',
      badgeText: '3/5',
      state: _TimelineNodeState.active,
      description:
          'Skill gap terbesar kedua-mu. Klien ingin melihat alur yang bisa diklik.',
      sourceName: 'Figma Learn',
      sourceType: 'Video',
      progressValue: 0.6,
    ),
    _StagePreset(
      stageLabel: 'Tahap 3 · 3 minggu',
      title: 'UX Research Praktis',
      badgeText: 'Berikutnya',
      state: _TimelineNodeState.upcoming,
      description:
          'Metode riset cepat, usability testing, dan sintesis insight yang meyakinkan klien.',
      sourceName: 'Maze & NN/g',
      sourceType: 'Panduan Praktis',
      progressValue: 0.0,
    ),
    _StagePreset(
      stageLabel: 'Tahap 4 · 1 minggu',
      title: 'Portofolio & Pitching\nKlien',
      badgeText: 'Terkunci',
      state: _TimelineNodeState.locked,
      description:
          'Susun studi kasus berorientasi dampak bisnis dan template proposal untuk melamar proyek.',
      sourceName: 'SkillBridge Playbook',
      sourceType: 'Template',
      progressValue: 0.0,
    ),
  ];

  @override
  void setState(VoidCallback fn) {
    super.setState(fn);
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF6F8FC),
        body: SafeArea(child: Center(child: CircularProgressIndicator())),
      );
    }

    final backendItems = (_roadmap?['items'] as List<dynamic>? ?? [])
        .map((value) => Map<String, dynamic>.from(value as Map))
        .toList();
    final stages = _buildStages(backendItems);

    final completedCount = backendItems.isNotEmpty
        ? backendItems.where((item) => item['status'] == 'completed').length
        : 1;
    final overallProgress = backendItems.isNotEmpty
        ? (completedCount / backendItems.length).clamp(0.15, 1.0)
        : 0.40;
    final progressPercent = (overallProgress * 100).round();

    final rawCareerTitle = _roadmap?['career_title'] as String?;
    final displayTitle = (rawCareerTitle == null || rawCareerTitle.isEmpty)
        ? 'Menuju Freelance UI/UX'
        : (rawCareerTitle.toLowerCase().contains('menuju')
              ? rawCareerTitle
              : 'Menuju $rawCareerTitle');

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: _load,
          color: _brandBlue,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(22, 18, 22, 130),
            children: [
              // Eyebrow
              const Text(
                'ROADMAP PERSONAL',
                style: TextStyle(
                  color: _brandBlue,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                displayTitle,
                style: const TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.6,
                  height: 1.18,
                ),
              ),
              const SizedBox(height: 16),

              // Progress bar + '40% · 6 mgg lagi'
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(99),
                      child: LinearProgressIndicator(
                        value: overallProgress,
                        minHeight: 8,
                        backgroundColor: const Color(0xFFE2E8F0),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          _brandBlue,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Text(
                    '$progressPercent% · 6 mgg lagi',
                    style: const TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),

              if (_isEmpty && _roadmap == null) ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFBFDBFE)),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.auto_awesome_rounded,
                        color: _brandBlue,
                        size: 18,
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          'Sinkronkan roadmap personalmu dengan AI backend.',
                          style: TextStyle(
                            color: Color(0xFF1E3A8A),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: _isGenerating ? null : _generate,
                        child: Text(
                          _isGenerating ? 'Membuat...' : 'Sinkronkan',
                          style: const TextStyle(
                            color: _brandBlue,
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // Timeline items
              ...List.generate(stages.length, (index) {
                final stage = stages[index];
                final isExpanded = _expandedIndex == index;
                final isLast = index == stages.length - 1;
                return _TimelineStageRow(
                  stage: stage,
                  stepNumber: index + 1,
                  isExpanded: isExpanded,
                  isLast: isLast,
                  onToggle: () {
                    setState(() {
                      _expandedIndex = isExpanded ? -1 : index;
                    });
                  },
                  onContinueLearning: () => _handleContinueLearning(stage),
                  onUpdateStatus: stage.backendItem != null
                      ? (status) => _updateStatus(
                            stage.backendItem!['id'] as int,
                            status,
                          )
                      : null,
                  onOpenResource: _openResource,
                  onSearchAiResources: () => _searchAiLearningResources(
                    stage.title,
                    displayTitle,
                  ),
                );
              }),

              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(
                  _error!,
                  style: const TextStyle(
                    color: AppColors.error,
                    fontSize: 12.5,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
