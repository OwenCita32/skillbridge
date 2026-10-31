import 'dart:async';
import 'package:flutter/material.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({
    this.skillName = 'UX Research',
    super.key,
  });

  final String skillName;

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentIndex = 0;
  int? _selectedAnswerIndex;
  int _correctCount = 0;
  int _secondsRemaining = 252; // 04:12
  Timer? _timer;

  static const _questions = [
    _Question(
      question:
          'Kamu ingin tahu kenapa pengguna sering meninggalkan halaman checkout. Metode apa yang paling tepat?',
      options: [
        'Survei kepuasan umum',
        'Usability testing pada alur checkout',
        'A/B test warna tombol',
        'Membuat persona baru',
      ],
      correctIndex: 1,
    ),
    _Question(
      question:
          'Kapan waktu terbaik melakukan Exploratory / Discovery Research dalam siklus desain produk?',
      options: [
        'Setelah produk selesai dideploy ke production',
        'Di awal sebelum fitur atau solusi mulai dirancang',
        'Saat membuat wireframe hi-fi terakhir',
        'Hanya saat ada komplain dari pengguna',
      ],
      correctIndex: 1,
    ),
    _Question(
      question:
          'Berapa jumlah partisipan optimal menurut standar Nielsen Norman Group untuk menemukan ~85% masalah usability utama?',
      options: [
        '5 partisipan per iterasi',
        '50 partisipan',
        '100 partisipan',
        'Cukup 1 orang saja',
      ],
      correctIndex: 0,
    ),
    _Question(
      question:
          'Apa perbedaan mendasar antara data Kualitatif vs Kuantitatif dalam riset UX?',
      options: [
        'Kualitatif menjawab "Mengapa", kuantitatif menjawab "Berapa banyak"',
        'Kualitatif menggunakan angka, kuantitatif menggunakan wawancara',
        'Kuantitatif hanya untuk programmer, kualitatif untuk desainer',
        'Tidak ada perbedaan signifikan antara keduanya',
      ],
      correctIndex: 0,
    ),
    _Question(
      question:
          'Metrik apa yang paling umum dipakai untuk mengukur kepuasan alur tugas (Task Success) setelah sesi usability test?',
      options: [
        'System Usability Scale (SUS) & SEQ',
        'Banyaknya baris kode',
        'Jumlah klik mouse total dalam sehari',
        'Ukuran file Figma',
      ],
      correctIndex: 0,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        timer.cancel();
        _showResultDialog();
      }
    });
  }

  String _formatTimer(int totalSeconds) {
    final m = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  void _onOptionSelected(int index) {
    setState(() => _selectedAnswerIndex = index);
  }

  void _next() {
    if (_selectedAnswerIndex == null) return;

    if (_selectedAnswerIndex == _questions[_currentIndex].correctIndex) {
      _correctCount++;
    }

    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedAnswerIndex = null;
      });
    } else {
      _timer?.cancel();
      _showResultDialog();
    }
  }

  void _showResultDialog() {
    final scorePct = ((_correctCount / _questions.length) * 100).round();
    final isPassed = scorePct >= 60;

    showModalBottomSheet<void>(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: isPassed ? const Color(0xFFDCFCE7) : const Color(0xFFFEF3C7),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isPassed ? Icons.check_circle_rounded : Icons.info_outline_rounded,
                    color: isPassed ? const Color(0xFF16A34A) : const Color(0xFFD97706),
                    size: 34,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  isPassed ? 'Kuis Berhasil Diselesaikan!' : 'Kuis Selesai',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Kamu menjawab $_correctCount dari ${_questions.length} soal dengan benar ($scorePct%).\nSkor skill ${widget.skillName} kamu otomatis diperbarui!',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 13.5,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      Navigator.of(context).pop(scorePct);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0057FF),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Kembali & Terapkan Skor',
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentQ = _questions[_currentIndex];
    final totalQ = _questions.length;
    final canProceed = _selectedAnswerIndex != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Top App Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
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
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Soal ${_currentIndex + 1} dari $totalQ',
                          style: const TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'Kuis ${widget.skillName}',
                          style: const TextStyle(
                            color: Color(0xFF0F172A),
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  // Timer badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(99),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.timer_outlined,
                          size: 15,
                          color: Color(0xFF64748B),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          _formatTimer(_secondsRemaining),
                          style: const TextStyle(
                            color: Color(0xFF0F172A),
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Segmented Progress Bar (5 pills)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: List.generate(totalQ, (index) {
                  final isDoneOrCurrent = index <= _currentIndex;
                  return Expanded(
                    child: Container(
                      height: 5,
                      margin: EdgeInsets.only(right: index == totalQ - 1 ? 0 : 6),
                      decoration: BoxDecoration(
                        color: isDoneOrCurrent
                            ? const Color(0xFF0057FF)
                            : const Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 16),

            // Question & Options List
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 6, 20, 120),
                children: [
                  Text(
                    currentQ.question,
                    style: const TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      height: 1.36,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 24),

                  ...List.generate(currentQ.options.length, (optIdx) {
                    final letter = String.fromCharCode(65 + optIdx); // A, B, C, D
                    final isSelected = _selectedAnswerIndex == optIdx;
                    final text = currentQ.options[optIdx];

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: InkWell(
                        onTap: () => _onOptionSelected(optIdx),
                        borderRadius: BorderRadius.circular(18),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFFEFF6FF) : Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFF0057FF)
                                  : const Color(0xFFE2E8F0),
                              width: isSelected ? 1.8 : 1.0,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: isSelected
                                    ? const Color(0xFF0057FF).withValues(alpha: 0.08)
                                    : const Color(0xFF0F172A).withValues(alpha: 0.02),
                                blurRadius: isSelected ? 16 : 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? const Color(0xFF0057FF)
                                      : const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  letter,
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : const Color(0xFF64748B),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Text(
                                  text,
                                  style: TextStyle(
                                    color: isSelected
                                        ? const Color(0xFF0F172A)
                                        : const Color(0xFF334155),
                                    fontSize: 14.5,
                                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                    height: 1.35,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),

      // Bottom Button: Soal Berikutnya / Selesai
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
            onPressed: canProceed ? _next : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0057FF),
              disabledBackgroundColor: const Color(0xFF93C5FD).withValues(alpha: 0.6),
              foregroundColor: Colors.white,
              disabledForegroundColor: Colors.white.withValues(alpha: 0.8),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(
              _currentIndex == totalQ - 1 ? 'Selesai & Lihat Skor' : 'Soal Berikutnya',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Question {
  const _Question({
    required this.question,
    required this.options,
    required this.correctIndex,
  });

  final String question;
  final List<String> options;
  final int correctIndex;
}

