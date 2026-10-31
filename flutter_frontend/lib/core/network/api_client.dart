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

  Future<Map<String, dynamic>> setCareerGoal([
    int? careerId,
    String? careerTitle,
  ]) async {
    final body = <String, dynamic>{};
    if (careerId != null) {
      body['career_id'] = careerId;
    }
    if (careerTitle != null && careerTitle.trim().isNotEmpty) {
      body['career_title'] = careerTitle.trim();
    }
    final response = await _sendMap(
      'POST',
      '/career-goals',
      authenticated: true,
      body: body,
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

  // Job Tracker
  Future<Map<String, dynamic>> getJobApplications({String? status}) {
    final query = (status != null && status != 'Semua') ? '?status=$status' : '';
    return _sendMap('GET', '/job-applications$query', authenticated: true);
  }

  Future<Map<String, dynamic>> createJobApplication({
    required String title,
    String? clientName,
    required String platform,
    String? budget,
    String? status,
    String? notes,
  }) => _sendMap(
    'POST',
    '/job-applications',
    authenticated: true,
    body: {
      'title': title,
      if (clientName != null) 'client_name': clientName,
      'platform': platform,
      if (budget != null) 'budget': budget,
      if (status != null) 'status': status,
      if (notes != null) 'notes': notes,
    },
  );

  Future<Map<String, dynamic>> updateJobApplicationStatus({
    required int id,
    required String status,
  }) => _sendMap(
    'PATCH',
    '/job-applications/$id/status',
    authenticated: true,
    body: {'status': status},
  );

  Future<Map<String, dynamic>> deleteJobApplication(int id) =>
      _sendMap('DELETE', '/job-applications/$id', authenticated: true);

  // Portfolio practice task submission
  Future<Map<String, dynamic>> submitPortfolioTask({
    required String title,
    String? submissionLink,
    List<String>? checklistCompleted,
    int? roadmapItemId,
  }) => _sendMap(
    'POST',
    '/portfolio-submissions',
    authenticated: true,
    body: {
      'title': title,
      if (submissionLink != null) 'submission_link': submissionLink,
      if (checklistCompleted != null) 'checklist_completed': checklistCompleted,
      if (roadmapItemId != null) 'roadmap_item_id': roadmapItemId,
    },
  );

  // Quiz submission & auto skill-gap update
  Future<Map<String, dynamic>> submitQuizScore({
    required int scorePercentage,
    String? skillName,
    int? skillId,
    int? correctCount,
    int? totalQuestions,
  }) => _sendMap(
    'POST',
    '/quizzes/submit',
    authenticated: true,
    body: {
      'score_percentage': scorePercentage,
      if (skillName != null) 'skill_name': skillName,
      if (skillId != null) 'skill_id': skillId,
      if (correctCount != null) 'correct_count': correctCount,
      if (totalQuestions != null) 'total_questions': totalQuestions,
    },
  );

  Future<Map<String, dynamic>> askAiMentor({
    required String message,
    List<Map<String, String>> history = const [],
  }) => _sendMap(
    'POST',
    '/mentor/chat',
    authenticated: true,
    body: {
      'message': message,
      if (history.isNotEmpty) 'history': history,
    },
  );

  // Profile update & integration
  Future<Map<String, dynamic>> updateProfile({
    required String name,
    String? headline,
    String? bio,
    String? githubUsername,
    String? linkedinUrl,
    String? avatarUrl,
  }) => _sendMap(
    'PATCH',
    '/profile',
    authenticated: true,
    body: {
      'name': name,
      if (headline != null) 'headline': headline,
      if (bio != null) 'bio': bio,
      if (githubUsername != null) 'github_username': githubUsername,
      if (linkedinUrl != null) 'linkedin_url': linkedinUrl,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
    },
  );

  Future<Map<String, dynamic>> importGithubRepos(String username) => _sendMap(
    'POST',
    '/profile/github-import',
    authenticated: true,
    body: {'username': username},
  );

  Future<Map<String, dynamic>> getLinkedInExport() =>
      _sendMap('GET', '/profile/linkedin-export', authenticated: true);

  Future<Map<String, dynamic>> getCertificates() =>
      _sendMap('GET', '/profile/certificates', authenticated: true);

  // In-App Notifications
  Future<Map<String, dynamic>> getNotifications() =>
      _sendMap('GET', '/notifications', authenticated: true);

  Future<Map<String, dynamic>> markNotificationAsRead(int id) =>
      _sendMap('PATCH', '/notifications/$id/read', authenticated: true);

  Future<Map<String, dynamic>> markAllNotificationsAsRead() =>
      _sendMap('POST', '/notifications/read-all', authenticated: true);

  Future<Map<String, dynamic>> deleteNotification(int id) =>
      _sendMap('DELETE', '/notifications/$id', authenticated: true);

  // Forgot password without SMTP / vendor
  Future<Map<String, dynamic>> requestPasswordReset(String email) => _sendMap(
    'POST',
    '/forgot-password',
    body: {'email': email},
  );

  Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String resetCode,
    required String password,
    required String passwordConfirmation,
  }) => _sendMap(
    'POST',
    '/reset-password',
    body: {
      'email': email,
      'reset_code': resetCode,
      'password': password,
      'password_confirmation': passwordConfirmation,
    },
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
