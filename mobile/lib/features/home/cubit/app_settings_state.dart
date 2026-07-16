import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';

class AppSettingsState extends Equatable {
  final ThemeMode themeMode;
  final String language;
  final bool wifiOnly;
  final bool notificationsEnabled;
  final bool autoRetry;

  const AppSettingsState({
    this.themeMode = ThemeMode.light,
    this.language = 'ar',
    this.wifiOnly = false,
    this.notificationsEnabled = true,
    this.autoRetry = true,
  });

  AppSettingsState copyWith({
    ThemeMode? themeMode,
    String? language,
    bool? wifiOnly,
    bool? notificationsEnabled,
    bool? autoRetry,
  }) {
    return AppSettingsState(
      themeMode: themeMode ?? this.themeMode,
      language: language ?? this.language,
      wifiOnly: wifiOnly ?? this.wifiOnly,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      autoRetry: autoRetry ?? this.autoRetry,
    );
  }

  @override
  List<Object?> get props => [themeMode, language, wifiOnly, notificationsEnabled, autoRetry];
}
