import 'package:supabase_flutter/supabase_flutter.dart' hide AuthUser;

import '../../domain/entities/auth_user.dart';

class AuthUserModel {
  const AuthUserModel({
    required this.id,
    this.phone,
    this.email,
  });

  final String id;
  final String? phone;
  final String? email;

  factory AuthUserModel.fromSupabaseUser(User user) {
    final metadata = user.userMetadata;

    final metadataEmail = metadata?['email'] as String?;

    return AuthUserModel(
      id: user.id,
      phone: user.phone,
      email: user.email ?? metadataEmail,
    );
  }

  AuthUser toEntity() {
    return AuthUser(
      id: id,
      phone: phone,
      email: email,
    );
  }
}