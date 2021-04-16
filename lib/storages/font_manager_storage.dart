import 'dart:convert';
import 'package:write_story/storages/share_preference_storage.dart';

/// structured data should be
/// ```
/// {
///   'en': "Quicksand",
///   'km': "Kantumruy",
/// }
/// ```
class FontManagerStorage extends SharePreferenceStorage {
  @override
  String get key => "fontFamilyFallback";

  Future<void> writeMap(Map<String, dynamic> fonts) async {
    await super.write(jsonEncode(fonts));
  }

  Future<Map<String, String>?> readAsMap() async {
    final String? result = await super.read();
    if (result == null) return null;

    Map<String, dynamic>? map;

    try {
      map = jsonDecode("$result");
    } catch (e) {
      return null;
    }

    Map<String, String>? json = Map.fromIterable(
      map!.entries,
      key: (e) => "${e.key}",
      value: (e) => "${e.value}",
    );

    return json;
  }
}
