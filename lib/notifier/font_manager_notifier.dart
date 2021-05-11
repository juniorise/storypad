import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:storypad/main.dart';
import 'package:storypad/mixins/change_notifier_mixin.dart';
import 'package:storypad/storages/font_manager_storage.dart';

const Map<String, String> fontFamilyFallbackDefault = {
  "en": "Quicksand",
  "km": "Kantumruy",
};

class FontManagerNotifier extends ChangeNotifier with ChangeNotifierMixin {
  FontManagerStorage storage = FontManagerStorage();

  bool _loading = true;
  List<String?>? _fontFamilyFallback;

  setLoading(bool value) {
    this._loading = value;
    notifyListeners();
  }

  load() async {
    setLoading(true);
    final result = await storage.readAsMap() ?? fontFamilyFallbackDefault;
    final families = initSupportedLocales.map((locale) {
      final code = locale.languageCode;
      return result[code];
    }).toList();
    _fontFamilyFallback = families;
    setLoading(false);
  }

  Future<bool> replaceFontInMap(
    String familyName,
    Locale locale,
  ) async {
    try {
      final storage = FontManagerStorage();
      Map<String, dynamic>? result = await storage.readAsMap();
      if (result == null) {
        result = fontFamilyFallbackDefault;
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
    return _fontFamilyFallback?.map((e) => "$e").toList() ??
        ["Quicksand", "Kantumruy"];
  }

  bool get loading => _loading;
}

final fontManagerProvider = ChangeNotifierProvider<FontManagerNotifier>(
  (ref) {
    return FontManagerNotifier()..load();
  },
);
