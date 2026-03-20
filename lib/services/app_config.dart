import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'api.dart';

/// Simple application configuration persisted locally.
class AppConfig {
  AppConfig._internal();
  static final AppConfig instance = AppConfig._internal();

  static const _kHostKey = 'api_host';
  static const _kUserBusinessModeKey = 'user_business_mode';

  final ValueNotifier<String?> host = ValueNotifier<String?>(null);
  final ValueNotifier<bool> businessMode = ValueNotifier<bool>(false);
  final ValueNotifier<bool> userBusinessMode = ValueNotifier<bool>(false);
  final ValueNotifier<bool> effectiveBusinessMode = ValueNotifier<bool>(false);
  
  // Add cache to prevent repeated calls
  bool _businessModeChecked = false;
  DateTime? _lastCheckTime;

  Future<void> init() async {
    final sp = await SharedPreferences.getInstance();
    host.value = sp.getString(_kHostKey);
    userBusinessMode.value = sp.getBool(_kUserBusinessModeKey) ?? false;
    
    // Only check business mode if not recently checked
    if (!_businessModeChecked || 
        _lastCheckTime == null || 
        DateTime.now().difference(_lastCheckTime!).inMinutes > 5) {
      await _checkBusinessModeSafe();
      _updateEffective();
    }
  }

  Future<void> _checkBusinessModeSafe() async {
    // Prevent repeated calls
    if (_businessModeChecked && 
        _lastCheckTime != null && 
        DateTime.now().difference(_lastCheckTime!).inMinutes < 5) {
      return;
    }
    
    try {
      // Add timeout to prevent hanging - use production endpoint
      final res = await Api.get('/api/admin/settings').timeout(Duration(seconds: 60));
      // Production backend doesn't have businessMode field, default to false
      businessMode.value = false;
      _businessModeChecked = true;
      _lastCheckTime = DateTime.now();
    } catch (e) {
      // Only print error once per session
      if (!_businessModeChecked) {
        debugPrint('Backend business mode unavailable, using default');
      }
      businessMode.value = false; // Default to false on error
      _businessModeChecked = true;
      _lastCheckTime = DateTime.now();
    }
    _updateEffective();
  }

  Future<void> setHost(String? h) async {
    final sp = await SharedPreferences.getInstance();
    if (h == null || h.isEmpty) {
      await sp.remove(_kHostKey);
      host.value = null;
    } else {
      await sp.setString(_kHostKey, h);
      host.value = h;
    }
  }

  Future<void> _checkBusinessMode() async {
    try {
      final res = await Api.get('/api/settings');
      businessMode.value = res['businessMode'] == true;
    } catch (e) {
      businessMode.value = false;
    }
    _updateEffective();
  }

  void _updateEffective() {
    effectiveBusinessMode.value = businessMode.value && userBusinessMode.value;
  }

  Future<void> updateBusinessMode() async {
    await _checkBusinessModeSafe();
  }

  // Test API connection
  Future<bool> testConnection() async {
    try {
      debugPrint('Testing connection to ${Api.BASE}');
      final res = await Api.get('/api/health').timeout(Duration(seconds: 60));
      return res != null && res['ok'] == true;
    } catch (e) {
      // Silently handle connection errors
      return false;
    }
  }

  Future<void> setUserBusinessMode(bool value) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setBool(_kUserBusinessModeKey, value);
    userBusinessMode.value = value;
    _updateEffective();
  }
}
