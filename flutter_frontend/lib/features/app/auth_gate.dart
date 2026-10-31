import 'package:flutter/material.dart';

import '../../core/network/api_client.dart';
import '../../core/theme/app_theme.dart';
import '../auth/auth_screen.dart';
import '../navigation/app_shell.dart';
import '../onboarding/onboarding_screen.dart';
import '../onboarding/personalization_flow_screen.dart';
import '../onboarding/splash_screen.dart';

part 'models/pre_auth_stage.dart';
part 'controllers/auth_gate_controller.dart';
part 'widgets/session_error_screen.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({
    required this.apiClient,
    this.showOnboardingInitially = true,
    super.key,
  });

  final ApiClient apiClient;
  final bool showOnboardingInitially;

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  Map<String, dynamic>? _user;
  ApiException? _restoreError;
  bool _isLoading = true;
  late _PreAuthStage _preAuthStage;

  @override
  void setState(VoidCallback fn) {
    super.setState(fn);
  }

  @override
  void initState() {
    super.initState();
    _preAuthStage = widget.showOnboardingInitially
        ? _PreAuthStage.onboardingSlides
        : _PreAuthStage.auth;
    _restoreSession();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SplashScreen();
    }
    if (_user != null) {
      return AppShell(
        apiClient: widget.apiClient,
        user: _user!,
        onLogout: _onLogout,
      );
    }
    if (_restoreError != null) {
      return _SessionErrorScreen(
        error: _restoreError!,
        onRetry: _restoreSession,
        onContinue: _continueWithoutSavedSession,
      );
    }

    return switch (_preAuthStage) {
      _PreAuthStage.onboardingSlides => OnboardingScreen(
        onCompleted: () =>
            setState(() => _preAuthStage = _PreAuthStage.personalization),
        onSkipToAuth: () =>
            setState(() => _preAuthStage = _PreAuthStage.personalization),
      ),
      _PreAuthStage.personalization => PersonalizationFlowScreen(
        onCompleted: (_, _) =>
            setState(() => _preAuthStage = _PreAuthStage.auth),
      ),
      _PreAuthStage.auth => AuthScreen(
        apiClient: widget.apiClient,
        onAuthenticated: _onAuthenticated,
      ),
    };
  }
}
