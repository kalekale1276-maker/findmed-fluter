import './api.dart';

class ChatApi {
  /// List messages related to a user (GET /api/chat/messages?userId=...)
  static Future<List<dynamic>> listByUser(String userId,
      {int limit = 200}) async {
    final res = await Api.get('/chat/messages',
        params: {'userId': userId, 'limit': '$limit'});
    if (res is List) return res;
    return [];
  }

  /// Get a single conversation by id (GET /api/chat/conversation/:id)
  static Future<List<dynamic>> getConversation(String id) async {
    final res = await Api.get('/chat/conversation/$id');
    if (res is List) return res;
    return [];
  }

  /// Post a message (POST /api/chat/messages)
  static Future<dynamic> postMessage(Map<String, dynamic> body,
      {Map<String, String>? headers}) async {
    return await Api.post('/chat/messages', body, headers: headers);
  }
}
