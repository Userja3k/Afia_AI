import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SizeManager with ChangeNotifier {
  double _textScale = 1.0;

  double get textScale => _textScale;

  SizeManager() {
    _loadTextScale();
  }

  Future<void> _loadTextScale() async {
    final prefs = await SharedPreferences.getInstance();
    _textScale = prefs.getDouble('textScale') ?? 1.0;
    notifyListeners();
  }

  Future<void> setTextScale(double scale) async {
    _textScale = scale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('textScale', scale);
    notifyListeners();
  }
}
