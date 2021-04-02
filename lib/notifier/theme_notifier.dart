import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:write_story/configs/theme_config.dart';
import 'package:write_story/storages/list_layout_storage.dart';
import 'package:write_story/storages/theme_mode_storage.dart';

class ThemeNotifier extends ChangeNotifier {
  ThemeModeStorage storage = ThemeModeStorage();
  ListLayoutStorage layoutStorage = ListLayoutStorage();
  bool isDarkMode = false;
  bool isNormalList = false;

  loadThemeMode() async {
    final result = await storage.getBool();
    if (result != null) {
      isDarkMode = result == true;
    }
    notifyListeners();
  }

  loadLayoutStorage() async {
    final result = await layoutStorage.getBool();
    if (result != null) {
      isNormalList = result == true;
    }
    notifyListeners();
  }

  toggleTheme() async {
    await storage.setBool(value: !isDarkMode);
    loadThemeMode();
  }

  toggleListLayout() async {
    await layoutStorage.setBool(value: !isNormalList);
    loadLayoutStorage();
  }

  ThemeData get theme {
    return isDarkMode ? ThemeConfig.dark : ThemeConfig.light;
  }
}

final themeProvider = ChangeNotifierProvider<ThemeNotifier>((ref) {
  final notifier = ThemeNotifier();
  notifier.loadThemeMode();
  notifier.loadLayoutStorage();
  return notifier;
});
