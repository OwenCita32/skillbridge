import 'package:flutter/material.dart';

import '../../core/network/api_client.dart';
import '../../core/theme/app_theme.dart';
import '../auth/auth_screen.dart';
import '../navigation/app_shell.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({required this.apiClient, super.key});

  final ApiClient apiClient;

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  Map<String, dynamic>? _user;
  ApiException? _restoreError;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _restoreSession();
  }

  Future<void> _restoreSession() async {
    setState(() {
      _isLoading = true;
      _restoreError = null;
    });

    try {
      final token = await widget.apiClient.readToken();
      if (token == null || token.isEmpty) {
        if (mounted) {
          setState(() => _isLoading = false);
        }
        return;
      }
      final user = await widget.apiClient.me();
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
      if (mounted) {
        setState(() {
          _restoreError = error.statusCode == 401 ? null : error;
          _isLoading = false;
        });
      }
    } catch (_) {
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
    setState(() => _user = null);
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
      return const _StartupScreen();
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

    return AuthScreen(
      apiClient: widget.apiClient,
      onAuthenticated: _onAuthenticated,
    );
  }
}

class _StartupScreen extends StatelessWidget {
  const _StartupScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _BrandMark(),
              SizedBox(height: AppSpacing.large),
              CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
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

class _BrandMark extends StatelessWidget {
  const _BrandMark();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 68,
      height: 68,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(22),
      ),
      child: const Icon(Icons.alt_route_rounded, color: Colors.white, size: 36),
    );
  }
}
