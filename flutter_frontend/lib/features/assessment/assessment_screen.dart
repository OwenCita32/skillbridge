import 'package:flutter/material.dart';

import '../../core/network/api_client.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/info_callout.dart';
import '../../shared/widgets/primary_button.dart';

part 'controllers/assessment_controller.dart';
part 'widgets/assessment_widgets.dart';

class AssessmentScreen extends StatefulWidget {
  const AssessmentScreen({
    required this.apiClient,
    required this.careerId,
    super.key,
  });

  final ApiClient apiClient;
  final int careerId;

  @override
  State<AssessmentScreen> createState() => _AssessmentScreenState();
}

class _AssessmentScreenState extends State<AssessmentScreen> {
  Map<String, dynamic>? _career;
  List<dynamic> _scale = [];
  final Map<int, int> _answers = {};
  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _error;

  @override
  void setState(VoidCallback fn) {
    super.setState(fn);
  }

  @override
  void initState() {
    super.initState();
    _loadAssessment();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('Self-assessment'),
      ),
      body: SafeArea(
        top: false,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null && _career == null
            ? _LoadError(message: _error!, onRetry: _loadAssessment)
            : Column(
                children: [
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.large,
                        AppSpacing.small,
                        AppSpacing.large,
                        AppSpacing.large,
                      ),
                      children: [
                        Text(
                          _career?['title'] as String? ?? 'Target karier',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: AppSpacing.xSmall),
                        Text(
                          'Nilai setiap kompetensi secara terpisah berdasarkan pengalamanmu saat ini.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: AppSpacing.medium),
                        const InfoCallout(
                          message:
                              'Jawaban ini adalah estimasi diri, bukan sertifikasi profesional atau bukti kemampuan yang diverifikasi.',
                        ),
                        const SizedBox(height: AppSpacing.medium),
                        _ScaleGuide(scale: _scale),
                        const SizedBox(height: AppSpacing.large),
                        ...(_career?['skills'] as List<dynamic>? ?? []).map((
                          value,
                        ) {
                          final skill = Map<String, dynamic>.from(value as Map);
                          final skillId = skill['id'] as int;
                          return Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppSpacing.medium,
                            ),
                            child: _SkillRatingCard(
                              skill: skill,
                              scale: _scale,
                              selectedLevel: _answers[skillId],
                              onSelected: (level) => setState(() {
                                _answers[skillId] = level;
                                _error = null;
                              }),
                            ),
                          );
                        }),
                        if (_error != null) ...[
                          const SizedBox(height: AppSpacing.xSmall),
                          Text(
                            _error!,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: AppColors.error),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.large,
                      AppSpacing.small,
                      AppSpacing.large,
                      AppSpacing.medium,
                    ),
                    child: PrimaryButton(
                      label: 'Simpan penilaian',
                      icon: Icons.check_rounded,
                      isLoading: _isSubmitting,
                      onPressed:
                          _answers.length ==
                              (_career?['skills'] as List<dynamic>? ?? [])
                                  .length
                          ? _submit
                          : null,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
