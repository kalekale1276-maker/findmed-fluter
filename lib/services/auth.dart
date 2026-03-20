import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api.dart';

class AuthService extends ChangeNotifier {
  static final AuthService instance = AuthService._internal();
  AuthService._internal();

  Map<String, dynamic>? _user;
  String? _token;
  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
    final s = _prefs!.getString('user');
    if (s != null) {
      final m = jsonDecode(s) as Map<String, dynamic>;
      _user = m['user'];
      _token = m['token'];
      notifyListeners();
    }
  }

  bool get isLoggedIn => _user != null;
  Map<String, dynamic>? get user => _user;
  String? get token => _token;

  Future<void> _save(Map<String, dynamic> user, String? token) async {
    _user = user;
    _token = token;
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs!.setString('user', jsonEncode({'user': user, 'token': token}));
    notifyListeners();
  }

  Future<void> logout() async {
    _user = null;
    _token = null;
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs!.remove('user');
    notifyListeners();
  }

  Future<void> updateProfile(Map<String, dynamic> fields) async {
    // include id so backend knows which user to update
    final id = _user?['id'] ?? fields['id'];
    if (id == null) throw Exception('No user id');
    final payload = {'id': id, ...fields};
    final headers = _token != null ? {'Authorization': 'Bearer $_token'} : null;
    final res = await Api.post('/users/profile', payload, headers: headers);
    // If the backend returned a token, use it. Then fetch the authoritative
    // profile from the server so we persist the full user object locally.
    final token = res['token'] as String?;
    if (token != null) {
      _token = token;
    }
    try {
      final fresh = await fetchProfile();
      if (fresh != null) {
        await _save(Map<String, dynamic>.from(fresh), _token);
        return;
      }
    } catch (_) {
      // ignore and fall back to response body below
    }
    // Fallback: if the response itself contains the updated user fields,
    // persist that (remove any token key first).
    final user = Map<String, dynamic>.from(res);
    user.remove('token');
    await _save(user, _token);
  }

  Future<void> login(String email, String password) async {
    final res =
        await Api.post('/users/login', {'email': email, 'password': password});
    final token = res['token'] as String?;
    final user = Map<String, dynamic>.from(res);
    user.remove('token');
    await _save(user, token);
  }

  Future<void> register(Map<String, dynamic> payload) async {
    final res = await Api.post('/users/register', payload);
    final token = res['token'] as String?;
    final user = Map<String, dynamic>.from(res);
    user.remove('token');
    await _save(user, token);
  }

  Future<Map<String, dynamic>?> fetchProfile() async {
    final id = _user?['id'] ?? _user?['_id'];
    if (id == null) return null;
    final headers = _token != null ? {'Authorization': 'Bearer $_token'} : null;
    final res = await Api.get('/users/$id', headers: headers);
    return res;
  }

  Future<void> signInWithGoogle() async {
    // Google Sign-In is not configured for this build/environment.
    // Keep the method present so callers compile; throw to indicate
    // authentication is not available at runtime.
    throw UnimplementedError('Google Sign-In is not available in this build.');
  }
}
