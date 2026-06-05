// lib/core/constants/app_constants.dart

class AppConstants {
  AppConstants._();

  // API
  static const String baseUrl = 'https://api.rentstuff.id/api';
  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;

  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String themeKey = 'theme_mode';

  // Pagination
  static const int pageSize = 10;

  // Booking Status
  static const String statusPending = 'pending';
  static const String statusApproved = 'approved';
  static const String statusRejected = 'rejected';
  static const String statusOngoing = 'ongoing';
  static const String statusCompleted = 'completed';
  static const String statusCancelled = 'cancelled';

  // User Roles
  static const String roleBorrower = 'borrower';
  static const String roleLender = 'lender';
  static const String roleAdmin = 'admin';

  // Review Types
  static const String reviewLenderToBorrower = 'lender_to_borrower';
  static const String reviewBorrowerToLender = 'borrower_to_lender';
}
