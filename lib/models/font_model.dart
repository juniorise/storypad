import 'package:flutter/material.dart';

class FontModel {
  final String familyName;
  String? previewFontUrl;
  final List<String> fontsUrl;
  final Locale locale;
  final bool isDefault;

  FontModel({
    required this.familyName,
    required this.fontsUrl,
    required this.locale,
    this.previewFontUrl,
    this.isDefault = false,
  });

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
      if (fontsMap.containsKey(locale) &&
          fontsMap[locale]?.isNotEmpty == true) {
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

  static final Map<String, FontModel> availableFonts = {
    "Quicksand": FontModel(
      familyName: "Quicksand",
      locale: Locale("en"),
      isDefault: true,
      fontsUrl: [],
    ),
    "Kantumruy": FontModel(
      familyName: "Kantumruy",
      locale: Locale("km"),
      isDefault: true,
      fontsUrl: [],
    ),
    "AbhayaLibre": FontModel(
      familyName: "AbhayaLibre",
      locale: Locale("en"),
      fontsUrl: [
        "https://github.com/google/fonts/raw/main/ofl/abhayalibre/AbhayaLibre-Bold.ttf",
        "https://github.com/google/fonts/raw/main/ofl/abhayalibre/AbhayaLibre-Regular.ttf",
        "https://github.com/google/fonts/raw/main/ofl/abhayalibre/AbhayaLibre-Medium.ttf"
      ],
    ),
    "Battambang": FontModel(
      familyName: "Battambang",
      locale: Locale("km"),
      fontsUrl: [
        "https://github.com/google/fonts/raw/main/ofl/battambang/Battambang-Regular.ttf",
        "https://github.com/google/fonts/raw/main/ofl/battambang/Battambang-Bold.ttf",
      ],
    ),
  };
}
