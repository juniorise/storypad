import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:write_story/storages/list_layout_storage.dart';
import 'package:write_story/storages/theme_mode_storage.dart';

class ThemeNotifier extends ChangeNotifier {
  ThemeModeStorage storage = ThemeModeStorage();
  ListLayoutStorage layoutStorage = ListLayoutStorage();
  bool? isDarkMode;
  bool isNormalList = false;

  ThemeMode get themeMode {
    if (this.isDarkMode == null) {
      return ThemeMode.system;
    } else if (this.isDarkMode == true) {
      return ThemeMode.dark;
    } else {
      return ThemeMode.light;
    }
  }

  loadThemeMode() async {
    final result = await storage.getBool();
    isDarkMode = result;
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
    if (isDarkMode != null) {
      await storage.setBool(value: !(isDarkMode == true));
    } else {
      var brightness = SchedulerBinding.instance?.window.platformBrightness;
      bool _isDarkMode = brightness == Brightness.dark;
      await storage.setBool(value: !(_isDarkMode == true));
    }
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
