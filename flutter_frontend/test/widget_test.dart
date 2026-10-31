import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/testing.dart';

import 'package:flutter_frontend/core/network/api_client.dart';
import 'package:flutter_frontend/core/storage/token_storage.dart';
import 'package:flutter_frontend/features/app/auth_gate.dart';

void main() {
  testWidgets('shows sign-in before a session exists', (tester) async {
    final apiClient = ApiClient(
      httpClient: MockClient(
        (_) async => throw StateError('No request expected'),
      ),
      tokenStorage: _MemoryTokenStorage(),
      baseUrl: 'https://api.example.test/api/v1',
    );

    await tester.pumpWidget(MaterialApp(home: AuthGate(apiClient: apiClient)));
    await tester.pumpAndSettle();

    expect(find.text('Selamat datang kembali'), findsOneWidget);
    expect(find.text('Masuk'), findsOneWidget);
  });

  testWidgets('account creation asks for a name', (tester) async {
    final apiClient = ApiClient(
      httpClient: MockClient(
        (_) async => throw StateError('No request expected'),
      ),
      tokenStorage: _MemoryTokenStorage(),
      baseUrl: 'https://api.example.test/api/v1',
    );

    await tester.pumpWidget(MaterialApp(home: AuthGate(apiClient: apiClient)));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Belum punya akun? Buat akun'));
    await tester.tap(find.text('Belum punya akun? Buat akun'));
    await tester.pumpAndSettle();

    expect(find.text('Buat akun'), findsNWidgets(2));
    expect(find.text('Nama'), findsOneWidget);
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
