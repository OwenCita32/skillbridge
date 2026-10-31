import 'package:flutter/material.dart';

import '../../core/network/api_client.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/info_callout.dart';
import '../../shared/widgets/primary_button.dart';

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
  void initState() {
    super.initState();
    _loadAssessment();
  }

  Future<void> _loadAssessment() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final career = await widget.apiClient.career(widget.careerId);
      final gaps = await widget.apiClient.skillGaps();
      final skills = gaps['skills'] as List<dynamic>? ?? [];
      for (final value in skills) {
        final skillGap = Map<String, dynamic>.from(value as Map);
        final skill = Map<String, dynamic>.from(skillGap['skill'] as Map);
        final currentLevel = skillGap['current_level'];
        if (currentLevel is int) {
          _answers[skill['id'] as int] = currentLevel;
        }
      }
      if (mounted) {
        setState(() {
          _career = career;
          _scale = career['assessment_scale'] as List<dynamic>? ?? [];
          _isLoading = false;
        });
      }
    } on ApiException catch (error) {
      if (mounted) {
        setState(() {
          _error = error.message;
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _submit() async {
    final skills = _career?['skills'] as List<dynamic>? ?? [];
    if (_answers.length != skills.length) {
      setState(
        () => _error = 'Pilih level untuk setiap skill sebelum menyimpan.',
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
      _error = null;
    });
    final answers = skills.map((value) {
      final skill = Map<String, dynamic>.from(value as Map);
      final id = skill['id'] as int;
      return {'skill_id': id, 'level': _answers[id]!};
    }).toList();

    try {
      await widget.apiClient.submitAssessment(answers);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Self-assessment tersimpan.')),
        );
        Navigator.of(context).pop(true);
      }
    } on ApiException catch (error) {
      if (mounted) setState(() => _error = error.message);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
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
                          message: 'Jawaban ini adalah estimasi diri, bukan sertifikasi profesional atau bukti kemampuan yang diverifikasi.',
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

class _ScaleGuide extends StatelessWidget {
  const _ScaleGuide({required this.scale});

  final List<dynamic> scale;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: ExpansionTile(
        title: const Text('Arti setiap level'),
        subtitle: Text('${scale.length} tingkat penilaian'),
        children: scale.map((value) {
          final level = Map<String, dynamic>.from(value as Map);
          return ListTile(
            dense: true,
            leading: CircleAvatar(
              radius: 15,
              backgroundColor: AppColors.primaryLight,
              child: Text(
                '${level['level']}',
                style: const TextStyle(
                  color: AppColors.primaryDark,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            title: Text(level['label'] as String? ?? ''),
            subtitle: Text(level['description'] as String? ?? ''),
            isThreeLine: true,
          );
        }).toList(),
      ),
    );
  }
}

class _SkillRatingCard extends StatelessWidget {
  const _SkillRatingCard({
    required this.skill,
    required this.scale,
    required this.selectedLevel,
    required this.onSelected,
  });

  final Map<String, dynamic> skill;
  final List<dynamic> scale;
  final int? selectedLevel;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final selected = selectedLevel == null
        ? null
        : Map<String, dynamic>.from(scale[selectedLevel!] as Map);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            skill['name'] as String? ?? '',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.xSmall),
          Text(
            skill['description'] as String? ?? '',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.medium),
          Wrap(
            spacing: AppSpacing.xSmall,
            runSpacing: AppSpacing.xSmall,
            children: scale.map((value) {
              final level = Map<String, dynamic>.from(value as Map);
              final number = level['level'] as int;
              final label = level['label'] as String? ?? '';
              final description = level['description'] as String? ?? '';
              return Tooltip(
                message: '$label. $description',
                child: ChoiceChip(
                  label: Text('$number'),
                  selected: selectedLevel == number,
                  onSelected: (_) => onSelected(number),
                  selectedColor: AppColors.primaryLight,
                  side: BorderSide(
                    color: selectedLevel == number
                        ? AppColors.primary
                        : AppColors.border,
                  ),
                  labelStyle: TextStyle(
                    color: selectedLevel == number
                        ? AppColors.primaryDark
                        : AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                  avatar: selectedLevel == number
                      ? const Icon(
                          Icons.check_rounded,
                          size: 16,
                          color: AppColors.primary,
                        )
                      : null,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: AppSpacing.small),
          if (selected == null)
            Text(
              'Pilih level untuk skill ini.',
              style: Theme.of(context).textTheme.bodySmall,
            )
          else ...[
            Text(
              '${selected['level']} · ${selected['label']}',
              style: Theme.of(context).textTheme.labelLarge
                  ?.copyWith(color: AppColors.primaryDark),
            ),
            const SizedBox(height: 3),
            Text(
              selected['description'] as String? ?? '',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ],
      ),
    );
  }
}

class _LoadError extends StatelessWidget {
  const _LoadError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.large),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.medium),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Coba lagi'),
            ),
          ],
        ),
      ),
    );
  }
}
