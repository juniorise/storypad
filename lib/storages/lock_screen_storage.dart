import 'dart:convert';

import 'package:write_story/storages/secure_preference_storage.dart';

class LockScreenStorage extends SecurePreferenceStorage {
  @override
  String get key => "LockScreenStorage";

  Future<Map<int, int>?> readMap() async {
    String? result = await super.read();
    if (result == null) return null;
    Map<String, dynamic> map = jsonDecode("$result");
    final readMap = Map.fromIterable(map.entries, value: (e) {
      return int.parse(e.value);
    }, key: (e) {
      return int.parse(e.key);
    });
    return readMap;
  }

  Future<void> writeMap(Map<int, int> map) async {
    final writeMap = Map.fromIterable(map.entries, value: (e) {
      return "${e.value}";
    }, key: (e) {
      return "${e.key}";
    });
    super.write(jsonEncode(writeMap));
  }
}
