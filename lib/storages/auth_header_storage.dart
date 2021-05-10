import 'dart:convert';
import 'package:storypad/storages/secure_preference_storage.dart';

class AuthHeaderStorage extends SecurePreferenceStorage {
  @override
  String get key {
    return "AuthHeaders";
  }

  Map<String, String>? getAuthHeader(String result) {
    final Map<String, dynamic> json = jsonDecode("$result");

    final Map<String, String>? authHeaders = Map.fromIterable(
      json.entries,
      key: (e) => "${e.key}",
      value: (e) => "${e.value}",
    );

    return authHeaders;
  }
}
