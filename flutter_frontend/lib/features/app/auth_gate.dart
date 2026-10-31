import 'package:flutter/material.dart';

import '../../core/network/api_client.dart';
import '../../core/theme/app_theme.dart';
import '../auth/auth_screen.dart';
import '../navigation/app_shell.dart';
import '../onboarding/onboarding_screen.dart';
import '../onboarding/personalization_flow_screen.dart';
import '../onboarding/splash_screen.dart';

enum _PreAuthStage {
  onboardingSlides,
  personalization,
  auth,
}

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

  bool get _isAutomatedTest =>
      WidgetsBinding.instance.runtimeType.toString().contains('AutomatedTest');

  @override
  void initState() {
    super.initState();
    _preAuthStage = widget.showOnboardingInitially
        ? _PreAuthStage.onboardingSlides
        : _PreAuthStage.auth;
    _restoreSession();
  }

  Future<void> _restoreSession() async {
    setState(() {
      _isLoading = true;
      _restoreError = null;
    });

    final minimumSplash = _isAutomatedTest
        ? Future<void>.value()
        : Future<void>.delayed(const Duration(milliseconds: 1400));

    try {
      final token = await widget.apiClient.readToken();
      if (token == null || token.isEmpty) {
        await minimumSplash;
        if (mounted) {
          setState(() => _isLoading = false);
        }
        return;
      }
      final user = await widget.apiClient.me();
      await minimumSplash;
      if (mounted) {
        setState(() {
          _user = user;
          _isLoading = false;
        });
      }
    } on ApiException catch (error) {
      if (error.statusCode == 401) {
        await widget.apiClient.logout().catchError((_) {});
      }
      await minimumSplash;
      if (mounted) {
        setState(() {
          _restoreError = error.statusCode == 401 ? null : error;
          _isLoading = false;
        });
      }
    } catch (_) {
      await minimumSplash;
      if (mounted) {
        setState(() {
          _restoreError = const ApiException(
            message: 'Sesi belum dapat diperiksa. Coba lagi saat terhubung.',
            code: 'SESSION_CHECK_FAILED',
          );
          _isLoading = false;
        });
      }
    }
  }

  void _onAuthenticated(Map<String, dynamic> user) {
    setState(() {
      _user = user;
      _restoreError = null;
    });
  }

  void _onLogout() {
    setState(() {
      _user = null;
      _preAuthStage = _PreAuthStage.auth;
    });
  }

  Future<void> _continueWithoutSavedSession() async {
    await widget.apiClient.logout().catchError((_) {});
    if (mounted) {
      setState(() => _restoreError = null);
    }
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

class _SessionErrorScreen extends StatelessWidget {
  const _SessionErrorScreen({
    required this.error,
    required this.onRetry,
    required this.onContinue,
  });

  final ApiException error;
  final Future<void> Function() onRetry;
  final Future<void> Function() onContinue;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.large),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.cloud_off_rounded,
                    color: AppColors.primary,
                    size: 42,
                  ),
                  const SizedBox(height: AppSpacing.medium),
                  Text(
                    'Belum tersambung',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: AppSpacing.xSmall),
                  Text(error.message, textAlign: TextAlign.center),
                  const SizedBox(height: AppSpacing.large),
                  FilledButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Coba lagi'),
                  ),
                  TextButton(
                    onPressed: onContinue,
                    child: const Text('Masuk dengan akun lain'),
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
