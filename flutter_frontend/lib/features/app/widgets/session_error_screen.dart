part of '../auth_gate.dart';

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
