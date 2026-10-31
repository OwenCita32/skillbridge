part of '../profile_screen.dart';

extension _ProfileEditModals on _ProfileScreenState {
  // 1. EDIT FOTO PROFIL MODAL
  void _showAvatarPickerSheet() {
    final customUrlCtrl = TextEditingController(
      text: (_userData['avatar_url'] as String?) ?? '',
    );
    String selectedUrl = (_userData['avatar_url'] as String?) ?? '';
    final githubUser = (_userData['github_username'] as String?) ?? 'rakapratama';
    final githubAvatarUrl = 'https://github.com/$githubUser.png';

    final presetAvatars = [
      'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200&h=200&fit=crop&crop=faces',
      'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200&h=200&fit=crop&crop=faces',
      'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=200&h=200&fit=crop&crop=faces',
      'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=200&h=200&fit=crop&crop=faces',
      'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200&h=200&fit=crop&crop=faces',
      'https://images.unsplash.com/photo-1522075469751-3a6694fb2f61?w=200&h=200&fit=crop&crop=faces',
    ];

    bool isSaving = false;
    String? error;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setPickerState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.86,
              padding: EdgeInsets.fromLTRB(
                24,
                16,
                24,
                MediaQuery.of(context).viewInsets.bottom + 24,
              ),
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Ubah Foto Profil',
                        style: TextStyle(
                          color: Color(0xFF0F172A),
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(sheetContext).pop(),
                        icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                  const Divider(height: 1, color: Color(0xFFE2E8F0)),
                  const SizedBox(height: 14),

                  if (error != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        error!,
                        style: const TextStyle(color: Color(0xFFEF4444), fontSize: 12.5),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  Expanded(
                    child: ListView(
                      children: [
                        // Option 1: 1-Click Foto GitHub
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: selectedUrl == githubAvatarUrl
                                  ? _ProfileScreenState._brandBlue
                                  : const Color(0xFFE2E8F0),
                              width: selectedUrl == githubAvatarUrl ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  githubAvatarUrl,
                                  width: 48,
                                  height: 48,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    width: 48,
                                    height: 48,
                                    color: const Color(0xFFCBD5E1),
                                    child: const Icon(Icons.code_rounded, color: Colors.white),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Gunakan Foto Profil GitHub',
                                      style: TextStyle(
                                        color: Color(0xFF0F172A),
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    Text(
                                      '@$githubUser',
                                      style: const TextStyle(
                                        color: Color(0xFF64748B),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              OutlinedButton(
                                onPressed: () {
                                  setPickerState(() {
                                    selectedUrl = githubAvatarUrl;
                                    customUrlCtrl.text = githubAvatarUrl;
                                  });
                                },
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: selectedUrl == githubAvatarUrl
                                      ? const Color(0xFFEFF6FF)
                                      : Colors.white,
                                  side: BorderSide(
                                    color: selectedUrl == githubAvatarUrl
                                        ? _ProfileScreenState._brandBlue
                                        : const Color(0xFFCBD5E1),
                                  ),
                                ),
                                child: Text(
                                  selectedUrl == githubAvatarUrl ? 'Dipilih' : 'Pilih',
                                  style: TextStyle(
                                    color: selectedUrl == githubAvatarUrl
                                        ? _ProfileScreenState._brandBlue
                                        : const Color(0xFF334155),
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),

                        // Option 2: Koleksi Avatar Preset
                        const Text(
                          'Pilih Dari Koleksi Profesional:',
                          style: TextStyle(
                            color: Color(0xFF0F172A),
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: presetAvatars.map((url) {
                            final isSel = selectedUrl == url;
                            return InkWell(
                              onTap: () {
                                setPickerState(() {
                                  selectedUrl = url;
                                  customUrlCtrl.text = url;
                                });
                              },
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                width: 70,
                                height: 70,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isSel ? _ProfileScreenState._brandBlue : Colors.transparent,
                                    width: 3,
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(13),
                                  child: Image.network(
                                    url,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const Icon(Icons.person),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 20),

                        // Option 3: Custom URL input
                        const Text(
                          'Atau Masukkan Link Gambar (URL):',
                          style: TextStyle(
                            color: Color(0xFF0F172A),
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: customUrlCtrl,
                          onChanged: (val) {
                            setPickerState(() => selectedUrl = val.trim());
                          },
                          decoration: InputDecoration(
                            hintText: 'https://...',
                            prefixIcon: const Icon(Icons.link_rounded, size: 18),
                            filled: true,
                            fillColor: const Color(0xFFF8FAFC),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                            ),
                            isDense: true,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Save button
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: FilledButton(
                      onPressed: isSaving
                          ? null
                          : () async {
                              final finalUrl = selectedUrl.trim();
                              if (finalUrl.isEmpty) {
                                setPickerState(() => error = 'Pilih avatar atau masukkan link foto.');
                                return;
                              }
                              setPickerState(() {
                                isSaving = true;
                                error = null;
                              });

                              try {
                                final res = await widget.apiClient.updateProfile(
                                  name: _userData['name'] as String? ?? 'Raka Pratama',
                                  avatarUrl: finalUrl,
                                );
                                final updated = res['user'] as Map<String, dynamic>? ?? {};

                                if (mounted) {
                                  _rebuild(() {
                                    _userData = Map<String, dynamic>.from(updated);
                                  });
                                  Navigator.of(sheetContext).pop();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Foto profil berhasil diubah!'),
                                      backgroundColor: Color(0xFF10B981),
                                    ),
                                  );
                                }
                              } on ApiException catch (e) {
                                setPickerState(() => error = e.message);
                              } finally {
                                setPickerState(() => isSaving = false);
                              }
                            },
                      style: FilledButton.styleFrom(
                        backgroundColor: _ProfileScreenState._brandBlue,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : const Text(
                              'Pasang Foto Profil Ini',
                              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14.5),
                            ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // 2. EDIT PROFIL MODAL
  void _showEditProfileSheet() {
    final nameCtrl = TextEditingController(text: _userData['name'] as String? ?? '');
    final headlineCtrl = TextEditingController(
      text: (_userData['headline'] as String?) ?? 'Mahasiswa Informatika · Bandung',
    );
    final githubCtrl = TextEditingController(
      text: (_userData['github_username'] as String?) ?? 'rakapratama',
    );
    final linkedinCtrl = TextEditingController(
      text: (_userData['linkedin_url'] as String?) ?? 'https://linkedin.com/in/raka-pratama',
    );
    final bioCtrl = TextEditingController(text: (_userData['bio'] as String?) ?? '');

    bool isSaving = false;
    String? errorMsg;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final avatarUrl = _userData['avatar_url'] as String?;
            final name = nameCtrl.text.trim().isNotEmpty ? nameCtrl.text.trim() : 'Raka';

            return Container(
              height: MediaQuery.of(context).size.height * 0.88,
              padding: EdgeInsets.fromLTRB(
                24,
                16,
                24,
                MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Edit Profil Pengguna',
                        style: TextStyle(
                          color: Color(0xFF0F172A),
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(sheetContext).pop(),
                        icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                  const Divider(height: 1, color: Color(0xFFE2E8F0)),
                  const SizedBox(height: 14),

                  if (errorMsg != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        errorMsg!,
                        style: const TextStyle(color: Color(0xFFEF4444), fontSize: 12.5),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  Expanded(
                    child: ListView(
                      children: [
                        // Avatar Photo Preview & Change button
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Container(
                                  width: 58,
                                  height: 58,
                                  color: const Color(0xFFEFF6FF),
                                  child: avatarUrl != null && avatarUrl.isNotEmpty
                                      ? Image.network(
                                          avatarUrl,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) => Center(
                                            child: Text(
                                              name[0].toUpperCase(),
                                              style: const TextStyle(
                                                color: _ProfileScreenState._brandBlue,
                                                fontWeight: FontWeight.w800,
                                                fontSize: 22,
                                              ),
                                            ),
                                          ),
                                        )
                                      : Center(
                                          child: Text(
                                            name[0].toUpperCase(),
                                            style: const TextStyle(
                                              color: _ProfileScreenState._brandBlue,
                                              fontWeight: FontWeight.w800,
                                              fontSize: 22,
                                            ),
                                          ),
                                        ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Foto Profil',
                                      style: TextStyle(
                                        color: Color(0xFF0F172A),
                                        fontWeight: FontWeight.w800,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    const Text(
                                      'GitHub, preset avatar, atau URL',
                                      style: TextStyle(
                                        color: Color(0xFF64748B),
                                        fontSize: 11.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              OutlinedButton.icon(
                                onPressed: () {
                                  Navigator.of(sheetContext).pop();
                                  _showAvatarPickerSheet();
                                },
                                icon: const Icon(Icons.photo_camera_outlined, size: 15),
                                label: const Text('Ganti Foto', style: TextStyle(fontSize: 12)),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: _ProfileScreenState._brandBlue,
                                  side: const BorderSide(color: Color(0xFFBFDBFE)),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        _buildInputField(
                          controller: nameCtrl,
                          label: 'Nama Lengkap',
                          hint: 'Nama kamu',
                          icon: Icons.person_outline_rounded,
                        ),
                        const SizedBox(height: 12),
                        _buildInputField(
                          controller: headlineCtrl,
                          label: 'Headline / Status',
                          hint: 'Contoh: Mahasiswa Informatika · Bandung',
                          icon: Icons.badge_outlined,
                        ),
                        const SizedBox(height: 12),
                        _buildInputField(
                          controller: githubCtrl,
                          label: 'Username GitHub',
                          hint: 'Contoh: rakapratama',
                          icon: Icons.code_rounded,
                        ),
                        const SizedBox(height: 12),
                        _buildInputField(
                          controller: linkedinCtrl,
                          label: 'Link Profil LinkedIn',
                          hint: 'https://linkedin.com/in/username',
                          icon: Icons.link_rounded,
                        ),
                        const SizedBox(height: 12),
                        _buildInputField(
                          controller: bioCtrl,
                          label: 'Bio Singkat',
                          hint: 'Ceritakan minat karier dan keahlianmu...',
                          icon: Icons.notes_rounded,
                          maxLines: 3,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: FilledButton(
                      onPressed: isSaving
                          ? null
                          : () async {
                              final name = nameCtrl.text.trim();
                              if (name.isEmpty) {
                                setModalState(() => errorMsg = 'Nama tidak boleh kosong.');
                                return;
                              }
                              setModalState(() {
                                isSaving = true;
                                errorMsg = null;
                              });

                              try {
                                final res = await widget.apiClient.updateProfile(
                                  name: name,
                                  headline: headlineCtrl.text.trim(),
                                  githubUsername: githubCtrl.text.trim(),
                                  linkedinUrl: linkedinCtrl.text.trim(),
                                  bio: bioCtrl.text.trim(),
                                );

                                final updatedUser = res['user'] as Map<String, dynamic>? ?? {};

                                if (mounted) {
                                  _rebuild(() {
                                    _userData = Map<String, dynamic>.from(updatedUser);
                                  });
                                  Navigator.of(sheetContext).pop();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Profil berhasil disimpan!'),
                                      backgroundColor: Color(0xFF10B981),
                                    ),
                                  );
                                }
                              } on ApiException catch (e) {
                                setModalState(() => errorMsg = e.message);
                              } finally {
                                setModalState(() => isSaving = false);
                              }
                            },
                      style: FilledButton.styleFrom(
                        backgroundColor: _ProfileScreenState._brandBlue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : const Text(
                              'Simpan Perubahan',
                              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14.5),
                            ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF334155),
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, size: 18, color: const Color(0xFF64748B)),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
            ),
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        ),
      ],
    );
  }
}
