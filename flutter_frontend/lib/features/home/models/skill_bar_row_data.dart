part of '../dashboard_screen.dart';

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
