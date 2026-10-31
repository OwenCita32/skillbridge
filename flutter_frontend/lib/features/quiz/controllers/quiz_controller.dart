part of '../quiz_screen.dart';

extension _QuizLogic on _QuizScreenState {
  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        timer.cancel();
        _showResultDialog();
      }
    });
  }

  String _formatTimer(int totalSeconds) {
    final m = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  void _onOptionSelected(int index) {
    setState(() => _selectedAnswerIndex = index);
  }

  void _next() {
    if (_selectedAnswerIndex == null) return;

    const questions = _QuizScreenState._questions;
    if (_selectedAnswerIndex == questions[_currentIndex].correctIndex) {
      _correctCount++;
    }

    if (_currentIndex < questions.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedAnswerIndex = null;
      });
    } else {
      _timer?.cancel();
      _showResultDialog();
    }
  }
}
