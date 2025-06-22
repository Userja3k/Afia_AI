import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageManager with ChangeNotifier {
  Locale _currentLocale = const Locale('fr');

  Locale get currentLocale => _currentLocale;

  LanguageManager() {
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString('languageCode') ?? 'fr';
    _currentLocale = Locale(languageCode);
    notifyListeners();
  }

  Future<void> changeLocale(Locale newLocale) async {
    _currentLocale = newLocale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('languageCode', newLocale.languageCode);
    notifyListeners();
  }
}
