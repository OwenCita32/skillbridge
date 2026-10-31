part of '../profile_screen.dart';

extension _ProfilePortfolioModals on _ProfileScreenState {
  // 3. GITHUB IMPORT DIALOG
  void _showGithubImportDialog() {
    final ctrl = TextEditingController(
      text: (_userData['github_username'] as String?) ?? 'rakapratama',
    );
    bool isLoading = false;
    String? error;

    showDialog<void>(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: const Row(
                children: [
                  _GithubOctocatIcon(size: 22, color: Color(0xFF0F172A)),
                  SizedBox(width: 10),
                  Text(
                    'Import GitHub',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Masukkan username GitHub untuk mengimpor repositori publik secara langsung (bebas vendor & gratis):',
                    style: TextStyle(color: Color(0xFF475569), fontSize: 13, height: 1.4),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: ctrl,
                    decoration: InputDecoration(
                      labelText: 'Username GitHub',
                      hintText: 'misal: rakapratama',
                      prefixIcon: const Icon(Icons.person_outline, size: 20),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                      ),
                    ),
                  ),
                  if (error != null) ...[
                    const SizedBox(height: 10),
                    Text(error!, style: const TextStyle(color: Color(0xFFEF4444), fontSize: 12)),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogCtx).pop(),
                  child: const Text('Batal'),
                ),
                FilledButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          final username = ctrl.text.trim();
                          if (username.isEmpty) {
                            setDialogState(() => error = 'Username tidak boleh kosong.');
                            return;
                          }
                          setDialogState(() {
                            isLoading = true;
                            error = null;
                          });

                          try {
                            final res = await widget.apiClient.importGithubRepos(username);
                            final repos = (res['repos'] as List<dynamic>? ?? []);

                            if (mounted) {
                              _rebuild(() {
                                _importedRepos = repos;
                                _userData['github_username'] = username;
                              });
                              Navigator.of(dialogCtx).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Berhasil mengimpor ${repos.length} repositori dari @$username!'),
                                  backgroundColor: const Color(0xFF10B981),
                                ),
                              );
                            }
                          } on ApiException catch (e) {
                            setDialogState(() => error = e.message);
                          } finally {
                            setDialogState(() => isLoading = false);
                          }
                        },
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF0F172A),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text('Sinkronkan'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // 4. LINKEDIN EXPORT MODAL
  void _showLinkedInExportSheet() async {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return FutureBuilder<Map<String, dynamic>>(
          future: widget.apiClient.getLinkedInExport(),
          builder: (context, snapshot) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.85,
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
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
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: const Color(0xFF0A66C2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          'in',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Export ke LinkedIn',
                              style: TextStyle(
                                color: Color(0xFF0F172A),
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              'Integrasi resmi 1-Click tanpa pihak ketiga vendor',
                              style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(sheetContext).pop(),
                        icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                  const Divider(height: 20, color: Color(0xFFE2E8F0)),

                  if (snapshot.connectionState == ConnectionState.waiting)
                    const Expanded(
                      child: Center(
                        child: CircularProgressIndicator(color: Color(0xFF0A66C2)),
                      ),
                    )
                  else if (snapshot.hasError)
                    Expanded(
                      child: Center(
                        child: Text(
                          'Gagal menyiapkan data export: ${snapshot.error}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Color(0xFFEF4444)),
                        ),
                      ),
                    )
                  else ...[
                    Expanded(
                      child: ListView(
                        children: [
                          // Option 1: 1-Click Add Certificate to LinkedIn
                          _buildExportOptionCard(
                            title: '🏅 Tambah Lisensi ke Profil LinkedIn',
                            subtitle:
                                'Membuka form sertifikat LinkedIn dengan nama kompetensi, ID kredensial, & URL verifikasi berlogo SkillBridge terisi otomatis.',
                            buttonText: 'Buka Form LinkedIn (1-Click)',
                            buttonColor: const Color(0xFF0A66C2),
                            onTap: () async {
                              final url = snapshot.data?['add_to_profile_url'] as String? ?? '';
                              final verifyUrl = snapshot.data?['verify_url'] as String? ?? '';
                              if (verifyUrl.isNotEmpty) {
                                Clipboard.setData(ClipboardData(text: verifyUrl));
                              }
                              if (url.isNotEmpty) {
                                await launchUrlString(url, mode: LaunchMode.externalApplication);
                              }
                            },
                          ),
                          const SizedBox(height: 14),

                          // Option 1B: Logo & Media Sertifikat untuk Form LinkedIn
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0F7FF),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: const Color(0xFFBFDBFE)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.network(
                                        (snapshot.data?['logo_url'] as String?) ??
                                            'https://forestgreen-mallard-481065.hostingersite.com/images/skillbridge-logo.jpg',
                                        width: 44,
                                        height: 44,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, _, _) => Container(
                                          width: 44,
                                          height: 44,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF0057FF),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: const Icon(
                                            Icons.verified_rounded,
                                            color: Colors.white,
                                            size: 24,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    const Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '🖼️ Logo & Media Sertifikat LinkedIn',
                                            style: TextStyle(
                                              color: Color(0xFF0F172A),
                                              fontSize: 14,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                          SizedBox(height: 2),
                                          Text(
                                            'Tempelkan tautan ini di bagian "+ Tambahkan media → Tambahkan tautan" pada form sertifikat LinkedIn agar logo SkillBridge tampil.',
                                            style: TextStyle(
                                              color: Color(0xFF475569),
                                              fontSize: 11.5,
                                              height: 1.35,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton.icon(
                                        onPressed: () {
                                          final mediaUrl = (snapshot.data?['verify_url'] as String?) ??
                                              'https://forestgreen-mallard-481065.hostingersite.com/verify/${_userData['id'] ?? 1}';
                                          Clipboard.setData(ClipboardData(text: mediaUrl));
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text('Tautan Media Berlogo SkillBridge disalin! Tempel di "+ Tambahkan media" LinkedIn.'),
                                              backgroundColor: Color(0xFF0A66C2),
                                            ),
                                          );
                                        },
                                        icon: const Icon(Icons.link_rounded, size: 16),
                                        label: const Text(
                                          'Salin Tautan Media',
                                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                                        ),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: const Color(0xFF0A66C2),
                                          side: const BorderSide(color: Color(0xFF93C5FD)),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: FilledButton.icon(
                                        onPressed: () async {
                                          final logoUrl = (snapshot.data?['logo_url'] as String?) ??
                                              'https://forestgreen-mallard-481065.hostingersite.com/images/skillbridge-logo.jpg';
                                          await launchUrlString(logoUrl, mode: LaunchMode.externalApplication);
                                        },
                                        icon: const Icon(Icons.download_rounded, size: 15),
                                        label: const Text(
                                          'Unduh Logo',
                                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                                        ),
                                        style: FilledButton.styleFrom(
                                          backgroundColor: const Color(0xFF0057FF),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),

                          // Option 2: Share Achievement Post to Feed
                          _buildExportOptionCard(
                            title: '📢 Bagikan Portofolio ke Feed LinkedIn',
                            subtitle:
                                'Posting skor kesiapan kerja dan link verifikasi karya ke linimasa profesionalmu.',
                            buttonText: 'Bagikan Postingan',
                            buttonColor: const Color(0xFF0057FF),
                            onTap: () async {
                              final url = snapshot.data?['share_post_url'] as String? ?? '';
                              if (url.isNotEmpty) {
                                await launchUrlString(url, mode: LaunchMode.externalApplication);
                              }
                            },
                          ),
                          const SizedBox(height: 14),

                          // Option 3: Copy Formatted Summary for Profile About/Experience
                          _buildExportOptionCard(
                            title: '📋 Salin Ringkasan Format LinkedIn',
                            subtitle:
                                'Teks siap pakai untuk bagian "About" atau "Projects" di akun LinkedIn-mu.',
                            buttonText: 'Salin Teks ke Clipboard',
                            buttonColor: const Color(0xFF334155),
                            onTap: () {
                              final text = snapshot.data?['formatted_summary'] as String? ?? '';
                              Clipboard.setData(ClipboardData(text: text));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Teks format LinkedIn berhasil disalin ke clipboard!'),
                                  backgroundColor: Color(0xFF10B981),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildExportOptionCard({
    required String title,
    required String subtitle,
    required String buttonText,
    required Color buttonColor,
    required VoidCallback onTap,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 14.5,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(color: Color(0xFF64748B), fontSize: 12.5, height: 1.4),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 42,
            child: FilledButton(
              onPressed: onTap,
              style: FilledButton.styleFrom(
                backgroundColor: buttonColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                buttonText,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 5. PROYEK MODAL (Dinamis dari GitHub Sync)
  void _showProjectsSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        final githubUser = (_userData['github_username'] as String?) ?? 'rakapratama';

        return Container(
          height: MediaQuery.of(context).size.height * 0.85,
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
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
              const SizedBox(height: 14),
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.code_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Proyek Terhubung (${_importedRepos.length})',
                          style: const TextStyle(
                            color: Color(0xFF0F172A),
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          'Repositori GitHub @$githubUser',
                          style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(sheetContext).pop(),
                    icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B)),
                  ),
                ],
              ),
              const Divider(height: 20, color: Color(0xFFE2E8F0)),

              // GitHub sync info banner
              Container(
                padding: const EdgeInsets.all(14),
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFBFDBFE)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.sync_rounded, color: Color(0xFF0057FF), size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Total ${_importedRepos.length} proyek tersinkron dari akun GitHub-mu. Data ini otomatis diperbarui!',
                        style: const TextStyle(
                          color: Color(0xFF1E40AF),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(sheetContext).pop();
                        _showGithubImportDialog();
                      },
                      child: const Text('Sinkronkan', style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
              ),

              // Repositories list
              Expanded(
                child: _importedRepos.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.folder_open_rounded, size: 48, color: Color(0xFF94A3B8)),
                            const SizedBox(height: 8),
                            const Text(
                              'Belum ada repositori yang disinkronkan.',
                              style: TextStyle(color: Color(0xFF64748B)),
                            ),
                            const SizedBox(height: 12),
                            FilledButton(
                              onPressed: () {
                                Navigator.of(sheetContext).pop();
                                _showGithubImportDialog();
                              },
                              style: FilledButton.styleFrom(backgroundColor: const Color(0xFF0F172A)),
                              child: const Text('Sinkronkan Sekarang'),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        itemCount: _importedRepos.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, idx) {
                          final repo = _importedRepos[idx] as Map;
                          final name = repo['name']?.toString() ?? 'Project';
                          final desc = repo['description']?.toString() ?? '-';
                          final lang = repo['language']?.toString() ?? 'Code';
                          final stars = repo['stars'] ?? 0;
                          final url = repo['html_url']?.toString() ?? '';

                          return Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.book_rounded, size: 16, color: Color(0xFF64748B)),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        name,
                                        style: const TextStyle(
                                          color: Color(0xFF0F172A),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFEFF6FF),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        lang,
                                        style: const TextStyle(
                                          color: Color(0xFF0057FF),
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  desc,
                                  style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(Icons.star_rounded, size: 14, color: Color(0xFFF59E0B)),
                                    const SizedBox(width: 3),
                                    Text(
                                      '$stars stars',
                                      style: const TextStyle(color: Color(0xFF64748B), fontSize: 11),
                                    ),
                                    const Spacer(),
                                    if (url.isNotEmpty)
                                      InkWell(
                                        onTap: () => launchUrlString(url, mode: LaunchMode.externalApplication),
                                        child: const Row(
                                          children: [
                                            Text(
                                              'Buka di GitHub',
                                              style: TextStyle(
                                                color: Color(0xFF0057FF),
                                                fontSize: 11.5,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                            SizedBox(width: 3),
                                            Icon(Icons.open_in_new_rounded, size: 12, color: Color(0xFF0057FF)),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
