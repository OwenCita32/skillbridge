import 'dart:async';
import 'package:flutter/material.dart';

part 'models/video_topic_item.dart';
part 'controllers/video_lesson_controller.dart';
part 'widgets/video_lesson_widgets.dart';

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
  void setState(VoidCallback fn) {
    super.setState(fn);
  }

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
            _buildTopAppBar(context),

            // Content
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 120),
                children: [
                  // Video Player Container (Dark Gradient Hero)
                  _buildVideoPlayerHero(progress),
                  const SizedBox(height: 20),

                  // White Card: Yang akan kamu pelajari
                  _buildTopicsCard(),
                ],
              ),
            ),
          ],
        ),
      ),

      // Bottom Sticky Button: Tandai Sudah Ditonton
      bottomNavigationBar: _buildBottomStickyButton(),
    );
  }
}
