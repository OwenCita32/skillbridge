import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/network/api_client.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/info_callout.dart';
import '../../shared/widgets/primary_button.dart';

class RoadmapScreen extends StatefulWidget {
  const RoadmapScreen({
    required this.apiClient,
    required this.onChanged,
    super.key,
  });

  final ApiClient apiClient;
  final VoidCallback onChanged;

  @override
  State<RoadmapScreen> createState() => _RoadmapScreenState();
}

class _RoadmapScreenState extends State<RoadmapScreen> {
  Map<String, dynamic>? _roadmap;
  bool _isLoading = true;
  bool _isGenerating = false;
  String? _error;
  bool _isEmpty = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _isEmpty = false;
    });
    try {
      final roadmap = await widget.apiClient.currentRoadmap();
      if (mounted) {
        setState(() {
          _roadmap = roadmap;
          _isLoading = false;
        });
      }
    } on ApiException catch (error) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          if (error.statusCode == 404) {
            _isEmpty = true;
          } else {
            _error = error.message;
          }
        });
      }
    }
  }

  Future<void> _generate() async {
    setState(() {
      _isGenerating = true;
      _error = null;
    });
    try {
      final roadmap = await widget.apiClient.generateRoadmap();
      if (mounted) {
        setState(() {
          _roadmap = roadmap;
          _isEmpty = false;
        });
        widget.onChanged();
      }
    } on ApiException catch (error) {
      if (mounted) setState(() => _error = error.message);
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  Future<void> _updateStatus(int itemId, String status) async {
    try {
      await widget.apiClient.updateProgress(itemId: itemId, status: status);
      if (mounted && _roadmap != null) {
        final items = (_roadmap!['items'] as List<dynamic>)
            .map((item) => Map<String, dynamic>.from(item as Map))
            .toList();
        final index = items.indexWhere((item) => item['id'] == itemId);
        if (index >= 0) items[index]['status'] = status;
        setState(() => _roadmap = {..._roadmap!, 'items': items});
        widget.onChanged();
      }
    } on ApiException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.message)));
      }
    }
  }

  Future<void> _openResource(Map<String, dynamic> resource) async {
    final url = Uri.tryParse(resource['url'] as String? ?? '');
    if (url == null ||
        !url.hasScheme ||
        !await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Resource belum dapat dibuka. Coba lagi nanti.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const _RoadmapLoading();
    }
    if (_error != null && _roadmap == null && !_isEmpty) {
      return _RoadmapError(message: _error!, onRetry: _load);
    }
    if (_isEmpty && _roadmap == null) {
      return _EmptyRoadmap(
        isGenerating: _isGenerating,
        error: _error,
        onGenerate: _generate,
        onRetry: _load,
      );
    }

    final roadmap = _roadmap!;
    final items = (roadmap['items'] as List<dynamic>? ?? [])
        .map((value) => Map<String, dynamic>.from(value as Map))
        .toList();
    final completed = items
        .where((item) => item['status'] == 'completed')
        .length;
    final isAiAssisted = roadmap['generation_mode'] == 'openai_responses';

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _load,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.large,
              AppSpacing.large,
              AppSpacing.large,
              AppSpacing.xxLarge,
            ),
            children: [
              Text(
                'Rencana belajarmu',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: AppSpacing.small),
              Text(
                roadmap['career_title'] as String? ?? '',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.large),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.route_rounded,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: AppSpacing.small),
                        Expanded(
                          child: Text(
                            isAiAssisted
                                ? 'Roadmap dibantu GPT-6 Luna'
                                : 'Roadmap deterministik',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        Text(
                          '${items.length} tugas',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.small),
                    Text(
                      roadmap['summary'] as String? ?? '',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: AppSpacing.medium),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: LinearProgressIndicator(
                        value: items.isEmpty ? 1 : completed / items.length,
                        minHeight: 8,
                        backgroundColor: AppColors.surfaceMuted,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xSmall),
                    Text(
                      '$completed dari ${items.length} tugas selesai',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.medium),
              const InfoCallout(
                message: 'Setiap materi pada roadmap berasal dari katalog yang disimpan dan diperiksa di server. Tidak ada URL hasil tebakan.',
                icon: Icons.verified_outlined,
                backgroundColor: AppColors.successLight,
              ),
              const SizedBox(height: AppSpacing.large),
              if (items.isEmpty)
                const AppCard(
                  child: Text(
                    'Semua skill sudah mencapai target yang dipilih. Tinjau kembali penilaian jika kebutuhanmu berubah.',
                  ),
                )
              else
                ...items.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.medium),
                    child: _RoadmapTaskCard(
                      item: item,
                      onStatusChanged: (status) =>
                          _updateStatus(item['id'] as int, status),
                      onOpenResource: _openResource,
                    ),
                  ),
                ),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.small),
                  child: Text(
                    _error!,
                    style: const TextStyle(color: AppColors.error),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoadmapTaskCard extends StatelessWidget {
  const _RoadmapTaskCard({
    required this.item,
    required this.onStatusChanged,
    required this.onOpenResource,
  });

  final Map<String, dynamic> item;
  final ValueChanged<String> onStatusChanged;
  final ValueChanged<Map<String, dynamic>> onOpenResource;

  static const _statuses = <String, String>{
    'not_started': 'Belum dimulai',
    'in_progress': 'Sedang dipelajari',
    'completed': 'Selesai',
    'skipped': 'Dilewati',
  };

  @override
  Widget build(BuildContext context) {
    final resources = (item['resources'] as List<dynamic>? ?? [])
        .map((value) => Map<String, dynamic>.from(value as Map))
        .toList();
    final skill = item['skill'] as Map?;
    final status = item['status'] as String? ?? 'not_started';

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: status == 'completed'
                    ? AppColors.successLight
                    : AppColors.primaryLight,
                child: Text(
                  '${item['position']}',
                  style: TextStyle(
                    color: status == 'completed'
                        ? AppColors.success
                        : AppColors.primaryDark,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.medium),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (skill is Map<String, dynamic>)
                      Text(
                        skill['name'] as String? ?? '',
                        style: Theme.of(context).textTheme.labelSmall
                            ?.copyWith(color: AppColors.primaryDark),
                      ),
                    const SizedBox(height: 3),
                    Text(
                      item['title'] as String? ?? '',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.small),
          Text(
            item['description'] as String? ?? '',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.small),
          Row(
            children: [
              const Icon(
                Icons.schedule_rounded,
                color: AppColors.textSecondary,
                size: 17,
              ),
              const SizedBox(width: 5),
              Text(
                '${item['estimated_hours']} jam perkiraan',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.medium),
          Text(
            'Kriteria selesai',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          Text(
            item['completion_criteria'] as String? ?? '',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.medium),
          Text(
            'Materi terkurasi',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          if (resources.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.xSmall),
              child: Text(
                'Belum ada materi yang dikaitkan untuk skill ini. Gunakan kriteria praktik di atas.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            )
          else
            ...resources.map(
              (resource) => _ResourceRow(
                resource: resource,
                onTap: () => onOpenResource(resource),
              ),
            ),
          const SizedBox(height: AppSpacing.small),
          DropdownButtonFormField<String>(
            initialValue: status,
            decoration: const InputDecoration(labelText: 'Progress tugas'),
            items: _statuses.entries
                .map(
                  (entry) => DropdownMenuItem(
                    value: entry.key,
                    child: Text(entry.value),
                  ),
                )
                .toList(),
            onChanged: (value) {
              if (value != null && value != status) onStatusChanged(value);
            },
          ),
        ],
      ),
    );
  }
}

class _ResourceRow extends StatelessWidget {
  const _ResourceRow({required this.resource, required this.onTap});

  final Map<String, dynamic> resource;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.small),
      child: Material(
        color: AppColors.primaryLight.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(AppRadius.small),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.small),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.small),
            child: Row(
              children: [
                const Icon(
                  Icons.open_in_new_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: AppSpacing.small),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        resource['title'] as String? ?? '',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${resource['source']} · ${resource['type']}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        resource['description'] as String? ?? '',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyRoadmap extends StatelessWidget {
  const _EmptyRoadmap({
    required this.isGenerating,
    required this.error,
    required this.onGenerate,
    required this.onRetry,
  });

  final bool isGenerating;
  final String? error;
  final VoidCallback onGenerate;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.large),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: const Icon(
                      Icons.route_rounded,
                      color: AppColors.primary,
                      size: 38,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.large),
                  Text(
                    'Roadmap belum dibuat',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: AppSpacing.small),
                  Text(
                    'Setelah assessment tersimpan, SkillBridge menyusun langkah belajar dari skill gap dan materi yang ada di katalog.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  if (error != null) ...[
                    const SizedBox(height: AppSpacing.medium),
                    Text(
                      error!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.error),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.large),
                  PrimaryButton(
                    label: 'Buat roadmap',
                    icon: Icons.arrow_forward_rounded,
                    isLoading: isGenerating,
                    onPressed: onGenerate,
                  ),
                  TextButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Muat ulang'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RoadmapLoading extends StatelessWidget {
  const _RoadmapLoading();

  @override
  Widget build(BuildContext context) => const Scaffold(
    body: SafeArea(child: Center(child: CircularProgressIndicator())),
  );
}

class _RoadmapError extends StatelessWidget {
  const _RoadmapError({required this.message, required this.onRetry});

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
