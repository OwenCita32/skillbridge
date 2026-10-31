part of '../roadmap_screen.dart';

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
