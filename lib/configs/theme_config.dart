import 'package:flutter/material.dart';
import 'package:storypad/constants/theme_constant.dart';

class ThemeConfig {
  List<String> fontFamilyFallback;
  ThemeConfig(this.fontFamilyFallback);

  ThemeData get({required isDarkMode}) {
    final theme = ThemeConstant(fontFamilyFallback);
    return isDarkMode ? theme.dark : theme.light;
  }

  static Color lighten(Color color, [double amount = 0.2]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    final hslLight = hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));
    return hslLight.toColor();
  }

  static const List<String> fontFamilyFallbackExample = ["Hello", "សួរស្តី"];
}
