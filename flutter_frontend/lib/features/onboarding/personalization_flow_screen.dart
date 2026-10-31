import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

part 'models/flow_step.dart';
part 'screens/ai_processing_step_screen.dart';
part 'screens/choose_level_step_screen.dart';
part 'screens/choose_role_step_screen.dart';
part 'widgets/role_cards_and_illustrations.dart';

class PersonalizationFlowScreen extends StatefulWidget {
  const PersonalizationFlowScreen({
    required this.onCompleted,
    this.onBackToOnboarding,
    this.enableLoopingAnimation,
    super.key,
  });

  final void Function(String selectedRole, String selectedLevel) onCompleted;
  final VoidCallback? onBackToOnboarding;
  final bool? enableLoopingAnimation;

  @override
  State<PersonalizationFlowScreen> createState() =>
      _PersonalizationFlowScreenState();
}

class _PersonalizationFlowScreenState extends State<PersonalizationFlowScreen> {
  _FlowStep _step = _FlowStep.chooseRole;
  String _selectedRole = 'UI/UX Designer';
  String _selectedLevel = 'Menengah';

  void _goToChooseLevel() {
    setState(() => _step = _FlowStep.chooseLevel);
  }

  void _goToAiProcessing() {
    setState(() => _step = _FlowStep.aiProcessing);
  }

  void _handleBackFromLevel() {
    setState(() => _step = _FlowStep.chooseRole);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 320),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      child: switch (_step) {
        _FlowStep.chooseRole => _ChooseRoleStepScreen(
          key: const ValueKey('step-choose-role'),
          selectedRole: _selectedRole,
          onSelectRole: (role) => setState(() => _selectedRole = role),
          onContinue: _goToChooseLevel,
          enableLoopingAnimation: widget.enableLoopingAnimation,
        ),
        _FlowStep.chooseLevel => _ChooseLevelStepScreen(
          key: const ValueKey('step-choose-level'),
          selectedRole: _selectedRole,
          selectedLevel: _selectedLevel,
          onSelectLevel: (level) => setState(() => _selectedLevel = level),
          onBack: _handleBackFromLevel,
          onContinue: _goToAiProcessing,
        ),
        _FlowStep.aiProcessing => _AiProcessingStepScreen(
          key: const ValueKey('step-ai-processing'),
          selectedRole: _selectedRole,
          selectedLevel: _selectedLevel,
          enableLoopingAnimation: widget.enableLoopingAnimation,
          onFinished: () =>
              widget.onCompleted(_selectedRole, _selectedLevel),
        ),
      },
    );
  }
}
