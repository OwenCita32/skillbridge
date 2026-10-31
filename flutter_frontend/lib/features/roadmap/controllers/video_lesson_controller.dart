part of '../video_lesson_screen.dart';

extension _VideoLessonScreenLogic on _VideoLessonScreenState {
  void _togglePlay() {
    setState(() {
      _isPlaying = !_isPlaying;
      if (_isPlaying) {
        _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
          if (_currentSeconds < _totalSeconds) {
            setState(() => _currentSeconds++);
          } else {
            timer.cancel();
            setState(() => _isPlaying = false);
          }
        });
      } else {
        _timer?.cancel();
      }
    });
  }

  String _formatTime(int totalSecs) {
    final m = (totalSecs ~/ 60).toString().padLeft(2, '0');
    final s = (totalSecs % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  void _markCompleted() {
    widget.onCompleted?.call();
    Navigator.of(context).pop(true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Video berhasil ditandai selesai! Progress bertambah.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
