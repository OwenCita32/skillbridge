import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:flutter_frontend/core/network/api_client.dart';
import 'package:flutter_frontend/core/storage/token_storage.dart';

void main() {
  test('stores the login token and sends it as a bearer token', () async {
    final storage = _MemoryTokenStorage();
    final client = ApiClient(
      baseUrl: 'https://api.example.test/api/v1',
      tokenStorage: storage,
      httpClient: MockClient((request) async {
        if (request.url.path.endsWith('/login')) {
          return _jsonResponse({
            'data': {
              'user': {'id': 7, 'name': 'Ayu'},
              'token': 'plain-session-token',
              'token_type': 'Bearer',
            },
            'meta': <String, Object?>{},
            'message': 'Berhasil masuk.',
          });
        }
        expect(request.headers['authorization'], 'Bearer plain-session-token');
        return _jsonResponse({
          'data': {
            'user': {
              'id': 7,
              'name': 'Ayu',
              'career_goal': {
                'career_id': 1,
                'career_title': 'Cybersecurity Analyst',
              },
            },
          },
          'meta': <String, Object?>{},
          'message': 'Profil berhasil dimuat.',
        });
      }),
    );

    final user = await client.login(
      email: 'ayu@example.test',
      password: 'password',
    );
    final restoredUser = await client.me();

    expect(user['name'], 'Ayu');
    expect(storage.token, 'plain-session-token');
    expect(
      restoredUser['career_goal']['career_title'],
      'Cybersecurity Analyst',
    );
    client.dispose();
  });

  test('maps Laravel validation errors to a safe message', () async {
    final client = ApiClient(
      baseUrl: 'https://api.example.test/api/v1',
      tokenStorage: _MemoryTokenStorage(),
      httpClient: MockClient(
        (_) async => _jsonResponse({
          'message': 'The given data was invalid.',
          'errors': {
            'email': ['Gunakan alamat email yang valid.'],
          },
        }, statusCode: 422),
      ),
    );

    await expectLater(
      client.login(email: 'not-an-email', password: 'password'),
      throwsA(
        isA<ApiException>()
            .having((error) => error.statusCode, 'statusCode', 422)
            .having(
              (error) => error.message,
              'message',
              'Gunakan alamat email yang valid.',
            ),
      ),
    );
    client.dispose();
  });

  test('unwraps paginated career catalog collections', () async {
    final client = ApiClient(
      baseUrl: 'https://api.example.test/api/v1',
      tokenStorage: _MemoryTokenStorage(),
      httpClient: MockClient(
        (_) async => _jsonResponse({
          'data': [
            {'id': 1, 'title': 'Cybersecurity Analyst'},
          ],
          'links': <String, Object?>{},
          'meta': <String, Object?>{'current_page': 1},
          'message': 'Daftar karier berhasil dimuat.',
        }),
      ),
    );

    final careers = await client.careers();

    expect(careers, hasLength(1));
    expect(
      (careers.single as Map<String, dynamic>)['title'],
      'Cybersecurity Analyst',
    );
    client.dispose();
  });
}

http.Response _jsonResponse(Map<String, Object?> body, {int statusCode = 200}) {
  return http.Response(
    jsonEncode(body),
    statusCode,
    headers: const {'content-type': 'application/json'},
  );
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
