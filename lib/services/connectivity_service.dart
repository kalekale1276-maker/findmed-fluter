import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

/// Simple connectivity helper that emits `true` when the app has internet access
/// and `false` otherwise. It combines connectivity_plus status with a quick
/// DNS lookup to ensure the connection actually reaches the internet.
class ConnectivityService {
  ConnectivityService._internal() {
    _init();
  }

  static final ConnectivityService instance = ConnectivityService._internal();

  final _controller = StreamController<bool>.broadcast();
  Stream<bool> get onStatusChange => _controller.stream;

  bool _online = true;
  bool get isOnline => _online;

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<dynamic>? _sub;

  void _init() {
    _sub = _connectivity.onConnectivityChanged.listen((_) => _check());
    // initial check
    _check();
  }

  Future<void> _check() async {
    final connected = await checkConnection();
    if (connected != _online) {
      _online = connected;
      _controller.add(_online);
    }
  }

  /// Returns true if there is an active internet connection.
  Future<bool> checkConnection() async {
    try {
      final result = await _connectivity.checkConnectivity();
      if (result is ConnectivityResult) {
        if (result == ConnectivityResult.none) return false;
      }
    
      // Web builds cannot use dart:io InternetAddress.lookup reliably.
      // For web, assume there is internet connectivity when the platform
      // reports a non-none network (the browser environment handles DNS).
      if (kIsWeb) return true;

      // For non-web platforms, perform a small HTTP GET to verify reachability.
      // Use a short timeout to avoid long waits when offline.
      try {
        final res = await http
            .get(Uri.parse('https://example.com'))
            .timeout(const Duration(seconds: 5));
        if (res.statusCode >= 200 && res.statusCode < 400) return true;
      } catch (_) {
        // fallback to DNS lookup if HTTP fails for some reason
      }

      // perform a DNS lookup to verify internet reachability as a last resort
      final List<InternetAddress> list =
          await InternetAddress.lookup('example.com')
              .timeout(const Duration(seconds: 5));
      return list.isNotEmpty && list[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  Future<void> dispose() async {
    await _sub?.cancel();
    await _controller.close();
  }
}
