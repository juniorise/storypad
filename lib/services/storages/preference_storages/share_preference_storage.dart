import 'package:shared_preferences/shared_preferences.dart';

abstract class SharePreferenceStorage {
  String get key;

  Future<String?> read() async {
    final storage = await SharedPreferences.getInstance();
    return storage.getString(key);
  }

  Future<void> write(String value) async {
    final storage = await SharedPreferences.getInstance();
    await storage.setString(key, value);
  }

  Future<void> remove() async {
    final storage = await SharedPreferences.getInstance();
    await storage.remove(key);
  }
}
