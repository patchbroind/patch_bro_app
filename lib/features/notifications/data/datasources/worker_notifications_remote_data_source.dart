import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/worker_notification_entity.dart';

class WorkerNotificationModel {
  const WorkerNotificationModel({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.data,
    required this.createdAt,
    this.readAt,
  });

  final String id;
  final String type;
  final String title;
  final String message;
  final Map<String, dynamic> data;
  final DateTime createdAt;
  final DateTime? readAt;

  factory WorkerNotificationModel.fromMap(
    Map<String, dynamic> map,
  ) {
    return WorkerNotificationModel(
      id: map['id']?.toString() ?? '',
      type: map['type']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      message: map['message']?.toString() ?? '',
      data: map['data'] is Map
          ? Map<String, dynamic>.from(map['data'] as Map)
          : const {},
      createdAt:
          DateTime.tryParse(
            map['created_at']?.toString() ?? '',
          )?.toLocal() ??
          DateTime.now(),
      readAt: map['read_at'] == null
          ? null
          : DateTime.tryParse(
              map['read_at'].toString(),
            )?.toLocal(),
    );
  }

  WorkerNotificationEntity toEntity() {
    return WorkerNotificationEntity(
      id: id,
      type: type,
      title: title,
      message: message,
      data: data,
      createdAt: createdAt,
      readAt: readAt,
    );
  }
}

class WorkerNotificationsRemoteDataSource {
  WorkerNotificationsRemoteDataSource(
    this._supabase,
  );

  final SupabaseClient _supabase;

  Future<List<WorkerNotificationModel>> getNotifications() async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      throw const AuthException(
        'No authenticated user found.',
      );
    }

    final response = await _supabase
        .from('notifications')
        .select()
        .eq('user_id', user.id)
        .order(
          'created_at',
          ascending: false,
        );

    return response
        .map(
          (item) => WorkerNotificationModel.fromMap(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList(growable: false);
  }

  Future<void> markAsRead(String notificationId) async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      throw const AuthException(
        'No authenticated user found.',
      );
    }

    await _supabase
        .from('notifications')
        .update({
          'read_at': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('id', notificationId)
        .eq('user_id', user.id);
  }

  Future<void> markAllAsRead() async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      throw const AuthException(
        'No authenticated user found.',
      );
    }

    await _supabase
        .from('notifications')
        .update({
          'read_at': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('user_id', user.id)
        .isFilter('read_at', null);
  }

  Stream<void> watchNotifications() {
    final controller = StreamController<void>.broadcast();

    final user = _supabase.auth.currentUser;

    if (user == null) {
      controller.close();
      return controller.stream;
    }

    final channel = _supabase.channel(
      'worker-notifications-${user.id}',
    );

    channel.onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: 'notifications',
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'user_id',
        value: user.id,
      ),
      callback: (_) {
        if (!controller.isClosed) {
          controller.add(null);
        }
      },
    );

    channel.subscribe();

    controller.onCancel = () async {
      await _supabase.removeChannel(channel);
    };

    return controller.stream;
  }
}