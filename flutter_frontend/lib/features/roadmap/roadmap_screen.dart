import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/network/api_client.dart';
import '../../core/theme/app_theme.dart';
import 'article_lesson_screen.dart';
import 'practice_task_screen.dart';
import 'video_lesson_screen.dart';

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
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _isEmpty = false;
    });
    try {
      final roadmap = await widget.apiClient.currentRoadmap();
      if (mounted) {
        final items = (roadmap['items'] as List<dynamic>? ?? [])
            .map((value) => Map<String, dynamic>.from(value as Map))
            .toList();
        final activeIdx = items.indexWhere(
          (item) => item['status'] != 'completed',
        );
        setState(() {
          _roadmap = roadmap;
          _isLoading = false;
          if (activeIdx >= 0) {
            _expandedIndex = activeIdx;
          }
        });
      }
    } on ApiException catch (error) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          if (error.statusCode == 404) {
            _isEmpty = true;
          } else {
            _error = error.message;
          }
        });
      }
    }
  }

  Future<void> _generate() async {
    setState(() {
      _isGenerating = true;
      _error = null;
    });
    try {
      final roadmap = await widget.apiClient.generateRoadmap();
      if (mounted) {
        setState(() {
          _roadmap = roadmap;
          _isEmpty = false;
        });
        widget.onChanged();
      }
    } on ApiException catch (error) {
      if (mounted) setState(() => _error = error.message);
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  Future<void> _updateStatus(int itemId, String status) async {
    try {
      await widget.apiClient.updateProgress(itemId: itemId, status: status);
      if (mounted && _roadmap != null) {
        final items = (_roadmap!['items'] as List<dynamic>)
            .map((item) => Map<String, dynamic>.from(item as Map))
            .toList();
        final index = items.indexWhere((item) => item['id'] == itemId);
        if (index >= 0) items[index]['status'] = status;
        setState(() => _roadmap = {..._roadmap!, 'items': items});
        widget.onChanged();
      }
    } on ApiException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.message)));
      }
    }
  }

  Future<void> _openResource(Map<String, dynamic> resource) async {
    final url = Uri.tryParse(resource['url'] as String? ?? '');
    if (url == null ||
        !url.hasScheme ||
        !await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Resource belum dapat dibuka. Coba lagi nanti.'),
          ),
        );
      }
    }
  }

  List<_StageViewModel> _buildStages(List<Map<String, dynamic>> backendItems) {
    if (backendItems.isEmpty) {
      return List.generate(
        _defaultStages.length,
        (index) => _StageViewModel(
          index: index,
          stageLabel: _defaultStages[index].stageLabel,
          title: _defaultStages[index].title,
          badgeText: _defaultStages[index].badgeText,
          state: _defaultStages[index].state,
          description: _defaultStages[index].description,
          sourceName: _defaultStages[index].sourceName,
          sourceType: _defaultStages[index].sourceType,
          progressValue: _defaultStages[index].progressValue,
          backendItem: null,
        ),
      );
    }

    int firstIncomplete = backendItems.indexWhere(
      (item) => item['status'] != 'completed',
    );
    if (firstIncomplete < 0) firstIncomplete = backendItems.length;

    return List.generate(backendItems.length, (index) {
      final item = backendItems[index];
      final status = item['status'] as String? ?? 'not_started';
      final preset = _defaultStages[index % _defaultStages.length];
      final resources = (item['resources'] as List<dynamic>? ?? [])
          .map((value) => Map<String, dynamic>.from(value as Map))
          .toList();
      final firstResource = resources.isNotEmpty ? resources.first : null;
      final hours = item['estimated_hours'] as int? ?? 6;
      final weeks = (hours / 4).ceil().clamp(1, 4);

      late final _TimelineNodeState nodeState;
      late final String badgeText;
      late final double progressValue;

      if (status == 'completed') {
        nodeState = _TimelineNodeState.completed;
        badgeText = 'Selesai';
        progressValue = 1.0;
      } else if (index == firstIncomplete || status == 'in_progress') {
        nodeState = _TimelineNodeState.active;
        badgeText = status == 'in_progress' ? '3/5' : 'Aktif';
        progressValue = status == 'in_progress' ? 0.6 : 0.35;
      } else if (index == firstIncomplete + 1) {
        nodeState = _TimelineNodeState.upcoming;
        badgeText = 'Berikutnya';
        progressValue = 0.0;
      } else {
        nodeState = _TimelineNodeState.locked;
        badgeText = 'Terkunci';
        progressValue = 0.0;
      }

      return _StageViewModel(
        index: index,
        stageLabel: 'Tahap ${index + 1} · $weeks minggu',
        title: item['title'] as String? ?? preset.title,
        badgeText: badgeText,
        state: nodeState,
        description: item['description'] as String? ?? preset.description,
        sourceName: firstResource?['source'] as String? ?? preset.sourceName,
        sourceType: firstResource?['type'] as String? ?? preset.sourceType,
        progressValue: progressValue,
        backendItem: item,
      );
    });
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

  void _handleContinueLearning(_StageViewModel stage) async {
    final titleLower = stage.title.toLowerCase();
    final typeLower = stage.sourceType.toLowerCase();

    final Widget targetScreen;
    if (typeLower.contains('video') || titleLower.contains('prototyping') || stage.index == 1) {
      targetScreen = VideoLessonScreen(
        title: 'Tonton: Figma Auto Layout',
        onCompleted: () {
          if (stage.backendItem != null) {
            _updateStatus(stage.backendItem!['id'] as int, 'completed');
          }
        },
      );
    } else if (typeLower.contains('praktik') || titleLower.contains('portofolio') || stage.index == 3) {
      targetScreen = PracticeTaskScreen(
        title: 'Update case study portofolio',
        apiClient: widget.apiClient,
        roadmapItemId: stage.backendItem?['id'] as int?,
        onCompleted: () {
          if (stage.backendItem != null) {
            _updateStatus(stage.backendItem!['id'] as int, 'completed');
          }
        },
      );
    } else {
      targetScreen = ArticleLessonScreen(
        title: 'Baca artikel pricing freelance',
        onCompleted: () {
          if (stage.backendItem != null) {
            _updateStatus(stage.backendItem!['id'] as int, 'completed');
          }
        },
      );
    }

    final completed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => targetScreen),
    );
    if (completed == true && mounted) {
      widget.onChanged();
    }
  }
}

enum _TimelineNodeState { completed, active, upcoming, locked }

class _StagePreset {
  const _StagePreset({
    required this.stageLabel,
    required this.title,
    required this.badgeText,
    required this.state,
    required this.description,
    required this.sourceName,
    required this.sourceType,
    required this.progressValue,
  });

  final String stageLabel;
  final String title;
  final String badgeText;
  final _TimelineNodeState state;
  final String description;
  final String sourceName;
  final String sourceType;
  final double progressValue;
}

class _StageViewModel {
  const _StageViewModel({
    required this.index,
    required this.stageLabel,
    required this.title,
    required this.badgeText,
    required this.state,
    required this.description,
    required this.sourceName,
    required this.sourceType,
    required this.progressValue,
    required this.backendItem,
  });

  final int index;
  final String stageLabel;
  final String title;
  final String badgeText;
  final _TimelineNodeState state;
  final String description;
  final String sourceName;
  final String sourceType;
  final double progressValue;
  final Map<String, dynamic>? backendItem;
}

class _TimelineStageRow extends StatelessWidget {
  const _TimelineStageRow({
    required this.stage,
    required this.stepNumber,
    required this.isExpanded,
    required this.isLast,
    required this.onToggle,
    required this.onContinueLearning,
    required this.onUpdateStatus,
    required this.onOpenResource,
  });

  final _StageViewModel stage;
  final int stepNumber;
  final bool isExpanded;
  final bool isLast;
  final VoidCallback onToggle;
  final VoidCallback onContinueLearning;
  final ValueChanged<String>? onUpdateStatus;
  final ValueChanged<Map<String, dynamic>> onOpenResource;

  static const _brandBlue = Color(0xFF0057FF);

  @override
  Widget build(BuildContext context) {
    final isActiveCard = stage.state == _TimelineNodeState.active || isExpanded;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Left timeline column
          SizedBox(
            width: 44,
            child: Column(
              children: [
                const SizedBox(height: 18),
                _buildNodeIndicator(),
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    color: const Color(0xFFE2E8F0),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          // Right stage card
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 6 : 16),
              child: GestureDetector(
                onTap: onToggle,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  padding: const EdgeInsets.fromLTRB(18, 16, 16, 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: isActiveCard
                          ? const Color(0xFF93C5FD)
                          : const Color(0xFFF1F5F9),
                      width: isActiveCard ? 1.8 : 1.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isActiveCard
                            ? _brandBlue.withValues(alpha: 0.08)
                            : const Color(0xFF0F172A).withValues(alpha: 0.03),
                        blurRadius: isActiveCard ? 24 : 14,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  stage.stageLabel,
                                  style: const TextStyle(
                                    color: Color(0xFF94A3B8),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  stage.title,
                                  style: TextStyle(
                                    color: stage.state ==
                                            _TimelineNodeState.locked
                                        ? const Color(0xFF64748B)
                                        : const Color(0xFF0F172A),
                                    fontSize: 16.5,
                                    fontWeight: FontWeight.w800,
                                    height: 1.25,
                                    letterSpacing: -0.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          _buildStatusPill(stage),
                          const SizedBox(width: 8),
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Icon(
                              isExpanded
                                  ? Icons.keyboard_arrow_up_rounded
                                  : Icons.keyboard_arrow_down_rounded,
                              color: const Color(0xFF64748B),
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                      if (isExpanded) ...[
                        const SizedBox(height: 14),
                        Text(
                          stage.description,
                          style: const TextStyle(
                            color: Color(0xFF475569),
                            fontSize: 13.5,
                            height: 1.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 14),
                        RichText(
                          text: TextSpan(
                            style: const TextStyle(
                              fontSize: 12.5,
                              color: Color(0xFF94A3B8),
                              fontWeight: FontWeight.w500,
                            ),
                            children: [
                              const TextSpan(text: 'Sumber: '),
                              TextSpan(
                                text: stage.sourceName,
                                style: const TextStyle(
                                  color: Color(0xFF334155),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              TextSpan(text: ' · ${stage.sourceType}'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(99),
                          child: LinearProgressIndicator(
                            value: stage.progressValue > 0
                                ? stage.progressValue
                                : 0.6,
                            minHeight: 6,
                            backgroundColor: const Color(0xFFF1F5F9),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              _brandBlue,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: onContinueLearning,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _brandBlue,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.play_arrow_outlined, size: 20),
                                SizedBox(width: 6),
                                Text(
                                  'Lanjut Belajar',
                                  style: TextStyle(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            _buildQuickChip(
                              context: context,
                              label: 'Video',
                              icon: Icons.play_circle_outline_rounded,
                              color: const Color(0xFF0057FF),
                              bgColor: const Color(0xFFEFF6FF),
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const VideoLessonScreen(),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            _buildQuickChip(
                              context: context,
                              label: 'Praktik',
                              icon: Icons.assignment_outlined,
                              color: const Color(0xFF059669),
                              bgColor: const Color(0xFFECFDF5),
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const PracticeTaskScreen(),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            _buildQuickChip(
                              context: context,
                              label: 'Bacaan',
                              icon: Icons.menu_book_rounded,
                              color: const Color(0xFFD97706),
                              bgColor: const Color(0xFFFEF3C7),
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const ArticleLessonScreen(),
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (stage.backendItem != null &&
                            onUpdateStatus != null) ...[
                          const SizedBox(height: 12),
                          _BackendStageControls(
                            item: stage.backendItem!,
                            onStatusChanged: onUpdateStatus!,
                            onOpenResource: onOpenResource,
                          ),
                        ],
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNodeIndicator() {
    switch (stage.state) {
      case _TimelineNodeState.completed:
        return Container(
          width: 34,
          height: 34,
          decoration: const BoxDecoration(
            color: _brandBlue,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_rounded,
            color: Colors.white,
            size: 18,
          ),
        );
      case _TimelineNodeState.active:
        return Container(
          width: 42,
          height: 42,
          padding: const EdgeInsets.all(4),
          decoration: const BoxDecoration(
            color: Color(0xFFDBEAFE),
            shape: BoxShape.circle,
          ),
          child: Container(
            decoration: const BoxDecoration(
              color: _brandBlue,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              '$stepNumber',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        );
      case _TimelineNodeState.upcoming:
        return Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFFCBD5E1),
              width: 1.6,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            '$stepNumber',
            style: const TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        );
      case _TimelineNodeState.locked:
        return Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFFE2E8F0),
              width: 1.6,
            ),
          ),
          child: const Icon(
            Icons.lock_outline_rounded,
            color: Color(0xFF94A3B8),
            size: 16,
          ),
        );
    }
  }

  Widget _buildStatusPill(_StageViewModel stage) {
    late final Color bgColor;
    late final Color textColor;

    switch (stage.state) {
      case _TimelineNodeState.completed:
        bgColor = const Color(0xFFDCFCE7);
        textColor = const Color(0xFF16A34A);
      case _TimelineNodeState.active:
        bgColor = const Color(0xFFEFF6FF);
        textColor = _brandBlue;
      case _TimelineNodeState.upcoming:
      case _TimelineNodeState.locked:
        bgColor = const Color(0xFFF1F5F9);
        textColor = const Color(0xFF64748B);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        stage.badgeText,
        style: TextStyle(
          color: textColor,
          fontSize: 11.5,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _buildQuickChip({
    required BuildContext context,
    required String label,
    required IconData icon,
    required Color color,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BackendStageControls extends StatelessWidget {
  const _BackendStageControls({
    required this.item,
    required this.onStatusChanged,
    required this.onOpenResource,
  });

  final Map<String, dynamic> item;
  final ValueChanged<String> onStatusChanged;
  final ValueChanged<Map<String, dynamic>> onOpenResource;

  static const _statuses = <String, String>{
    'not_started': 'Belum dimulai',
    'in_progress': 'Sedang dipelajari',
    'completed': 'Selesai',
    'skipped': 'Dilewati',
  };

  @override
  Widget build(BuildContext context) {
    final status = item['status'] as String? ?? 'not_started';
    final resources = (item['resources'] as List<dynamic>? ?? [])
        .map((value) => Map<String, dynamic>.from(value as Map))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (resources.isNotEmpty) ...[
          const Divider(height: 18, color: Color(0xFFF1F5F9)),
          ...resources.map(
            (resource) => InkWell(
              onTap: () => onOpenResource(resource),
              borderRadius: BorderRadius.circular(10),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    const Icon(
                      Icons.open_in_new_rounded,
                      size: 16,
                      color: Color(0xFF0057FF),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        resource['title'] as String? ?? 'Buka materi',
                        style: const TextStyle(
                          color: Color(0xFF0F172A),
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
        const SizedBox(height: 6),
        Row(
          children: [
            const Text(
              'Status:',
              style: TextStyle(
                color: Color(0xFF64748B),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _statuses.containsKey(status) ? status : 'not_started',
                  isDense: true,
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                  ),
                  items: _statuses.entries
                      .map(
                        (entry) => DropdownMenuItem<String>(
                          value: entry.key,
                          child: Text(entry.value),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null && value != status) {
                      onStatusChanged(value);
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
