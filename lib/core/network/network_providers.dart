import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'api_client.dart';

/// Shared Dio-based API client.
///
/// This is a singleton within the Riverpod container.
///
/// Every feature that needs the HTTP API should obtain ApiClient
/// through this provider.
///
/// Do NOT create a new Dio instance inside individual features.
final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});
