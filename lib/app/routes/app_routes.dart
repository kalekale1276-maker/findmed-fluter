import 'package:flutter/material.dart';
import '../../presentation/pages/splash/splash_page.dart';
import '../../presentation/pages/onboarding/onboarding_page.dart';
import '../../presentation/pages/auth/login_page.dart';
import '../../presentation/pages/auth/register_page.dart';
import '../../presentation/pages/home/home_page.dart';
import '../../presentation/pages/profile/profile_page.dart';
import '../../presentation/pages/facilities/facilities_page.dart';
import '../../presentation/pages/appointments/appointments_page.dart';
import '../../presentation/pages/settings/settings_page.dart';
import '../constants/route_constants.dart';

class AppRoutes {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteConstants.splash:
        return MaterialPageRoute(builder: (_) => const SplashPage());
      case RouteConstants.onboarding:
        return MaterialPageRoute(builder: (_) => const OnboardingPage());
      case RouteConstants.login:
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case RouteConstants.register:
        return MaterialPageRoute(builder: (_) => const RegisterPage());
      case RouteConstants.home:
        return MaterialPageRoute(builder: (_) => const HomePage());
      case RouteConstants.profile:
        return MaterialPageRoute(builder: (_) => const ProfilePage());
      case RouteConstants.facilities:
        return MaterialPageRoute(builder: (_) => const FacilitiesPage());
      case RouteConstants.appointments:
        return MaterialPageRoute(builder: (_) => const AppointmentsPage());
      case RouteConstants.settings:
        return MaterialPageRoute(builder: (_) => const SettingsPage());
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(
              child: Text('Route not found'),
            ),
          ),
        );
    }
  }
}
