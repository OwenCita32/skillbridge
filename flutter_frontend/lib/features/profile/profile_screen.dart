import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../core/network/api_client.dart';
import '../../core/theme/app_theme.dart';

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
  late Map<String, dynamic> _userData;
  List<dynamic> _importedRepos = [];
  List<Map<String, dynamic>> _certificates = [];
  bool _isLoggingOut = false;
  bool _isSyncingGithub = false;
  bool _linkedInConnected = true;

  static const _brandBlue = Color(0xFF0057FF);

  @override
  void initState() {
    super.initState();
    _userData = Map<String, dynamic>.from(widget.user);
    final rawRepos = _userData['github_repos'];
    if (rawRepos is List && rawRepos.isNotEmpty) {
      _importedRepos = List<dynamic>.from(rawRepos);
    } else {
      // Data repositori awal terkurasi
      _importedRepos = [
        {
          'name': 'design-system-kit',
          'description': 'Reusable UI component library dan token sistem desain.',
          'language': 'TypeScript',
          'stars': 48,
          'html_url': 'https://github.com/rakapratama/design-system-kit',
        },
        {
          'name': 'freelance-marketplace-app',
          'description': 'Aplikasi web interaktif dengan arsitektur REST API & state management.',
          'language': 'Dart',
          'stars': 34,
          'html_url': 'https://github.com/rakapratama/freelance-marketplace-app',
        },
        {
          'name': 'portfolio-showcase-v2',
          'description': 'Website portofolio live dengan optimasi performa.',
          'language': 'Next.js',
          'stars': 19,
          'html_url': 'https://github.com/rakapratama/portfolio-showcase-v2',
        },
      ];
    }

    final careerGoal = _userData['career_goal'] as Map?;
    final rawCareerTitle = (careerGoal?['career_title'] as String?)?.trim() ?? '';
    final careerLabel = rawCareerTitle.isEmpty ? 'UI/UX Designer' : rawCareerTitle;
    _certificates = _getInitialCertificates(careerLabel);
    _loadCertificates();
    _refreshProfileAndRepos();
  }

  Future<void> _refreshProfileAndRepos() async {
    try {
      final freshUser = await widget.apiClient.me();
      if (!mounted) return;
      final rawRepos = freshUser['github_repos'];
      final ghUser = (freshUser['github_username'] as String?)?.trim() ?? '';

      setState(() {
        _userData = Map<String, dynamic>.from(freshUser);
        if (rawRepos is List && rawRepos.isNotEmpty) {
          _importedRepos = List<dynamic>.from(rawRepos);
        }
      });

      // Jika username GitHub sudah terhubung tapi masih memakai batas lama (<= 6),
      // otomatis sinkronkan ulang agar seluruh repositori asli (misal 24 repo) terambil penuh
      if (ghUser.isNotEmpty && _importedRepos.length <= 6) {
        final res = await widget.apiClient.importGithubRepos(ghUser);
        final fullRepos = res['repos'] as List<dynamic>?;
        if (fullRepos != null && fullRepos.isNotEmpty && mounted) {
          setState(() {
            _importedRepos = List<dynamic>.from(fullRepos);
          });
        }
      }
    } catch (_) {
      // Gunakan state lokal jika offline
    }
  }

  List<Map<String, dynamic>> _getInitialCertificates(String careerTitle) {
    final userId = _userData['id']?.toString() ?? '1';
    final idNum = int.tryParse(userId) ?? 1;
    return [
      {
        'id': '1',
        'title': '$careerTitle Job-Ready Certification',
        'category': 'Sertifikasi Kesiapan Kerja',
        'issuer': 'SkillBridge Industry Standard',
        'credential_id': 'SKB-2026-JR-${userId.padLeft(4, '0')}',
        'issue_date': 'Oktober 2026',
        'score': '88%',
        'status': 'Terverifikasi Otomatis',
        'criteria': 'Lulus evaluasi gap kompetensi industri ≥ 80% & siap menangani proyek klien.',
        'skills': ['Standar Klien Terpenuhi', 'Portofolio Terverifikasi', 'Studi Kasus'],
        'icon': Icons.workspace_premium_rounded,
        'badge_color': const Color(0xFF0057FF),
      },
      {
        'id': '2',
        'title': 'Design Tokens & UI Component Architecture',
        'category': 'Spesialisasi Teknis',
        'issuer': 'SkillBridge Tech Benchmark',
        'credential_id': 'SKB-2026-TK-${1000 + idNum}',
        'issue_date': 'Oktober 2026',
        'score': '92%',
        'status': 'Terverifikasi Otomatis',
        'criteria': 'Evaluasi penguasaan tata letak responsif, auto layout, dan sistem token desain modern.',
        'skills': ['Design Systems', 'Auto Layout', 'Figma Variants'],
        'icon': Icons.layers_rounded,
        'badge_color': const Color(0xFF8B5CF6),
      },
      {
        'id': '3',
        'title': 'Interactive Prototyping & Flow Simulation',
        'category': 'Pengujian Praktik',
        'issuer': 'SkillBridge Lab Project',
        'credential_id': 'SKB-2026-PR-${2000 + idNum}',
        'issue_date': 'September 2026',
        'score': '86%',
        'status': 'Terverifikasi Otomatis',
        'criteria': 'Penyelesaian simulasi interaksi antarmuka pengguna untuk serah terima siap developer.',
        'skills': ['Micro-Interactions', 'User Flow', 'Handoff'],
        'icon': Icons.bolt_rounded,
        'badge_color': const Color(0xFF10B981),
      },
      {
        'id': '4',
        'title': 'Freelance Client Scoping & Delivery Standard',
        'category': 'Kesiapan Industri Freelance',
        'issuer': 'SkillBridge Career Bridge',
        'credential_id': 'SKB-2026-FL-${3000 + idNum}',
        'issue_date': 'September 2026',
        'score': '90%',
        'status': 'Terverifikasi Otomatis',
        'criteria': 'Penguasaan negosiasi project brief, estimasi tarif pasar, dan milestone delivery.',
        'skills': ['Project Scoping', 'Pricing Strategy', 'Client Communication'],
        'icon': Icons.handshake_outlined,
        'badge_color': const Color(0xFFF59E0B),
      },
    ];
  }

  Future<void> _loadCertificates() async {
    try {
      final res = await widget.apiClient.getCertificates();
      final list = res['certificates'] as List<dynamic>?;
      if (list != null && list.isNotEmpty && mounted) {
        setState(() {
          _certificates = list.map((e) {
            final map = Map<String, dynamic>.from(e as Map);
            final id = map['id']?.toString() ?? '1';
            if (id == '1') {
              map['icon'] = Icons.workspace_premium_rounded;
              map['badge_color'] = const Color(0xFF0057FF);
            } else if (id == '2') {
              map['icon'] = Icons.layers_rounded;
              map['badge_color'] = const Color(0xFF8B5CF6);
            } else if (id == '3') {
              map['icon'] = Icons.bolt_rounded;
              map['badge_color'] = const Color(0xFF10B981);
            } else {
              map['icon'] = Icons.handshake_outlined;
              map['badge_color'] = const Color(0xFFF59E0B);
            }
            return map;
          }).toList();
        });
      }
    } catch (_) {
      // Fallback tetap digunakan jika API offline
    }
  }

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
                                  ? _brandBlue
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
                                        ? _brandBlue
                                        : const Color(0xFFCBD5E1),
                                  ),
                                ),
                                child: Text(
                                  selectedUrl == githubAvatarUrl ? 'Dipilih' : 'Pilih',
                                  style: TextStyle(
                                    color: selectedUrl == githubAvatarUrl
                                        ? _brandBlue
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
                                    color: isSel ? _brandBlue : Colors.transparent,
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
                                  setState(() {
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
                        backgroundColor: _brandBlue,
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
                                                color: _brandBlue,
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
                                              color: _brandBlue,
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
                                  foregroundColor: _brandBlue,
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
                                  setState(() {
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
                        backgroundColor: _brandBlue,
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
                              setState(() {
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
                                'Membuka form sertifikat LinkedIn dengan nama kompetensi & penerbit SkillBridge terisi otomatis.',
                            buttonText: 'Buka Form LinkedIn (1-Click)',
                            buttonColor: const Color(0xFF0A66C2),
                            onTap: () async {
                              final url = snapshot.data?['add_to_profile_url'] as String? ?? '';
                              if (url.isNotEmpty) {
                                await launchUrlString(url, mode: LaunchMode.externalApplication);
                              }
                            },
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

  // 6. SERTIFIKAT MODAL (Daftar Sertifikat & Asal-Usul)
  void _showCertificatesSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.88,
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
                      gradient: const LinearGradient(
                        colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.workspace_premium_rounded,
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
                          'Sertifikat Kompetensi (${_certificates.length})',
                          style: const TextStyle(
                            color: Color(0xFF0F172A),
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const Text(
                          'Verifikasi resmi standar industri SkillBridge',
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

              // Explanatory Banner: Dari mana sertifikat ini?
              Container(
                padding: const EdgeInsets.all(14),
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFBBF7D0)),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.verified_outlined,
                      color: Color(0xFF16A34A),
                      size: 20,
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Dari mana sertifikat ini diperoleh?',
                            style: TextStyle(
                              color: Color(0xFF15803D),
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          SizedBox(height: 3),
                          Text(
                            'Sertifikat diterbitkan otomatis berbasis bukti kompetensi nyata ketika hasil evaluasimu mencapai standar target industri (skor ≥ 80%) atau setelah menyelesaikan proyek praktik di roadmap.',
                            style: TextStyle(
                              color: Color(0xFF166534),
                              fontSize: 11.5,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Certificate List
              Expanded(
                child: ListView.separated(
                  itemCount: _certificates.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, idx) {
                    final cert = _certificates[idx];
                    final title = cert['title'] as String? ?? 'Sertifikat';
                    final category = cert['category'] as String? ?? 'Kompetensi';
                    final credentialId = cert['credential_id'] as String? ?? 'SKB-2026';
                    final issueDate = cert['issue_date'] as String? ?? '2026';
                    final score = cert['score'] as String? ?? '85%';
                    final criteria = cert['criteria'] as String? ?? '';
                    final skills = (cert['skills'] as List<dynamic>? ?? []);
                    final badgeColor = cert['badge_color'] as Color? ?? const Color(0xFF0057FF);
                    final icon = cert['icon'] as IconData? ?? Icons.workspace_premium_rounded;

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
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: badgeColor.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(icon, color: badgeColor, size: 20),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      category.toUpperCase(),
                                      style: TextStyle(
                                        color: badgeColor,
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      title,
                                      style: const TextStyle(
                                        color: Color(0xFF0F172A),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFECFDF5),
                                  borderRadius: BorderRadius.circular(99),
                                  border: Border.all(color: const Color(0xFFA7F3D0)),
                                ),
                                child: const Text(
                                  '✓ Terverifikasi',
                                  style: TextStyle(
                                    color: Color(0xFF059669),
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (criteria.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              criteria,
                              style: const TextStyle(
                                color: Color(0xFF64748B),
                                fontSize: 11.5,
                                height: 1.35,
                              ),
                            ),
                          ],
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              const Text(
                                'ID: ',
                                style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
                              ),
                              Text(
                                credentialId,
                                style: const TextStyle(
                                  color: Color(0xFF334155),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                'Terbit: $issueDate • Skor $score',
                                style: const TextStyle(
                                  color: Color(0xFF64748B),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          if (skills.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 6,
                              runSpacing: 4,
                              children: skills.map((s) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: const Color(0xFFE2E8F0)),
                                  ),
                                  child: Text(
                                    s.toString(),
                                    style: const TextStyle(
                                      color: Color(0xFF475569),
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    Clipboard.setData(ClipboardData(text: credentialId));
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('ID Kredensial $credentialId disalin!'),
                                        backgroundColor: const Color(0xFF0F172A),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.copy_rounded, size: 14),
                                  label: const Text('Salin ID', style: TextStyle(fontSize: 11.5)),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: const Color(0xFF475569),
                                    side: const BorderSide(color: Color(0xFFCBD5E1)),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: FilledButton.icon(
                                  onPressed: () {
                                    Navigator.of(sheetContext).pop();
                                    _showLinkedInExportSheet();
                                  },
                                  icon: const Icon(Icons.add_task_rounded, size: 14),
                                  label: const Text('Ke LinkedIn', style: TextStyle(fontSize: 11.5)),
                                  style: FilledButton.styleFrom(
                                    backgroundColor: const Color(0xFF0A66C2),
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

  @override
  Widget build(BuildContext context) {
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
              projectCount: _importedRepos.length,
              certificateCount: _certificates.length,
              onTapCareer: widget.onChangeCareer,
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
                        foregroundColor: _brandBlue,
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

class _ProfileHeroCard extends StatelessWidget {
  const _ProfileHeroCard({
    required this.name,
    required this.subtitle,
    this.avatarUrl,
    required this.projectCount,
    required this.certificateCount,
    required this.onTapCareer,
    required this.onEditProfile,
    required this.onEditAvatar,
    required this.onTapProjects,
    required this.onTapCertificates,
  });

  final String name;
  final String subtitle;
  final String? avatarUrl;
  final int projectCount;
  final int certificateCount;
  final VoidCallback onTapCareer;
  final VoidCallback onEditProfile;
  final VoidCallback onEditAvatar;
  final VoidCallback onTapProjects;
  final VoidCallback onTapCertificates;

  static Widget _buildAvatarFallback(String name) {
    final initial = name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : 'R';
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 28,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Royal Blue Banner + Overlapping Avatar Arch
          SizedBox(
            height: 124,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Blue gradient wave banner
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: 92,
                  child: CustomPaint(
                    painter: _ProfileBannerPainter(),
                  ),
                ),
                // Left interactive Avatar Frame with Camera Edit Badge
                Positioned(
                  top: 36,
                  left: 16,
                  child: GestureDetector(
                    onTap: onEditAvatar,
                    child: Stack(
                      children: [
                        Container(
                          width: 82,
                          height: 68,
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(24),
                              topRight: Radius.circular(24),
                              bottomLeft: Radius.circular(16),
                              bottomRight: Radius.circular(16),
                            ),
                            border: Border.all(
                              color: Colors.white,
                              width: 3,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: avatarUrl != null && avatarUrl!.trim().isNotEmpty
                              ? Image.network(
                                  avatarUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => _buildAvatarFallback(name),
                                )
                              : _buildAvatarFallback(name),
                        ),
                        // Mini camera edit icon badge
                        Positioned(
                          right: 2,
                          bottom: 2,
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: const Color(0xFF0057FF),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(
                              Icons.camera_alt_rounded,
                              color: Colors.white,
                              size: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Green verified circle
                Positioned(
                  top: 86,
                  left: 74,
                  child: Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2.5),
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                ),
                // Right pill: Skill terverifikasi 71%
                Positioned(
                  top: 88,
                  right: 18,
                  child: GestureDetector(
                    onTap: onTapCareer,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: const Text(
                        'Skill terverifikasi 71%',
                        style: TextStyle(
                          color: Color(0xFF0057FF),
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        style: const TextStyle(
                          color: Color(0xFF0F172A),
                          fontSize: 21,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.4,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: onEditProfile,
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFBFDBFE)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.edit_outlined, size: 14, color: Color(0xFF0057FF)),
                            SizedBox(width: 4),
                            Text(
                              'Edit Profil',
                              style: TextStyle(
                                color: Color(0xFF0057FF),
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 16),

                // Stats container: X Proyek (GitHub) | Y Sertifikat
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: onTapProjects,
                          borderRadius: BorderRadius.circular(14),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      '$projectCount',
                                      style: const TextStyle(
                                        color: Color(0xFF0F172A),
                                        fontSize: 20,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    const Icon(
                                      Icons.arrow_forward_ios_rounded,
                                      size: 10,
                                      color: Color(0xFF94A3B8),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                const Text(
                                  'Proyek',
                                  style: TextStyle(
                                    color: Color(0xFF64748B),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 36,
                        color: const Color(0xFFE2E8F0),
                      ),
                      Expanded(
                        child: InkWell(
                          onTap: onTapCertificates,
                          borderRadius: BorderRadius.circular(14),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      '$certificateCount',
                                      style: const TextStyle(
                                        color: Color(0xFF0F172A),
                                        fontSize: 20,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    const Icon(
                                      Icons.arrow_forward_ios_rounded,
                                      size: 10,
                                      color: Color(0xFF94A3B8),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                const Text(
                                  'Sertifikat',
                                  style: TextStyle(
                                    color: Color(0xFF64748B),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
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
        ],
      ),
    );
  }
}

class _ProfileBannerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF0057FF), Color(0xFF2563EB)],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, bgPaint);

    final wavePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.14)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;

    final path1 = Path()
      ..moveTo(0, size.height * 0.65)
      ..quadraticBezierTo(
        size.width * 0.45,
        size.height * 0.35,
        size.width,
        size.height * 0.78,
      );
    canvas.drawPath(path1, wavePaint);

    final path2 = Path()
      ..moveTo(0, size.height * 0.85)
      ..quadraticBezierTo(
        size.width * 0.55,
        size.height * 0.55,
        size.width,
        size.height * 0.92,
      );
    canvas.drawPath(path2, wavePaint);

    canvas.drawCircle(
      Offset(size.width * 0.88, size.height * 0.2),
      48,
      wavePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _GithubConnectCard extends StatelessWidget {
  const _GithubConnectCard({
    required this.username,
    required this.repoCount,
    required this.isSyncing,
    required this.onSync,
  });

  final String username;
  final int repoCount;
  final bool isSyncing;
  final VoidCallback onSync;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: const _GithubOctocatIcon(size: 22, color: Colors.white),
              ),
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFF10B981),
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Text(
            'GitHub',
            style: TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 15.5,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            '@$username · $repoCount repo',
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 36,
            child: TextButton(
              onPressed: isSyncing ? null : onSync,
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFFF1F5F9),
                foregroundColor: const Color(0xFF0F172A),
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(11),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.refresh_rounded, size: 15),
                  const SizedBox(width: 5),
                  Text(
                    isSyncing ? 'Sinkron...' : 'Sinkron ulang',
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LinkedInConnectCard extends StatelessWidget {
  const _LinkedInConnectCard({
    required this.isConnected,
    required this.onTap,
  });

  final bool isConnected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF0A66C2),
                  borderRadius: BorderRadius.circular(12),
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
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: isConnected
                      ? const Color(0xFF10B981)
                      : const Color(0xFFCBD5E1),
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Text(
            'LinkedIn',
            style: TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 15.5,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 3),
          const Text(
            'Export 1-Click Profil',
            style: TextStyle(
              color: Color(0xFF64748B),
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 36,
            child: ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0057FF),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(11),
                ),
              ),
              child: const Text(
                'Hubungkan & Export',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ImportedGithubCard extends StatelessWidget {
  const _ImportedGithubCard({
    required this.repos,
    required this.onTapSync,
    required this.onTapViewAll,
  });

  final List<dynamic> repos;
  final VoidCallback onTapSync;
  final VoidCallback onTapViewAll;

  static const _contribShades = [
    Color(0xFF065F46),
    Color(0xFF10B981),
    Color(0xFF059669),
    Color(0xFF1E293B),
    Color(0xFF10B981),
    Color(0xFF34D399),
    Color(0xFF059669),
    Color(0xFF064E3B),
    Color(0xFF10B981),
    Color(0xFF1E293B),
    Color(0xFF059669),
    Color(0xFF34D399),
    Color(0xFF10B981),
    Color(0xFF065F46),
    Color(0xFF059669),
    Color(0xFF10B981),
    Color(0xFF1E293B),
    Color(0xFF065F46),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.18),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const _GithubOctocatIcon(size: 18, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Diimport dari GitHub (${repos.length} Repo)',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              InkWell(
                onTap: onTapSync,
                child: const Row(
                  children: [
                    Icon(Icons.sync_rounded, color: Color(0xFF38BDF8), size: 14),
                    SizedBox(width: 4),
                    Text(
                      'Ubah / Sinkron',
                      style: TextStyle(
                        color: Color(0xFF38BDF8),
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...repos.take(4).map(
            (item) {
              final repo = Map<String, dynamic>.from(item as Map);
              final name = repo['name'] as String? ?? 'Repo';
              final lang = repo['language'] as String? ?? 'Code';
              final stars = repo['stars'] ?? 0;
              final url = repo['html_url'] as String? ?? '';

              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: InkWell(
                  onTap: url.isNotEmpty
                      ? () => launchUrlString(url, mode: LaunchMode.externalApplication)
                      : null,
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: const Color(0xFF334155).withValues(alpha: 0.65),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          alignment: Alignment.center,
                          child: const Text(
                            '<>',
                            style: TextStyle(
                              color: Color(0xFFCBD5E1),
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '$lang · ★ $stars',
                                style: const TextStyle(
                                  color: Color(0xFF94A3B8),
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF064E3B),
                            borderRadius: BorderRadius.circular(99),
                          ),
                          child: const Text(
                            'Bukti skill',
                            style: TextStyle(
                              color: Color(0xFF34D399),
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          if (repos.length > 4) ...[
            const SizedBox(height: 2),
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: onTapViewAll,
                icon: const Icon(Icons.list_alt_rounded, size: 15, color: Color(0xFF38BDF8)),
                label: Text(
                  'Lihat semua ${repos.length} repositori GitHub →',
                  style: const TextStyle(
                    color: Color(0xFF38BDF8),
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: 6),
          // Contribution heatmap squares strip
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _contribShades
                .map(
                  (color) => Container(
                    width: 11,
                    height: 11,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(2.5),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _GithubOctocatIcon extends StatelessWidget {
  const _GithubOctocatIcon({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Icon(Icons.code_rounded, size: size, color: color);
  }
}
