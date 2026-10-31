import 'package:flutter/material.dart';

import '../../core/network/api_client.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/primary_button.dart';

part 'controllers/career_selection_controller.dart';
part 'screens/career_selection_body.dart';
part 'widgets/career_load_error.dart';

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
  void setState(VoidCallback fn) {
    super.setState(fn);
  }

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

  @override
  Widget build(BuildContext context) {
    final hasCustomText = _customController.text.trim().isNotEmpty;
    final canSave =
        hasCustomText || _selectedId != null || _selectedPresetTitle != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: _buildCareerSelectionBody(
          hasCustomText: hasCustomText,
          canSave: canSave,
        ),
      ),
    );
  }
}
