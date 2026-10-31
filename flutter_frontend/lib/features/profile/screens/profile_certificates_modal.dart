part of '../profile_screen.dart';

extension _ProfileCertificatesModal on _ProfileScreenState {
  // 6. SERTIFIKAT MODAL (Daftar Sertifikat & Asal-Usul 2 Jalur)
  void _showCertificatesSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        final earnedCount = _earnedCertificateCount;
        final totalCount = _certificates.length;
        final pendingCount = totalCount - earnedCount;

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
                          'Sertifikat Kompetensi ($earnedCount/$totalCount Aktif)',
                          style: const TextStyle(
                            color: Color(0xFF0F172A),
                            fontSize: 16.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          'Skill terverifikasi saat ini: $_readinessScore%',
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
              const Divider(height: 18, color: Color(0xFFE2E8F0)),

              // 2-Path Source Explanation Banner
              Container(
                padding: const EdgeInsets.all(14),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFBBF7D0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.verified_outlined,
                          color: Color(0xFF16A34A),
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            '2 Jalur Penerbitan Sertifikat Otomatis:',
                            style: TextStyle(
                              color: Color(0xFF15803D),
                              fontSize: 12.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDCFCE7),
                            borderRadius: BorderRadius.circular(99),
                          ),
                          child: Text(
                            '$earnedCount Aktif • $pendingCount Progres',
                            style: const TextStyle(
                              color: Color(0xFF166534),
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      '1. Evaluasi Gap Skill ≥ 80%: Aktif otomatis saat hasil kuis/evaluasi skill mencapai standar klien (≥ 80%).\n'
                      '2. Modul Portofolio Selesai: Aktif otomatis saat modul belajar & tugas praktik di Roadmap diselesaikan.',
                      style: TextStyle(
                        color: Color(0xFF166534),
                        fontSize: 11.5,
                        height: 1.4,
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
                    final skillName = cert['skill_name'] as String? ?? title;
                    final category = cert['category'] as String? ?? 'Kompetensi';
                    final issuer = cert['issuer'] as String? ?? 'Dicoding Indonesia';
                    final credentialId = cert['credential_id'] as String? ?? 'N9ZO6K870XG5';
                    final verifyUrl = cert['verify_url'] as String? ??
                        'https://www.dicoding.com/certificates/N9ZO6K870XG5';
                    final issueDate = cert['issue_date'] as String? ?? '2026';
                    final score = cert['score'] as String? ?? '85%';
                    final progressPct = (cert['progress_pct'] as num?)?.toInt() ?? 50;
                    final isEarned = cert['is_earned'] == true;
                    final criteria = cert['criteria'] as String? ?? '';
                    final skills = (cert['skills'] as List<dynamic>? ?? []);
                    final badgeColor = isEarned
                        ? (cert['badge_color'] as Color? ?? const Color(0xFF0057FF))
                        : const Color(0xFFF59E0B);
                    final icon = cert['icon'] as IconData? ?? Icons.workspace_premium_rounded;

                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isEarned ? const Color(0xFFF8FAFC) : const Color(0xFFFFFBEB).withValues(alpha: 0.45),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: isEarned ? const Color(0xFFE2E8F0) : const Color(0xFFFDE68A),
                        ),
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
                                child: Icon(
                                  isEarned ? icon : Icons.lock_clock_outlined,
                                  color: badgeColor,
                                  size: 20,
                                ),
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
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.4,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      title,
                                      style: const TextStyle(
                                        color: Color(0xFF0F172A),
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Penerbit Otomatis: $issuer',
                                      style: const TextStyle(
                                        color: Color(0xFF0A66C2),
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: isEarned ? const Color(0xFFECFDF5) : const Color(0xFFFEF3C7),
                                  borderRadius: BorderRadius.circular(99),
                                  border: Border.all(
                                    color: isEarned ? const Color(0xFFA7F3D0) : const Color(0xFFFDE68A),
                                  ),
                                ),
                                child: Text(
                                  isEarned ? '✓ Terverifikasi' : '⏳ Belum Aktif',
                                  style: TextStyle(
                                    color: isEarned ? const Color(0xFF059669) : const Color(0xFFB45309),
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
                          if (!isEarned) ...[
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Progres Evaluasi Saat Ini: $progressPct%',
                                  style: const TextStyle(
                                    color: Color(0xFF92400E),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const Text(
                                  'Target Lulus: ≥ 80%',
                                  style: TextStyle(
                                    color: Color(0xFF0057FF),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 5),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(99),
                              child: LinearProgressIndicator(
                                value: (progressPct / 100.0).clamp(0.0, 1.0),
                                minHeight: 6,
                                backgroundColor: const Color(0xFFE2E8F0),
                                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFF59E0B)),
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
                                isEarned
                                    ? 'Terbit: $issueDate • $score'
                                    : 'Status: $score',
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
                          if (isEarned)
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
                                      _showLinkedInExportSheet(
                                        initialCertName: title,
                                        initialCertId: credentialId,
                                        initialIssuer: issuer,
                                        initialVerifyUrl: verifyUrl,
                                      );
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
                            )
                          else
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton.icon(
                                onPressed: () {
                                  Navigator.of(sheetContext).pop();
                                  _openCertificationQuiz(skillName, progressPct);
                                },
                                icon: const Icon(Icons.quiz_outlined, size: 15),
                                label: const Text(
                                  '⚡ Uji Kuis Sertifikasi (Capai ≥ 80% untuk Aktifkan)',
                                  style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700),
                                ),
                                style: FilledButton.styleFrom(
                                  backgroundColor: const Color(0xFF0057FF),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
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
          ),
        );
      },
    );
  }
}
