import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:storypad/mixins/change_notifier_mixin.dart';
import 'package:storypad/services/storages/preference_storages//list_layout_storage.dart';
import 'package:storypad/services/storages/preference_storages//theme_mode_storage.dart';

class ThemeNotifier extends ChangeNotifier with ChangeNotifierMixin {
  ThemeModeStorage storage = ThemeModeStorage();
  ListLayoutStorage layoutStorage = ListLayoutStorage();
  bool? _isDarkMode;
  bool isNormalList = false;

  bool? get isDarkModeSystem => this._isDarkMode;
  bool get isDarkMode {
    if (this._isDarkMode == null) {
      var brightness = SchedulerBinding.instance?.window.platformBrightness;
      bool _isDarkMode = brightness == Brightness.dark;
      return _isDarkMode;
    } else {
      return this._isDarkMode == true;
    }
  }

  ThemeMode get themeMode {
    if (this._isDarkMode == null) {
      return ThemeMode.system;
    } else if (this._isDarkMode == true) {
      return ThemeMode.dark;
    } else {
      return ThemeMode.light;
    }
  }

  loadThemeMode() async {
    final result = await storage.getBool();
    _isDarkMode = result;
    notifyListeners();
  }

  loadLayoutStorage() async {
    final result = await layoutStorage.getBool();
    if (result != null) {
      isNormalList = result == true;
    }
    notifyListeners();
  }

  setDarkMode(bool? value) async {
    if (value != null) {
      await storage.setBool(value: value);
    } else {
      await storage.clear();
    }
    loadThemeMode();
  }

  toggleTheme() async {
    await storage.setBool(value: !this.isDarkMode);
    loadThemeMode();
  }

  setListLayout(bool value) async {
    await layoutStorage.setBool(value: value);
    loadLayoutStorage();
  }

  toggleListLayout() async {
    await layoutStorage.setBool(value: !isNormalList);
    loadLayoutStorage();
  }
}

final themeProvider = ChangeNotifierProvider<ThemeNotifier>((ref) {
  final notifier = ThemeNotifier();
  notifier.loadThemeMode();
  notifier.loadLayoutStorage();
  return notifier;
});
