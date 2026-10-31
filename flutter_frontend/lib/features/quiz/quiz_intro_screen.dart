import 'package:flutter/material.dart';

import 'quiz_screen.dart';

part 'widgets/quiz_intro_widgets.dart';

class QuizIntroScreen extends StatelessWidget {
  const QuizIntroScreen({
    this.skillName = 'UX Research',
    this.currentScore = 45,
    this.onScoreUpdated,
    super.key,
  });

  final String skillName;
  final int currentScore;
  final ValueChanged<int>? onScoreUpdated;

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

            // Content
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
                children: [
                  // Hero Gradient Banner
                  _buildHeroBanner(),
                  const SizedBox(height: 18),

                  // 3 Stats Cards
                  _buildStatsRow(),
                  const SizedBox(height: 18),

                  // Skor Saat Ini Card
                  _buildCurrentScoreCard(),
                ],
              ),
            ),
          ],
        ),
      ),

      // Bottom Action Button: Mulai Kuis
      bottomNavigationBar: _buildBottomActionButton(context),
    );
  }
}
