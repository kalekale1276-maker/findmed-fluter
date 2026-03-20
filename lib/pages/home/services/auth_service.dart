import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  AuthService._internal();
  static final AuthService instance = AuthService._internal();

  factory AuthService() => AuthService._internal();

  AuthService._internal();

  Map<String, dynamic>? get user => null;
  String? get token => null;
}
