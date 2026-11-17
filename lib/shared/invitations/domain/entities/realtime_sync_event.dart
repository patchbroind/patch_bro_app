import 'package:supabase_flutter/supabase_flutter.dart';

class RealtimeSyncEvent {
  const RealtimeSyncEvent._({this.eventType, this.error, this.isConnected = false});

  const RealtimeSyncEvent.change(PostgresChangeEvent eventType)
      : this._(eventType: eventType);
  const RealtimeSyncEvent.connected() : this._(isConnected: true);
  const RealtimeSyncEvent.disconnected() : this._();
  const RealtimeSyncEvent.error(String error) : this._(error: error);

  final PostgresChangeEvent? eventType;
  final String? error;
  final bool isConnected;
}
