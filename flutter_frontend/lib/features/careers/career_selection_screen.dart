import 'package:flutter/material.dart';

import '../../core/network/api_client.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/primary_button.dart';

class CareerSelectionScreen extends StatefulWidget {
  const CareerSelectionScreen({
    required this.apiClient,
    required this.onSelected,
    this.onCancel,
    super.key,
  });

  final ApiClient apiClient;
  final ValueChanged<Map<String, dynamic>> onSelected;
  final VoidCallback? onCancel;

  @override
  State<CareerSelectionScreen> createState() => _CareerSelectionScreenState();
}

class _CareerSelectionScreenState extends State<CareerSelectionScreen> {
  List<dynamic> _careers = [];
  int? _selectedId;
  bool _isLoading = true;
  bool _isSaving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCareers();
  }

  Future<void> _loadCareers() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final careers = await widget.apiClient.careers();
      if (mounted) {
        setState(() {
          _careers = careers;
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

  Future<void> _saveGoal() async {
    final careerId = _selectedId;
    if (careerId == null) return;
    setState(() => _isSaving = true);
    try {
      final career = await widget.apiClient.setCareerGoal(careerId);
      if (mounted) widget.onSelected(career);
    } on ApiException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.message)));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.large,
                      AppSpacing.medium,
                      AppSpacing.large,
                      AppSpacing.large,
                    ),
                    sliver: SliverList.list(
                      children: [
                        Row(
                          children: [
                            if (widget.onCancel != null)
                              IconButton(
                                onPressed: widget.onCancel,
                                tooltip: 'Kembali',
                                icon: const Icon(Icons.arrow_back_rounded),
                              )
                            else
                              const Icon(
                                Icons.alt_route_rounded,
                                color: AppColors.primary,
                              ),
                            const SizedBox(width: AppSpacing.xSmall),
                            Text(
                              'SkillBridge',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xLarge),
                        Text(
                          'Tentukan target kariermu',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: AppSpacing.xSmall),
                        Text(
                          'Pilih peran yang ingin kamu persiapkan. Kamu bisa mengubah pilihan ini nanti.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: AppSpacing.large),
                        if (_isLoading)
                          const Padding(
                            padding: EdgeInsets.all(AppSpacing.xxLarge),
                            child: Center(child: CircularProgressIndicator()),
                          )
                        else if (_error != null)
                          _LoadError(message: _error!, onRetry: _loadCareers)
                        else if (_careers.isEmpty)
                          const _EmptyCareers()
                        else
                          ..._careers.map((value) {
                            final career = Map<String, dynamic>.from(
                              value as Map,
                            );
                            final id = career['id'] as int;
                            final selected = _selectedId == id;
                            final skills =
                                career['skills'] as List<dynamic>? ?? [];

                            return Padding(
                              padding: const EdgeInsets.only(
                                bottom: AppSpacing.medium,
                              ),
                              child: AppCard(
                                onTap: () => setState(() => _selectedId = id),
                                borderColor: selected
                                    ? AppColors.primary
                                    : AppColors.border,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryLight,
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: const Icon(
                                        Icons.security_rounded,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    const SizedBox(width: AppSpacing.medium),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  career['title'] as String? ??
                                                      '',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .titleMedium,
                                                ),
                                              ),
                                              Icon(
                                                selected
                                                    ? Icons.check_circle_rounded
                                                    : Icons
                                                          .radio_button_unchecked_rounded,
                                                color: selected
                                                    ? AppColors.primary
                                                    : AppColors.textMuted,
                                              ),
                                            ],
                                          ),
                                          const SizedBox(
                                            height: AppSpacing.xSmall,
                                          ),
                                          Text(
                                            career['summary'] as String? ?? '',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium,
                                          ),
                                          const SizedBox(
                                            height: AppSpacing.small,
                                          ),
                                          Text(
                                            '${skills.length} skill terkait',
                                            style: Theme.of(context)
                                                .textTheme
                                                .labelSmall
                                                ?.copyWith(
                                                  color:
                                                      AppColors.textSecondary,
                                                ),
                                          ),
                                          if (career['is_demo'] == true) ...[
                                            const SizedBox(
                                              height: AppSpacing.small,
                                            ),
                                            const _DemoBadge(),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                      ],
                    ),
                  ),
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
                label: 'Simpan target karier',
                icon: Icons.arrow_forward_rounded,
                isLoading: _isSaving,
                onPressed: _selectedId == null ? null : _saveGoal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DemoBadge extends StatelessWidget {
  const _DemoBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.warningLight,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        'Profil demo',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: AppColors.warningText,
          fontWeight: FontWeight.w600,
        ),
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
    return AppCard(
      child: Column(
        children: [
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: AppSpacing.small),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Muat ulang'),
          ),
        ],
      ),
    );
  }
}

class _EmptyCareers extends StatelessWidget {
  const _EmptyCareers();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Text(
        'Belum ada karier yang tersedia. Coba muat ulang beberapa saat lagi.',
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }
}
