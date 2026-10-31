part of '../roadmap_screen.dart';

class _TimelineStageRow extends StatelessWidget {
  const _TimelineStageRow({
    required this.stage,
    required this.stepNumber,
    required this.isExpanded,
    required this.isLast,
    required this.onToggle,
    required this.onContinueLearning,
    required this.onUpdateStatus,
    required this.onOpenResource,
  });

  final _StageViewModel stage;
  final int stepNumber;
  final bool isExpanded;
  final bool isLast;
  final VoidCallback onToggle;
  final VoidCallback onContinueLearning;
  final ValueChanged<String>? onUpdateStatus;
  final ValueChanged<Map<String, dynamic>> onOpenResource;

  static const _brandBlue = Color(0xFF0057FF);

  @override
  Widget build(BuildContext context) {
    final isActiveCard = stage.state == _TimelineNodeState.active || isExpanded;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Left timeline column
          SizedBox(
            width: 44,
            child: Column(
              children: [
                const SizedBox(height: 18),
                _buildNodeIndicator(),
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    color: const Color(0xFFE2E8F0),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          // Right stage card
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 6 : 16),
              child: GestureDetector(
                onTap: onToggle,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  padding: const EdgeInsets.fromLTRB(18, 16, 16, 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: isActiveCard
                          ? const Color(0xFF93C5FD)
                          : const Color(0xFFF1F5F9),
                      width: isActiveCard ? 1.8 : 1.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isActiveCard
                            ? _brandBlue.withValues(alpha: 0.08)
                            : const Color(0xFF0F172A).withValues(alpha: 0.03),
                        blurRadius: isActiveCard ? 24 : 14,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  stage.stageLabel,
                                  style: const TextStyle(
                                    color: Color(0xFF94A3B8),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  stage.title,
                                  style: TextStyle(
                                    color: stage.state ==
                                            _TimelineNodeState.locked
                                        ? const Color(0xFF64748B)
                                        : const Color(0xFF0F172A),
                                    fontSize: 16.5,
                                    fontWeight: FontWeight.w800,
                                    height: 1.25,
                                    letterSpacing: -0.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          _buildStatusPill(stage),
                          const SizedBox(width: 8),
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Icon(
                              isExpanded
                                  ? Icons.keyboard_arrow_up_rounded
                                  : Icons.keyboard_arrow_down_rounded,
                              color: const Color(0xFF64748B),
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                      if (isExpanded) ...[
                        const SizedBox(height: 14),
                        Text(
                          stage.description,
                          style: const TextStyle(
                            color: Color(0xFF475569),
                            fontSize: 13.5,
                            height: 1.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 14),
                        RichText(
                          text: TextSpan(
                            style: const TextStyle(
                              fontSize: 12.5,
                              color: Color(0xFF94A3B8),
                              fontWeight: FontWeight.w500,
                            ),
                            children: [
                              const TextSpan(text: 'Sumber: '),
                              TextSpan(
                                text: stage.sourceName,
                                style: const TextStyle(
                                  color: Color(0xFF334155),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              TextSpan(text: ' · ${stage.sourceType}'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(99),
                          child: LinearProgressIndicator(
                            value: stage.progressValue > 0
                                ? stage.progressValue
                                : 0.6,
                            minHeight: 6,
                            backgroundColor: const Color(0xFFF1F5F9),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              _brandBlue,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: onContinueLearning,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _brandBlue,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.play_arrow_outlined, size: 20),
                                SizedBox(width: 6),
                                Text(
                                  'Lanjut Belajar',
                                  style: TextStyle(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            _buildQuickChip(
                              context: context,
                              label: 'Video',
                              icon: Icons.play_circle_outline_rounded,
                              color: const Color(0xFF0057FF),
                              bgColor: const Color(0xFFEFF6FF),
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const VideoLessonScreen(),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            _buildQuickChip(
                              context: context,
                              label: 'Praktik',
                              icon: Icons.assignment_outlined,
                              color: const Color(0xFF059669),
                              bgColor: const Color(0xFFECFDF5),
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const PracticeTaskScreen(),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            _buildQuickChip(
                              context: context,
                              label: 'Bacaan',
                              icon: Icons.menu_book_rounded,
                              color: const Color(0xFFD97706),
                              bgColor: const Color(0xFFFEF3C7),
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const ArticleLessonScreen(),
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (stage.backendItem != null &&
                            onUpdateStatus != null) ...[
                          const SizedBox(height: 12),
                          _BackendStageControls(
                            item: stage.backendItem!,
                            onStatusChanged: onUpdateStatus!,
                            onOpenResource: onOpenResource,
                          ),
                        ],
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNodeIndicator() {
    switch (stage.state) {
      case _TimelineNodeState.completed:
        return Container(
          width: 34,
          height: 34,
          decoration: const BoxDecoration(
            color: _brandBlue,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_rounded,
            color: Colors.white,
            size: 18,
          ),
        );
      case _TimelineNodeState.active:
        return Container(
          width: 42,
          height: 42,
          padding: const EdgeInsets.all(4),
          decoration: const BoxDecoration(
            color: Color(0xFFDBEAFE),
            shape: BoxShape.circle,
          ),
          child: Container(
            decoration: const BoxDecoration(
              color: _brandBlue,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              '$stepNumber',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        );
      case _TimelineNodeState.upcoming:
        return Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFFCBD5E1),
              width: 1.6,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            '$stepNumber',
            style: const TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        );
      case _TimelineNodeState.locked:
        return Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFFE2E8F0),
              width: 1.6,
            ),
          ),
          child: const Icon(
            Icons.lock_outline_rounded,
            color: Color(0xFF94A3B8),
            size: 16,
          ),
        );
    }
  }

  Widget _buildStatusPill(_StageViewModel stage) {
    late final Color bgColor;
    late final Color textColor;

    switch (stage.state) {
      case _TimelineNodeState.completed:
        bgColor = const Color(0xFFDCFCE7);
        textColor = const Color(0xFF16A34A);
      case _TimelineNodeState.active:
        bgColor = const Color(0xFFEFF6FF);
        textColor = _brandBlue;
      case _TimelineNodeState.upcoming:
      case _TimelineNodeState.locked:
        bgColor = const Color(0xFFF1F5F9);
        textColor = const Color(0xFF64748B);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        stage.badgeText,
        style: TextStyle(
          color: textColor,
          fontSize: 11.5,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _buildQuickChip({
    required BuildContext context,
    required String label,
    required IconData icon,
    required Color color,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BackendStageControls extends StatelessWidget {
  const _BackendStageControls({
    required this.item,
    required this.onStatusChanged,
    required this.onOpenResource,
  });

  final Map<String, dynamic> item;
  final ValueChanged<String> onStatusChanged;
  final ValueChanged<Map<String, dynamic>> onOpenResource;

  static const _statuses = <String, String>{
    'not_started': 'Belum dimulai',
    'in_progress': 'Sedang dipelajari',
    'completed': 'Selesai',
    'skipped': 'Dilewati',
  };

  @override
  Widget build(BuildContext context) {
    final status = item['status'] as String? ?? 'not_started';
    final resources = (item['resources'] as List<dynamic>? ?? [])
        .map((value) => Map<String, dynamic>.from(value as Map))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (resources.isNotEmpty) ...[
          const Divider(height: 18, color: Color(0xFFF1F5F9)),
          ...resources.map(
            (resource) => InkWell(
              onTap: () => onOpenResource(resource),
              borderRadius: BorderRadius.circular(10),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    const Icon(
                      Icons.open_in_new_rounded,
                      size: 16,
                      color: Color(0xFF0057FF),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        resource['title'] as String? ?? 'Buka materi',
                        style: const TextStyle(
                          color: Color(0xFF0F172A),
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
        const SizedBox(height: 6),
        Row(
          children: [
            const Text(
              'Status:',
              style: TextStyle(
                color: Color(0xFF64748B),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _statuses.containsKey(status) ? status : 'not_started',
                  isDense: true,
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                  ),
                  items: _statuses.entries
                      .map(
                        (entry) => DropdownMenuItem<String>(
                          value: entry.key,
                          child: Text(entry.value),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null && value != status) {
                      onStatusChanged(value);
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
