import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'app_config.dart';

class Api {
  // Cache to prevent repeated error messages
  static final Map<String, DateTime> _lastErrorTime = {};
  static const Duration _errorCooldown = Duration(minutes: 1);
  
  // Global offline mode to prevent all API calls when backend is down
  static bool _isOfflineMode = false;
  static DateTime? _lastOfflineCheck;
  
  // Queue to process HTTP requests sequentially to shield the backend from burst requests
  static Future<dynamic> _requestQueue = Future.value();
  
  static Future<T> _enqueue<T>(Future<T> Function() action) {
    final completer = Completer<T>();
    _requestQueue = _requestQueue.whenComplete(() async {
      try {
        final result = await action();
        completer.complete(result);
      } catch (e, st) {
        completer.completeError(e, st);
      }
      // Small delay between requests
      await Future.delayed(const Duration(milliseconds: 200));
    });
    return completer.future;
  }

  // Automatic retry with exponential backoff for backend stability
  static Future<http.Response> _executeWithRetry(Future<http.Response> Function() action) async {
    int maxRetries = 3;
    for (int i = 0; i < maxRetries; i++) {
      try {
        final res = await action().timeout(const Duration(seconds: 60));
        // Return immediately if it's a successful response or user error (4xx)
        if (res.statusCode < 500) return res;
        
        // Final attempt completed, return the 5xx response
        if (i == maxRetries - 1) return res;
      } catch (e) {
        // Full failure (network down, complete timeout)
        if (i == maxRetries - 1) rethrow;
      }
      // Wait before retrying (exponential backoff: 2s, 4s...)
      debugPrint('API Retry attempt ${i+1}');
      await Future.delayed(Duration(seconds: 2 * (i + 1)));
    }
    throw Exception('Retry mechanism failed');
  }

  // Picks an appropriate base URL depending on the platform:
  // - Android emulator: 10.0.2.2 -> host machine
  // - iOS simulator / desktop: localhost or 127.0.0.1
  static String get BASE {
    // Use production backend URL
    return 'https://findmed-backend-1.onrender.com';
  }

  static Future<Map<String, dynamic>> post(String path, Map body,
      {Map<String, String>? headers}) async {
    // Check offline mode first
    if (_isOfflineMode && _shouldUseOfflineMode()) {
      throw Exception('App is in offline mode');
    }
    
    try {
      return await _enqueue(() async {
      final uri = Uri.parse('$BASE$path');
      debugPrint('API POST: $uri');
      
      final res = await _executeWithRetry(() => http.post(uri,
          body: jsonEncode(body),
          headers: {'Content-Type': 'application/json', ...?headers}));
      
      debugPrint('API Response Status: ${res.statusCode}');
      
      if (res.statusCode >= 200 && res.statusCode < 300) {
        _resetOfflineMode(); // Reset on success
        return jsonDecode(res.body) as Map<String, dynamic>;
      }
      
      // Try to extract a helpful message from response body
      try {
        final m = jsonDecode(res.body);
        if (m is Map && m['message'] != null) {
          throw Exception('${m['message']}');
        }
      } catch (_) {}
      // Fallback to raw body or status
      String respBody = res.body.isNotEmpty ? res.body : 'HTTP ${res.statusCode}';
      if (respBody.trim().startsWith('<')) {
        respBody = 'HTTP ${res.statusCode}: HTML Error Response from server';
      }
      throw Exception(respBody);
      });
    } catch (e) {
      _setOfflineMode();
      _logErrorOnce('API POST Error for $path', e);
      rethrow;
    }
  }

  static Future<dynamic> get(String path,
      {Map<String, String>? params, Map<String, String>? headers}) async {
    // Check offline mode first
    if (_isOfflineMode && _shouldUseOfflineMode()) {
      return null;
    }
    
    try {
      return await _enqueue(() async {
      var uri = Uri.parse('$BASE$path');
      if (params != null && params.isNotEmpty) {
        uri = uri.replace(queryParameters: params);
      }
      debugPrint('API GET: $uri');
      
      final res = await _executeWithRetry(() => http.get(uri, headers: headers));
      
      debugPrint('API Response Status: ${res.statusCode}');
      
      if (res.statusCode >= 200 && res.statusCode < 300) {
        if (res.body.isEmpty) return null;
        _resetOfflineMode(); // Reset on success
        return jsonDecode(res.body);
      }
      
      // Try to extract a helpful message from response body
      try {
        final m = jsonDecode(res.body);
        if (m is Map && m['message'] != null) {
          throw Exception('${m['message']}');
        }
      } catch (_) {}
      // Fallback to raw body or status
      String respBody = res.body.isNotEmpty ? res.body : 'HTTP ${res.statusCode}';
      if (respBody.trim().startsWith('<')) {
        respBody = 'HTTP ${res.statusCode}: HTML Error Response from server';
      }
      throw Exception(respBody);
      });
    } catch (e) {
      _setOfflineMode();
      _logErrorOnce('API GET Error for $path', e);
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> delete(String path,
      {Map<String, String>? headers}) async {
    // Check offline mode first
    if (_isOfflineMode && _shouldUseOfflineMode()) {
      throw Exception('App is in offline mode');
    }
    
    try {
      return await _enqueue(() async {
      final uri = Uri.parse('$BASE$path');
      final res = await _executeWithRetry(() => http.delete(uri, headers: headers));
      if (res.statusCode >= 200 && res.statusCode < 300) {
        _resetOfflineMode(); // Reset on success
        return jsonDecode(res.body) as Map<String, dynamic>;
      }
      // Try to extract a helpful message from the response body
      try {
        final m = jsonDecode(res.body);
        if (m is Map && m['message'] != null) {
          throw Exception('${m['message']}');
        }
      } catch (_) {}
      // Fallback to raw body or status
      String respBody = res.body.isNotEmpty ? res.body : 'HTTP ${res.statusCode}';
      if (respBody.trim().startsWith('<')) {
        respBody = 'HTTP ${res.statusCode}: HTML Error Response from server';
      }
      throw Exception(respBody);
      });
    } catch (e) {
      _logErrorOnce('API DELETE Error for $path', e);
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> put(String path, Map body,
      {Map<String, String>? headers}) async {
    try {
      return await _enqueue(() async {
      final uri = Uri.parse('$BASE$path');
      final res = await _executeWithRetry(() => http.put(uri,
          body: jsonEncode(body),
          headers: {'Content-Type': 'application/json', ...?headers}));
      if (res.statusCode >= 200 && res.statusCode < 300) {
        return jsonDecode(res.body) as Map<String, dynamic>;
      }
      // Try to extract a helpful message from the response body
      try {
        final m = jsonDecode(res.body);
        if (m is Map && m['message'] != null) {
          throw Exception('${m['message']}');
        }
      } catch (_) {}
      // Fallback to raw body or status
      String respBody = res.body.isNotEmpty ? res.body : 'HTTP ${res.statusCode}';
      if (respBody.trim().startsWith('<')) {
        respBody = 'HTTP ${res.statusCode}: HTML Error Response from server';
      }
      throw Exception(respBody);
      });
    } catch (e) {
      _logErrorOnce('API PUT Error for $path', e);
      rethrow;
    }
  }

  static void _logErrorOnce(String message, dynamic error) {
    final now = DateTime.now();
    final lastTime = _lastErrorTime[message];
    
    // Only log if this error hasn't been seen in the last minute
    if (lastTime == null || now.difference(lastTime) > _errorCooldown) {
      debugPrint('$message: $error');
      _lastErrorTime[message] = now;
    }
  }

  static bool _shouldUseOfflineMode() {
    if (_lastOfflineCheck == null) return false;
    return DateTime.now().difference(_lastOfflineCheck!).inMinutes < 2;
  }

  static void _setOfflineMode() {
    _isOfflineMode = true;
    _lastOfflineCheck = DateTime.now();
  }

  static void _resetOfflineMode() {
    _isOfflineMode = false;
    _lastOfflineCheck = null;
  }
}
