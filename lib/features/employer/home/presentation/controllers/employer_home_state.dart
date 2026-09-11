import 'package:patch_bro/features/profile/domain/entities/profile_location.dart';

enum EmployerHomeStatus { initial, loading, success, failure }

class EmployerHomeState {
  const EmployerHomeState({
    this.status = EmployerHomeStatus.initial,
    this.name = 'User',
    this.avatarUrl,
    this.location,
    this.searchQuery = '',
    this.currentCarouselIndex = 0,
    this.isUpdatingLocation = false,
    this.locationPromptShown = false,
    this.errorMessage,
  });

  final EmployerHomeStatus status;

  final String name;

  final String? avatarUrl;

  final ProfileLocation? location;

  final String searchQuery;

  final int currentCarouselIndex;

  final bool isUpdatingLocation;

  final bool locationPromptShown;

  final String? errorMessage;

  bool get hasLocation => location != null;

  bool get isLoading => status == EmployerHomeStatus.loading;

  bool get hasError => status == EmployerHomeStatus.failure;

  EmployerHomeState copyWith({
    EmployerHomeStatus? status,
    String? name,
    String? avatarUrl,
    ProfileLocation? location,
    String? searchQuery,
    int? currentCarouselIndex,
    bool? isUpdatingLocation,
    bool? locationPromptShown,
    String? errorMessage,
    bool clearLocation = false,
    bool clearAvatarUrl = false,
    bool clearError = false,
  }) {
    return EmployerHomeState(
      status: status ?? this.status,
      name: name ?? this.name,
      avatarUrl: clearAvatarUrl ? null : avatarUrl ?? this.avatarUrl,
      location: clearLocation ? null : location ?? this.location,
      searchQuery: searchQuery ?? this.searchQuery,
      currentCarouselIndex: currentCarouselIndex ?? this.currentCarouselIndex,
      isUpdatingLocation: isUpdatingLocation ?? this.isUpdatingLocation,
      locationPromptShown: locationPromptShown ?? this.locationPromptShown,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}
