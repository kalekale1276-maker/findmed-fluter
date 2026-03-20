import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/auth.dart';
import '../services/notifications.dart';
import '../services/app_config.dart';
import '../pages/login.dart';
import '../pages/register.dart';
import '../pages/profile/profile_page.dart';
import '../pages/medical_profile/medical_profile_page.dart';
import '../pages/settings/settings_page.dart';
import '../pages/agent/agent_page.dart';
import '../pages/help/help_page.dart';
import '../pages/feedback/feedback_page.dart';
import '../pages/about/about_page.dart';
import '../pages/chat/chat_page.dart';
import '../pages/booking_list/booking_list_page.dart';

class AppDrawer extends StatefulWidget {
  final void Function(int)? onSelectTab;
  const AppDrawer({super.key, this.onSelectTab});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  final AuthService _auth = AuthService.instance;
  bool _hasAgent = false;
  String? _agentFacilityType;
  int _unread = 0;
  late bool _businessMode;

  @override
  void initState() {
    super.initState();
    _auth.init().then((_) => setState(() {}));
    _auth.addListener(_onAuth);
    SharedPreferences.getInstance().then((prefs) {
      final aid = prefs.getString('agentId');
      final ftype = prefs.getString('agentFacilityType');
      if (aid != null && aid.isNotEmpty) setState(() => _hasAgent = true);
      if (ftype != null && ftype.isNotEmpty) {
        setState(() => _agentFacilityType = ftype);
      }
      _loadUnreadCount();
    });
    _businessMode = AppConfig.instance.effectiveBusinessMode.value;
    AppConfig.instance.effectiveBusinessMode.addListener(_onBusinessModeChange);
  }

  @override
  void dispose() {
    _auth.removeListener(_onAuth);
    AppConfig.instance.effectiveBusinessMode.removeListener(_onBusinessModeChange);
    super.dispose();
  }

  void _onAuth() {
    setState(() {});
    _loadUnreadCount();
  }

  void _onBusinessModeChange() {
    setState(() {
      _businessMode = AppConfig.instance.businessMode.value;
    });
  }

  Future<void> _loadUnreadCount() async {
    try {
      final user = _auth.user;
      List<Map<String, dynamic>> list = [];
      if (user != null && (user['email'] ?? '').toString().isNotEmpty) {
        list = await NotificationsService.list(email: user['email'].toString());
      } else {
        final fid = await NotificationsService.lastFeedbackId();
        if (fid != null) {
          list = await NotificationsService.list(feedbackId: fid);
        }
      }
      final unread = list.where((n) => n['read'] != true).length;
      if (mounted) setState(() => _unread = unread);
    } catch (e) {
      // ignore errors
    }
  }

  @override
  Widget build(BuildContext context) {
    final logged = _auth.isLoggedIn;
    final user = _auth.user;

    String initialLetter(String? name) {
      final s = (name ?? '').toString();
      return s.isNotEmpty ? s[0].toUpperCase() : 'U';
    }

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              color: Theme.of(context).primaryColor,
              padding: const EdgeInsets.all(16),
              child: logged && user != null
                  ? Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: Colors.white,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Text(initialLetter(user['fullName'] ??
                                  user['name'] ??
                                  user['email'])),
                              if (_unread > 0)
                                Positioned(
                                  right: -6,
                                  top: -6,
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: const BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle),
                                    constraints: const BoxConstraints(
                                        minWidth: 18, minHeight: 18),
                                    child: Center(
                                      child: Text(
                                        _unread > 99 ? '99+' : '$_unread',
                                        style: const TextStyle(
                                            color: Colors.white, fontSize: 10),
                                      ),
                                    ),
                                  ),
                                )
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(children: [
                                Expanded(
                                  child: Text(
                                    user['fullName'] ??
                                        user['name'] ??
                                        user['email'] ??
                                        'User',
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (_hasAgent) ...[
                                  const SizedBox(width: 8),
                                  Icon(
                                    (_agentFacilityType == 'pharmacy')
                                        ? Icons.local_pharmacy
                                        : Icons.medical_services,
                                    color: Colors.white,
                                    size: 18,
                                  )
                                ]
                              ]),
                              const SizedBox(height: 6),
                              Text(
                                'ID: ${user['id'] ?? user['_id'] ?? '-'}',
                                style: const TextStyle(
                                    color: Colors.white70, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: () async {
                            await _auth.logout();
                            Navigator.of(context).pop(); // Close drawer
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                  builder: (_) => const LoginPage()),
                              (route) => false,
                            );
                          },
                          child: const Text('Logout',
                              style: TextStyle(color: Colors.white)),
                        )
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Welcome',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (_) => const LoginPage()));
                              },
                              child: const Text('Login'),
                            ),
                            const SizedBox(width: 8),
                            OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.white),
                              onPressed: () {
                                Navigator.pop(context);
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (_) => const RegisterPage()));
                              },
                              child: const Text('Register'),
                            )
                          ],
                        ),
                        if (_hasAgent) ...[
                          const SizedBox(height: 8),
                          const Text('Agent ID registered on this device',
                              style: TextStyle(
                                  color: Color.fromARGB(179, 194, 9, 9),
                                  fontSize: 12))
                        ]
                      ],
                    ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  if (logged) ...[
                    ListTile(
                      leading: const Icon(Icons.person),
                      title: const Text('Profile Management'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => AgentPage(),
                          ),
                        );
                      },
                    ),
                  ],
                    ListTile(
                      leading: const Icon(Icons.medical_services),
                      title: const Text('Medical Profile'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => AgentPage(),
                          ),
                        );
                      },
                    ),
                    if (_businessMode)
                      ListTile(
                        leading: const Icon(Icons.person_search),
                        title: const Text('Agent'),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => AgentPage(),
                            ),
                          );
                        },
                      ),
                  ListTile(
                    leading: const Icon(Icons.map),
                    title: const Text('Home / Map'),
                    onTap: () {
                      Navigator.pop(context);
                      widget.onSelectTab?.call(0);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.favorite),
                    title: const Text('Favorites'),
                    onTap: () {
                      Navigator.pop(context);
                      widget.onSelectTab?.call(2);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.warning),
                    title: const Text('Emergency'),
                    onTap: () {
                      Navigator.pop(context);
                      widget.onSelectTab?.call(99);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.settings),
                    title: const Text('Settings'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => SettingsPage()));
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.person_search),
                    title: const Text('Agent'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.help),
                    title: const Text('Help & FAQ'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => HelpPage()));
                    },
                  ),
                  if (logged)
                    ListTile(
                      leading: const Icon(Icons.chat),
                      title: const Text('Support Chat'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => ChatPage()));
                      },
                    ),
                  ListTile(
                    leading: const Icon(Icons.feedback),
                    title: const Text('Send Feedback'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => FeedbackPage()));
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.info),
                    title: const Text('About'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => AboutPage()));
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
