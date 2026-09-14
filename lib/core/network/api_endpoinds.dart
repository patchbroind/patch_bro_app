
/// Centralized API endpoint definitions.
///
/// Keep endpoint paths here instead of scattering strings throughout
/// feature implementations.
///
/// These endpoints are application-level endpoints, not Supabase REST
/// endpoint syntax.
///
/// Example:
///
/// GET    /jobs
/// GET    /jobs/{id}
/// POST   /jobs
///
/// Later our FastAPI/Node.js backend can expose the exact same contract.
abstract final class ApiEndpoints {
  ApiEndpoints._();

  // ================================================================
  // AUTH
  // ================================================================
  //
  // These are reserved for the future custom authentication API.
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

  // ================================================================
  // JOBS
  // ================================================================

  static const jobs = '/jobs';

  static String jobById(String id) => '/jobs/$id';

  // ================================================================
  // EMPLOYER
  // ================================================================

  static const employerProfile = '/employer/profile';

  static const employerHome = '/employer/home';

  static const employerAddresses = '/employer/addresses';

  static String employerAddressById(String id) {
    return '/employer/addresses/$id';
  }

  static const employerBenefits = '/employer/benefits';

  static const employerTrust = '/employer/trust';

  static const employerFavouriteWorkers =
      '/employer/favourite-workers';

  // ================================================================
  // NOTIFICATIONS
  // ================================================================

  static const notifications = '/notifications';
}

