import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:write_story/configs/theme_config.dart';
import 'package:write_story/storages/theme_mode_storage.dart';

class ThemeNotifier extends ChangeNotifier {
  ThemeModeStorage storage = ThemeModeStorage();
  bool isDarkMode = false;

  load() async {
    final result = await storage.getBool();
    if (result != null) {
      isDarkMode = result == true;
    }
    notifyListeners();
  }

  toggleTheme() async {
    await storage.setBool(value: !isDarkMode);
    load();
  }

  ThemeData get theme {
    return isDarkMode ? ThemeConfig.dark : ThemeConfig.light;
  }
}

final themeProvider = ChangeNotifierProvider<ThemeNotifier>((ref) {
  return ThemeNotifier()..load();
});
