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
  static const baseUrl = String.fromEnvironment(
    'API_BASE_URL',
  );

  /// API version prefix.
  static const apiVersion = '';

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
