part of '../profile_screen.dart';

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
