import 'package:flutter/material.dart';

import '../../core/network/api_client.dart';
import 'new_application_screen.dart';

class ApplicationTrackerScreen extends StatefulWidget {
  const ApplicationTrackerScreen({this.apiClient, super.key});

  final ApiClient? apiClient;

  @override
  State<ApplicationTrackerScreen> createState() =>
      _ApplicationTrackerScreenState();
}

class _ApplicationTrackerScreenState extends State<ApplicationTrackerScreen> {
  String _selectedFilter = 'Semua';
  bool _isLoading = false;
  Map<String, dynamic>? _apiSummary;

  // Application state (synced with backend when apiClient is provided)
  late List<ApplicationItem> _applications;

  @override
  void initState() {
    super.initState();
    _applications = _initialDemoList();
    if (widget.apiClient != null) {
      _loadFromApi();
    }
  }

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

  @override
  Widget build(BuildContext context) {
    final total = _applications.length;
    final countMenunggu = _applications.where((a) => a.status == 'Menunggu').length;
    final countInterview = _applications.where((a) => a.status == 'Interview').length;
    final countDiterima = _applications.where((a) => a.status == 'Diterima').length;
    final countDitolak = _applications.where((a) => a.status == 'Ditolak').length;

    final todaySent = _applications.where((a) => a.date == 'Hari ini').length;
    const todayTarget = 5;
    final remaining = (todayTarget - todaySent).clamp(0, todayTarget);

    final filteredList = _selectedFilter == 'Semua'
        ? _applications
        : _applications.where((a) => a.status == _selectedFilter).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Top App Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_rounded, size: 20),
                      color: const Color(0xFF0F172A),
                      padding: EdgeInsets.zero,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Text(
                    'Tracker Lamaran',
                    style: TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
            ),

            // Scrollable Content
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(18, 10, 18, 120),
                children: [
                  // 1. Target Hari Ini Card (Royal Blue)
                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF2563EB), Color(0xFF0057FF)],
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0057FF).withValues(alpha: 0.28),
                          blurRadius: 22,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Target hari ini',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              '$todaySent',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 34,
                                fontWeight: FontWeight.w800,
                                height: 1.0,
                              ),
                            ),
                            Text(
                              ' / $todayTarget',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.85),
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              remaining == 0 ? 'Target tercapai! 🎉' : 'Kurang $remaining lagi',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.90),
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // 5 Segmented Progress Capsules
                        Row(
                          children: List.generate(todayTarget, (index) {
                            final isFilled = index < todaySent;
                            return Expanded(
                              child: Container(
                                height: 8.5,
                                margin: EdgeInsets.only(
                                  right: index == todayTarget - 1 ? 0 : 6,
                                ),
                                decoration: BoxDecoration(
                                  color: isFilled
                                      ? Colors.white
                                      : Colors.white.withValues(alpha: 0.28),
                                  borderRadius: BorderRadius.circular(99),
                                ),
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 2. Ringkasan 12 Lamaran Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0F172A).withValues(alpha: 0.03),
                          blurRadius: 18,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ringkasan $total lamaran',
                          style: const TextStyle(
                            color: Color(0xFF0F172A),
                            fontSize: 15.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Multi-color segmented ratio bar
                        ClipRRect(
                          borderRadius: BorderRadius.circular(99),
                          child: SizedBox(
                            height: 10,
                            child: Row(
                              children: [
                                if (countMenunggu > 0)
                                  Expanded(
                                    flex: countMenunggu,
                                    child: Container(color: const Color(0xFFD97706)),
                                  ),
                                if (countInterview > 0)
                                  Expanded(
                                    flex: countInterview,
                                    child: Container(color: const Color(0xFF0057FF)),
                                  ),
                                if (countDiterima > 0)
                                  Expanded(
                                    flex: countDiterima,
                                    child: Container(color: const Color(0xFF10B981)),
                                  ),
                                if (countDitolak > 0)
                                  Expanded(
                                    flex: countDitolak,
                                    child: Container(color: const Color(0xFF64748B)),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // 4 Stats columns
                        Row(
                          children: [
                            _buildStatCol('$countMenunggu', 'Menunggu', const Color(0xFFD97706)),
                            _buildStatCol('$countInterview', 'Interview', const Color(0xFF0057FF)),
                            _buildStatCol('$countDiterima', 'Diterima', const Color(0xFF10B981)),
                            _buildStatCol('$countDitolak', 'Ditolak', const Color(0xFF64748B)),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // Info callout: Response rate
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Text(
                            'Response rate 50% (6 dari 12 dibalas) · Rata-rata freelancer pemula: 25%',
                            style: TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 12,
                              height: 1.4,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // 3. Filter Chips Row
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip('Semua', 'Semua ($total)'),
                        _buildFilterChip('Menunggu', 'Menunggu ($countMenunggu)'),
                        _buildFilterChip('Interview', 'Interview ($countInterview)'),
                        _buildFilterChip('Diterima', 'Diterima ($countDiterima)'),
                        _buildFilterChip('Ditolak', 'Ditolak ($countDitolak)'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // 4. Application Cards List
                  if (filteredList.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(24),
                      alignment: Alignment.center,
                      child: Text(
                        'Tidak ada lamaran dengan status "$_selectedFilter".',
                        style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                      ),
                    )
                  else
                    ...filteredList.map(
                      (item) => _ApplicationCard(
                        item: item,
                        onStatusChanged: (newStatus) => _changeStatus(item.id, newStatus),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),

      // Bottom Sticky Button: + Catat Lamaran Baru
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withValues(alpha: 0.05),
              blurRadius: 16,
              offset: const Offset(0, -6),
            ),
          ],
        ),
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _openCreateScreen,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0057FF),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_rounded, size: 20),
                SizedBox(width: 6),
                Text(
                  'Catat Lamaran Baru',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCol(String count, String label, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(
            count,
            style: TextStyle(
              color: color,
              fontSize: 19,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String filterKey, String label) {
    final isActive = _selectedFilter == filterKey;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: () => setState(() => _selectedFilter = filterKey),
        borderRadius: BorderRadius.circular(99),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF0F172A) : Colors.white,
            borderRadius: BorderRadius.circular(99),
            border: Border.all(
              color: isActive ? const Color(0xFF0F172A) : const Color(0xFFE2E8F0),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isActive ? Colors.white : const Color(0xFF64748B),
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _ApplicationCard extends StatelessWidget {
  const _ApplicationCard({
    required this.item,
    required this.onStatusChanged,
  });

  final ApplicationItem item;
  final ValueChanged<String> onStatusChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.025),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Square Platform Badge Icon
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: item.badgeColor,
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: Text(
              item.badgeCode,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14.5,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Main Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  '${item.client} · ${item.budget}',
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${item.platform} · ${item.date}',
                  style: const TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Status Badge / Dropdown Picker
          PopupMenuButton<String>(
            initialValue: item.status,
            onSelected: onStatusChanged,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(99),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item.status,
                    style: const TextStyle(
                      color: Color(0xFFD97706),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 3),
                  const Icon(
                    Icons.arrow_drop_down_rounded,
                    color: Color(0xFFD97706),
                    size: 16,
                  ),
                ],
              ),
            ),
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'Menunggu', child: Text('Menunggu')),
              PopupMenuItem(value: 'Interview', child: Text('Interview')),
              PopupMenuItem(value: 'Diterima', child: Text('Diterima')),
              PopupMenuItem(value: 'Ditolak', child: Text('Ditolak')),
            ],
          ),
        ],
      ),
    );
  }
}

class ApplicationItem {
  const ApplicationItem({
    required this.id,
    required this.title,
    required this.client,
    required this.budget,
    required this.platform,
    required this.badgeCode,
    required this.badgeColor,
    required this.date,
    required this.status,
  });

  final int id;
  final String title;
  final String client;
  final String budget;
  final String platform;
  final String badgeCode;
  final Color badgeColor;
  final String date;
  final String status;

  ApplicationItem copyWith({String? status}) {
    return ApplicationItem(
      id: id,
      title: title,
      client: client,
      budget: budget,
      platform: platform,
      badgeCode: badgeCode,
      badgeColor: badgeColor,
      date: date,
      status: status ?? this.status,
    );
  }
}

