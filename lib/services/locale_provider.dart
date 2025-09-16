
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  Locale? _locale;
  Locale? get locale => _locale;

  Future<void> load() async {
    final sp = await SharedPreferences.getInstance();
    final code = sp.getString('lang') ?? 'zh-TW';
    _locale = _parse(code);
    notifyListeners();
  }

  Future<void> setLocale(String code) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString('lang', code);
    _locale = _parse(code);
    notifyListeners();
  }

  Locale _parse(String code) {
    if (code.contains('-')) {
      final parts = code.split('-');
      return Locale(parts[0], parts[1]);
    }
    return Locale(code);
  }
}
