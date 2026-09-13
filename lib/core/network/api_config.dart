/// Central configuration for the application's HTTP API.
///
/// IMPORTANT:
/// This is intentionally separate from SupabaseConfig.
///
/// SupabaseConfig is used by Supabase Auth and the existing Supabase
/// data sources.
///
/// ApiConfig will be used by Dio-based API communication.
///
/// When we introduce our own backend in the future, the main thing
/// that changes here will be the API_BASE_URL.
abstract final class ApiConfig {
  ApiConfig._();

  /// Base URL for the application's HTTP API.
  ///
  /// For now this can remain empty because we are NOT migrating
  /// the existing Supabase data sources yet.
  ///
  /// When the first Dio-based endpoint is ready, provide:
  ///
  /// --dart-define=API_BASE_URL=https://your-api-url.com
  static const baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );

  /// API version prefix.
  static const apiVersion = '/api/v1';

  /// Whether a Dio API base URL has been configured.
  static bool get isConfigured => baseUrl.isNotEmpty;

  /// Complete API base URL.
  ///
  /// Example:
  /// https://api.patchbro.com/api/v1
  static String get fullBaseUrl {
    if (!isConfigured) {
      return '';
    }

    final normalizedBaseUrl = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;

    return '$normalizedBaseUrl$apiVersion';
  }
}
