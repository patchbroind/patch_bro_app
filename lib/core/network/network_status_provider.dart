import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

/// The app only considers the device online when it can reach the internet.
/// This avoids treating a connected, but unusable, Wi-Fi network as online.
enum NetworkConnectionStatus { online, offline }

final internetConnectionProvider = Provider<InternetConnection>((ref) {
  return InternetConnection();
});

/// Emits an initial reachability result before listening for subsequent
/// connection changes, so app startup can be gated reliably.
final networkConnectionStatusProvider = StreamProvider<NetworkConnectionStatus>(
  (ref) async* {
    final connection = ref.watch(internetConnectionProvider);

    final hasInternetAccess = await connection.hasInternetAccess;
    yield hasInternetAccess
        ? NetworkConnectionStatus.online
        : NetworkConnectionStatus.offline;

    yield* connection.onStatusChange.map((status) {
      return status == InternetStatus.connected
          ? NetworkConnectionStatus.online
          : NetworkConnectionStatus.offline;
    });
  },
);
