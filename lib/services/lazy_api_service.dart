import 'package:flutter/foundation.dart';
import 'api.dart';

/// Service to manage lazy API calls based on page visits
class LazyApiService {
  static final LazyApiService _instance = LazyApiService._internal();
  factory LazyApiService() => _instance;
  LazyApiService._internal();

  // Track which pages have been loaded
  final Set<String> _loadedPages = <String>{};
  
  // Track which API calls have been made
  final Map<String, bool> _apiCallStatus = <String, bool>{};

  /// Initialize with home page only (essential calls)
  Future<void> initializeHomePage() async {
    debugPrint('LazyApiService: Initializing home page with essential API calls only');
    
    // Only make essential API calls for home page
    await _makeApiCallOnce('business_mode', () async {
      try {
        await Api.get('/api/admin/settings');
      } catch (e) {
        debugPrint('Business mode check failed: $e');
      }
    });
    
    await _makeApiCallOnce('health_check', () async {
      try {
        await Api.get('/api/health');
      } catch (e) {
        debugPrint('Health check failed: $e');
      }
    });
    
    // Mark home page as loaded
    _loadedPages.add('home');
  }

  /// Load data for a specific page only when needed
  Future<void> loadPageData(String pageName, Map<String, Future<void> Function()> apiCalls) async {
    if (_loadedPages.contains(pageName)) {
      debugPrint('LazyApiService: $pageName already loaded, skipping API calls');
      return;
    }
    
    debugPrint('LazyApiService: Loading data for $pageName');
    
    for (final entry in apiCalls.entries) {
      final callName = entry.key;
      final callFunction = entry.value;
      
      await _makeApiCallOnce(callName, callFunction);
    }
    
    _loadedPages.add(pageName);
  }

  /// Make an API call only once per session
  Future<void> _makeApiCallOnce(String callName, Future<void> Function() callFunction) async {
    if (_apiCallStatus[callName] == true) {
      debugPrint('LazyApiService: $callName already called, skipping');
      return;
    }
    
    try {
      _apiCallStatus[callName] = true;
      await callFunction();
    } catch (e) {
      debugPrint('LazyApiService: $callName failed: $e');
      // Don't reset status on failure to prevent repeated calls
    }
  }

  /// Check if a page has been loaded
  bool isPageLoaded(String pageName) {
    return _loadedPages.contains(pageName);
  }

  /// Reset all cached data (for testing or refresh)
  void reset() {
    debugPrint('LazyApiService: Resetting all cached data');
    _loadedPages.clear();
    _apiCallStatus.clear();
  }

  /// Force reload a specific page
  Future<void> reloadPage(String pageName, Map<String, Future<void> Function()> apiCalls) async {
    debugPrint('LazyApiService: Force reloading $pageName');
    _loadedPages.remove(pageName);
    
    // Reset specific API call statuses for this page
    for (final callName in apiCalls.keys) {
      _apiCallStatus.remove(callName);
    }
    
    await loadPageData(pageName, apiCalls);
  }
}
