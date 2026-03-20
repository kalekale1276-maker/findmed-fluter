import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/utils/tailwind_extensions.dart';
import '../../../services/app_config.dart';
import '../../../services/lazy_api_service.dart';
import '../../../services/auth.dart';
import '../home/facilities_list.dart';
import '../home/facility_detail_page.dart';
import '../home/facility_search_delegate.dart';
import '../home/filter_modal.dart';
import '../feedback/feedback_page.dart';
import '../../../widgets/app_drawer.dart';
import '../../map/map.dart';
import '../../favorites/favorites.dart';
import '../../notifications/notifications_page.dart';
import '../../emergency/emergency_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  LatLng? _currentLocation;
  List<Map<String, dynamic>> _all = [];
  List<Map<String, dynamic>> _filtered = [];
  final TextEditingController _search = TextEditingController();
  bool _loading = true;
  bool _error = false;
  bool _usingFallbackData = false;
  Map<String, String>? _selectedTip;
  bool _showAllFacilities = false;
  String _type = 'all';
  bool _openNow = false;
  String? _hospitalTypeFilter;
  String? _pharmacyTypeFilter;
  String? _hospitalOwnershipFilter;
  String? _pharmacyOwnershipFilter;
  int? _radiusMeters;
  final ScrollController _scrollController = ScrollController();
  int _currentPage = 1;
  int _pageSize = 20;
  bool _hasMore = true;
  bool _isLoadingMore = false;
  String _ownershipFilter = 'any';
  List<Map<String, String>> _adsList = [];
  List<Map<String, String>> get _ads =>
      _adsList.isNotEmpty ? _adsList : _generateAds();
  late final PageController _adController;
  Timer? _adTimer;
  final AuthService _auth = AuthService.instance;
  int _chatUnreadCount = 0;
  String _tipCategory = 'general';
  List<Map<String, String>> _tips = [];
  final Set<String> _serviceFilters = <String>{};

  @override
  void initState() {
    super.initState();
    _adController = PageController();
    _search.addListener(_apply);
    
    // Load data using lazy loading - only essential calls for home page
    _loadHomeDataLazy();
  }

  Future<void> _loadHomeDataLazy() async {
    // Load home page data using lazy API service
    await LazyApiService().loadPageData('home', {
      'facilities': () async {
        // Only load facilities if not already loaded by lazy service
        if (!LazyApiService().isPageLoaded('home')) {
          await _load();
        }
      },
      'tips': () async {
        // Only load tips if not already loaded by lazy service
        if (!LazyApiService().isPageLoaded('home')) {
          await _loadTips();
        }
      },
      'notifications': () async {
        // Only load notifications if not already loaded by lazy service
        if (!LazyApiService().isPageLoaded('home')) {
          await _checkUnreadCount();
        }
      },
      'location': () async {
        // Always try to get location (essential for home page)
        await _refreshLocation();
      },
    });
    
    // Start ad rotation immediately
    _startAdRotation();
  }

  @override
  void dispose() {
    _adTimer?.cancel();
    _adController.dispose();
    _search.removeListener(_apply);
    super.dispose();
  }

  List<Map<String, String>> _generateAds() {
    return [
      {
        'title': 'Health Tip of the Day',
        'subtitle': 'Stay hydrated!',
        'body': 'Drink at least 8 glasses of water daily for better health.',
        'image': 'https://picsum.photos/seed/health/64/64.jpg'
      },
      {
        'title': 'Emergency Contacts',
        'subtitle': 'Save important numbers',
        'body': 'Keep emergency contacts easily accessible.',
        'image': 'https://picsum.photos/seed/emergency/64/64.jpg'
      }
    ];
  }

  void _startAdRotation() {
    // Reduced frequency from 8 seconds to 12 seconds for better performance
    _adTimer = Timer.periodic(const Duration(seconds: 12), (timer) {
      if (_adController.hasClients && mounted) {
        final cur = (_adController.page ?? _adController.initialPage).round();
        final next = (cur + 1) % _ads.length;
        _adController.animateToPage(
          next,
          duration: const Duration(milliseconds: 300), 
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _showAdDetail(Map<String, String> ad) {
    if (!mounted) return;
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(children: [
          ListTile(
            title: Text(ad['title'] ?? ''),
            subtitle: (ad['subtitle'] ?? '').isNotEmpty
                ? Text(ad['subtitle']!)
                : null,
          ),
          if (((ad['body'] ?? '').isNotEmpty))
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(ad['body'] ?? ''),
            ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Close'),
            ),
          ),
        ]),
      ),
    );
  }

  Future<void> _loadTips() async {
    // Add guard to prevent repeated calls
    if (_tips.isNotEmpty) return;
    
    final bases = ['https://findmed-backend-1.onrender.com'];
    
    // Try with shorter timeout for faster fallback
    try {
      final uri = Uri.parse('${bases.first}/api/content');
      final r = await http.get(uri).timeout(const Duration(seconds: 60));
      if (r.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(r.body);
        final List<dynamic> items = data['items'] ?? [];
        final list = items
            .where((e) => e['type'] == 'tip' || e['category'] == 'general' || e['type'] == 'health_tip')
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
        if (list.isNotEmpty && mounted) {
          setState(() {
            _tips = list.map((e) => e.map((k, v) => MapEntry(k, v.toString()))).toList();
          });
          return;
        }
      }
    } catch (e) {
      debugPrint('Backend tips error: $e');
    }
    
    // Immediate fallback if backend fails
    debugPrint('Backend unavailable, using fallback tips data');
    if (mounted) {
      setState(() {
        _tips = _getFallbackTips();
      });
    }
  }

  List<Map<String, String>> _getFallbackTips() {
    return [
      {
        'title': 'Stay Hydrated',
        'subtitle': 'Health Tip',
        'body': 'Drink at least 8 glasses of water daily for better health and energy.',
        'category': 'general'
      },
      {
        'title': 'Emergency Preparedness',
        'subtitle': 'Safety Tip',
        'body': 'Keep emergency contacts easily accessible and save important medical numbers.',
        'category': 'emergency'
      },
      {
        'title': 'Regular Check-ups',
        'subtitle': 'Preventive Care',
        'body': 'Schedule regular medical check-ups to maintain good health and detect issues early.',
        'category': 'general'
      },
      {
        'title': 'Medication Safety',
        'subtitle': 'Health Tip',
        'body': 'Always follow prescription instructions and keep medications out of reach of children.',
        'category': 'general'
      }
    ];
  }

  Map<String, String>? _currentTip() {
    if (_tips.isNotEmpty) {
      final filtered = _tips.where((t) =>
          (t['category'] ?? 'general') == _tipCategory);
      if (filtered.isNotEmpty) {
        final index = _tips.indexOf(filtered.first);
        final i = (index + DateTime.now().millisecond) % filtered.length;
        return filtered.elementAt(i);
      }
    }
    return null;
  }

  void _showTipDetails(Map<String, String> tip) {
    if (!mounted) return;
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(children: [
          ListTile(
            title: Text(tip['title'] ?? ''),
            subtitle: (tip['subtitle'] ?? '').isNotEmpty
                ? Text(tip['subtitle']!)
                : null,
          ),
          if (((tip['body'] ?? '').isNotEmpty))
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(tip['body'] ?? ''),
            ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Close'),
            ),
          ),
        ]),
      ),
    );
  }

  Future<void> _checkUnreadCount() async {
    final uid = _auth.user?['id'] ?? _auth.user?['_id'];
    if (uid != null) {
      try {
        final headers = <String, String>{};
        if (_auth.token != null) {
          headers['Authorization'] = 'Bearer ${_auth.token}';
        }
        final data = await Api.get('/chat/unread/$uid', headers: headers);
        if (mounted && data != null) {
          setState(() {
            _chatUnreadCount = data['count'] ?? 0;
          });
        }
      } catch (e) {
        // Silently handle notification errors to reduce console noise
        debugPrint('Chat unread count check failed: $e');
      }
    }
  }

  Future<void> _refreshLocation() async {
    bool hasPermission = await _handleLocationPermission();
    if (!hasPermission) return;
    
    try {
      // Use faster location settings
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium, // Changed from high to medium for speed
        timeLimit: const Duration(seconds: 5), // Add timeout
      );
      if (mounted) {
        setState(() {
          _currentLocation = LatLng(pos.latitude, pos.longitude);
        });
      }
      // Don't call _load() here - it's already called in _loadAllData()
    } catch (e) {
      debugPrint('Location error: $e');
      // Continue without location rather than blocking
    }
  }

  Future<bool> _handleLocationPermission() async {
    final s = await Geolocator.checkPermission();
    if (s == LocationPermission.denied) {
      final result = await Geolocator.requestPermission();
      return result == LocationPermission.whileInUse ||
          result == LocationPermission.always;
    }
    return s == LocationPermission.whileInUse ||
        s == LocationPermission.always;
  }

  void _showLocationInfo() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Location Info'),
        content: Text(_currentLocation != null
            ? 'Lat: ${_currentLocation!.latitude}, Lng: ${_currentLocation!.longitude}'
            : 'Location not available'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _openSearch() {
    showSearch(
      context: context,
      delegate: FacilitySearchDelegate(
        onSearch: (query) {
          if (query.isEmpty) {
            setState(() {
              _search.clear();
              _filtered = _all;
              _type = 'all';
            });
          } else {
            setState(() {
              _search.text = query;
              _apply();
            });
          }
        },
        onFilter: () => _openFilters(),
      ),
    );
  }

  void _apply() {
    final q = _search.text.toLowerCase().trim();
    if (q.isEmpty) {
      setState(() {
        _filtered = _all;
        _type = 'all';
      });
      return;
    }
    final filtered = _all.where((f) {
      final name = (f['name'] ?? '').toString().toLowerCase();
      final type = (f['type'] ?? '').toString().toLowerCase();
      final query = q.toLowerCase();
      if (_type != 'all' && _type != type) return false;
      if (_openNow && !_isOpen(f)) return false;
      if (_hospitalTypeFilter != null &&
          (f['hospitalType'] ?? '').toString().toLowerCase() != _hospitalTypeFilter) {
        return false;
      }
      if (_pharmacyTypeFilter != null &&
          (f['pharmacyType'] ?? '').toString().toLowerCase() != _pharmacyTypeFilter) {
        return false;
      }
      if (_hospitalOwnershipFilter != null &&
          (f['ownership'] ?? '').toString().toLowerCase() != _hospitalOwnershipFilter) {
        return false;
      }
      if (_pharmacyOwnershipFilter != null &&
          (f['ownership'] ?? '').toString().toLowerCase() != _pharmacyOwnershipFilter) {
        return false;
      }
      if (_ownershipFilter != 'any' &&
          (f['ownership'] ?? '').toString().toLowerCase() != _ownershipFilter) {
        return false;
      }
      if (_radiusMeters != null) {
        final dist = _distance(f);
        if (dist != null && dist > _radiusMeters!) return false;
      }
      return name.contains(query) || type.contains(query);
    }).toList();

    setState(() {
      _filtered = filtered;
      _showAllFacilities = false;
    });
  }

  void _openFilters() {
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (_, setModalState) => FilterModal(
          currentType: _type,
          currentOpenNow: _openNow,
          currentHospitalType: _hospitalTypeFilter,
          currentPharmacyType: _pharmacyTypeFilter,
          currentHospitalOwnership: _hospitalOwnershipFilter,
          currentPharmacyOwnership: _pharmacyOwnershipFilter,
          currentOwnership: _ownershipFilter,
          currentRadius: _radiusMeters,
          onApply: (type, openNow, hospitalType, pharmacyType,
              hospitalOwnership, pharmacyOwnership, ownership, radiusMeters) {
            setModalState(() {});
            Navigator.of(ctx).pop();
            setState(() {
              _type = type;
              _openNow = openNow;
              _hospitalTypeFilter = hospitalType;
              _pharmacyTypeFilter = pharmacyType;
              _hospitalOwnershipFilter = hospitalOwnership;
              _pharmacyOwnershipFilter = pharmacyOwnership;
              _ownershipFilter = ownership;
              _radiusMeters = radiusMeters;
            });
            _apply();
          },
        ),
      ),
    );
  }

  Future<void> _load() async {
    if (_loading) return;
    setState(() => _loading = true);

    final bases = ['https://findmed-backend-1.onrender.com'];
    
    // Try with shorter timeout for faster fallback
    try {
      final baseUri = Uri.tryParse(bases.first);
      if (baseUri != null && baseUri.host.isNotEmpty) {
        final uri = baseUri.replace(
          path: '${baseUri.path.replaceAll(RegExp(r'/$'), '')}/api/facilities',
        );
        
        // Increased timeout from 3 to 60 seconds for backend spin-up
        final r = await http.get(uri).timeout(const Duration(seconds: 60));
        if (r.statusCode == 200) {
          final data = jsonDecode(r.body) as List<dynamic>;
          final list = data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
          if (mounted) {
            setState(() {
              _all = list;
              _filtered = list;
              _error = false;
              _loading = false;
              _usingFallbackData = false;
            });
          }
          return;
        }
      }
    } catch (e) {
      debugPrint('Backend facilities error: $e');
    }

    // Immediate fallback if backend fails
    if (!_usingFallbackData) {
      debugPrint('Backend unavailable, using fallback facilities data');
    }
    final fallbackData = _getFallbackFacilities();
    if (mounted) {
      setState(() {
        _all = fallbackData;
        _filtered = fallbackData;
        _error = false;
        _loading = false;
        _usingFallbackData = true;
      });
    }
  }

  List<Map<String, dynamic>> _getFallbackFacilities() {
    return [
      {
        'name': 'Addis Ababa University Hospital',
        'address': 'Addis Ababa, Ethiopia',
        'type': 'hospital',
        'phone': '+251 11 123 4567',
        'email': 'info@aauhospital.edu.et',
        'openingHours': 'Mon-Fri: 8:00 AM - 8:00 PM; Sat-Sun: 9:00 AM - 6:00 PM',
        'latitude': 9.0340,
        'longitude': 38.7610,
        'services': ['Emergency', 'Surgery', 'Pediatrics', 'Maternity'],
        'ownership': 'public'
      },
      {
        'name': 'St. Paul\'s Hospital Millennium Medical College',
        'address': 'Addis Ababa, Ethiopia',
        'type': 'hospital',
        'phone': '+251 11 234 5678',
        'email': 'info@stpauls.edu.et',
        'openingHours': '24/7 Emergency; Mon-Fri: 8:00 AM - 8:00 PM',
        'latitude': 9.0240,
        'longitude': 38.7510,
        'services': ['Emergency', 'Cardiology', 'Oncology', 'Neurology'],
        'ownership': 'public'
      },
      {
        'name': 'Luna Pharmacy',
        'address': 'Bole, Addis Ababa, Ethiopia',
        'type': 'pharmacy',
        'phone': '+251 11 345 6789',
        'email': 'info@lunapharmacy.et',
        'openingHours': 'Mon-Sat: 8:00 AM - 9:00 PM; Sun: 10:00 AM - 7:00 PM',
        'latitude': 9.0140,
        'longitude': 38.7410,
        'services': ['Prescription Drugs', 'Over-the-Counter Medicine', 'Medical Supplies'],
        'ownership': 'private'
      },
      {
        'name': 'Black Lion Hospital',
        'address': 'Addis Ababa, Ethiopia',
        'type': 'hospital',
        'phone': '+251 11 456 7890',
        'email': 'info@blacklion.edu.et',
        'openingHours': '24/7 Emergency; Mon-Fri: 8:00 AM - 8:00 PM',
        'latitude': 9.0440,
        'longitude': 38.7710,
        'services': ['Emergency', 'Trauma', 'Surgery', 'ICU'],
        'ownership': 'public'
      },
      {
        'name': 'Meda Pharmacy',
        'address': 'Mekelle, Ethiopia',
        'type': 'pharmacy',
        'phone': '+251 34 567 8901',
        'email': 'info@medapharmacy.et',
        'openingHours': 'Mon-Sat: 8:00 AM - 8:00 PM; Sun: 9:00 AM - 6:00 PM',
        'latitude': 13.4967,
        'longitude': 39.4753,
        'services': ['Prescription Drugs', 'Medical Equipment', 'Health Products'],
        'ownership': 'private'
      }
    ];
  }

  double? _distance(Map<String, dynamic> f) {
    if (_currentLocation == null) return null;
    final lat = f['latitude'] as double?;
    final lng = f['longitude'] as double?;
    if (lat == null || lng == null) return null;
    return Geolocator.distanceBetween(
            _currentLocation!.latitude,
            _currentLocation!.longitude,
            lat!,
            lng!);
  }

  bool _isOpen(Map<String, dynamic> f) {
    try {
      final open = f['openingHours'] as String? ?? '';
      if (open.isEmpty) return false;
      final now = DateTime.now();
      final day = now.weekday;
      final lines = open.split(';');
      if (day < 1 || day > 7) return false;
      final today = lines[day - 1];
      final parts = today.split('-');
      if (parts.length != 2) return false;
      final openTime = parts[0].trim();
      final closeTime = parts[1].trim();
      final current = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
      return _isTimeInRange(current, openTime, closeTime);
    } catch (e) {
      return false;
    }
  }

  bool _isTimeInRange(String current, String open, String close) {
    final format = RegExp(r'^([0-9]{1,2}):([0-9]{1,2})\s*([APap]{0,2})$');
    final curMatch = format.firstMatch(current);
    final openMatch = format.firstMatch(open);
    final closeMatch = format.firstMatch(close);
    if (curMatch == null || openMatch == null || closeMatch == null) {
      return false;
    }
    final cur = int.parse(curMatch.group(1)!) * 60 +
        int.parse(curMatch.group(2)!);
    final openTime = int.parse(openMatch.group(1)!) * 60 +
        int.parse(openMatch.group(2)!);
    final closeTime = int.parse(closeMatch.group(1)!) * 60 +
        int.parse(closeMatch.group(2)!);
    final period = openMatch.group(3)!.toLowerCase();
    var adjustedClose = closeTime;
    var adjustedOpen = openTime;
    if (period == 'am' && closeMatch.group(3)!.toLowerCase() == 'pm') {
      adjustedClose += 12 * 60;
    }
    if (period == 'pm' && openMatch.group(3)!.toLowerCase() == 'am') {
      adjustedOpen += 12 * 60;
    }
    return cur >= adjustedOpen && cur < adjustedClose;
  }

  void _showDetail(Map<String, dynamic> f) {
    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => FacilityDetailPage(facility: f)),
    );
  }

  Future<void> _openDirections(Map<String, dynamic> f) async {
    final lat = f['latitude'] as double?;
    final lng = f['longitude'] as double?;
    if (lat == null || lng == null) return;
    final url = 'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng';
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'FindMed',
          style: TextStyle(
            fontSize: context.responsiveTextLg,
            fontWeight: FontWeight.bold,
            color: context.isDarkMode ? Colors.white : TailwindColors.gray900,
          ),
        ),
        backgroundColor: context.isDarkMode ? TailwindColors.gray800 : Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _openSearch,
            icon: Icon(Icons.search, 
              size: context.isMobile ? 22.w : 24.w,
              color: context.isDarkMode ? Colors.white : TailwindColors.gray700),
            tooltip: 'Search',
          ),
          IconButton(
            onPressed: _openFilters,
            icon: Icon(Icons.filter_list,
              size: context.isMobile ? 22.w : 24.w,
              color: context.isDarkMode ? Colors.white : TailwindColors.gray700),
            tooltip: 'Filters',
          ),
          IconButton(
            onPressed: _showLocationInfo,
            icon: Icon(Icons.my_location,
              size: context.isMobile ? 22.w : 24.w,
              color: context.isDarkMode ? Colors.white : TailwindColors.gray700),
            tooltip: 'Location',
          ),
          IconButton(
            onPressed: _refreshLocation,
            icon: Icon(Icons.refresh,
              size: context.isMobile ? 22.w : 24.w,
              color: context.isDarkMode ? Colors.white : TailwindColors.gray700),
            tooltip: 'Refresh',
          ),
          IconButton(
            onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => EmergencyPage())),
            icon: Icon(Icons.warning, 
              size: context.isMobile ? 22.w : 24.w,
              color: Colors.redAccent),
            tooltip: 'Emergency',
          ),
        ],
      ),
      drawer: AppDrawer(),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(context.responsivePadding),
          child: RefreshIndicator(
            onRefresh: _load,
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      // Quick Action Buttons Row
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: context.responsivePaddingSm),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _QuickActionButton(
                              icon: Icons.search,
                              label: 'Search',
                              onTap: _openSearch,
                              context: context,
                            ),
                            _QuickActionButton(
                              icon: Icons.filter_list,
                              label: 'Filter',
                              onTap: _openFilters,
                              context: context,
                            ),
                            _QuickActionButton(
                              icon: Icons.my_location,
                              label: 'Location',
                              onTap: _showLocationInfo,
                              context: context,
                            ),
                            _QuickActionButton(
                              icon: Icons.refresh,
                              label: 'Refresh',
                              onTap: _refreshLocation,
                              context: context,
                            ),
                            _QuickActionButton(
                              icon: Icons.warning,
                              label: 'Emergency',
                              onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => EmergencyPage())),
                              context: context,
                              isEmergency: true,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: context.responsiveGap),
                  if (_usingFallbackData)
                    Container(
                      padding: EdgeInsets.all(context.responsivePadding),
                      margin: EdgeInsets.only(bottom: context.responsiveGapSm),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(TailwindRadius.lg),
                        border: Border.all(color: Colors.orange.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.warning_amber, color: Colors.orange, 
                            size: context.isMobile ? 18.w : 20.w),
                          SizedBox(width: context.responsiveGapSm),
                          Expanded(
                            child: Text(
                              'Using offline data - Backend server unavailable',
                              style: TextStyle(
                                color: Colors.orange[800],
                                fontSize: context.responsiveTextSm,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                      // Health Tip Card
                      Container(
                        margin: EdgeInsets.only(bottom: context.responsiveGap),
                        decoration: BoxDecoration(
                          color: context.isDarkMode ? TailwindColors.gray800 : Colors.white,
                          borderRadius: BorderRadius.circular(TailwindRadius.lg),
                          boxShadow: [TailwindShadows.md],
                          border: Border.all(
                            color: context.isDarkMode ? TailwindColors.gray700 : TailwindColors.gray200,
                          ),
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.all(context.responsivePadding),
                          leading: CircleAvatar(
                            radius: context.isMobile ? 22.r : 24.r,
                            backgroundColor: Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.12),
                            child: Icon(
                              Icons.health_and_safety,
                              color: Theme.of(context).colorScheme.primary,
                              size: context.isMobile ? 22.w : 24.w,
                            ),
                          ),
                          title: Text(
                            _currentTip()?['title'] ?? 'Health Tip',
                            style: TextStyle(
                              fontSize: context.responsiveText,
                              fontWeight: FontWeight.w600,
                              color: context.isDarkMode ? Colors.white : TailwindColors.gray900,
                            ),
                          ),
                          subtitle: Text(
                            _currentTip()?['body'] ??
                                'Wash your hands frequently. Call ahead before visiting facilities.',
                            style: TextStyle(
                              fontSize: context.responsiveTextSm,
                              color: context.isDarkMode ? Colors.white70 : TailwindColors.gray600,
                            ),
                          ),
                          trailing: TextButton(
                            onPressed: _currentTip() != null
                                ? () => _showTipDetails(_currentTip()!)
                                : null,
                            child: Text(
                              'See more',
                              style: TextStyle(
                                fontSize: context.responsiveTextSm,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: context.responsiveGap),
                      // Ad Carousel
                      SizedBox(
                        height: context.isMobile ? 100.h : 110.h,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            PageView.builder(
                              controller: _adController,
                              itemCount: _ads.length,
                              itemBuilder: (context, idx) {
                                final ad = _ads[idx];
                                return Padding(
                                  padding: EdgeInsets.symmetric(horizontal: context.responsivePaddingSm),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Theme.of(context)
                                              .colorScheme
                                              .primary
                                              .withOpacity(0.9),
                                          Theme.of(context)
                                              .colorScheme
                                              .secondary
                                              .withOpacity(0.9),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(TailwindRadius.lg),
                                      boxShadow: [TailwindShadows.lg],
                                    ),
                                    padding: EdgeInsets.all(context.responsivePadding),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: InkWell(
                                            onTap: () => _showAdDetail(ad),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  ad['title'] ?? '',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: context.responsiveText,
                                                  ),
                                                ),
                                                SizedBox(height: context.responsiveGapSm),
                                                Text(
                                                  ad['subtitle'] ?? '',
                                                  style: TextStyle(
                                                    color: Colors.white70,
                                                    fontSize: context.responsiveTextSm,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: context.responsiveGapSm),
                                        Container(
                                          width: context.isMobile ? 60.w : 64.w,
                                          height: context.isMobile ? 60.w : 64.w,
                                          decoration: BoxDecoration(
                                            color: Colors.white24,
                                            borderRadius: BorderRadius.circular(TailwindRadius.md),
                                          ),
                                          child: ad.containsKey('image') && ad['image'] != null
                                              ? ClipRRect(
                                                  borderRadius: BorderRadius.circular(TailwindRadius.md),
                                                  child: Image.network(
                                                    ad['image']!,
                                                    width: context.isMobile ? 60.w : 64.w,
                                                    height: context.isMobile ? 60.w : 64.w,
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (context, error, stackTrace) {
                                                      return Icon(
                                                        Icons.local_offer,
                                                        color: Colors.white,
                                                        size: context.isMobile ? 28.w : 32.w,
                                                      );
                                                    },
                                                    loadingBuilder: (context, child, loadingProgress) {
                                                      return Container(
                                                        width: context.isMobile ? 60.w : 64.w,
                                                        height: context.isMobile ? 60.w : 64.w,
                                                        color: Colors.white24,
                                                        child: Center(
                                                          child: SizedBox(
                                                            width: context.isMobile ? 16.w : 20.w,
                                                            height: context.isMobile ? 16.w : 20.w,
                                                            child: CircularProgressIndicator(
                                                              strokeWidth: 2,
                                                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                                            ),
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                )
                                              : Icon(
                                                  Icons.local_offer,
                                                  color: Colors.white,
                                                  size: context.isMobile ? 28.w : 32.w,
                                                ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                            // Navigation arrows
                            Positioned(
                              left: context.responsivePaddingSm,
                              child: IconButton(
                                icon: Icon(
                                  Icons.chevron_left,
                                  color: Colors.white70,
                                  size: context.isMobile ? 28.w : 32.w,
                                ),
                                onPressed: () {
                                  if (!_adController.hasClients) return;
                                  final cur = (_adController.page ??
                                          _adController.initialPage)
                                      .round();
                                  final prev =
                                      (cur - 1 + _ads.length) % _ads.length;
                                  _adController.animateToPage(
                                    prev,
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                  );
                                },
                              ),
                            ),
                            Positioned(
                              right: context.responsivePaddingSm,
                              child: IconButton(
                                icon: Icon(
                                  Icons.chevron_right,
                                  color: Colors.white70,
                                  size: context.isMobile ? 28.w : 32.w,
                                ),
                                onPressed: () {
                                  if (!_adController.hasClients) return;
                                  final cur = (_adController.page ??
                                          _adController.initialPage)
                                      .round();
                                  final next = (cur + 1) % _ads.length;
                                  _adController.animateToPage(
                                    next,
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: context.responsiveGap),
                    ],
                  ),
                ),
                if (_loading)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (_error)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Failed to load facilities'),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _load,
                            child: const Text('Try Again'),
                          ),
                        ],
                      ),
                    ),
                  )
                else if (_filtered.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('No facilities found'),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _load,
                            child: const Text('Try Again'),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: context.isMobile ? 350.h : 400.h,
                      child: FacilitiesList(
                        facilities: _filtered,
                        onLoadMore: _loadMore,
                        currentLocation: _currentLocation,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || !_hasMore) return;
    setState(() => _isLoadingMore = true);
    final nextPage = _currentPage + 1;
    final bases = ['https://findmed-backend-1.onrender.com'];
    for (final b in bases) {
      try {
        final uri = Uri.parse('$b/api/facilities')
            .replace(queryParameters: {
              'page': nextPage.toString(),
              'limit': _pageSize.toString(),
              if (_type != 'all') 'type': _type,
              if (_openNow) 'openNow': 'true',
              if (_hospitalTypeFilter != null) 'hospitalType': _hospitalTypeFilter!,
              if (_pharmacyTypeFilter != null) 'pharmacyType': _pharmacyTypeFilter!,
              if (_hospitalOwnershipFilter != null) 'hospitalOwnership': _hospitalOwnershipFilter!,
              if (_pharmacyOwnershipFilter != null) 'pharmacyOwnership': _pharmacyOwnershipFilter!,
              if (_ownershipFilter != 'any') 'ownership': _ownershipFilter,
              if (_radiusMeters != null) 'radius': _radiusMeters.toString(),
            });
        final r = await http.get(uri).timeout(const Duration(seconds: 60));
        if (r.statusCode == 200) {
          final data = jsonDecode(r.body) as List<dynamic>;
          final list =
              data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
          if (mounted) {
            setState(() {
              _all.addAll(list);
              _filtered.addAll(list);
              _currentPage = nextPage;
              _hasMore = list.length == _pageSize;
              _isLoadingMore = false;
            });
          }
          return;
        }
      } catch (e) {
        continue;
      }
    }
    setState(() => _isLoadingMore = false);
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final BuildContext context;
  final bool isEmergency;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.context,
    this.isEmergency = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(TailwindRadius.lg),
      child: Container(
        padding: EdgeInsets.all(context.responsivePaddingSm),
        decoration: BoxDecoration(
          color: isEmergency 
              ? TailwindColors.red50 
              : context.isDarkMode ? TailwindColors.gray800 : TailwindColors.gray50,
          borderRadius: BorderRadius.circular(TailwindRadius.lg),
          border: Border.all(
            color: isEmergency 
                ? TailwindColors.red200
                : context.isDarkMode ? TailwindColors.gray700 : TailwindColors.gray200,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: context.isMobile ? 20.w : 24.w,
              color: isEmergency 
                  ? TailwindColors.red500
                  : context.isDarkMode ? Colors.white : TailwindColors.gray700,
            ),
            SizedBox(height: context.responsiveGapSm),
            Text(
              label,
              style: TextStyle(
                fontSize: context.responsiveTextSm,
                fontWeight: FontWeight.w500,
                color: isEmergency 
                    ? TailwindColors.red700
                    : context.isDarkMode ? Colors.white70 : TailwindColors.gray600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}