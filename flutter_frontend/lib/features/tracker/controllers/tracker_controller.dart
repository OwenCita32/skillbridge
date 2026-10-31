// ignore_for_file: invalid_use_of_protected_member
part of '../application_tracker_screen.dart';

extension _ApplicationTrackerLogic on _ApplicationTrackerScreenState {
  Future<void> _loadFromApi() async {
    if (widget.apiClient == null) return;
    setState(() => _isLoading = true);
    try {
      final res = await widget.apiClient!.getJobApplications();
      if (!mounted) return;
      final rawList = res['applications'] as List<dynamic>? ?? [];
      final summary = res['summary'] as Map<String, dynamic>?;

      final mapped = rawList.map((item) {
        final m = Map<String, dynamic>.from(item as Map);
        final platform = m['platform'] as String? ?? 'Upwork';
        final (code, color) = _getPlatformBadge(platform);

        return ApplicationItem(
          id: m['id'] as int? ?? DateTime.now().millisecondsSinceEpoch,
          title: m['title'] as String? ?? 'Lamaran',
          client: m['client_name'] as String? ?? 'Klien',
          budget: m['budget'] as String? ?? 'Fleksibel',
          platform: platform,
          badgeCode: code,
          badgeColor: color,
          date: _formatAppliedDate(m['applied_date'] as String?),
          status: m['status'] as String? ?? 'Menunggu',
        );
      }).toList();

      setState(() {
        _applications = mapped;
        _apiSummary = summary;
      });
    } catch (_) {
      // Keep demo list on network failure
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  (String, Color) _getPlatformBadge(String platform) {
    switch (platform) {
      case 'Upwork':
        return ('Up', const Color(0xFF16A34A));
      case 'Fiverr':
        return ('Fv', const Color(0xFF10B981));
      case 'Sribulancer':
        return ('Sr', const Color(0xFFEA580C));
      case 'Projects.co.id':
        return ('Pr', const Color(0xFF2563EB));
      case 'LinkedIn':
        return ('In', const Color(0xFF0A66C2));
      default:
        return ('Ln', const Color(0xFF64748B));
    }
  }

  String _formatAppliedDate(String? raw) {
    if (raw == null) return 'Hari ini';
    final now = DateTime.now();
    final todayStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    if (raw.startsWith(todayStr)) return 'Hari ini';
    return raw;
  }

  List<ApplicationItem> _initialDemoList() {
    return [
      const ApplicationItem(
        id: 1,
        title: 'Redesign landing page kopi',
        client: 'Kopi Senja',
        budget: 'Rp1.500.000',
        platform: 'Sribulancer',
        badgeCode: 'Sr',
        badgeColor: Color(0xFFEA580C),
        date: 'Hari ini',
        status: 'Menunggu',
      ),
      const ApplicationItem(
        id: 2,
        title: 'UI aplikasi kasir UMKM',
        client: 'PT Niaga Kecil',
        budget: 'Rp3.500.000',
        platform: 'Projects.co.id',
        badgeCode: 'Pr',
        badgeColor: Color(0xFF2563EB),
        date: 'Hari ini',
        status: 'Menunggu',
      ),
      const ApplicationItem(
        id: 3,
        title: 'Mobile app booking futsal',
        client: 'Andi S.',
        budget: 'Rp4.200.000',
        platform: 'Upwork',
        badgeCode: 'Up',
        badgeColor: Color(0xFF16A34A),
        date: 'Hari ini',
        status: 'Menunggu',
      ),
      const ApplicationItem(
        id: 4,
        title: 'Dashboard analitik fintech',
        client: 'FinSmart Labs',
        budget: 'Rp6.000.000',
        platform: 'Upwork',
        badgeCode: 'Up',
        badgeColor: Color(0xFF16A34A),
        date: 'Kemarin',
        status: 'Interview',
      ),
      const ApplicationItem(
        id: 5,
        title: 'Design system e-commerce',
        client: 'TokoRetail ID',
        budget: 'Rp5.500.000',
        platform: 'LinkedIn',
        badgeCode: 'In',
        badgeColor: Color(0xFF0A66C2),
        date: '2 hari lalu',
        status: 'Interview',
      ),
      const ApplicationItem(
        id: 6,
        title: 'E-learning micro-learning UI',
        client: 'EduTech Indo',
        budget: 'Rp3.000.000',
        platform: 'Projects.co.id',
        badgeCode: 'Pr',
        badgeColor: Color(0xFF2563EB),
        date: '3 hari lalu',
        status: 'Diterima',
      ),
      const ApplicationItem(
        id: 7,
        title: 'Icon set & banner marketing',
        client: 'Agency Kreatif',
        budget: 'Rp800.000',
        platform: 'Fiverr',
        badgeCode: 'Fv',
        badgeColor: Color(0xFF10B981),
        date: '4 hari lalu',
        status: 'Ditolak',
      ),
      const ApplicationItem(
        id: 8,
        title: 'Website profil arsitek',
        client: 'Studio Rancang',
        budget: 'Rp2.800.000',
        platform: 'Sribulancer',
        badgeCode: 'Sr',
        badgeColor: Color(0xFFEA580C),
        date: '5 hari lalu',
        status: 'Ditolak',
      ),
      const ApplicationItem(
        id: 9,
        title: 'App fitness workout planner',
        client: 'FitLife Global',
        budget: 'Rp4.500.000',
        platform: 'Upwork',
        badgeCode: 'Up',
        badgeColor: Color(0xFF16A34A),
        date: '6 hari lalu',
        status: 'Ditolak',
      ),
      const ApplicationItem(
        id: 10,
        title: 'Revamp website yayasan',
        client: 'Bina Insan',
        budget: 'Rp2.000.000',
        platform: 'Projects.co.id',
        badgeCode: 'Pr',
        badgeColor: Color(0xFF2563EB),
        date: '1 minggu lalu',
        status: 'Menunggu',
      ),
      const ApplicationItem(
        id: 11,
        title: 'SaaS onboarding wireframe',
        client: 'CloudFlow Tech',
        budget: 'Rp3.800.000',
        platform: 'Upwork',
        badgeCode: 'Up',
        badgeColor: Color(0xFF16A34A),
        date: '1 minggu lalu',
        status: 'Menunggu',
      ),
      const ApplicationItem(
        id: 12,
        title: 'Landing page properti luxury',
        client: 'Grand Realty',
        budget: 'Rp2.500.000',
        platform: 'Sribulancer',
        badgeCode: 'Sr',
        badgeColor: Color(0xFFEA580C),
        date: '1 minggu lalu',
        status: 'Menunggu',
      ),
    ];
  }

  void _openCreateScreen() async {
    final result = await Navigator.of(context).push<ApplicationItem>(
      MaterialPageRoute(
        builder: (_) => NewApplicationScreen(
          apiClient: widget.apiClient,
          currentTodayCount: _applications
              .where((item) => item.date == 'Hari ini')
              .length,
        ),
      ),
    );

    if (result != null && mounted) {
      if (widget.apiClient != null) {
        _loadFromApi();
      } else {
        setState(() {
          _applications.insert(0, result);
        });
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lamaran "${result.title}" berhasil dicatat & disimpan!'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _changeStatus(int id, String newStatus) async {
    setState(() {
      final index = _applications.indexWhere((app) => app.id == id);
      if (index >= 0) {
        _applications[index] = _applications[index].copyWith(status: newStatus);
      }
    });

    if (widget.apiClient != null) {
      try {
        await widget.apiClient!.updateJobApplicationStatus(
          id: id,
          status: newStatus,
        );
      } catch (_) {}
    }
  }
}
