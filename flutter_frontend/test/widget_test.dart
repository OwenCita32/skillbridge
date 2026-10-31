import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:flutter_frontend/core/network/api_client.dart';
import 'package:flutter_frontend/core/storage/token_storage.dart';
import 'package:flutter_frontend/features/app/auth_gate.dart';
import 'package:flutter_frontend/features/navigation/app_shell.dart';
import 'package:flutter_frontend/features/onboarding/splash_screen.dart';
import 'package:flutter_frontend/features/profile/profile_screen.dart';
import 'package:flutter_frontend/features/quiz/quiz_intro_screen.dart';
import 'package:flutter_frontend/features/roadmap/article_lesson_screen.dart';
import 'package:flutter_frontend/features/roadmap/practice_task_screen.dart';
import 'package:flutter_frontend/features/roadmap/video_lesson_screen.dart';
import 'package:flutter_frontend/features/tracker/application_tracker_screen.dart';

void main() {
  testWidgets('renders splash screen with brand identity and tagline', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: SplashScreen(enableLoopingAnimation: false)),
    );

    expect(find.text('SkillBridge'), findsOneWidget);
    expect(find.text('Jembatan menuju karier impianmu'), findsOneWidget);
  });

  testWidgets(
    'completes onboarding slides, role/level personalization, and AI processing into sign-in',
    (tester) async {
      final apiClient = ApiClient(
        httpClient: MockClient(
          (_) async => throw StateError('No request expected'),
        ),
        tokenStorage: _MemoryTokenStorage(),
        baseUrl: 'https://api.example.test/api/v1',
      );

      await tester.pumpWidget(
        MaterialApp(home: AuthGate(apiClient: apiClient)),
      );
      await tester.pumpAndSettle();

      // Slide 1
      expect(find.text('LANGKAH PERTAMA'), findsOneWidget);
      expect(find.text('Tentukan'), findsOneWidget);
      expect(find.text('Target Kariermu'), findsOneWidget);
      expect(find.text('Jalur freelance dipilih'), findsOneWidget);

      // Advance to Slide 2
      await tester.tap(find.bySemanticsLabel('Selanjutnya'));
      await tester.pumpAndSettle();

      expect(find.text('DIDUKUNG AI'), findsOneWidget);
      expect(find.text('Analisis Skill &'), findsOneWidget);
      expect(find.text('Roadmap Cerdas'), findsOneWidget);
      expect(find.text('72%'), findsOneWidget);

      // Advance to Slide 3
      await tester.tap(find.bySemanticsLabel('Selanjutnya'));
      await tester.pumpAndSettle();

      expect(find.text('SIAP DILIRIK KLIEN'), findsOneWidget);
      expect(find.text('Bangun Portofolio'), findsOneWidget);
      expect(find.text('& Mulai Melamar'), findsOneWidget);
      expect(find.text('Level 2 Unlocked'), findsOneWidget);
      expect(find.text('Dibagikan ke LinkedIn'), findsOneWidget);

      // Tap "Mulai Perjalananmu" -> Personalization Step 1/2
      await tester.tap(find.text('Mulai Perjalananmu'));
      await tester.pumpAndSettle();

      expect(find.text('1/2'), findsOneWidget);
      expect(find.text('UI/UX Designer'), findsOneWidget);
      expect(find.text('Data Analyst'), findsOneWidget);

      // Tap "Lanjutkan" -> Personalization Step 2/2
      await tester.tap(find.text('Lanjutkan'));
      await tester.pumpAndSettle();

      expect(find.text('2/2'), findsOneWidget);
      expect(find.text('Bidang: UI/UX Designer'), findsOneWidget);
      expect(find.text('Pemula'), findsOneWidget);
      expect(find.text('Menengah'), findsOneWidget);
      expect(find.text('Mahir'), findsOneWidget);

      // Tap "Lanjutkan" -> AI Processing -> AuthScreen
      await tester.tap(find.text('Lanjutkan'));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Skill gap'), findsOneWidget);
      expect(find.text('Roadmap'), findsOneWidget);
      expect(find.text('Target lamaran'), findsOneWidget);

      await tester.pumpAndSettle(const Duration(milliseconds: 600));

      expect(find.text('Selamat datang kembali'), findsOneWidget);
      expect(find.text('Masuk'), findsOneWidget);
    },
  );

  testWidgets('account creation asks for a name', (tester) async {
    final apiClient = ApiClient(
      httpClient: MockClient(
        (_) async => throw StateError('No request expected'),
      ),
      tokenStorage: _MemoryTokenStorage(),
      baseUrl: 'https://api.example.test/api/v1',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: AuthGate(apiClient: apiClient, showOnboardingInitially: false),
      ),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Belum punya akun? Buat akun'));
    await tester.tap(find.text('Belum punya akun? Buat akun'));
    await tester.pumpAndSettle();

    expect(find.text('Buat akun'), findsNWidgets(2));
    expect(find.text('Nama'), findsOneWidget);
  });

  testWidgets('renders Beranda, Roadmap, and Profil tabs in AppShell', (
    tester,
  ) async {
    final apiClient = ApiClient(
      httpClient: MockClient((request) async {
        if (request.url.path.endsWith('/skill-gaps')) {
          return http.Response(
            jsonEncode({
              'data': {
                'career_goal': {
                  'career_title': 'Freelance UI/UX Designer',
                  'readiness_percent': 71,
                },
                'gaps': [],
                'roadmap_summary': {'total_items': 4, 'completed_items': 1},
              },
            }),
            200,
          );
        }
        if (request.url.path.endsWith('/roadmaps/current')) {
          return http.Response(
            jsonEncode({'message': 'Not found'}),
            404,
          );
        }
        return http.Response(jsonEncode({'data': {}}), 200);
      }),
      tokenStorage: _MemoryTokenStorage(),
      baseUrl: 'https://api.example.test/api/v1',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: AppShell(
          apiClient: apiClient,
          user: const {
            'name': 'Raka Pratama',
            'email': 'raka@example.test',
            'career_goal': {'career_title': 'Freelance UI/UX Designer'},
          },
          onLogout: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Beranda
    expect(find.text('Raka Pratama'), findsOneWidget);
    expect(find.text('AI Skill Gap Analysis'), findsOneWidget);
    expect(find.text('Tracker Lamaran'), findsOneWidget);

    // Switch to Roadmap tab
    await tester.tap(find.text('Roadmap'));
    await tester.pumpAndSettle();
    expect(find.text('ROADMAP PERSONAL'), findsOneWidget);
    expect(find.text('Dasar Desain Visual'), findsOneWidget);
    expect(find.text('Prototyping Interaktif'), findsOneWidget);

    // Switch to Profil tab
    await tester.tap(find.text('Profil'));
    await tester.pumpAndSettle();
    expect(find.text('Skill terverifikasi 71%'), findsOneWidget);
    expect(find.text('Akun Terhubung'), findsOneWidget);
    expect(find.text('Diimport dari GitHub'), findsOneWidget);
  });

  testWidgets('renders tracker lamaran and opens catat lamaran baru screen', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: ApplicationTrackerScreen()),
    );
    await tester.pumpAndSettle();

    expect(find.text('Tracker Lamaran'), findsWidgets);
    expect(find.text('Target hari ini'), findsOneWidget);
    expect(find.text('Ringkasan 12 lamaran'), findsOneWidget);
    expect(find.text('Catat Lamaran Baru'), findsOneWidget);

    await tester.tap(find.text('Catat Lamaran Baru'));
    await tester.pumpAndSettle();

    expect(find.text('Platform'), findsOneWidget);
    expect(find.text('Judul proyek *'), findsOneWidget);
    expect(find.text('Simpan Lamaran'), findsOneWidget);
  });

  testWidgets('renders quiz intro screen and navigates to quiz questions', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: QuizIntroScreen()),
    );
    await tester.pumpAndSettle();

    expect(find.text('Kuis UX Research'), findsOneWidget);
    expect(find.text('Tes Dasar\nUX Research'), findsOneWidget);
    expect(find.text('Mulai Kuis'), findsOneWidget);

    await tester.tap(find.text('Mulai Kuis'));
    await tester.pumpAndSettle();

    expect(find.text('Soal 1 dari 5'), findsOneWidget);
    expect(find.textContaining('checkout'), findsOneWidget);
    expect(find.text('Soal Berikutnya'), findsOneWidget);
  });

  testWidgets('renders video lesson screen with topics and completes', (tester) async {
    bool completed = false;
    await tester.pumpWidget(
      MaterialApp(
        home: VideoLessonScreen(onCompleted: () => completed = true),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Tonton: Figma Auto Layout'), findsOneWidget);
    expect(find.text('Video'), findsOneWidget);
    expect(find.text('Yang akan kamu pelajari'), findsOneWidget);
    expect(find.text('Konsep frame & auto layout'), findsOneWidget);

    await tester.tap(find.text('Tandai Sudah Ditonton'));
    await tester.pumpAndSettle();
    expect(completed, isTrue);
  });

  testWidgets('renders practice task screen and submits', (tester) async {
    bool submitted = false;
    await tester.pumpWidget(
      MaterialApp(
        home: PracticeTaskScreen(onCompleted: () => submitted = true),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Update case study portofolio'), findsOneWidget);
    expect(find.text('Praktik'), findsOneWidget);
    expect(find.text('Brief tugas'), findsOneWidget);
    expect(find.text('Langkah-langkah'), findsOneWidget);
    expect(find.text('Tulis latar belakang masalah'), findsOneWidget);

    // Tap checkbox
    await tester.tap(find.text('Tulis latar belakang masalah'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Kirim Hasil Praktik'));
    await tester.pumpAndSettle();
    expect(submitted, isTrue);
  });

  testWidgets('renders article lesson screen with formula box and finishes', (tester) async {
    bool finished = false;
    await tester.pumpWidget(
      MaterialApp(
        home: ArticleLessonScreen(onCompleted: () => finished = true),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Baca artikel pricing freelance'), findsOneWidget);
    expect(find.text('Bacaan'), findsOneWidget);
    expect(find.text('Cara Menentukan Harga Jasa Desain Pertamamu'), findsOneWidget);
    expect(find.textContaining('Rumus sederhana'), findsOneWidget);

    await tester.tap(find.text('Selesai Membaca'));
    await tester.pumpAndSettle();
    expect(finished, isTrue);
  });

  testWidgets('renders profile screen with edit profile, github import, and linkedin export', (tester) async {
    final apiClient = ApiClient(
      httpClient: MockClient((_) async => throw StateError('No request expected')),
      tokenStorage: _MemoryTokenStorage(),
      baseUrl: 'https://api.example.test/api/v1',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: ProfileScreen(
          apiClient: apiClient,
          user: const {
            'id': 1,
            'name': 'Raka Pratama',
            'email': 'raka@example.com',
            'headline': 'Mahasiswa Informatika · Bandung',
            'github_username': 'rakapratama',
            'career_goal': {
              'career_title': 'Web Developer',
            },
          },
          onChangeCareer: () {},
          onLogout: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Raka Pratama'), findsOneWidget);
    expect(find.text('Edit Profil'), findsOneWidget);
    expect(find.text('Akun Terhubung'), findsOneWidget);
    expect(find.text('GitHub'), findsOneWidget);
    expect(find.text('LinkedIn'), findsOneWidget);
    expect(find.text('Diimport dari GitHub'), findsOneWidget);
  });
}

class _MemoryTokenStorage implements TokenStorage {
  String? token;

  @override
  Future<void> clear() async => token = null;

  @override
  Future<String?> read() async => token;

  @override
  Future<void> write(String value) async => token = value;
}
