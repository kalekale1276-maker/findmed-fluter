class AppConstants {
  static const String appName = 'FindMed';
  static const String appVersion = '1.0.0';
}

class ApiConstants {
  static const String baseUrl = 'https://api.findmed.com';
  static const String loginEndpoint = '/auth/login';
  static const String registerEndpoint = '/auth/register';
  static const String userProfileEndpoint = '/user/profile';
  static const String facilitiesEndpoint = '/facilities';
  static const String appointmentsEndpoint = '/appointments';
}

class StorageConstants {
  static const String authToken = 'auth_token';
  static const String refreshToken = 'refresh_token';
  static const String userProfile = 'user_profile';
  static const String isFirstLaunch = 'is_first_launch';
  static const String themeMode = 'theme_mode';
}

class RouteConstants {
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String profile = '/profile';
  static const String facilities = '/facilities';
  static const String appointments = '/appointments';
  static const String settings = '/settings';
}

class ValidationConstants {
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 128;
  static const int minNameLength = 2;
  static const int maxNameLength = 50;
  static const String emailRegex = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
  static const String phoneRegex = r'^\+?[1-9]\d{1,14}$';
}

class UIConstants {
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double defaultRadius = 12.0;
  static const double smallRadius = 8.0;
  static const double largeRadius = 16.0;
  static const double defaultSpacing = 16.0;
  static const double smallSpacing = 8.0;
  static const double largeSpacing = 24.0;
}
