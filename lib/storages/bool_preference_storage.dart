import 'package:shared_preferences/shared_preferences.dart';

abstract class BoolPreferenceStorage {
  String get key;

  Future<void> toggle() async {
    SharedPreferences _instance = await SharedPreferences.getInstance();
    final bool current = await getBool() == true;
    await _instance.setBool(key, !current);
  }

  Future<void> setBool({required bool value}) async {
    SharedPreferences _instance = await SharedPreferences.getInstance();
    await _instance.setBool(key, value);
  }

  Future<bool?> getBool() async {
    SharedPreferences _instance = await SharedPreferences.getInstance();
    return _instance.getBool(key);
  }
}
