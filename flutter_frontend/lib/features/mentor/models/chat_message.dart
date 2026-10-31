part of '../ai_mentor_chat_screen.dart';

class _ChatMessage {
  _ChatMessage({
    required this.role,
    required this.content,
    required this.time,
    this.source,
  });

  final String role; // 'user' or 'assistant'
  final String content;
  final DateTime time;
  final String? source;
}
