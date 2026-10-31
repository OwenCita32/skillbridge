import 'package:flutter/material.dart';

import '../../core/network/api_client.dart';

part 'controllers/practice_task_controller.dart';
part 'widgets/practice_task_widgets.dart';

class PracticeTaskScreen extends StatefulWidget {
  const PracticeTaskScreen({
    this.title = 'Update case study portofolio',
    this.durationMinutes = 30,
    this.brief =
        'Perbarui case study "Travel App" dengan menambahkan bagian proses riset dan hasil usability test.',
    this.steps = const [
      'Tulis latar belakang masalah',
      'Tambahkan 2 insight riset',
      'Lampirkan before/after desain',
    ],
    this.apiClient,
    this.roadmapItemId,
    this.onCompleted,
    super.key,
  });

  final String title;
  final int durationMinutes;
  final String brief;
  final List<String> steps;
  final ApiClient? apiClient;
  final int? roadmapItemId;
  final VoidCallback? onCompleted;

  @override
  State<PracticeTaskScreen> createState() => _PracticeTaskScreenState();
}

class _PracticeTaskScreenState extends State<PracticeTaskScreen> {
  final _linkController = TextEditingController();
  late final List<bool> _stepChecked;

  @override
  void setState(VoidCallback fn) {
    super.setState(fn);
  }

  @override
  void initState() {
    super.initState();
    _stepChecked = List.filled(widget.steps.length, false);
  }

  @override
  void dispose() {
    _linkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canSubmit =
        _linkController.text.trim().isNotEmpty || _stepChecked.any((c) => c);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Top App Bar
            _buildTopAppBar(context),

            // Form Cards
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 120),
                children: [
                  // Card 1: Brief tugas
                  _buildBriefCard(),
                  const SizedBox(height: 18),

                  // Card 2: Langkah-langkah
                  _buildStepsCard(),
                  const SizedBox(height: 18),

                  // Card 3: Kumpulkan hasil
                  _buildSubmissionCard(),
                ],
              ),
            ),
          ],
        ),
      ),

      // Bottom Sticky Button: Kirim Hasil Praktik
      bottomNavigationBar: _buildBottomStickyButton(canSubmit),
    );
  }
}
