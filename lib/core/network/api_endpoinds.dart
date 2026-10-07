/// Centralized API endpoint definitions.
///
/// Keep endpoint paths here instead of scattering strings throughout
/// feature implementations.
///
/// These are application-level API endpoints.
///
/// The Flutter application should depend only on these contracts,
/// not on Supabase table names, RPC names, or database implementation
/// details.
///
/// The backend can later be replaced with FastAPI / Node.js without
/// changing the feature data sources.
abstract final class ApiEndpoints {
  ApiEndpoints._();

  // ================================================================
  // AUTH
  // ================================================================
  //
  // Reserved for future custom authentication API.
  //
  // DO NOT USE THESE YET.
  //

  static const signIn = '/auth/sign-in';
  static const signUp = '/auth/sign-up';
  static const refreshToken = '/auth/refresh';
  static const signOut = '/auth/sign-out';

  // ================================================================
  // PROFILE
  // ================================================================

  static const profile = '/profile';

  static const profileLocation = '/profile/location';

  static const workerProfileStatus = '/profile/worker-status';

  static const employerProfileStatus = '/profile/employer-status';

  // ================================================================
  // WORKER
  // ================================================================

  static const workerProfile = '/worker/profile';

  // ================================================================
  // JOBS
  // ================================================================

  static const jobs = '/jobs';

  static String jobById(String id) => '/jobs/$id';

  static String jobCancel(String id) => '/employer/jobs/$id/cancel';

  // ================================================================
  // EMPLOYER
  // ================================================================

  static const employerProfile = '/employer/profile';

  static const employerHome = '/employer/home';

  static const employerHomeLocation = '/employer/home/location';

  static const employerJobs = '/employer/jobs';

  static const employerAddresses = '/employer/addresses';

  static String employerAddressById(String id) {
    return '/employer/addresses/$id';
  }

  static const employerBenefits = '/employer/benefits';

  static const employerTrust = '/employer/trust';

  static const employerFavouriteWorkers = '/employer/favourite-workers';

  // ================================================================
  // NOTIFICATIONS
  // ================================================================

  static const notifications = '/notifications';
}
