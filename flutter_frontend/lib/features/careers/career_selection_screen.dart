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
  final _customController = TextEditingController();
  List<dynamic> _careers = [];
  int? _selectedId;
  String? _selectedPresetTitle;
  bool _isLoading = true;
  bool _isSaving = false;
  String? _error;

  static const _quickPresets = [
    (
      title: 'Freelance UI/UX Designer',
      desc: 'Desain visual, prototyping Figma, dan riset alur user.',
      icon: Icons.palette_outlined,
    ),
    (
      title: 'Frontend Developer',
      desc: 'Membangun UI web/mobile modern dengan React & Flutter.',
      icon: Icons.code_rounded,
    ),
    (
      title: 'Data Analyst',
      desc: 'Query SQL, visualisasi insight bisnis, dan analisis data.',
      icon: Icons.analytics_outlined,
    ),
    (
      title: 'Cybersecurity Analyst',
      desc: 'Analisis log SIEM, mitigasi risiko sistem, dan alert triage.',
      icon: Icons.security_rounded,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadCareers();
  }

  @override
  void dispose() {
    _customController.dispose();
    super.dispose();
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
    final customText = _customController.text.trim();
    final hasCustom = customText.isNotEmpty;
    final hasSelectedId = _selectedId != null;
    final hasPreset = _selectedPresetTitle != null;

    if (!hasCustom && !hasSelectedId && !hasPreset) return;

    setState(() => _isSaving = true);
    try {
      final Map<String, dynamic> career;
      if (hasCustom) {
        career = await widget.apiClient.setCareerGoal(null, customText);
      } else if (hasSelectedId) {
        career = await widget.apiClient.setCareerGoal(_selectedId, null);
      } else {
        career = await widget.apiClient.setCareerGoal(null, _selectedPresetTitle!);
      }

      if (mounted) widget.onSelected(career);
    } on ApiException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.message),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _onSelectPreset(String title) {
    setState(() {
      _selectedPresetTitle = title;
      _selectedId = null;
      _customController.text = title;
    });
  }

  void _onSelectDbCareer(int id, String title) {
    setState(() {
      _selectedId = id;
      _selectedPresetTitle = null;
      _customController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasCustomText = _customController.text.trim().isNotEmpty;
    final canSave = hasCustomText || _selectedId != null || _selectedPresetTitle != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
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
                                color: Color(0xFF0057FF),
                              ),
                            const SizedBox(width: AppSpacing.xSmall),
                            const Text(
                              'SkillBridge',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.large),
                        const Text(
                          'Tentukan target kariermu',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Pilih peran cepat di bawah, atau ketik karier spesifik yang kamu minati.',
                          style: TextStyle(
                            fontSize: 13.5,
                            color: Color(0xFF64748B),
                            height: 1.45,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // FITUR 1: KETIK TARGET KUSTOM (INPUT BOX)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(
                              color: hasCustomText
                                  ? const Color(0xFF0057FF)
                                  : const Color(0xFFE2E8F0),
                              width: hasCustomText ? 1.8 : 1.0,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: hasCustomText
                                    ? const Color(0xFF0057FF).withValues(alpha: 0.08)
                                    : const Color(0xFF0F172A).withValues(alpha: 0.03),
                                blurRadius: 18,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(
                                    Icons.edit_note_rounded,
                                    color: Color(0xFF0057FF),
                                    size: 20,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Ketik Peran Kustom',
                                    style: TextStyle(
                                      color: Color(0xFF0F172A),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  Spacer(),
                                  Text(
                                    'Sesuai minat',
                                    style: TextStyle(
                                      color: Color(0xFF94A3B8),
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              TextField(
                                controller: _customController,
                                onChanged: (val) {
                                  setState(() {
                                    if (val.trim().isNotEmpty) {
                                      _selectedId = null;
                                      _selectedPresetTitle = null;
                                    }
                                  });
                                },
                                decoration: InputDecoration(
                                  hintText: 'Misal: 3D Animator, SEO Specialist, Flutter Dev...',
                                  hintStyle: const TextStyle(
                                    color: Color(0xFF94A3B8),
                                    fontSize: 13,
                                  ),
                                  filled: true,
                                  fillColor: const Color(0xFFF8FAFC),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 12,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: const BorderSide(color: Color(0xFF0057FF), width: 1.6),
                                  ),
                                  suffixIcon: hasCustomText
                                      ? IconButton(
                                          icon: const Icon(Icons.clear_rounded, size: 18),
                                          onPressed: () {
                                            _customController.clear();
                                            setState(() {});
                                          },
                                        )
                                      : null,
                                ),
                              ),
                              if (hasCustomText) ...[
                                const SizedBox(height: 8),
                                const Row(
                                  children: [
                                    Icon(
                                      Icons.check_circle_rounded,
                                      color: Color(0xFF10B981),
                                      size: 15,
                                    ),
                                    SizedBox(width: 6),
                                    Text(
                                      'AI akan memetakan 4 skill esensial peran ini secara otomatis.',
                                      style: TextStyle(
                                        color: Color(0xFF059669),
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // FITUR 2: PILIHAN CEPAT (POPULER)
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Pilihan Cepat Populer',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            Text(
                              '1-klik pilih',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF94A3B8),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        if (_isLoading)
                          const Padding(
                            padding: EdgeInsets.all(AppSpacing.xxLarge),
                            child: Center(child: CircularProgressIndicator()),
                          )
                        else if (_error != null && _careers.isEmpty) ...[
                          _LoadError(message: _error!, onRetry: _loadCareers),
                          const SizedBox(height: 16),
                          const Text(
                            'Atau pilih preset langsung:',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF64748B),
                            ),
                          ),
                          const SizedBox(height: 10),
                          ..._quickPresets.map((preset) => _buildPresetTile(preset)),
                        ] else if (_careers.isNotEmpty) ...[
                          // Tampilkan karier dari database
                          ..._careers.map((value) {
                            final career = Map<String, dynamic>.from(value as Map);
                            final id = career['id'] as int;
                            final title = career['title'] as String? ?? '';
                            final selected = _selectedId == id && !hasCustomText;
                            final skills = career['skills'] as List<dynamic>? ?? [];

                            return Padding(
                              padding: const EdgeInsets.only(bottom: AppSpacing.medium),
                              child: AppCard(
                                onTap: () => _onSelectDbCareer(id, title),
                                borderColor: selected
                                    ? const Color(0xFF0057FF)
                                    : const Color(0xFFE2E8F0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: selected
                                            ? const Color(0xFFEFF6FF)
                                            : const Color(0xFFF1F5F9),
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: Icon(
                                        Icons.auto_awesome_rounded,
                                        color: selected
                                            ? const Color(0xFF0057FF)
                                            : const Color(0xFF64748B),
                                        size: 22,
                                      ),
                                    ),
                                    const SizedBox(width: AppSpacing.medium),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  title,
                                                  style: const TextStyle(
                                                    fontSize: 15.5,
                                                    fontWeight: FontWeight.w800,
                                                    color: Color(0xFF0F172A),
                                                  ),
                                                ),
                                              ),
                                              Icon(
                                                selected
                                                    ? Icons.check_circle_rounded
                                                    : Icons.radio_button_unchecked_rounded,
                                                color: selected
                                                    ? const Color(0xFF0057FF)
                                                    : const Color(0xFFCBD5E1),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            career['summary'] as String? ?? '',
                                            style: const TextStyle(
                                              fontSize: 12.5,
                                              color: Color(0xFF64748B),
                                              height: 1.4,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            '${skills.length} skill terkait',
                                            style: const TextStyle(
                                              fontSize: 11.5,
                                              fontWeight: FontWeight.w700,
                                              color: Color(0xFF0057FF),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                        ] else ...[
                          // Database kosong, tampilkan quick presets
                          ..._quickPresets.map((preset) => _buildPresetTile(preset)),
                        ],
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
                label: hasCustomText
                    ? 'Simpan peran: ${_customController.text.trim()}'
                    : 'Simpan target karier',
                icon: Icons.arrow_forward_rounded,
                isLoading: _isSaving,
                onPressed: canSave ? _saveGoal : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPresetTile(({String title, String desc, IconData icon}) preset) {
    final isSelected = _selectedPresetTitle == preset.title;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _onSelectPreset(preset.title),
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF0057FF)
                  : const Color(0xFFE2E8F0),
              width: isSelected ? 1.8 : 1.0,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFFEFF6FF)
                      : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  preset.icon,
                  color: isSelected ? const Color(0xFF0057FF) : const Color(0xFF64748B),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      preset.title,
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      preset.desc,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                isSelected
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked_rounded,
                color: isSelected ? const Color(0xFF0057FF) : const Color(0xFFCBD5E1),
              ),
            ],
          ),
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
