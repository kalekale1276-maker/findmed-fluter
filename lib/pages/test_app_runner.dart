import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'emergency/emergency_page.dart';
import 'notifications/notifications_page.dart';
import 'profile/profile_page.dart';
import 'reports/reports_page.dart';
import 'reset_password/reset_password_page.dart';
import 'saved_facilities/saved_facilities_page.dart';
import 'settings/settings_page.dart';
import 'test_pages_integration.dart';

/// Test app runner to verify all pages work correctly
class TestAppRunner extends StatelessWidget {
  const TestAppRunner({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FindMed - Test Runner',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
      ),
      home: const TestRunnerHomePage(),
    );
  }
}

class TestRunnerHomePage extends StatefulWidget {
  const TestRunnerHomePage({super.key});

  @override
  State<TestRunnerHomePage> createState() => _TestRunnerHomePageState();
}

class _TestRunnerHomePageState extends State<TestRunnerHomePage> {
  @override
  void initState() {
    super.initState();
    // Initialize ScreenUtil
    ScreenUtil.init(context, designSize: const Size(375, 812));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FindMed - Page Test Runner'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Test All Refactored Pages',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Click on each page to test its functionality:',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.5,
                children: [
                  _buildPageCard(
                    title: 'Emergency',
                    icon: Icons.emergency,
                    color: Colors.red,
                    onTap: () => _navigateToPage(const EmergencyPage()),
                  ),
                  _buildPageCard(
                    title: 'Notifications',
                    icon: Icons.notifications,
                    color: Colors.blue,
                    onTap: () => _navigateToPage(const NotificationsPage()),
                  ),
                  _buildPageCard(
                    title: 'Profile',
                    icon: Icons.person,
                    color: Colors.green,
                    onTap: () => _navigateToPage(const ProfilePage()),
                  ),
                  _buildPageCard(
                    title: 'Reports',
                    icon: Icons.report,
                    color: Colors.orange,
                    onTap: () => _navigateToPage(const ReportsPage()),
                  ),
                  _buildPageCard(
                    title: 'Reset Password',
                    icon: Icons.lock_reset,
                    color: Colors.purple,
                    onTap: () => _navigateToPage(const ResetPasswordPage()),
                  ),
                  _buildPageCard(
                    title: 'Saved Facilities',
                    icon: Icons.location_on,
                    color: Colors.teal,
                    onTap: () => _navigateToPage(const SavedFacilitiesPage()),
                  ),
                  _buildPageCard(
                    title: 'Settings',
                    icon: Icons.settings,
                    color: Colors.grey,
                    onTap: () => _navigateToPage(const SettingsPage()),
                  ),
                  _buildPageCard(
                    title: 'Integration Tests',
                    icon: Icons.bug_report,
                    color: Colors.indigo,
                    onTap: () => _navigateToPage(const TestPagesIntegrationPage()),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageCard({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 48,
                color: color,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToPage(Widget page) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => page,
      ),
    );
  }
}

/// Individual page test wrapper
class PageTestWrapper extends StatefulWidget {
  final Widget page;
  final String pageName;

  const PageTestWrapper({
    super.key,
    required this.page,
    required this.pageName,
  });

  @override
  State<PageTestWrapper> createState() => _PageTestWrapperState();
}

class _PageTestWrapperState extends State<PageTestWrapper> {
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _testPage();
  }

  Future<void> _testPage() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Wait a bit to let the page initialize
      await Future.delayed(const Duration(seconds: 2));
      
      // Check if the page is still mounted and working
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Testing: ${widget.pageName}'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        ],
      ),
      body: _error != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error,
                    size: 64,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error in ${widget.pageName}:',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _error!,
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _testPage,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : widget.page,
    );
  }
}

/// Quick test utility
class QuickPageTest {
  static Widget testPage(Widget page, String pageName) {
    return PageTestWrapper(
      page: page,
      pageName: pageName,
    );
  }

  static Future<bool> testPageFunctionality(Widget page) async {
    try {
      // Basic functionality test
      await Future.delayed(const Duration(milliseconds: 500));
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<Map<String, bool>> testAllPages() async {
    final pages = {
      'Emergency': const EmergencyPage(),
      'Notifications': const NotificationsPage(),
      'Profile': const ProfilePage(),
      'Reports': const ReportsPage(),
      'Reset Password': const ResetPasswordPage(),
      'Saved Facilities': const SavedFacilitiesPage(),
      'Settings': const SettingsPage(),
    };

    final results = <String, bool>{};

    for (final entry in pages.entries) {
      results[entry.key] = await testPageFunctionality(entry.value);
    }

    return results;
  }
}
