/// Global constants
class AppConstants {
  AppConstants._();

  // ─── API ───
  static const String apiBaseUrl = 'http://10.0.2.2:8000/api';
  static const String tokenKey = 'auth_token';
  static const String userKey = 'current_user';
  static const String onboardingKey = 'onboarding_complete';

  // ─── Spacing (8pt grid) ───
  static const double spacingXs = 4;
  static const double spacingSm = 8;
  static const double spacingMd = 16;
  static const double spacingLg = 24;
  static const double spacingXl = 32;
  static const double gutter = 16;
  static const double marginMobile = 20;
  static const double marginDesktop = 40;

  // ─── Radius ───
  static const double radiusSm = 4;
  static const double radiusDefault = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 16;
  static const double radiusXl = 24;
  static const double radiusFull = 9999;

  // ─── Shadows ───
  static const double shadowBlurLevel1 = 20;
  static const double shadowBlurLevel2 = 30;
}
