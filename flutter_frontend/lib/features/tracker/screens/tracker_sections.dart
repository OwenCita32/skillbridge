// ignore_for_file: invalid_use_of_protected_member
part of '../application_tracker_screen.dart';

extension _ApplicationTrackerSections on _ApplicationTrackerScreenState {
  Widget _buildTopAppBar(BuildContext context) {
    return Padding(
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
    );
  }

  Widget _buildTodayTargetCard({
    required int todaySent,
    required int todayTarget,
    required int remaining,
  }) {
    return Container(
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
    );
  }

  Widget _buildSummaryCard({
    required int total,
    required int countMenunggu,
    required int countInterview,
    required int countDiterima,
    required int countDitolak,
  }) {
    return Container(
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
    );
  }

  Widget _buildFilterChipsRow({
    required int total,
    required int countMenunggu,
    required int countInterview,
    required int countDiterima,
    required int countDitolak,
  }) {
    return SingleChildScrollView(
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
    );
  }

  Widget _buildBottomCreateBar() {
    return Container(
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
