part of '../roadmap_screen.dart';

class _AiLearningResourcesSheet extends StatefulWidget {
  const _AiLearningResourcesSheet({
    required this.apiClient,
    required this.stageTitle,
    required this.careerTitle,
  });

  final ApiClient apiClient;
  final String stageTitle;
  final String careerTitle;

  @override
  State<_AiLearningResourcesSheet> createState() =>
      _AiLearningResourcesSheetState();
}

class _AiLearningResourcesSheetState extends State<_AiLearningResourcesSheet> {
  bool _isLoading = true;
  String? _error;
  List<Map<String, dynamic>> _recommendations = [];

  @override
  void initState() {
    super.initState();
    _fetchAiResources();
  }

  Future<void> _fetchAiResources() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final prompt =
        'Saya sedang mempelajari topik "${widget.stageTitle}" untuk karier "${widget.careerTitle}".\n'
        'Tolong carikan dan rekomendasikan 4 materi/video/referensi belajar terbaik di internet '
        '(seperti dari YouTube, Medium, dokumentasi resmi, atau platform terpercaya).\n'
        'Jawab secara terstruktur dengan format teks yang jelas, sebutkan:\n'
        '1. Judul materi\n'
        '2. Platform/Sumber (YouTube, Figma, Coursera, dll)\n'
        '3. Kenapa ini penting untuk dipelajari\n'
        '4. Kata kunci pencarian cepat';

    try {
      final res = await widget.apiClient
          .askAiMentor(message: prompt)
          .timeout(const Duration(seconds: 12));

      final reply = res['reply'] as String? ?? '';
      if (mounted) {
        setState(() {
          _recommendations = _parseAiReply(reply);
          _isLoading = false;
        });
      }
    } catch (_) {
      // Fallback rekomendasi cerdas otomatis jika jaringan offline/timeout
      if (mounted) {
        setState(() {
          _recommendations = _getCuratedFallback(widget.stageTitle);
          _isLoading = false;
        });
      }
    }
  }

  List<Map<String, dynamic>> _parseAiReply(String reply) {
    if (reply.trim().isEmpty) return _getCuratedFallback(widget.stageTitle);

    return [
      {
        'title': 'Rekomendasi Terkurasi AI: ${widget.stageTitle}',
        'source': 'OpenAI Live Mentor',
        'type': 'Panduan & Referensi',
        'desc': reply,
        'search_query': '${widget.stageTitle} ${widget.careerTitle} tutorial',
      },
      ..._getCuratedFallback(widget.stageTitle).take(3),
    ];
  }

  List<Map<String, dynamic>> _getCuratedFallback(String title) {
    return [
      {
        'title': 'Tutorial Praktis Terlengkap $title',
        'source': 'YouTube',
        'type': 'Video Interaktif',
        'desc':
            'Panduan langkah-demi-langkah dari praktisi industri dengan studi kasus siap pakai.',
        'search_query': 'Tutorial $title ${widget.careerTitle}',
      },
      {
        'title': 'Dokumentasi & Best Practice Resmi $title',
        'source': 'Official Guide / Docs',
        'type': 'Artikel & Guideline',
        'desc':
            'Standar baku, tips efisiensi alur kerja, dan shortcut kerja komersial.',
        'search_query': 'Best practice $title standard',
      },
      {
        'title': 'Studi Kasus Portofolio Siap Klien',
        'source': 'Medium & Behance',
        'type': 'Bedah Kasus Nyata',
        'desc':
            'Contoh nyata bagaimana $title diterapkan pada proyek freelance nyata.',
        'search_query': '$title case study freelance portfolio',
      },
    ];
  }

  Future<void> _openSearch(String query) async {
    final encoded = Uri.encodeComponent(query);
    final url = Uri.parse('https://www.google.com/search?q=$encoded');
    await launchUrl(url, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      padding: const EdgeInsets.fromLTRB(22, 16, 22, 24),
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
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: Color(0xFF0057FF),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Rekomendasi Materi AI Live',
                      style: TextStyle(
                        color: Color(0xFF0F172A),
                        fontSize: 16.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      'Pencarian materi & referensi: ${widget.stageTitle}',
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B)),
              ),
            ],
          ),
          const Divider(height: 20, color: Color(0xFFE2E8F0)),
          if (_isLoading)
            const Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Color(0xFF0057FF)),
                    SizedBox(height: 14),
                    Text(
                      'AI sedang mencari referensi materi terbaik...',
                      style: TextStyle(
                        color: Color(0xFF0F172A),
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Menganalisis kebutuhan materi di internet & YouTube',
                      style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
                    ),
                  ],
                ),
              ),
            )
          else ...[
            Expanded(
              child: ListView.separated(
                itemCount: _recommendations.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, idx) {
                  final item = _recommendations[idx];
                  final title = item['title'] as String? ?? 'Materi Belajar';
                  final source = item['source'] as String? ?? 'Online';
                  final type = item['type'] as String? ?? 'Tutorial';
                  final desc = item['desc'] as String? ?? '';
                  final searchQuery = item['search_query'] as String? ?? title;

                  return Container(
                    padding: const EdgeInsets.all(16),
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
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEFF6FF),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                source,
                                style: const TextStyle(
                                  color: Color(0xFF0057FF),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              type,
                              style: const TextStyle(
                                color: Color(0xFF64748B),
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          title,
                          style: const TextStyle(
                            color: Color(0xFF0F172A),
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          desc,
                          style: const TextStyle(
                            color: Color(0xFF475569),
                            fontSize: 12.5,
                            height: 1.45,
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () => _openSearch(searchQuery),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF0057FF),
                              side: const BorderSide(color: Color(0xFFBFDBFE)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            icon: const Icon(Icons.search_rounded, size: 16),
                            label: const Text(
                              'Cari & Buka Materi Langsung',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}

