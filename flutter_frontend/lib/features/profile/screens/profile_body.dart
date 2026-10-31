part of '../profile_screen.dart';

extension _ProfileScreenBody on _ProfileScreenState {
  Widget _buildProfileScaffold(BuildContext context) {
    final rawName = (_userData['name'] as String?)?.trim() ?? '';
    final displayName = rawName.isEmpty ? 'Raka Pratama' : rawName;
    final careerGoal = _userData['career_goal'] as Map?;
    final rawCareerTitle =
        (careerGoal?['career_title'] as String?)?.trim() ?? '';
    final careerLabel = rawCareerTitle.isEmpty
        ? 'UI/UX Designer'
        : rawCareerTitle.replaceFirst(
            RegExp(r'^Freelance\s+', caseSensitive: false),
            '',
          );

    final headline = (_userData['headline'] as String?)?.trim().isNotEmpty == true
        ? _userData['headline'] as String
        : '$careerLabel · Mahasiswa Informatika · Bandung';

    final githubUser = (_userData['github_username'] as String?)?.trim().isNotEmpty == true
        ? _userData['github_username'] as String
        : 'rakapratama';

    final avatarUrl = _userData['avatar_url'] as String?;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 130),
          children: [
            // Top Hero Profile Card
            _ProfileHeroCard(
              name: displayName,
              subtitle: headline,
              avatarUrl: avatarUrl,
              readinessScore: _readinessScore,
              projectCount: _importedRepos.length,
              certificateCount: _earnedCertificateCount,
              onTapCareer: _showCertificatesSheet,
              onEditProfile: _showEditProfileSheet,
              onEditAvatar: _showAvatarPickerSheet,
              onTapProjects: _showProjectsSheet,
              onTapCertificates: _showCertificatesSheet,
            ),
            const SizedBox(height: 22),

            // Section Header: Akun Terhubung
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Akun Terhubung',
                  style: TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 16.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
                Text(
                  'Sinkron otomatis',
                  style: TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // 2-Column Connected Accounts Grid
            Row(
              children: [
                Expanded(
                  child: _GithubConnectCard(
                    username: githubUser,
                    repoCount: _importedRepos.length,
                    isSyncing: _isSyncingGithub,
                    onSync: _showGithubImportDialog,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _LinkedInConnectCard(
                    isConnected: _linkedInConnected,
                    onTap: _showLinkedInExportSheet,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Dark Card: Diimport dari GitHub
            _ImportedGithubCard(
              repos: _importedRepos,
              onTapSync: _showGithubImportDialog,
              onTapViewAll: _showProjectsSheet,
            ),
            const SizedBox(height: 18),

            // Account Actions (Ubah Target Karier & Keluar dari Akun)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0F172A).withValues(alpha: 0.03),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: OutlinedButton.icon(
                      onPressed: widget.onChangeCareer,
                      icon: const Icon(Icons.flag_outlined, size: 18),
                      label: const Text(
                        'Ubah target karier',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13.5,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _ProfileScreenState._brandBlue,
                        side: const BorderSide(color: Color(0xFFBFDBFE)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: OutlinedButton.icon(
                      onPressed: _isLoggingOut ? null : _logout,
                      icon: _isLoggingOut
                          ? const SizedBox.square(
                              dimension: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.logout_rounded, size: 18),
                      label: const Text(
                        'Keluar dari akun',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13.5,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textPrimary,
                        side: const BorderSide(color: Color(0xFFE2E8F0)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
