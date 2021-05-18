import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class SecurePreferenceStorage {
  FlutterSecureStorage storage = FlutterSecureStorage();
  String get key;
  Object? error;

  Future<String?> read() async {
    try {
      final result = await storage.read(key: key);
      error = null;
      return result;
    } catch (e) {
      error = e;
    }
  }

  Future<void> write(String value) async {
    try {
      await storage.write(key: key, value: value);
      error = null;
    } catch (e) {
      error = e;
    }
  }

  Future<void> remove() async {
    try {
      await storage.delete(key: key);
      error = null;
    } catch (e) {
      error = e;
    }
  }
}
