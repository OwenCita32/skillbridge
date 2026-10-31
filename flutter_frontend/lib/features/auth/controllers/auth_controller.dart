part of '../auth_screen.dart';

extension _AuthScreenLogic on _AuthScreenState {
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _rebuild(() {
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
        _rebuild(() => _errorMessage = error.message);
      }
    } catch (_) {
      if (mounted) {
        _rebuild(() => _errorMessage = 'Terjadi kendala. Coba lagi.');
      }
    } finally {
      if (mounted) {
        _rebuild(() => _isLoading = false);
      }
    }
  }

  void _showForgotPasswordModal() {
    final resetEmailController =
        TextEditingController(text: _emailController.text.trim());
    final resetCodeController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    bool isRequesting = false;
    bool isSubmitting = false;
    String? generatedCode;
    String? modalError;
    bool codeSent = false;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (modalContext, setModalState) {
            return Container(
              padding: EdgeInsets.fromLTRB(
                24,
                16,
                24,
                MediaQuery.of(modalContext).viewInsets.bottom + 24,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 38,
                        height: 4,
                        decoration: BoxDecoration(
                          color: const Color(0xFFCBD5E1),
                          borderRadius: BorderRadius.circular(99),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.lock_reset_rounded,
                            color: Color(0xFF0057FF),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Pemulihan Kata Sandi',
                                style: TextStyle(
                                  color: Color(0xFF0F172A),
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Text(
                                'Reset kata sandi instan tanpa SMTP / vendor',
                                style: TextStyle(
                                  color: Color(0xFF64748B),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(sheetContext).pop(),
                          icon: const Icon(
                            Icons.close_rounded,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (modalError != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF2F2),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFFECACA)),
                        ),
                        child: Text(
                          modalError!,
                          style: const TextStyle(
                            color: Color(0xFFEF4444),
                            fontSize: 12.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    if (!codeSent) ...[
                      const Text(
                        'Masukkan alamat email akunmu untuk membuat kode pemulihan 6 digit secara otomatis:',
                        style: TextStyle(
                          color: Color(0xFF475569),
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: resetEmailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: _fieldDecoration(
                          labelText: 'Email',
                          hintText: 'nama@email.com',
                          prefixIcon: Icons.mail_outline_rounded,
                        ),
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: FilledButton(
                          onPressed: isRequesting
                              ? null
                              : () async {
                                  final email =
                                      resetEmailController.text.trim();
                                  if (email.isEmpty || !email.contains('@')) {
                                    setModalState(
                                      () => modalError =
                                          'Masukkan email yang valid.',
                                    );
                                    return;
                                  }
                                  setModalState(() {
                                    isRequesting = true;
                                    modalError = null;
                                  });
                                  try {
                                    final res = await widget.apiClient
                                        .requestPasswordReset(email);
                                    final code =
                                        res['reset_code'] as String? ?? '';
                                    setModalState(() {
                                      generatedCode = code;
                                      resetCodeController.text = code;
                                      codeSent = true;
                                    });
                                  } on ApiException catch (e) {
                                    setModalState(() => modalError = e.message);
                                  } finally {
                                    setModalState(() => isRequesting = false);
                                  }
                                },
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF0057FF),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: isRequesting
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'Buat Kode Pemulihan',
                                  style: TextStyle(fontWeight: FontWeight.w700),
                                ),
                        ),
                      ),
                    ] else ...[
                      // Step 2: Show code & input new password
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFBFDBFE)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Kode Pemulihan Instan Anda:',
                              style: TextStyle(
                                color: Color(0xFF1E40AF),
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              generatedCode ?? '',
                              style: const TextStyle(
                                color: Color(0xFF0057FF),
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 4,
                              ),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'Gunakan kode di atas untuk mereset kata sandi baru.',
                              style: TextStyle(
                                color: Color(0xFF64748B),
                                fontSize: 11.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: resetCodeController,
                        keyboardType: TextInputType.number,
                        decoration: _fieldDecoration(
                          labelText: 'Kode Pemulihan 6 Digit',
                          hintText: '6 digit angka',
                          prefixIcon: Icons.pin_outlined,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: newPasswordController,
                        obscureText: true,
                        decoration: _fieldDecoration(
                          labelText: 'Kata Sandi Baru',
                          hintText: 'Minimal 8 karakter',
                          prefixIcon: Icons.lock_outline_rounded,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: confirmPasswordController,
                        obscureText: true,
                        decoration: _fieldDecoration(
                          labelText: 'Konfirmasi Kata Sandi Baru',
                          hintText: 'Ulangi kata sandi baru',
                          prefixIcon: Icons.lock_reset_rounded,
                        ),
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: FilledButton(
                          onPressed: isSubmitting
                              ? null
                              : () async {
                                  final code = resetCodeController.text.trim();
                                  final pwd = newPasswordController.text;
                                  final confirm =
                                      confirmPasswordController.text;

                                  if (code.length != 6) {
                                    setModalState(
                                      () =>
                                          modalError = 'Kode harus 6 digit.',
                                    );
                                    return;
                                  }
                                  if (pwd.length < 8) {
                                    setModalState(
                                      () => modalError =
                                          'Kata sandi minimal 8 karakter.',
                                    );
                                    return;
                                  }
                                  if (pwd != confirm) {
                                    setModalState(
                                      () => modalError =
                                          'Konfirmasi kata sandi tidak cocok.',
                                    );
                                    return;
                                  }

                                  setModalState(() {
                                    isSubmitting = true;
                                    modalError = null;
                                  });

                                  try {
                                    await widget.apiClient.resetPassword(
                                      email: resetEmailController.text.trim(),
                                      resetCode: code,
                                      password: pwd,
                                      passwordConfirmation: confirm,
                                    );
                                    if (sheetContext.mounted) {
                                      Navigator.of(sheetContext).pop();
                                      _emailController.text =
                                          resetEmailController.text.trim();
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Kata sandi berhasil direset! Silakan masuk.',
                                              ),
                                              backgroundColor: Color(
                                                0xFF10B981,
                                              ),
                                            ),
                                          );
                                    }
                                  } on ApiException catch (e) {
                                    setModalState(() => modalError = e.message);
                                  } finally {
                                    setModalState(() => isSubmitting = false);
                                  }
                                },
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF0057FF),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: isSubmitting
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'Simpan Kata Sandi Baru',
                                  style: TextStyle(fontWeight: FontWeight.w700),
                                ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
