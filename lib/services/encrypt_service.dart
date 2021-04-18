import 'dart:convert';

import 'package:write_story/constants/api_constant.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:write_story/models/story_model.dart';

class EncryptService {
  static String? storyMapEncrypt(Map<int, StoryModel> map) {
    final result = Map.fromIterable(
      map.entries,
      key: (e) => "${e.key}",
      value: (e) => e.value.toJson(),
    );
    final encode = jsonEncode(result);
    return encryptToString(encode);
  }

  static Map<int, StoryModel>? storyMapDecrypt(String encrypted) {
    Map<int, StoryModel>? map;
    final decrypted = decryptToString(encrypted);
    Map<String, dynamic> decode = jsonDecode(decrypted);
    map = Map.fromIterable(
      decode.entries,
      key: (e) => int.parse(e.key),
      value: (e) {
        return StoryModel.fromJson(e.value);
      },
    );

    return map;
  }

  /// encode it to `convert.jsonEncode(backups);`
  static String encryptToString(String json) {
    final key = encrypt.Key.fromUtf8(ApiConstant.SECRET_KEY);
    final iv = encrypt.IV.fromLength(16);
    final encrypter = encrypt.Encrypter(encrypt.AES(key));
    final encrypted = encrypter.encrypt(json, iv: iv);
    return encrypted.base64;
  }

  static String decryptToString(String backup) {
    final key = encrypt.Key.fromUtf8(ApiConstant.SECRET_KEY);
    final iv = encrypt.IV.fromLength(16);
    final encrypter = encrypt.Encrypter(encrypt.AES(key));
    return encrypter.decrypt64(backup, iv: iv);
  }
}
