import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:write_story/models/font_model.dart';
import 'package:write_story/storages/font_manager_storage.dart';

const Map<String, String> fontFamilyFallbackDefault = {
  "en": "Quicksand",
  "km": "Kantumruy",
};

class FontManagerService {
  Future<ByteData> fetchFont(String url) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return ByteData.view(response.bodyBytes.buffer);
    } else {
      // If that call was not successful, throw an error.
      throw Exception('Failed to load font');
    }
  }

  Future<void> replaceFontInMap(
    String familyName,
    Locale locale,
  ) async {
    final storage = FontManagerStorage();
    Map<String, dynamic>? result = await storage.readAsMap();

    if (!(result != null && result.isNotEmpty)) {
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
  }

  Future<void> loadDefault(Locale locale) async {
    await replaceFontInMap(
      fontFamilyFallbackDefault[locale.languageCode]!,
      locale,
    );
  }

  // return true if success
  Future<bool> loadAFont({
    required String familyName,
    required List<String> fontFamilyStyleUrls,
    required Locale locale,
  }) async {
    var fontLoader = FontLoader(familyName);
    try {
      fontFamilyStyleUrls.forEach((url) {
        var font = fetchFont(url);
        fontLoader.addFont(font);
      });
      await fontLoader.load();
      await replaceFontInMap(familyName, locale);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> loadStorageFont() async {
    final storage = FontManagerStorage();
    Map<String, String> map =
        await storage.readAsMap() ?? fontFamilyFallbackDefault;
    map.forEach((key, value) async {
      FontModel? font = FontModel.availableFonts[value];
      if (font != null && font.isDefault == false) {
        final bool success = await loadAFont(
          familyName: font.familyName,
          fontFamilyStyleUrls: font.fontsUrl,
          locale: font.locale,
        );
        if (success == false) {
          await loadDefault(Locale(key));
        }
      } else {
        await loadDefault(Locale(key));
      }
    });
  }
}
