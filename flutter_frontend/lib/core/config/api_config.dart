const String apiBaseUrl =
    'https://forestgreen-mallard-481065.hostingersite.com/api/v1';

class ApiConfig {
  static const baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: apiBaseUrl,
  );
}
