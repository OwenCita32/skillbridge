import 'package:flutter/material.dart';
import '../../core/network/api_client.dart';

part 'models/chat_message.dart';
part 'controllers/mentor_chat_controller.dart';
part 'widgets/mentor_chat_widgets.dart';

class AiMentorChatScreen extends StatefulWidget {
  const AiMentorChatScreen({
    super.key,
    required this.apiClient,
    required this.careerTitle,
    required this.readinessScore,
  });

  final ApiClient apiClient;
  final String careerTitle;
  final int readinessScore;

  @override
  State<AiMentorChatScreen> createState() => _AiMentorChatScreenState();
}

class _AiMentorChatScreenState extends State<AiMentorChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<_ChatMessage> _messages = [];

  bool _isSending = false;

  final List<String> _quickPrompts = [
    '🚀 Cara tercepat tutup gap skill?',
    '💰 Rekomendasi rate freelance pemula?',
    '📁 Tips portofolio yang disukai klien?',
    '💼 Cara menulis proposal freelance lolos?',
    '🛠️ Stack teknologi yang paling dicari?',
  ];

  @override
  void setState(VoidCallback fn) {
    super.setState(fn);
  }

  @override
  void initState() {
    super.initState();
    // Inisialisasi pesan sambutan personal dari AI Mentor
    _messages.add(
      _ChatMessage(
        role: 'assistant',
        content:
            'Halo! Saya **SkillBridge AI Mentor**.\n\nSaya memantau progres kariermu sebagai **${widget.careerTitle}** dengan kesiapan **${widget.readinessScore}%**.\n\nAda yang ingin kamu diskusikan seputar strategi menutup gap, portofolio, atau mencari klien freelance pertama?',
        time: DateTime.now(),
        source: 'SkillBridge Engine',
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.90,
      decoration: const BoxDecoration(
        color: Color(0xFFF8FAFC),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // 1. Grabber & Header
          _buildHeader(context),

          // 2. Context Summary Bar
          _buildContextRibbon(),

          // 3. Quick Chips
          _buildQuickChips(),

          // 4. Message List
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
              itemCount: _messages.length + (_isSending ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length) {
                  return _buildTypingIndicator();
                }
                return _buildMessageItem(_messages[index]);
              },
            ),
          ),

          // 5. Bottom Input Field
          _buildInputField(),
        ],
      ),
    );
  }
}
