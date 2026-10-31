import 'package:flutter/material.dart';

part 'controllers/article_lesson_controller.dart';
part 'widgets/article_lesson_widgets.dart';

class ArticleLessonScreen extends StatelessWidget {
  const ArticleLessonScreen({
    this.title = 'Baca artikel pricing freelance',
    this.durationMinutes = 8,
    this.source = 'Freelance Academy',
    this.heading = 'Cara Menentukan Harga Jasa Desain Pertamamu',
    this.onCompleted,
    super.key,
  });

  final String title;
  final int durationMinutes;
  final String source;
  final String heading;
  final VoidCallback? onCompleted;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Top App Bar
            _buildTopAppBar(context),

            // Article Content Card
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 120),
                children: [
                  _buildArticleCard(),
                ],
              ),
            ),
          ],
        ),
      ),

      // Bottom Sticky Button: Selesai Membaca
      bottomNavigationBar: _buildBottomStickyButton(context),
    );
  }
}
