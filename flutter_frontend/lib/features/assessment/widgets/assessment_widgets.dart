part of '../assessment_screen.dart';

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
