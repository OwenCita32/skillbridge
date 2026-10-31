import 'package:flutter/material.dart';

import '../../core/network/api_client.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/info_callout.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    required this.apiClient,
    required this.user,
    required this.onChangeCareer,
    required this.onLogout,
    super.key,
  });

  final ApiClient apiClient;
  final Map<String, dynamic> user;
  final VoidCallback onChangeCareer;
  final VoidCallback onLogout;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoggingOut = false;

  Future<void> _logout() async {
    setState(() => _isLoggingOut = true);
    try {
      await widget.apiClient.logout();
    } on ApiException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.message)));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoggingOut = false);
        widget.onLogout();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final careerGoal = widget.user['career_goal'] as Map?;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.large,
            AppSpacing.large,
            AppSpacing.large,
            AppSpacing.xxLarge,
          ),
          children: [
            Text('Profil', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: AppSpacing.large),
            AppCard(
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: AppColors.primaryLight,
                    child: Text(
                      _initials(widget.user['name'] as String? ?? ''),
                      style: const TextStyle(
                        color: AppColors.primaryDark,
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.medium),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.user['name'] as String? ?? '',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          widget.user['email'] as String? ?? '',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.medium),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Target karier',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: AppSpacing.xSmall),
                  Text(
                    careerGoal?['career_title'] as String? ?? 'Belum dipilih',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppSpacing.medium),
                  OutlinedButton.icon(
                    onPressed: widget.onChangeCareer,
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Ubah target karier'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.medium),
            const InfoCallout(
              message: 'Level skill dan roadmap bersifat panduan belajar. Self-assessment tidak membuktikan kompetensi dan tidak menjamin hasil kerja.',
              icon: Icons.info_outline_rounded,
              backgroundColor: AppColors.warningLight,
            ),
            const SizedBox(height: AppSpacing.xLarge),
            SizedBox(
              height: 52,
              child: OutlinedButton.icon(
                onPressed: _isLoggingOut ? null : _logout,
                icon: _isLoggingOut
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.logout_rounded),
                label: const Text('Keluar dari akun'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textPrimary,
                  side: const BorderSide(color: AppColors.border),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.button),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _initials(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty);
    return parts
        .take(2)
        .map((part) => part.characters.first.toUpperCase())
        .join();
  }
}
