part of '../ai_mentor_chat_screen.dart';

extension _MentorChatLogic on _AiMentorChatScreenState {
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage(String text) async {
    final clean = text.trim();
    if (clean.isEmpty || _isSending) return;

    _textController.clear();

    setState(() {
      _messages.add(
        _ChatMessage(
          role: 'user',
          content: clean,
          time: DateTime.now(),
        ),
      );
      _isSending = true;
    });
    _scrollToBottom();

    try {
      final history = _messages
          .take(_messages.length - 1)
          .map((m) => {'role': m.role, 'content': m.content})
          .toList();

      final res = await widget.apiClient.askAiMentor(
        message: clean,
        history: history,
      );

      final reply = res['reply'] as String? ?? 'Maaf, belum dapat menjawab.';
      final source = res['source'] as String?;

      if (mounted) {
        setState(() {
          _messages.add(
            _ChatMessage(
              role: 'assistant',
              content: reply,
              time: DateTime.now(),
              source: source,
            ),
          );
        });
        _scrollToBottom();
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _messages.add(
            _ChatMessage(
              role: 'assistant',
              content:
                  'Terjadi kendala jaringan: ${e.message}. Coba tanyakan kembali ya!',
              time: DateTime.now(),
            ),
          );
        });
        _scrollToBottom();
      }
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }
}
