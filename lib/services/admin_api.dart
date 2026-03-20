import 'api.dart';

class AdminApi {
  /// Fetch server-side admin settings (from GET /api/admin/settings)
  static Future<Map<String, dynamic>> getSettings() async {
    return await Api.get('/api/admin/settings');
  }

  /// Update settings (not used by the mobile app by default)
  static Future<Map<String, dynamic>> updateSettings(Map body) async {
    return await Api.put('/api/admin/settings', body);
  }
}
