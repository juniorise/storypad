import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class SecurePreferenceStorage {
  FlutterSecureStorage storage = FlutterSecureStorage();
  String get key;

  Future<String?> read() async {
    return await storage.read(key: key);
  }

  Future<void> write(String value) async {
    await storage.write(key: key, value: value);
  }

  Future<void> remove() async {
    await storage.delete(key: key);
  }
}
