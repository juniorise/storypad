import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:storypad/constants/app_constant.dart';
import 'package:storypad/notifier/base_notifier.dart';
import 'package:storypad/services/storages/preference_storages//font_manager_storage.dart';

class FontManagerNotifier extends BaseNotifier {
  FontManagerStorage storage = FontManagerStorage();

  List<String?>? _fontFamilyFallback;

  load() async {
    final result = await storage.readAsMap() ?? AppConstant.fontFamilyFallbackDefault;
    final families = AppConstant.initSupportedLocales.map((locale) {
      final code = locale.languageCode;
      return result[code];
    }).toList();
    _fontFamilyFallback = families;
    notifyListeners();
  }

  Future<bool> replaceFontInMap(
    String familyName,
    Locale locale,
  ) async {
    try {
      final storage = FontManagerStorage();
      Map<String, dynamic>? result = await storage.readAsMap();
      if (result == null) {
        result = AppConstant.fontFamilyFallbackDefault;
      }

      final code = locale.languageCode;
      Map<String, String> map = Map.fromIterable(
        result.entries,
        key: (e) => "${e.key}",
        value: (e) {
          if (e.key == code) {
            return "$familyName";
          } else {
            return "${e.value}";
          }
        },
      );

      await storage.writeMap(map);
      await load();
      return true;
    } catch (e) {
      return false;
    }
  }

  List<String> get fontFamilyFallback {
    if (_fontFamilyFallback == null) {
      _fontFamilyFallback = ["Quicksand", "Kantumruy"];
    } else {
      _fontFamilyFallback?.removeWhere((e) => e == null);
    }
    return _fontFamilyFallback?.map((e) => "$e").toList() ?? ["Quicksand", "Kantumruy"];
  }
}

final fontManagerProvider = ChangeNotifierProvider.autoDispose<FontManagerNotifier>(
  (ref) {
    return FontManagerNotifier()..load();
  },
);
