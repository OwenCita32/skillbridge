part of '../application_tracker_screen.dart';

class ApplicationItem {
  const ApplicationItem({
    required this.id,
    required this.title,
    required this.client,
    required this.budget,
    required this.platform,
    required this.badgeCode,
    required this.badgeColor,
    required this.date,
    required this.status,
  });

  final int id;
  final String title;
  final String client;
  final String budget;
  final String platform;
  final String badgeCode;
  final Color badgeColor;
  final String date;
  final String status;

  ApplicationItem copyWith({String? status}) {
    return ApplicationItem(
      id: id,
      title: title,
      client: client,
      budget: budget,
      platform: platform,
      badgeCode: badgeCode,
      badgeColor: badgeColor,
      date: date,
      status: status ?? this.status,
    );
  }
}
