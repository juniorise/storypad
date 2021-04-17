import 'dart:convert';

import 'package:write_story/storages/secure_preference_storage.dart';

class LockScreenStorage extends SecurePreferenceStorage {
  @override
  String get key => "LockScreenStorage";

  Future<Map<String, String>?> readMap() async {
    String? result = await super.read();
    if (result == null) return null;
    Map<String, dynamic> map = jsonDecode("$result");
    final readMap = Map.fromIterable(map.entries, value: (e) {
      return "${e.value}";
    }, key: (e) {
      return "${e.key}";
    });
    return readMap;
  }

  Future<void> writeMap(Map<String, dynamic> map) async {
    final writeMap = Map.fromIterable(map.entries, value: (e) {
      return "${e.value}";
    }, key: (e) {
      return "${e.key}";
    });
    super.write(jsonEncode(writeMap));
  }
}
