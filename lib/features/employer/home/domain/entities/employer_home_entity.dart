import 'package:patch_bro/features/profile/domain/entities/profile_location.dart';

class EmployerHomeEntity {
  const EmployerHomeEntity({required this.name, this.avatarUrl, this.location});

  final String name;
  final String? avatarUrl;
  final ProfileLocation? location;

  bool get hasLocation => location != null;
}
