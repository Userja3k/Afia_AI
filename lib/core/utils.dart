import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AppUtils {
  static Future<void> saveToHistory(Map<String, dynamic> diagnostic) async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getString('diagnostic_history') ?? '[]';
    final history = List<Map<String, dynamic>>.from(
      json.decode(historyJson).map((x) => Map<String, dynamic>.from(x))
    );
    
    diagnostic['date'] = DateTime.now().toIso8601String();
    history.insert(0, diagnostic);
    
    // Garder seulement les 50 derniers diagnostics
    if (history.length > 50) {
      history.removeRange(50, history.length);
    }
    
    await prefs.setString('diagnostic_history', json.encode(history));
  }

  static void showSnackBar(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : const Color(0xFFFF7A00),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  static void showLoadingDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 20),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
  }

  static String formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} à ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}