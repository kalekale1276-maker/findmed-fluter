library flutter_web_config;

import 'dart:html' as html;

/// Automatically configures Flutter web to use preferred ports
class FlutterWebConfig {
  static const List<int> preferredPorts = [50000, 55000, 60000, 65000, 70000];
  
  /// Initialize web configuration
  static void initialize() {
    _redirectIfNeeded();
  }
  
  /// Redirect to preferred port if needed
  static void _redirectIfNeeded() {
    try {
      final currentUrl = html.window.location.href;
      final uri = Uri.parse(currentUrl);
      
      // Only redirect if we're on localhost and not on a preferred port
      if (uri.host == 'localhost' && !preferredPorts.contains(uri.port)) {
        // Try each preferred port until we find one that works
        for (int port in preferredPorts) {
          try {
            final newUri = uri.replace(port: port);
            html.window.location.replace(newUri.toString());
            break;
          } catch (e) {
            continue; // Try next port
          }
        }
      }
    } catch (e) {
      // Silently fail to avoid breaking the app
    }
  }
}
