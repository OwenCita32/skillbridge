import 'dart:async';
import 'package:flutter/material.dart';

part 'models/quiz_question.dart';
part 'controllers/quiz_controller.dart';
part 'screens/quiz_views.dart';

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
  void setState(VoidCallback fn) {
    super.setState(fn);
  }

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
            _buildTopAppBar(context, totalQ),

            // Segmented Progress Bar (5 pills)
            _buildProgressBar(totalQ),
            const SizedBox(height: 16),

            // Question & Options List
            Expanded(
              child: _buildQuestionAndOptionsList(currentQ),
            ),
          ],
        ),
      ),

      // Bottom Button: Soal Berikutnya / Selesai
      bottomNavigationBar: _buildBottomButton(canProceed, totalQ),
    );
  }
}
