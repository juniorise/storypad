import 'package:flutter/material.dart';

class FontModel {
  final String familyName;
  final Locale locale;

  FontModel({
    required this.familyName,
    required this.locale,
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
    ),
    "PlayfairDisplay": FontModel(
      familyName: "PlayfairDisplay",
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
}
