import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_frontend/core/network/api_client.dart';
import 'package:flutter_frontend/core/storage/token_storage.dart';

const _runIntegration = bool.fromEnvironment('RUN_API_INTEGRATION_TESTS');
const _apiBaseUrl = String.fromEnvironment(
  'API_TEST_BASE_URL',
  defaultValue: 'http://127.0.0.1:8765/api/v1',
);

void main() {
  test(
    'Flutter API client completes the Laravel career-to-progress flow',
    () async {
      final storage = _MemoryTokenStorage();
      final client = ApiClient(baseUrl: _apiBaseUrl, tokenStorage: storage);

      try {
        final uniqueEmail =
            'flutter-${DateTime.now().microsecondsSinceEpoch}@example.test';
        await client.register(
          name: 'Flutter Integration',
          email: uniqueEmail,
          password: 'integration-password',
        );

        final careers = await client.careers();
        expect(careers, isNotEmpty);
        final careerId = careers.first['id'] as int;
        await client.setCareerGoal(careerId);

        final career = await client.career(careerId);
        final skills = career['skills'] as List<dynamic>;
        expect(skills, isNotEmpty);
        final answers = skills.map((value) {
          final skill = Map<String, dynamic>.from(value as Map);
          return {'skill_id': skill['id'] as int, 'level': 0};
        }).toList();
        await client.submitAssessment(answers);

        final gaps = await client.skillGaps();
        expect(gaps['assessment_id'], isNotNull);
        expect(gaps['skills'].first['current_level'], 0);

        final explanation = await client.explainSkillGaps();
        expect(
          ['openai_responses', 'deterministic_fallback'],
          contains(explanation['explanation_source']),
        );
        if (explanation['explanation_source'] == 'openai_responses') {
          expect(explanation['model'], 'gpt-6-luna');
        }
        expect(explanation['skills'].first['current_level'], 0);

        final resources = await client.resources();
        expect(resources, isNotEmpty);
        final resourceIds = resources
            .map((value) => (value as Map<String, dynamic>)['id'])
            .toSet();
        final roadmap = await client.generateRoadmap();
        expect(
          ['openai_responses', 'deterministic_fallback'],
          contains(roadmap['generation_mode']),
        );
        if (roadmap['generation_mode'] == 'openai_responses') {
          expect(roadmap['generation_model'], 'gpt-6-luna');
        }
        final items = roadmap['items'] as List<dynamic>;
        expect(items, isNotEmpty);
        for (final value in items) {
          final item = Map<String, dynamic>.from(value as Map);
          for (final resourceValue in item['resources'] as List<dynamic>) {
            final resource = Map<String, dynamic>.from(resourceValue as Map);
            expect(resourceIds, contains(resource['id']));
          }
        }

        final firstItem = Map<String, dynamic>.from(items.first as Map);
        await client.updateProgress(
          itemId: firstItem['id'] as int,
          status: 'in_progress',
        );
        final currentRoadmap = await client.currentRoadmap();
        expect(currentRoadmap['items'].first['status'], 'in_progress');

        await client.logout();
        expect(storage.token, isNull);
      } finally {
        client.dispose();
      }
    },
    skip: _runIntegration ? false : 'Run with RUN_API_INTEGRATION_TESTS=true against the local Laravel API.',
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
