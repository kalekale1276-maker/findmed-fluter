import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService {
  ThemeService._();
  static final ThemeService instance = ThemeService._();

  final ValueNotifier<bool> isDark = ValueNotifier<bool>(false);

  Future<void> init() async {
    final sp = await SharedPreferences.getInstance();
    isDark.value = sp.getBool('darkTheme') ?? false;
  }

  Future<void> setDark(bool value) async {
    isDark.value = value;
    final sp = await SharedPreferences.getInstance();
    await sp.setBool('darkTheme', value);
  }
}
