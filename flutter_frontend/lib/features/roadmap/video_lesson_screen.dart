import 'dart:async';
import 'package:flutter/material.dart';

class VideoLessonScreen extends StatefulWidget {
  const VideoLessonScreen({
    this.title = 'Tonton: Figma Auto Layout',
    this.durationMinutes = 15,
    this.onCompleted,
    super.key,
  });

  final String title;
  final int durationMinutes;
  final VoidCallback? onCompleted;

  @override
  State<VideoLessonScreen> createState() => _VideoLessonScreenState();
}

class _VideoLessonScreenState extends State<VideoLessonScreen> {
  bool _isPlaying = false;
  int _currentSeconds = 0;
  Timer? _timer;
  late final int _totalSeconds;

  static const _topics = [
    _TopicItem(time: '00:00', title: 'Konsep frame & auto layout'),
    _TopicItem(time: '05:00', title: 'Padding, gap, dan resizing'),
    _TopicItem(time: '10:00', title: 'Membuat tombol & card responsif'),
  ];

  @override
  void initState() {
    super.initState();
    _totalSeconds = widget.durationMinutes * 60;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

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

  @override
  Widget build(BuildContext context) {
    final progress = _totalSeconds > 0 ? (_currentSeconds / _totalSeconds) : 0.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Top App Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_rounded, size: 20),
                      color: const Color(0xFF0F172A),
                      padding: EdgeInsets.zero,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Video · ${widget.durationMinutes} menit',
                          style: const TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          widget.title,
                          style: const TextStyle(
                            color: Color(0xFF0F172A),
                            fontSize: 16.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: const Text(
                      'Video',
                      style: TextStyle(
                        color: Color(0xFF0057FF),
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 120),
                children: [
                  // Video Player Container (Dark Gradient Hero)
                  Container(
                    height: 220,
                    decoration: BoxDecoration(
                      gradient: const RadialGradient(
                        center: Alignment(0.2, -0.1),
                        radius: 1.1,
                        colors: [
                          Color(0xFF2A3D78),
                          Color(0xFF1E284A),
                          Color(0xFF0D1424),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0F172A).withValues(alpha: 0.14),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Center Circular Play / Pause Button
                        InkWell(
                          onTap: _togglePlay,
                          borderRadius: BorderRadius.circular(99),
                          child: Container(
                            width: 62,
                            height: 62,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.25),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Icon(
                              _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                              color: const Color(0xFF0057FF),
                              size: 34,
                            ),
                          ),
                        ),

                        // Bottom Player Controls (Timeline bar & timestamps)
                        Positioned(
                          left: 18,
                          right: 18,
                          bottom: 14,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    _formatTime(_currentSeconds),
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.90),
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(99),
                                      child: LinearProgressIndicator(
                                        value: progress.clamp(0.0, 1.0),
                                        minHeight: 5,
                                        backgroundColor: Colors.white.withValues(alpha: 0.25),
                                        valueColor: const AlwaysStoppedAnimation<Color>(
                                          Color(0xFF60A5FA),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    _formatTime(_totalSeconds),
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.90),
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // White Card: Yang akan kamu pelajari
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0F172A).withValues(alpha: 0.03),
                          blurRadius: 18,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Yang akan kamu pelajari',
                          style: TextStyle(
                            color: Color(0xFF0F172A),
                            fontSize: 15.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 16),
                        for (int i = 0; i < _topics.length; i++) ...[
                          Row(
                            children: [
                              SizedBox(
                                width: 52,
                                child: Text(
                                  _topics[i].time,
                                  style: const TextStyle(
                                    color: Color(0xFF94A3B8),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  _topics[i].title,
                                  style: const TextStyle(
                                    color: Color(0xFF334155),
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (i < _topics.length - 1) const SizedBox(height: 14),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      // Bottom Sticky Button: Tandai Sudah Ditonton
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withValues(alpha: 0.05),
              blurRadius: 16,
              offset: const Offset(0, -6),
            ),
          ],
        ),
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _markCompleted,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0057FF),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text(
              'Tandai Sudah Ditonton',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TopicItem {
  const _TopicItem({required this.time, required this.title});

  final String time;
  final String title;
}

