// ignore_for_file: unused_field
import 'package:flutter/material.dart';

import '../../core/network/api_client.dart';
import 'new_application_screen.dart';

part 'models/application_item.dart';
part 'controllers/tracker_controller.dart';
part 'screens/tracker_sections.dart';
part 'widgets/application_card.dart';

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
            _buildTopAppBar(context),

            // Scrollable Content
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(18, 10, 18, 120),
                children: [
                  // 1. Target Hari Ini Card (Royal Blue)
                  _buildTodayTargetCard(
                    todaySent: todaySent,
                    todayTarget: todayTarget,
                    remaining: remaining,
                  ),
                  const SizedBox(height: 16),

                  // 2. Ringkasan 12 Lamaran Card
                  _buildSummaryCard(
                    total: total,
                    countMenunggu: countMenunggu,
                    countInterview: countInterview,
                    countDiterima: countDiterima,
                    countDitolak: countDitolak,
                  ),
                  const SizedBox(height: 18),

                  // 3. Filter Chips Row
                  _buildFilterChipsRow(
                    total: total,
                    countMenunggu: countMenunggu,
                    countInterview: countInterview,
                    countDiterima: countDiterima,
                    countDitolak: countDitolak,
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
      bottomNavigationBar: _buildBottomCreateBar(),
    );
  }
}
