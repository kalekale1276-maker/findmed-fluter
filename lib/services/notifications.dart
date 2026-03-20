import 'package:shared_preferences/shared_preferences.dart';
import 'api.dart';

class NotificationsService {
  // list notifications by email or feedbackId
  static Future<List<Map<String, dynamic>>> list(
      {String? email, String? feedbackId}) async {
    final params = <String, String>{};
    if (email != null) params['email'] = email;
    if (feedbackId != null) params['feedbackId'] = feedbackId;
    final res = await Api.get('/api/notifications', params: params);
    return List<Map<String, dynamic>>.from(res['notifications'] ?? []);
  }

  static Future<void> markRead(String id) async {
    await Api.put('/api/notifications/$id/read', {});
  }

  static Future<Map<String, dynamic>> cleanup({List<String>? keepIds}) async {
    final body = <String, dynamic>{};
    if (keepIds != null) body['keepIds'] = keepIds;
    final res = await Api.post('/api/notifications/cleanup', body);
    return res;
  }

  static Future<String?> lastFeedbackId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('lastFeedbackId');
  }

  static Future<void> setLastFeedbackId(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('lastFeedbackId', id);
  }
}
