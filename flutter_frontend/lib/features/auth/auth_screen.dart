import 'package:flutter/material.dart';

import '../../core/network/api_client.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/primary_button.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({
    required this.apiClient,
    required this.onAuthenticated,
    super.key,
  });

  final ApiClient apiClient;
  final ValueChanged<Map<String, dynamic>> onAuthenticated;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isRegistering = false;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final user = _isRegistering
          ? await widget.apiClient.register(
              name: _nameController.text.trim(),
              email: _emailController.text.trim(),
              password: _passwordController.text,
            )
          : await widget.apiClient.login(
              email: _emailController.text.trim(),
              password: _passwordController.text,
            );
      if (mounted) {
        widget.onAuthenticated(user);
      }
    } on ApiException catch (error) {
      if (mounted) {
        setState(() => _errorMessage = error.message);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _errorMessage = 'Terjadi kendala. Coba lagi.');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.large),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.alt_route_rounded,
                          color: Colors.white,
                          size: 34,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.medium),
                    Center(
                      child: Text(
                        'SkillBridge',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xSmall),
                    Center(
                      child: Text(
                        'Learn the Skills. Prove Them. Get Hired.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxLarge),
                    Text(
                      _isRegistering ? 'Buat akun' : 'Selamat datang kembali',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: AppSpacing.xSmall),
                    Text(
                      _isRegistering
                          ? 'Mulai petakan skill dan rencana belajarmu.'
                          : 'Masuk untuk melanjutkan perjalanan kariermu.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    if (_isRegistering) ...[
                      const SizedBox(height: AppSpacing.large),
                      TextFormField(
                        controller: _nameController,
                        textCapitalization: TextCapitalization.words,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'Nama',
                          hintText: 'Nama lengkap',
                        ),
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                            ? 'Nama wajib diisi.'
                            : null,
                      ),
                    ],
                    const SizedBox(height: AppSpacing.medium),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.email],
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        hintText: 'nama@email.com',
                      ),
                      validator: (value) {
                        final email = value?.trim() ?? '';
                        if (email.isEmpty) {
                          return 'Email wajib diisi.';
                        }
                        if (!email.contains('@')) {
                          return 'Gunakan email yang valid.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.medium),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      textInputAction: TextInputAction.done,
                      autofillHints: [
                        _isRegistering
                            ? AutofillHints.newPassword
                            : AutofillHints.password,
                      ],
                      onFieldSubmitted: (_) => _submit(),
                      decoration: const InputDecoration(
                        labelText: 'Kata sandi',
                      ),
                      validator: (value) {
                        final password = value ?? '';
                        if (password.isEmpty) return 'Kata sandi wajib diisi.';
                        if (_isRegistering && password.length < 8) {
                          return 'Kata sandi minimal 8 karakter.';
                        }
                        return null;
                      },
                    ),
                    if (_errorMessage != null) ...[
                      const SizedBox(height: AppSpacing.medium),
                      _ErrorBanner(message: _errorMessage!),
                    ],
                    const SizedBox(height: AppSpacing.large),
                    PrimaryButton(
                      label: _isRegistering ? 'Buat akun' : 'Masuk',
                      onPressed: _submit,
                      isLoading: _isLoading,
                      icon: Icons.arrow_forward_rounded,
                    ),
                    const SizedBox(height: AppSpacing.small),
                    Center(
                      child: TextButton(
                        onPressed: _isLoading
                            ? null
                            : () => setState(() {
                                _isRegistering = !_isRegistering;
                                _errorMessage = null;
                              }),
                        child: Text(
                          _isRegistering
                              ? 'Sudah punya akun? Masuk'
                              : 'Belum punya akun? Buat akun',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.medium),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppRadius.small),
      ),
      child: Text(
        message,
        style: Theme.of(context).textTheme.bodyMedium
            ?.copyWith(color: AppColors.error),
      ),
    );
  }
}
