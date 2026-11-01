part of '../roadmap_screen.dart';

extension _RoadmapScreenLogic on _RoadmapScreenState {
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

  void _searchAiLearningResources(String stageTitle, String careerTitle) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return _AiLearningResourcesSheet(
          apiClient: widget.apiClient,
          stageTitle: stageTitle,
          careerTitle: careerTitle,
        );
      },
    );
  }

  List<_StageViewModel> _buildStages(List<Map<String, dynamic>> backendItems) {
    const defaultStages = _RoadmapScreenState._defaultStages;
    if (backendItems.isEmpty) {
      return List.generate(
        defaultStages.length,
        (index) => _StageViewModel(
          index: index,
          stageLabel: defaultStages[index].stageLabel,
          title: defaultStages[index].title,
          badgeText: defaultStages[index].badgeText,
          state: defaultStages[index].state,
          description: defaultStages[index].description,
          sourceName: defaultStages[index].sourceName,
          sourceType: defaultStages[index].sourceType,
          progressValue: defaultStages[index].progressValue,
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
      final preset = defaultStages[index % defaultStages.length];
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

  void _handleContinueLearning(_StageViewModel stage) async {
    final titleLower = stage.title.toLowerCase();
    final typeLower = stage.sourceType.toLowerCase();

    final Widget targetScreen;
    if (typeLower.contains('video') ||
        titleLower.contains('prototyping') ||
        stage.index == 1) {
      targetScreen = VideoLessonScreen(
        title: 'Tonton: Figma Auto Layout',
        onCompleted: () {
          if (stage.backendItem != null) {
            _updateStatus(stage.backendItem!['id'] as int, 'completed');
          }
        },
      );
    } else if (typeLower.contains('praktik') ||
        titleLower.contains('portofolio') ||
        stage.index == 3) {
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
