import 'package:flutter/material.dart';

class SettingsModel {
  final Locale locale;
  final bool isDarkMode;
  final double textScale;
  final bool notificationsEnabled;

  SettingsModel({
    required this.locale,
    required this.isDarkMode,
    required this.textScale,
    required this.notificationsEnabled,
  });

  factory SettingsModel.defaultSettings() {
    return SettingsModel(
      locale: const Locale('fr'),
      isDarkMode: false,
      textScale: 1.0,
      notificationsEnabled: true,
    );
  }

  SettingsModel copyWith({
    Locale? locale,
    bool? isDarkMode,
    double? textScale,
    bool? notificationsEnabled,
  }) {
    return SettingsModel(
      locale: locale ?? this.locale,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      textScale: textScale ?? this.textScale,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'locale': locale.languageCode,
      'isDarkMode': isDarkMode,
      'textScale': textScale,
      'notificationsEnabled': notificationsEnabled,
    };
  }

  factory SettingsModel.fromJson(Map<String, dynamic> json) {
    return SettingsModel(
      locale: Locale(json['locale'] ?? 'fr'),
      isDarkMode: json['isDarkMode'] ?? false,
      textScale: json['textScale']?.toDouble() ?? 1.0,
      notificationsEnabled: json['notificationsEnabled'] ?? true,
    );
  }
}