import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../app/themes/app_theme.dart';
import '../../../../core/utils/navigation_service.dart';
import '../../../../app/constants/route_constants.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingItem> _items = [
    OnboardingItem(
      icon: Icons.location_on,
      title: 'Find Nearby Facilities',
      description: 'Locate healthcare facilities near you quickly and easily.',
    ),
    OnboardingItem(
      icon: Icons.calendar_month,
      title: 'Book Appointments',
      description: 'Schedule appointments with healthcare providers seamlessly.',
    ),
    OnboardingItem(
      icon: Icons.medical_services,
      title: 'Quality Healthcare',
      description: 'Access trusted healthcare services at your fingertips.',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _items.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _getStarted();
    }
  }

  void _getStarted() {
    NavigationService.pushReplacementNamed(RouteConstants.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
              children: [
                Expanded(
                  flex: 3,
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    itemCount: _items.length,
                    itemBuilder: (context, index) {
                      return OnboardingItemWidget(item: _items[index]);
                    },
                  ),
                ),
                SizedBox(height: 16.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _items.length,
                    (index) => Container(
                      margin: EdgeInsets.symmetric(horizontal: 4.w),
                      width: 8.w,
                      height: 8.w,
                      decoration: BoxDecoration(
                        color: _currentPage == index
                            ? AppColors.primary
                            : AppColors.border,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 32.h),
                SizedBox(
                  width: double.infinity,
                  height: 56.h,
                  child: ElevatedButton(
                    onPressed: _nextPage,
                    child: Text(
                      _currentPage == _items.length - 1 ? 'Get Started' : 'Next',
                      style: TextStyle(fontSize: 16.sp),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                if (_currentPage == _items.length - 1)
                  TextButton(
                    onPressed: () {
                      NavigationService.pushNamed(RouteConstants.register);
                    },
                    child: Text(
                      'Create Account',
                      style: TextStyle(fontSize: 16.sp),
                    ),
                  ),
              ],
            ),
        ),
      ),
    );
  }
}

class OnboardingItem {
  final IconData icon;
  final String title;
  final String description;

  OnboardingItem({
    required this.icon,
    required this.title,
    required this.description,
  });
}

class OnboardingItemWidget extends StatelessWidget {
  final OnboardingItem item;

  const OnboardingItemWidget({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          item.icon,
          size: 120.w,
          color: AppColors.primary,
        ),
        SizedBox(height: 32.h),
        Text(
          item.title,
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.onBackground,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 16.h),
        Text(
          item.description,
          style: TextStyle(
            fontSize: 16.sp,
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
