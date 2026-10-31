import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../storage/token_storage.dart';

class ApiException implements Exception {
  const ApiException({
    required this.message,
    this.code = 'REQUEST_FAILED',
    this.statusCode,
  });

  final String message;
  final String code;
  final int? statusCode;

  @override
  String toString() => message;
}

class ApiClient {
  ApiClient({
    http.Client? httpClient,
    TokenStorage? tokenStorage,
    String baseUrl = ApiConfig.baseUrl,
  }) : _httpClient = httpClient ?? http.Client(),
       _tokenStorage = tokenStorage ?? SecureTokenStorage(),
       _baseUrl = baseUrl.replaceFirst(RegExp(r'/$'), '');

  final http.Client _httpClient;
  final TokenStorage _tokenStorage;
  final String _baseUrl;
  static const _timeout = Duration(seconds: 20);

  Future<String?> readToken() => _tokenStorage.read();

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await _sendMap(
      'POST',
      '/register',
      body: {
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': password,
      },
    );
    await _saveToken(response['token']);
    return _mapValue(response['user']);
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await _sendMap(
      'POST',
      '/login',
      body: {'email': email, 'password': password},
    );
    await _saveToken(response['token']);
    return _mapValue(response['user']);
  }

  Future<void> logout() async {
    try {
      await _sendMap('POST', '/logout', authenticated: true);
    } finally {
      await _tokenStorage.clear();
    }
  }

  Future<Map<String, dynamic>> me() async {
    final response = await _sendMap('GET', '/me', authenticated: true);
    return _mapValue(response['user']);
  }

  Future<List<dynamic>> careers() async {
    return _listValue(await _send('GET', '/careers'));
  }

  Future<Map<String, dynamic>> career(int careerId) async =>
      _mapValue(await _send('GET', '/careers/$careerId'));

  Future<List<dynamic>> resources({int? skillId}) async {
    final query = skillId == null ? '' : '?skill_id=$skillId';
    return _listValue(await _send('GET', '/resources$query'));
  }

  Future<Map<String, dynamic>> setCareerGoal(int careerId) async {
    final response = await _sendMap(
      'POST',
      '/career-goals',
      authenticated: true,
      body: {'career_id': careerId},
    );
    return _mapValue(response['career']);
  }

  Future<Map<String, dynamic>> skillGaps() =>
      _sendMap('GET', '/skill-gaps', authenticated: true);

  Future<Map<String, dynamic>> explainSkillGaps() =>
      _sendMap('POST', '/skill-gaps/explanation', authenticated: true);

  Future<Map<String, dynamic>> submitAssessment(
    List<Map<String, int>> answers,
  ) => _sendMap(
    'POST',
    '/assessments',
    authenticated: true,
    body: {'answers': answers},
  );

  Future<Map<String, dynamic>> generateRoadmap() =>
      _sendMap('POST', '/roadmaps/generate', authenticated: true);

  Future<Map<String, dynamic>> currentRoadmap() =>
      _sendMap('GET', '/roadmaps/current', authenticated: true);

  Future<Map<String, dynamic>> updateProgress({
    required int itemId,
    required String status,
  }) => _sendMap(
    'PATCH',
    '/roadmap-items/$itemId/progress',
    authenticated: true,
    body: {'status': status},
  );

  Future<void> _saveToken(dynamic token) async {
    if (token is! String || token.isEmpty) {
      throw const ApiException(
        message: 'Server tidak mengembalikan token sesi.',
        code: 'INVALID_AUTH_RESPONSE',
      );
    }
    await _tokenStorage.write(token);
  }

  Future<Map<String, dynamic>> _sendMap(
    String method,
    String path, {
    Map<String, Object?>? body,
    bool authenticated = false,
  }) async => _mapValue(
    await _send(method, path, body: body, authenticated: authenticated),
  );

  Future<dynamic> _send(
    String method,
    String path, {
    Map<String, Object?>? body,
    bool authenticated = false,
  }) async {
    final headers = <String, String>{'Accept': 'application/json'};
    if (body != null) {
      headers['Content-Type'] = 'application/json';
    }
    if (authenticated) {
      final token = await _tokenStorage.read();
      if (token == null || token.isEmpty) {
        throw const ApiException(
          message: 'Sesi berakhir. Silakan masuk kembali.',
          code: 'UNAUTHENTICATED',
          statusCode: 401,
        );
      }
      headers['Authorization'] = 'Bearer $token';
    }

    final request = http.Request(method, Uri.parse('$_baseUrl$path'))
      ..headers.addAll(headers);
    if (body != null) {
      request.body = jsonEncode(body);
    }

    try {
      final streamed = await _httpClient.send(request).timeout(_timeout);
      final response = await http.Response.fromStream(streamed)
          .timeout(_timeout);
      final decoded = response.body.isEmpty
          ? <String, dynamic>{}
          : jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        throw ApiException(
          message: 'Server mengirim respons yang tidak dapat dibaca.',
          code: 'INVALID_RESPONSE',
          statusCode: response.statusCode,
        );
      }
      if (response.statusCode < 200 || response.statusCode >= 300) {
        final error = decoded['error'];
        final validationMessage = decoded['message'];
        final fieldMessage = _firstValidationMessage(decoded['errors']);
        throw ApiException(
          message: error is Map<String, dynamic>
              ? (error['message'] as String? ?? 'Permintaan tidak berhasil.')
              : (fieldMessage ??
                    validationMessage as String? ??
                    'Permintaan tidak berhasil.'),
          code: error is Map<String, dynamic>
              ? (error['code'] as String? ?? 'REQUEST_FAILED')
              : 'VALIDATION_ERROR',
          statusCode: response.statusCode,
        );
      }
      return decoded['data'];
    } on ApiException {
      rethrow;
    } on TimeoutException {
      throw const ApiException(
        message: 'Server terlalu lama merespons. Coba lagi.',
        code: 'REQUEST_TIMEOUT',
      );
    } on http.ClientException {
      throw const ApiException(
        message:
            'Tidak dapat terhubung ke server. Periksa koneksi dan alamat API.',
        code: 'NETWORK_UNAVAILABLE',
      );
    } on FormatException {
      throw const ApiException(
        message: 'Server mengirim respons yang tidak dapat dibaca.',
        code: 'INVALID_RESPONSE',
      );
    }
  }

  Map<String, dynamic> _mapValue(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    throw const ApiException(
      message: 'Server mengirim data dengan format yang tidak sesuai.',
      code: 'INVALID_RESPONSE',
    );
  }

  String? _firstValidationMessage(dynamic errors) {
    if (errors is! Map<String, dynamic>) return null;
    for (final messages in errors.values) {
      if (messages is List<dynamic> &&
          messages.isNotEmpty &&
          messages.first is String) {
        return messages.first as String;
      }
    }
    return null;
  }

  List<dynamic> _listValue(dynamic value) {
    if (value is List<dynamic>) {
      return value;
    }
    throw const ApiException(
      message: 'Server mengirim daftar dengan format yang tidak sesuai.',
      code: 'INVALID_RESPONSE',
    );
  }

  void dispose() => _httpClient.close();
}
