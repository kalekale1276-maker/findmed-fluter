import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../app/themes/app_theme.dart';
import '../../../../core/utils/navigation_service.dart';
import '../../../../app/constants/route_constants.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              NavigationService.pushNamed(RouteConstants.settings);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            children: [
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50.r,
                      backgroundColor: AppColors.primary,
                      child: const Icon(
                        Icons.person,
                        size: 50,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'John Doe',
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.onBackground,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'john.doe@example.com',
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 32.h),
              Card(
                child: Column(
                  children: [
                    _ProfileMenuItem(
                      icon: Icons.person_outline,
                      title: 'Personal Information',
                      onTap: () {
                        // TODO: Navigate to personal info
                      },
                    ),
                    _ProfileMenuItem(
                      icon: Icons.local_hospital_outlined,
                      title: 'Medical History',
                      onTap: () {
                        // TODO: Navigate to medical history
                      },
                    ),
                    _ProfileMenuItem(
                      icon: Icons.calendar_month_outlined,
                      title: 'Appointment History',
                      onTap: () {
                        NavigationService.pushNamed(RouteConstants.appointments);
                      },
                    ),
                    _ProfileMenuItem(
                      icon: Icons.payment_outlined,
                      title: 'Payment Methods',
                      onTap: () {
                        // TODO: Navigate to payment methods
                      },
                    ),
                    _ProfileMenuItem(
                      icon: Icons.notifications_outlined,
                      title: 'Notifications',
                      onTap: () {
                        // TODO: Navigate to notifications
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.h),
              Card(
                child: Column(
                  children: [
                    _ProfileMenuItem(
                      icon: Icons.help_outline,
                      title: 'Help & Support',
                      onTap: () {
                        // TODO: Navigate to help
                      },
                    ),
                    _ProfileMenuItem(
                      icon: Icons.privacy_tip_outlined,
                      title: 'Privacy Policy',
                      onTap: () {
                        // TODO: Navigate to privacy policy
                      },
                    ),
                    _ProfileMenuItem(
                      icon: Icons.info_outline,
                      title: 'About',
                      onTap: () {
                        // TODO: Navigate to about
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24.h),
              SizedBox(
                width: double.infinity,
                height: 56.h,
                child: OutlinedButton(
                  onPressed: () {
                    _showLogoutDialog(context);
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColors.error),
                    foregroundColor: AppColors.error,
                  ),
                  child: Text(
                    'Sign Out',
                    style: TextStyle(fontSize: 16.sp),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Implement logout logic
              NavigationService.pushReplacementNamed(RouteConstants.login);
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _ProfileMenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}
