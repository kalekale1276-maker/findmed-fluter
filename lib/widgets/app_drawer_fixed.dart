import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../core/utils/tailwind_extensions.dart';
import '../pages/profile/profile_page.dart';
import '../pages/settings/settings_page.dart';
import '../pages/agent/agent_page.dart';
import '../pages/help/help_page.dart';
import '../pages/feedback/feedback_page.dart';
import '../pages/about/about_page.dart';
import '../pages/chat/chat_page.dart';
import '../pages/booking_list/booking_list_page.dart';
import '../pages/login/login_page.dart';
import '../pages/register/register_page.dart';
import '../services/app_config.dart';

/// App Drawer - Navigation drawer with proper routing
class AppDrawer extends StatelessWidget {
  final Function(int)? onSelectTab;
  final bool isBusinessMode;

  const AppDrawer({
    super.key,
    required this.onSelectTab,
    this.isBusinessMode = false,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: 'FindMed User',
            accountEmail: 'user@findmed.et',
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.blue,
              child: Icon(Icons.person, color: Colors.white),
            ),
          ),
          const Divider(),
          _buildMenuItems(context),
        ],
      ),
    );
  }

  Widget _buildMenuItems(BuildContext context) {
    return Column(
      children: [
        _buildSection('Main', [
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () {
              Navigator.pop(context);
              onSelectTab?.call(0);
            },
          ),
          ListTile(
            leading: const Icon(Icons.map),
            title: const Text('Map'),
            onTap: () {
              Navigator.pop(context);
              onSelectTab?.call(1);
            },
          ),
          ListTile(
            leading: const Icon(Icons.favorite),
            title: const Text('Favorites'),
            onTap: () {
              Navigator.pop(context);
              onSelectTab?.call(2);
            },
          ),
        ]),
        _buildSection('Services', [
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Notifications'),
            onTap: () {
              Navigator.pop(context);
              onSelectTab?.call(3);
            },
          ),
          ListTile(
            leading: const Icon(Icons.emergency),
            title: const Text('Emergency'),
            onTap: () {
              Navigator.pop(context);
              onSelectTab?.call(4);
            },
          ),
        ]),
        if (isBusinessMode) ...[
          _buildSection('Business', [
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('My Bookings'),
              onTap: () {
                Navigator.pop(context);
                onSelectTab?.call(5);
              },
            ),
          ]),
        ],
        _buildSection('Account', [
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profile'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/profile');
            },
          ),
          ListTile(
            leading: const Icon(Icons.medical_services),
            title: const Text('Medical Profile'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/medical_profile');
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ]),
        _buildSection('Support', [
          ListTile(
            leading: const Icon(Icons.help),
            title: const Text('Help'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/help');
            },
          ),
          ListTile(
            leading: const Icon(Icons.feedback),
            title: const Text('Feedback'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/feedback');
            },
          ),
          ListTile(
            leading: const Icon(Icons.chat),
            title: const Text('Chat'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/chat');
            },
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('About'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/about');
            },
          ),
        ]),
        _buildSection('Authentication', [
          ListTile(
            leading: const Icon(Icons.login),
            title: const Text('Login'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/login');
            },
          ),
          ListTile(
            leading: const Icon(Icons.app_registration),
            title: const Text('Register'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/register');
            },
          ),
        ]),
        const Divider(),
        ListTile(
          leading: Icon(
            Icons.info,
            color: Colors.blue,
          ),
          title: Text(
            'Version ${AppConfig.appVersion}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          onTap: null, // Disabled
        ),
      ],
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
          ),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }
}
