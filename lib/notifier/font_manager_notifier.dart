import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:write_story/main.dart';
import 'package:write_story/models/font_model.dart';
import 'package:write_story/services/font_manager_service.dart';
import 'package:write_story/storages/font_manager_storage.dart';

class FontManagerNotifier extends ChangeNotifier {
  List<String>? _fontFamilyFallback;
  List<String> get fontFamilyFallback {
    return _fontFamilyFallback ?? ["Quicksand", "Kantumruy"];
  }

  final List<Locale> supportedLocales = initSupportedLocales;
  FontManagerNotifier();

  FontManagerStorage storage = FontManagerStorage();

  bool _loading = true;
  bool get loading => _loading;

  setLoading(bool value) {
    this._loading = value;
    notifyListeners();
  }

  load() async {
    setLoading(true);
    try {
      final result = await storage.readAsMap() ?? fontFamilyFallbackDefault;
      final families = supportedLocales.map((locale) {
        final code = locale.languageCode;
        return result[code];
      }).toList();
      families.removeWhere((e) => e == null);
      _fontFamilyFallback = families as List<String>;
      FontModel.availableFonts.forEach((key, value) async {
        if (value.isDefault == false ||
            value.previewFontUrl != null ||
            value.fontsUrl.length > 0) {
          await FontManagerService().loadAFont(
            familyName: value.familyName,
            fontFamilyStyleUrls: [value.previewFontUrl ?? value.fontsUrl[0]],
            locale: value.locale,
          );
        }
      });
      setLoading(false);
    } catch (e) {
      setLoading(false);
    }
  }

  Future<bool> loadAFont(
    List<String> url,
    Locale locale,
    String familyName,
  ) async {
    setLoading(true);
    final service = FontManagerService();
    bool success = await service.loadAFont(
      familyName: familyName,
      fontFamilyStyleUrls: url,
      locale: locale,
    );
    await load();
    return success;
  }
}

final fontManagerProvider = ChangeNotifierProvider<FontManagerNotifier>(
  (ref) {
    return FontManagerNotifier()..load();
  },
);
