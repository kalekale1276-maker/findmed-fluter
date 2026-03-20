import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import 'routes/app_routes.dart';
import 'themes/app_theme.dart';
import '../core/utils/navigation_service.dart';
import '../shared/providers/theme_provider.dart';
import 'constants/route_constants.dart';

class FindMedApp extends StatelessWidget {
  const FindMedApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return Consumer<ThemeProvider>(
          builder: (context, themeProvider, child) {
            return MaterialApp(
              title: 'FindMed',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: themeProvider.themeMode,
              navigatorKey: NavigationService.navigatorKey,
              onGenerateRoute: AppRoutes.onGenerateRoute,
              initialRoute: RouteConstants.splash,
            );
          },
        );
      },
    );
  }
}
