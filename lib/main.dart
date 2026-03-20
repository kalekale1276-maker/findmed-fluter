import 'package:flutter/material.dart';
import 'dart:html' as html;
import 'services/theme_service.dart';
import 'services/app_config.dart';
import 'services/api.dart';
import 'services/lazy_api_service.dart';
import 'pages/home/home_page.dart';
import 'pages/splash/splash_page.dart';

// Lazy loading for pages
import 'pages/map.dart';
import 'pages/favorites.dart';
import 'pages/notifications/notifications_page.dart';
import 'pages/login.dart';
import 'pages/register.dart';
import 'pages/reset_password/reset_password_page.dart';
import 'pages/emergency/emergency_page.dart';
import 'widgets/app_drawer_fixed.dart';
import 'package:latlong2/latlong.dart';
import 'services/map_nav.dart';
import 'services/notification_center.dart';
import 'services/notifications.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'dart:convert';
import 'services/connectivity_service.dart';
import 'package:app_settings/app_settings.dart';
import 'services/admin_api.dart';
import 'dart:async';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Start the app immediately, do initialization in background
  runApp(const MyApp());
  
  // Initialize services in background after app starts
  _initializeServices();
}

Future<void> _initializeServices() async {
  try {
    // Initialize theme service first (fast)
    await ThemeService.instance.init();
    
    // Initialize lazy API service with essential home page calls only
    await LazyApiService().initializeHomePage();
    
    // Initialize app config (fast)
    await AppConfig.instance.init();
    
  } catch (e) {
    debugPrint('Error during initialization: $e');
  }
}

// Helper to avoid awaiting futures we don't care about
void unawaited(Future<void> future) {
  // Intentionally not awaiting
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: ThemeService.instance.isDark,
      builder: (context, isDark, child) {
        return MaterialApp(
          title: 'FindMed Mobile',
          theme: ThemeData(
              primarySwatch: Colors.blue,
              brightness: Brightness.light,
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(foregroundColor: Colors.blue),
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              )),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: Colors.blue[200]),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style:
                  ElevatedButton.styleFrom(backgroundColor: Colors.blue[300]),
            ),
          ),
          themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
          home: const AppInitializer(),
          routes: {
            '/login': (context) => const LoginPage(),
            '/register': (context) => const RegisterPage(),
            '/reset': (context) => const ResetPasswordPage(),
          },
        );
      },
    );
  }
}

class AppInitializer extends StatefulWidget {
  const AppInitializer({super.key});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Wait a moment for services to initialize
    await Future.delayed(Duration(milliseconds: 100));
    
    if (mounted) {
      setState(() {
        _initialized = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.local_hospital,
                size: 80,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(height: 20),
              Text(
                'FindMed',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).primaryColor,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Loading...',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return const AppShell();
  }
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});
  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;
  int _bodyIndex = 0;
  bool _menuVisible = true;

  LatLng? _mapFrom;
  LatLng? _mapTo;

  bool _offlineDialogShown = false;

  bool _maintenanceMode = false;
  String _maintenanceMessage = 'The app is currently under maintenance. Please try again later.';

  Timer? _businessModeTimer;

  // Lazy loaded pages - only create when needed
  late final List<Widget Function()> _pages = [
    () => const HomePage(),
    () => MapPage(from: _mapFrom, to: _mapTo),
    () => const FavoritesPage(),
    () => const NotificationsPage(),
    () => const EmergencyPage(),
  ];

  // Lazy loading for pages with proper disposal
  Widget _getPage(int index) {
    if (index >= 0 && index < _pages.length) {
      return _pages[index]();
    }
    return const HomePage();
  }

  @override
  void initState() {
    super.initState();
    
    // Emit app ready event when the app shell is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      html.document.dispatchEvent(html.CustomEvent('flutter-app-ready'));
    });
    
    // initialize notification center and setup socket for real-time updates
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final platform = Theme.of(context).platform;
      await NotificationCenter.refresh();

      // Fetch initial server settings to know if maintenance mode is active
      await _checkMaintenanceMode();

      try {
        final url = Api.BASE.replaceAll('/api', '');
        final socket = io.io(url, <String, dynamic>{
          'transports': ['websocket']
        });
        socket.on('connect', (_) {});

        // Listen for broadcast updates (notifications + maintenance state)
        socket.on('settings_updated', (data) {
          try {
            Map<String, dynamic> m;
            if (data is Map) {
              m = Map<String, dynamic>.from(data);
            } else {
              m = jsonDecode(data.toString()) as Map<String, dynamic>;
            }
            final mMode = m['maintenanceModeMobile'] == true;
            if (mounted) {
              setState(() {
                _maintenanceMode = mMode;
              });
            }
            // Update business mode
            final prevBusinessMode = AppConfig.instance.businessMode.value;
            AppConfig.instance.businessMode.value = m['businessMode'] == true;
            // Notify if newly enabled and user hasn't enabled it
            if (!prevBusinessMode && AppConfig.instance.businessMode.value && !AppConfig.instance.userBusinessMode.value) {
              NotificationCenter.addNotification({
                'title': 'Business Mode Available',
                'message': 'Business Mode has been enabled by admin. You can enable it in settings to access booking features.',
                'type': 'info',
                'timestamp': DateTime.now().toIso8601String(),
              });
            }
          } catch (_) {}
        });

        socket.on('notification', (data) {
          try {
            Map<String, dynamic> m;
            if (data is Map) {
              m = Map<String, dynamic>.from(data);
            } else {
              m = jsonDecode(data.toString()) as Map<String, dynamic>;
            }
            NotificationCenter.addNotification(m);
          } catch (_) {}
        });
        socket.on('notification_reminder', (data) {
          try {
            Map<String, dynamic> m;
            if (data is Map) {
              m = Map<String, dynamic>.from(data);
            } else {
              m = jsonDecode(data.toString()) as Map<String, dynamic>;
            }
            NotificationCenter.addNotification(m);
            try {
              NotificationCenter.refresh();
            } catch (_) {}
          } catch (_) {}
        });
        socket.on('notification_deleted', (data) {
          // refresh notification list and counts
          try {
            NotificationCenter.refresh();
          } catch (_) {}
        });
        socket.on('notification_updated', (data) {
          try {
            NotificationCenter.refresh();
          } catch (_) {}
        });
      } catch (_) {}
    });

    // Periodic check for business mode updates (fallback for socket)
    _businessModeTimer = Timer.periodic(const Duration(seconds: 60), (_) => AppConfig.instance.updateBusinessMode());

    MapNav.instance.target.addListener(() {
      final t = MapNav.instance.target.value;
      if (t != null) {
        setState(() {
          _mapFrom = t['from'];
          _mapTo = t['to'];
          _currentIndex = 1;
          _bodyIndex = 1;
        });
        MapNav.instance.clear();
      }
    });

    // Listen for connectivity changes and show a persistent dialog when offline
    ConnectivityService.instance.onStatusChange.listen((online) {
      if (!mounted) return;
      if (!online) {
        _showOfflineDialog();
      } else {
        _hideOfflineDialog();
      }
    });
  }

  List<BottomNavigationBarItem> _navItems(BuildContext ctx) => [
        const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        const BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Map'),
        const BottomNavigationBarItem(
            icon: Icon(Icons.favorite), label: 'Favorites'),
        BottomNavigationBarItem(
            icon: ValueListenableBuilder<int>(
              valueListenable: NotificationCenter.unreadCount,
              builder: (context, count, child) {
                if (count <= 0) return const Icon(Icons.notifications);
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Icon(Icons.notifications),
                    Positioned(
                      right: -6,
                      top: -6,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        constraints:
                            const BoxConstraints(minWidth: 20, minHeight: 20),
                        child: Center(
                            child: Text(
                          count > 99 ? '99+' : count.toString(),
                          style: const TextStyle(
                              color: Colors.white, fontSize: 11),
                        )),
                      ),
                    )
                  ],
                );
              },
            ),
            label: 'Notifications'),
      ];

  @override
  Widget build(BuildContext context) {
    // If mobile maintenance mode is enabled, lock the app with a dedicated screen
    if (_maintenanceMode) {
      return Scaffold(
        appBar: AppBar(title: const Text('Maintenance')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(Icons.construction, size: 80, color: Colors.orange),
                const SizedBox(height: 24),
                Text(_maintenanceMessage,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _checkMaintenanceMode,
                  child: const Text('Check again'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('FindMed'),
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
      ),
      drawer: AppDrawer(onSelectTab: (i) {
        if (i == 99) {
          // show Emergency inside the main body (keeps bottom nav visible)
          setState(() => _bodyIndex = 4);
        } else {
          setState(() {
            _currentIndex = i;
            _bodyIndex = i;
          });
        }
      }),
      body: Column(
        children: [
          ValueListenableBuilder<Map<String, dynamic>?>(
            valueListenable: NotificationCenter.latest,
            builder: (ctx, latest, child) {
              if (latest == null) return const SizedBox.shrink();
              final title = latest['title']?.toString() ?? '';
              final body = latest['body']?.toString() ?? '';
              return Material(
                color: Colors.yellow[100],
                child: ListTile(
                  leading: const Icon(Icons.notifications),
                  title: Text(title),
                  subtitle:
                      Text(body, maxLines: 2, overflow: TextOverflow.ellipsis),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextButton(
                        child: const Text('View'),
                        onPressed: () async {
                          // mark latest as read (if possible) and navigate to notifications
                          try {
                            final id = latest['id']?.toString();
                            if (id != null && id.isNotEmpty) {
                              await NotificationsService.markRead(id);
                              NotificationCenter.markReadLocally(id);
                            }
                          } catch (_) {}
                          setState(() {
                            _currentIndex = 3;
                            _bodyIndex = 3;
                          });
                          NotificationCenter.clearLatest();
                        },
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        child: const Text('Close'),
                        onPressed: () {
                          NotificationCenter.clearLatest();
                        },
                      )
                    ],
                  ),
                ),
              );
            },
          ),
          Expanded(child: IndexedStack(index: _bodyIndex, children: [
            _getPage(0), // Home
            _getPage(1), // Map
            _getPage(2), // Favorites
            _getPage(3), // Notifications
          ])),
        ],
      ),
      bottomNavigationBar: SizedBox(
        height: 88,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            // Sliding bottom navigation
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              transform:
                  Matrix4.translationValues(0, _menuVisible ? 0 : 120, 0),
              child: Material(
                elevation: 12,
                color: Theme.of(context).colorScheme.surface,
                child: BottomNavigationBar(
                  currentIndex: _currentIndex,
                  items: _navItems(context),
                  onTap: (i) => setState(() {
                    _currentIndex = i;
                    _bodyIndex = i;
                  }),
                  type: BottomNavigationBarType.fixed,
                ),
              ),
            ),

            // Animated circular toggle that moves above/below the menu
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              bottom: _menuVisible ? 56 : 12,
              left: 0,
              right: 0,
              child: GestureDetector(
                onTap: () => setState(() => _menuVisible = !_menuVisible),
                child: Semantics(
                  button: true,
                  label: _menuVisible ? 'Hide menu' : 'Show menu',
                  child: Center(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                              color: Color.fromRGBO(0, 0, 0, 0.12),
                              blurRadius: 8),
                        ],
                      ),
                      child: AnimatedRotation(
                        turns: _menuVisible ? 0.5 : 0.0,
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeInOut,
                        child: Icon(
                          Icons.keyboard_arrow_up,
                          size: 28,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _checkMaintenanceMode() async {
    try {
      final settings = await AdminApi.getSettings();
      final isMobileMaint = settings['maintenanceModeMobile'] == true;
      if (mounted) {
        setState(() {
          _maintenanceMode = isMobileMaint;
        });
      }
    } catch (_) {
      // ignore errors - keep existing state
    }
  }

  void _showOfflineDialog() {
    if (_offlineDialogShown) return;
    _offlineDialogShown = true;
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => PopScope(
        canPop: false,
        child: AlertDialog(
          title: Row(children: [
            Icon(Icons.signal_wifi_off,
                color: Theme.of(context).colorScheme.error),
            const SizedBox(width: 8),
            const Text('No Internet')
          ]),
          content: const Text(
              'Connection lost. Please check your internet connection or turn on Wi‑Fi / Mobile data.'),
          actions: [
            TextButton(
              onPressed: () async {
                final ok = await ConnectivityService.instance.checkConnection();
                if (ok) {
                  _hideOfflineDialog();
                } else {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Still offline')));
                  }
                }
              },
              child: const Text('Retry'),
            ),
            TextButton(
              onPressed: () {
                try {
                  // opens wifi settings on device (no-op on web)
                  AppSettings.openAppSettings();
                } catch (_) {}
              },
              child: const Text('Open Settings'),
            ),
          ],
        ),
      ),
    ).then((_) {
      // dialog dismissed
      _offlineDialogShown = false;
    });
  }

  void _hideOfflineDialog() {
    if (!_offlineDialogShown) return;
    try {
      Navigator.of(context, rootNavigator: true).pop();
    } catch (_) {}
    _offlineDialogShown = false;
  }

  @override
  void dispose() {
    _businessModeTimer?.cancel();
    super.dispose();
  }
}
