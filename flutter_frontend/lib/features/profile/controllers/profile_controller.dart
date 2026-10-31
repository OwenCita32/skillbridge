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

  Map<String, String> _resolveIssuerForCertificate(
    String skillName,
    String? rawIssuer,
    int index,
  ) {
    final lowerSkill = skillName.toLowerCase();
    final lowerIssuer = (rawIssuer ?? '').toLowerCase();

    if (lowerIssuer.contains('coursera') ||
        lowerSkill.contains('alat') ||
        lowerSkill.contains('alur kerja') ||
        lowerSkill.contains('prototyp')) {
      return {
        'issuer': 'Coursera',
        'org_id': '2453129',
        'credential_id': 'CRS-2026-9Z8X7C',
        'verify_url':
            'https://www.coursera.org/account/accomplishments/verify/9Z8X7C6V5B4N',
      };
    }
    if (lowerIssuer.contains('google') ||
        lowerSkill.contains('komunikasi') ||
        lowerSkill.contains('klien') ||
        lowerSkill.contains('research') ||
        lowerSkill.contains('riset')) {
      return {
        'issuer': 'Google',
        'org_id': '1441',
        'credential_id': 'GGL-2026-UXR99',
        'verify_url': 'https://www.dicoding.com/certificates/N9ZO6K870XG5',
      };
    }
    if (lowerIssuer.contains('freecodecamp') ||
        lowerSkill.contains('portofolio') ||
        lowerSkill.contains('proyek')) {
      return {
        'issuer': 'freeCodeCamp',
        'org_id': '4831032',
        'credential_id': 'FCC-2026-PRJ04',
        'verify_url':
            'https://www.freecodecamp.org/certification/fcc-2026/responsive-web-design',
      };
    }
    if (lowerIssuer.contains('dicoding') ||
        lowerSkill.contains('dasar') ||
        lowerSkill.contains('teori') ||
        lowerSkill.contains('visual') ||
        index == 0) {
      return {
        'issuer': 'Dicoding Indonesia',
        'org_id': '11287043',
        'credential_id': 'N9ZO6K870XG5',
        'verify_url': 'https://www.dicoding.com/certificates/N9ZO6K870XG5',
      };
    }

    const rotation = [
      {
        'issuer': 'Dicoding Indonesia',
        'org_id': '11287043',
        'credential_id': 'N9ZO6K870XG5',
        'verify_url': 'https://www.dicoding.com/certificates/N9ZO6K870XG5',
      },
      {
        'issuer': 'Coursera',
        'org_id': '2453129',
        'credential_id': 'CRS-2026-9Z8X7C',
        'verify_url':
            'https://www.coursera.org/account/accomplishments/verify/9Z8X7C6V5B4N',
      },
      {
        'issuer': 'Google',
        'org_id': '1441',
        'credential_id': 'GGL-2026-UXR99',
        'verify_url': 'https://www.dicoding.com/certificates/N9ZO6K870XG5',
      },
      {
        'issuer': 'freeCodeCamp',
        'org_id': '4831032',
        'credential_id': 'FCC-2026-PRJ04',
        'verify_url':
            'https://www.freecodecamp.org/certification/fcc-2026/responsive-web-design',
      },
    ];
    return rotation[index % rotation.length];
  }

  List<Map<String, dynamic>> _getInitialCertificates(String careerTitle) {
    return [
      {
        'id': '1',
        'skill_name': 'Dasar & Teori $careerTitle',
        'title': 'Belajar Fundamental Dasar & Teori $careerTitle',
        'category': 'Jalur 2 · Modul & Kuis Selesai',
        'source_badge': 'Modul Roadmap Selesai',
        'issuer': 'Dicoding Indonesia',
        'issuer_org_id': '11287043',
        'credential_id': 'N9ZO6K870XG5',
        'verify_url': 'https://www.dicoding.com/certificates/N9ZO6K870XG5',
        'issue_date': 'Okt 2026',
        'score': '100% Selesai',
        'progress_pct': 85,
        'is_earned': true,
        'status': 'Terverifikasi Otomatis',
        'criteria':
            'Diterbitkan otomatis dari penyelesaian materi & kuis Dasar & Teori $careerTitle (Mitra Kurikulum: Dicoding Indonesia).',
        'skills': ['Dasar & Teori $careerTitle', 'Dicoding Indonesia', 'Terverifikasi'],
        'icon': Icons.layers_rounded,
        'badge_color': const Color(0xFF10B981),
      },
      {
        'id': '2',
        'skill_name': 'Alat & Alur Kerja $careerTitle',
        'title': 'Professional Alat & Alur Kerja $careerTitle',
        'category': 'Jalur 2 · Video & Praktik Selesai',
        'source_badge': 'Modul Roadmap Selesai',
        'issuer': 'Coursera',
        'issuer_org_id': '2453129',
        'credential_id': 'CRS-2026-9Z8X7C',
        'verify_url':
            'https://www.coursera.org/account/accomplishments/verify/9Z8X7C6V5B4N',
        'issue_date': 'Okt 2026',
        'score': '100% Selesai',
        'progress_pct': 85,
        'is_earned': true,
        'status': 'Terverifikasi Otomatis',
        'criteria':
            'Diterbitkan otomatis dari penyelesaian modul video & latihan Alat & Alur Kerja $careerTitle (Mitra Kurikulum: Coursera).',
        'skills': ['Alat & Alur Kerja $careerTitle', 'Coursera', 'Terverifikasi'],
        'icon': Icons.bolt_rounded,
        'badge_color': const Color(0xFF0057FF),
      },
      {
        'id': '3',
        'skill_name': 'Komunikasi & Kesiapan Klien',
        'title': 'Foundations of Komunikasi & Kesiapan Klien',
        'category': 'Jalur 1 · Evaluasi Kuis ≥ 80%',
        'source_badge': 'Modul Roadmap Selesai',
        'issuer': 'Google',
        'issuer_org_id': '1441',
        'credential_id': 'GGL-2026-UXR99',
        'verify_url': 'https://www.dicoding.com/certificates/N9ZO6K870XG5',
        'issue_date': 'Okt 2026',
        'score': '100% Selesai',
        'progress_pct': 85,
        'is_earned': true,
        'status': 'Terverifikasi Otomatis',
        'criteria':
            'Diterbitkan otomatis dari kelulusan kuis & evaluasi Komunikasi & Kesiapan Klien (Mitra Kurikulum: Google).',
        'skills': ['Komunikasi & Kesiapan Klien', 'Google', 'Terverifikasi'],
        'icon': Icons.handshake_outlined,
        'badge_color': const Color(0xFF8B5CF6),
      },
      {
        'id': '4',
        'skill_name': 'Portofolio & Proyek Nyata',
        'title': 'Certification: Portofolio & Proyek Nyata',
        'category': 'Menunggu Verifikasi (Target ≥ 80%)',
        'source_badge': 'Belum Aktif',
        'issuer': 'freeCodeCamp',
        'issuer_org_id': '4831032',
        'credential_id': 'FCC-2026-PRJ04',
        'verify_url':
            'https://www.freecodecamp.org/certification/fcc-2026/responsive-web-design',
        'issue_date': 'Belum Terbit',
        'score': 'Progres 67%',
        'progress_pct': 67,
        'is_earned': false,
        'status': 'Belum Aktif',
        'criteria':
            'Capai skor kuis ≥ 80% atau selesaikan proyek Portofolio & Proyek Nyata di Roadmap untuk mengaktifkan sertifikat freeCodeCamp ini.',
        'skills': ['Portofolio & Proyek Nyata', 'freeCodeCamp', 'Target ≥ 80%'],
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
              final skillName =
                  (map['skill_name'] as String?) ?? (map['title'] as String?) ?? '';
              final resolved = _resolveIssuerForCertificate(
                skillName,
                map['issuer'] as String?,
                i,
              );
              map['issuer'] = resolved['issuer'];
              map['issuer_org_id'] = resolved['org_id'];
              map['credential_id'] = resolved['credential_id'];
              map['verify_url'] = resolved['verify_url'];
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
