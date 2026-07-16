import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import '../../../core/constants/hive_keys.dart';
import 'app_settings_state.dart';

export 'app_settings_state.dart';

class AppSettingsCubit extends Cubit<AppSettingsState> {
  final Box _settingsBox;

  AppSettingsCubit(this._settingsBox) : super(_loadInitialState(_settingsBox));

  static AppSettingsState _loadInitialState(Box box) {
    final isDark = box.get(HiveKeys.isDarkMode, defaultValue: false);
    return AppSettingsState(
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      language: box.get('language', defaultValue: 'ar'),
      wifiOnly: box.get('wifiOnly', defaultValue: false),
      notificationsEnabled: box.get('notificationsEnabled', defaultValue: true),
      autoRetry: box.get('autoRetry', defaultValue: true),
    );
  }

  void toggleTheme() {
    final isDark = state.themeMode == ThemeMode.dark;
    final newMode = isDark ? ThemeMode.light : ThemeMode.dark;
    _settingsBox.put(HiveKeys.isDarkMode, !isDark);
    emit(state.copyWith(themeMode: newMode));
  }

  void setLanguage(String langCode) {
    _settingsBox.put('language', langCode);
    emit(state.copyWith(language: langCode));
  }

  void toggleWifiOnly(bool value) {
    _settingsBox.put('wifiOnly', value);
    emit(state.copyWith(wifiOnly: value));
  }

  void toggleNotifications(bool value) {
    _settingsBox.put('notificationsEnabled', value);
    emit(state.copyWith(notificationsEnabled: value));
  }

  void toggleAutoRetry(bool value) {
    _settingsBox.put('autoRetry', value);
    emit(state.copyWith(autoRetry: value));
  }

  Future<void> clearHistory() async {
    await _settingsBox.delete(HiveKeys.recentReciters);
  }

  Future<void> clearCache() async {}

  Future<void> resetSettings() async {
    await _settingsBox.clear();
    emit(const AppSettingsState());
  }
}
