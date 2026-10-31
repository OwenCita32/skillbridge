import 'package:flutter/material.dart';

import '../../core/network/api_client.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/info_callout.dart';
import '../../shared/widgets/primary_button.dart';
import '../assessment/assessment_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({
    required this.apiClient,
    required this.user,
    required this.onOpenRoadmap,
    super.key,
  });

  final ApiClient apiClient;
  final Map<String, dynamic> user;
  final VoidCallback onOpenRoadmap;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Map<String, dynamic>? _gapData;
  Map<String, dynamic>? _roadmap;
  Map<String, dynamic>? _explanationData;
  bool _isLoading = true;
  bool _isGenerating = false;
  bool _isExplaining = false;
  String? _explanationError;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final gaps = await widget.apiClient.skillGaps();
      Map<String, dynamic>? roadmap;
      try {
        roadmap = await widget.apiClient.currentRoadmap();
      } on ApiException catch (error) {
        if (error.statusCode != 404) rethrow;
      }
      if (mounted) {
        setState(() {
          _gapData = gaps;
          _roadmap = roadmap;
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

  Future<void> _openAssessment() async {
    final careerGoal = widget.user['career_goal'] as Map?;
    final careerId = careerGoal?['career_id'];
    if (careerId is! int) return;

    final submitted = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) =>
            AssessmentScreen(apiClient: widget.apiClient, careerId: careerId),
      ),
    );
    if (submitted == true) await _load();
  }

  Future<void> _generateRoadmap() async {
    setState(() => _isGenerating = true);
    try {
      await widget.apiClient.generateRoadmap();
      if (mounted) widget.onOpenRoadmap();
    } on ApiException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.message)));
      }
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  Future<void> _explainGaps() async {
    setState(() {
      _isExplaining = true;
      _explanationError = null;
    });
    try {
      final explanation = await widget.apiClient.explainSkillGaps();
      if (mounted) setState(() => _explanationData = explanation);
    } on ApiException catch (error) {
      if (mounted) setState(() => _explanationError = error.message);
    } finally {
      if (mounted) setState(() => _isExplaining = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const _DashboardLoading();
    }
    if (_error != null || _gapData == null) {
      return _DashboardError(
        message: _error ?? 'Belum dapat memuat ringkasan.',
        onRetry: _load,
      );
    }

    final career = Map<String, dynamic>.from(_gapData!['career'] as Map);
    final skills = (_gapData!['skills'] as List<dynamic>)
        .map((value) => Map<String, dynamic>.from(value as Map))
        .toList();
    final focusSkills = skills
        .where((skill) => skill['priority'] == 'focus')
        .toList();
    final unassessedCount = skills
        .where((skill) => skill['is_assessed'] != true)
        .length;
    final hasAssessment = _gapData!['assessment_id'] != null;

    final actionLabel = !hasAssessment
        ? 'Mulai self-assessment'
        : _roadmap == null
        ? 'Buat roadmap belajar'
        : 'Lihat roadmap';
    final action = !hasAssessment
        ? _openAssessment
        : _roadmap == null
        ? _generateRoadmap
        : widget.onOpenRoadmap;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _load,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.large,
              AppSpacing.medium,
              AppSpacing.large,
              AppSpacing.xxLarge,
            ),
            children: [
              Text(
                'Halo, ${widget.user['name'] ?? 'teman'}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.xSmall),
              Text(
                'Langkah kariermu berikutnya',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: AppSpacing.large),
              _CareerCard(career: career, skillCount: skills.length),
              const SizedBox(height: AppSpacing.medium),
              Row(
                children: [
                  Expanded(
                    child: _MetricCard(
                      label: 'Skill ditinjau',
                      value: hasAssessment
                          ? '${skills.length}'
                          : '0/${skills.length}',
                      icon: Icons.track_changes_rounded,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.small),
                  Expanded(
                    child: _MetricCard(
                      label: 'Perlu latihan',
                      value: hasAssessment ? '${focusSkills.length}' : '—',
                      icon: Icons.trending_up_rounded,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.medium),
              const InfoCallout(
                message: 'Self-assessment membantu memperkirakan skill gap. Hasilnya bukan sertifikasi atau bukti kompetensi terverifikasi.',
              ),
              const SizedBox(height: AppSpacing.large),
              PrimaryButton(
                label: actionLabel,
                onPressed: action,
                isLoading: _isGenerating,
                icon: Icons.arrow_forward_rounded,
              ),
              if (hasAssessment) ...[
                const SizedBox(height: AppSpacing.medium),
                _SkillGapExplanationPanel(
                  data: _explanationData,
                  isLoading: _isExplaining,
                  error: _explanationError,
                  onExplain: _explainGaps,
                ),
              ],
              const SizedBox(height: AppSpacing.xLarge),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Skill untuk diperhatikan',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  if (unassessedCount > 0)
                    Text(
                      '$unassessedCount belum dinilai',
                      style: Theme.of(context).textTheme.labelSmall
                          ?.copyWith(color: AppColors.textSecondary),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.medium),
              ...skills
                  .take(4)
                  .map(
                    (skill) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.small),
                      child: _SkillSummaryCard(skill: skill),
                    ),
                  ),
              if (skills.isEmpty)
                const AppCard(child: Text('Belum ada skill untuk karier ini.')),
            ],
          ),
        ),
      ),
    );
  }
}

class _SkillGapExplanationPanel extends StatelessWidget {
  const _SkillGapExplanationPanel({
    required this.data,
    required this.isLoading,
    required this.error,
    required this.onExplain,
  });

  final Map<String, dynamic>? data;
  final bool isLoading;
  final String? error;
  final VoidCallback onExplain;

  @override
  Widget build(BuildContext context) {
    if (data == null) {
      return AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Penjelasan skill gap', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppSpacing.xSmall),
            Text(
              'Minta GPT-6 Luna menjelaskan prioritas belajar dari nilai yang dihitung backend. Nama dan email akun tidak dikirim ke OpenAI.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (error != null) ...[
              const SizedBox(height: AppSpacing.xSmall),
              Text(error!, style: const TextStyle(color: AppColors.error)),
            ],
            const SizedBox(height: AppSpacing.small),
            TextButton.icon(
              onPressed: isLoading ? null : onExplain,
              icon: isLoading
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.auto_awesome_rounded),
              label: Text(isLoading ? 'Sedang menjelaskan' : 'Jelaskan skill gap'),
            ),
          ],
        ),
      );
    }

    final source = data!['explanation_source'] as String? ?? 'deterministic_fallback';
    final skills = (data!['skills'] as List<dynamic>? ?? [])
        .map((value) => Map<String, dynamic>.from(value as Map))
        .toList();

    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.medium,
              AppSpacing.medium,
              AppSpacing.medium,
              AppSpacing.small,
            ),
            child: Row(
              children: [
                const Icon(Icons.auto_awesome_rounded, color: AppColors.primary),
                const SizedBox(width: AppSpacing.small),
                Expanded(
                  child: Text(
                    source == 'openai_responses'
                        ? 'Penjelasan GPT-6 Luna'
                        : 'Penjelasan deterministik',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                IconButton(
                  tooltip: 'Muat ulang penjelasan',
                  onPressed: isLoading ? null : onExplain,
                  icon: isLoading
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.refresh_rounded),
                ),
              ],
            ),
          ),
          if (source == 'openai_responses')
            const Padding(
              padding: EdgeInsets.fromLTRB(AppSpacing.medium, 0, AppSpacing.medium, AppSpacing.small),
              child: Text(
                'Penjelasan bersifat saran. Angka gap tetap dihitung oleh backend.',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
            ),
          ...skills.map((skill) => ExpansionTile(
                dense: true,
                title: Text(skill['skill']['name'] as String? ?? ''),
                subtitle: Text(skill['current_level'] == null
                    ? 'Belum dinilai'
                    : 'Gap ${skill['gap'] ?? 'belum dihitung'}'),
                childrenPadding: const EdgeInsets.fromLTRB(
                  AppSpacing.medium,
                  0,
                  AppSpacing.medium,
                  AppSpacing.medium,
                ),
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(skill['explanation'] as String? ?? ''),
                  ),
                  const SizedBox(height: AppSpacing.xSmall),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      skill['suggested_next_action'] as String? ?? '',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.primaryDark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              )),
        ],
      ),
    );
  }
}

class _CareerCard extends StatelessWidget {
  const _CareerCard({required this.career, required this.skillCount});

  final Map<String, dynamic> career;
  final int skillCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.large),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(AppRadius.standard),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.work_outline_rounded, color: Colors.white, size: 24),
          const SizedBox(height: AppSpacing.medium),
          Text(
            'TARGET KARIER',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.82),
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: AppSpacing.xSmall),
          Text(
            career['title'] as String? ?? '',
            style: Theme.of(context).textTheme.titleLarge
                ?.copyWith(color: Colors.white, fontSize: 22),
          ),
          const SizedBox(height: AppSpacing.xSmall),
          Text(
            '$skillCount kompetensi dalam profil karier ini',
            style: Theme.of(context).textTheme.bodyMedium
                ?.copyWith(color: Colors.white.withValues(alpha: 0.88)),
          ),
          if (career['is_demo'] == true) ...[
            const SizedBox(height: AppSpacing.medium),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Text(
                'Profil demo · target level dapat ditinjau',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(height: AppSpacing.small),
          Text(value, style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 2),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _SkillSummaryCard extends StatelessWidget {
  const _SkillSummaryCard({required this.skill});

  final Map<String, dynamic> skill;

  @override
  Widget build(BuildContext context) {
    final current = skill['current_level'];
    final target = skill['target_level'];
    final state = skill['priority'] as String? ?? 'unassessed';
    final statusLabel = switch (state) {
      'focus' => 'Gap ${skill['gap']}',
      'on_track' => 'Sesuai target',
      _ => 'Belum dinilai',
    };
    final statusColor = state == 'on_track'
        ? AppColors.success
        : AppColors.primary;

    return AppCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.medium,
        vertical: 14,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  skill['skill']['name'] as String? ?? '',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  current == null
                      ? 'Target level $target'
                      : 'Level $current dari target $target',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.small),
          Text(
            statusLabel,
            style: Theme.of(context).textTheme.labelSmall
                ?.copyWith(color: statusColor, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _DashboardLoading extends StatelessWidget {
  const _DashboardLoading();

  @override
  Widget build(BuildContext context) => const Scaffold(
    body: SafeArea(child: Center(child: CircularProgressIndicator())),
  );
}

class _DashboardError extends StatelessWidget {
  const _DashboardError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.large),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.cloud_off_rounded,
                color: AppColors.primary,
                size: 40,
              ),
              const SizedBox(height: AppSpacing.medium),
              Text(message, textAlign: TextAlign.center),
              const SizedBox(height: AppSpacing.medium),
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Muat ulang'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
