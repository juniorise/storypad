import 'package:flutter/material.dart';
import 'package:storypad/models/font_model.dart';

class AppConstant {
  AppConstant._internal();
  static const Map<String, String> fontFamilyFallbackDefault = {
    "en": "Quicksand",
    "km": "Kantumruy",
  };

  static const initSupportedLocales = [
    Locale('en'),
    Locale('km'),
  ];

  static final Map<String, FontModel> availableFonts = {
    "Quicksand": FontModel(
      familyName: "Quicksand",
      locale: Locale("en"),
    ),
    "Lora": FontModel(
      familyName: "Lora",
      locale: Locale("en"),
    ),
    "OpenSans": FontModel(
      familyName: "OpenSans",
      locale: Locale("en"),
    ),
    "Kantumruy": FontModel(
      familyName: "Kantumruy",
      locale: Locale("km"),
    ),
    "Battambang": FontModel(
      familyName: "Battambang",
      locale: Locale("km"),
    ),
    "Bokor": FontModel(
      familyName: "Bokor",
      locale: Locale("km"),
    ),
  };

  /// ```
  /// avaiableFontsMap = {
  ///   Locale("en"):[
  ///     "Quicksand",
  ///      ...
  ///   ],
  ///   Locale("km"):[
  ///     "Kantumruy",
  ///      ...
  ///   ],
  /// }
  /// ```
  static Map<Locale, List<FontModel>> get avaiableFontsMap {
    Map<Locale, List<FontModel>> fontsMap = {};
    availableFonts.forEach((key, value) {
      final locale = value.locale;
      if (fontsMap.containsKey(locale) && fontsMap[locale]?.isNotEmpty == true) {
        fontsMap[locale]?.add(value);
      } else {
        fontsMap[locale] = [value];
      }
    });
    return fontsMap;
  }

  static Map<Locale, String> localeExamples = {
    Locale("en"): "Almost before we knew it, we had left the ground.",
    Locale("km"): "ខ្ញុំបានមើលព្យុះ ដែលមានភាពស្រស់ស្អាតណាស់ ប៉ុន្តែគួរឲ្យខ្លាច",
  };
}
