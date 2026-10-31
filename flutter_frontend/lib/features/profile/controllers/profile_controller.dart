part of '../profile_screen.dart';

extension _ProfileScreenLogic on _ProfileScreenState {
  Future<void> _refreshProfileAndRepos() async {
    try {
      final freshUser = await widget.apiClient.me();
      if (!mounted) return;
      final rawRepos = freshUser['github_repos'];
      final ghUser = (freshUser['github_username'] as String?)?.trim() ?? '';

      _rebuild(() {
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
          _rebuild(() {
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
        'skill_name': 'Dasar & Teori $careerTitle',
        'title': 'Sertifikat Kompetensi: Dasar & Teori $careerTitle',
        'category': 'Jalur 2 · Modul Portofolio Selesai',
        'source_badge': 'Modul Roadmap Selesai',
        'issuer': 'SkillBridge Assessment & Lab',
        'credential_id': 'SKB-2026-SK-${1000 + idNum}',
        'issue_date': 'Okt 2026',
        'score': '100% Selesai',
        'progress_pct': 85,
        'is_earned': true,
        'status': 'Terverifikasi Otomatis',
        'criteria': 'Diterbitkan karena berhasil menyelesaikan modul pembelajaran & praktik Dasar & Teori $careerTitle pada roadmap.',
        'skills': ['Dasar & Teori $careerTitle', careerTitle, 'Terverifikasi'],
        'icon': Icons.layers_rounded,
        'badge_color': const Color(0xFF10B981),
      },
      {
        'id': '2',
        'skill_name': 'Alat & Alur Kerja $careerTitle',
        'title': 'Sertifikat Kompetensi: Alat & Alur Kerja $careerTitle',
        'category': 'Jalur 2 · Modul Portofolio Selesai',
        'source_badge': 'Modul Roadmap Selesai',
        'issuer': 'SkillBridge Assessment & Lab',
        'credential_id': 'SKB-2026-SK-${2000 + idNum}',
        'issue_date': 'Okt 2026',
        'score': '100% Selesai',
        'progress_pct': 85,
        'is_earned': true,
        'status': 'Terverifikasi Otomatis',
        'criteria': 'Diterbitkan karena berhasil menyelesaikan modul pembelajaran & praktik Alat & Alur Kerja $careerTitle pada roadmap.',
        'skills': ['Alat & Alur Kerja $careerTitle', careerTitle, 'Terverifikasi'],
        'icon': Icons.bolt_rounded,
        'badge_color': const Color(0xFF0057FF),
      },
      {
        'id': '3',
        'skill_name': 'Komunikasi & Kesiapan Klien',
        'title': 'Sertifikat Kompetensi: Komunikasi & Kesiapan Klien',
        'category': 'Jalur 2 · Modul Portofolio Selesai',
        'source_badge': 'Modul Roadmap Selesai',
        'issuer': 'SkillBridge Assessment & Lab',
        'credential_id': 'SKB-2026-SK-${3000 + idNum}',
        'issue_date': 'Okt 2026',
        'score': '100% Selesai',
        'progress_pct': 85,
        'is_earned': true,
        'status': 'Terverifikasi Otomatis',
        'criteria': 'Diterbitkan karena berhasil menyelesaikan modul pembelajaran & praktik Komunikasi & Kesiapan Klien pada roadmap.',
        'skills': ['Komunikasi & Kesiapan Klien', careerTitle, 'Terverifikasi'],
        'icon': Icons.handshake_outlined,
        'badge_color': const Color(0xFF8B5CF6),
      },
      {
        'id': '4',
        'skill_name': 'Portofolio & Proyek Nyata',
        'title': 'Sertifikat Kompetensi: Portofolio & Proyek Nyata',
        'category': 'Menunggu Verifikasi (Target ≥ 80%)',
        'source_badge': 'Belum Aktif',
        'issuer': 'SkillBridge Assessment & Lab',
        'credential_id': 'SKB-2026-SK-${4000 + idNum}',
        'issue_date': 'Belum Terbit',
        'score': 'Progres 67%',
        'progress_pct': 67,
        'is_earned': false,
        'status': 'Belum Aktif',
        'criteria': 'Capai skor evaluasi ≥ 80% atau selesaikan modul Portofolio & Proyek Nyata di Roadmap untuk mengaktifkan sertifikat ini.',
        'skills': ['Portofolio & Proyek Nyata', careerTitle, 'Target ≥ 80%'],
        'icon': Icons.workspace_premium_rounded,
        'badge_color': const Color(0xFFF59E0B),
      },
    ];
  }

  Future<void> _loadCertificates() async {
    try {
      final res = await widget.apiClient.getCertificates();
      final list = res['certificates'] as List<dynamic>?;
      final readiness = (res['readiness_score'] as num?)?.toInt();

      if (mounted) {
        _rebuild(() {
          if (readiness != null && readiness > 0) {
            _readinessScore = readiness;
          }
          if (list != null && list.isNotEmpty) {
            final icons = [
              Icons.workspace_premium_rounded,
              Icons.layers_rounded,
              Icons.bolt_rounded,
              Icons.handshake_outlined,
              Icons.verified_rounded,
            ];
            final colors = [
              const Color(0xFF0057FF),
              const Color(0xFF10B981),
              const Color(0xFF8B5CF6),
              const Color(0xFFF59E0B),
              const Color(0xFF0284C7),
            ];

            int i = 0;
            _certificates = list.map((e) {
              final map = Map<String, dynamic>.from(e as Map);
              final isEarned = map['is_earned'] == true;
              map['icon'] = icons[i % icons.length];
              map['badge_color'] = isEarned
                  ? colors[i % colors.length]
                  : const Color(0xFF94A3B8);
              i++;
              return map;
            }).toList();
          }
        });
      }
    } catch (_) {
      // Fallback tetap digunakan jika API offline
    }
  }

  Future<void> _openCertificationQuiz(String skillName, int currentScore) async {
    final result = await Navigator.of(context).push<int>(
      MaterialPageRoute(
        builder: (_) => QuizIntroScreen(
          skillName: skillName,
          currentScore: currentScore,
        ),
      ),
    );
    if (result != null && mounted) {
      try {
        await widget.apiClient.submitQuizScore(
          scorePercentage: result,
          skillName: skillName,
        );
      } catch (_) {}
      await _loadCertificates();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result >= 80
                  ? '🎉 Selamat! Skor kuis $result% (≥ 80%). Sertifikat "$skillName" telah AKTIF!'
                  : 'Skor kuis $result% disimpan. Capai minimal 80% untuk mengaktifkan sertifikat.',
            ),
            backgroundColor: result >= 80
                ? const Color(0xFF10B981)
                : const Color(0xFF0F172A),
          ),
        );
      }
    }
  }

  Future<void> _logout() async {
    _rebuild(() => _isLoggingOut = true);
    try {
      await widget.apiClient.logout();
    } on ApiException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.message)));
      }
    } finally {
      if (mounted) {
        _rebuild(() => _isLoggingOut = false);
        widget.onLogout();
      }
    }
  }
}
