part of '../auth_gate.dart';

extension _AuthGateLogic on _AuthGateState {
  bool get _isAutomatedTest =>
      WidgetsBinding.instance.runtimeType.toString().contains('AutomatedTest');

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
}
