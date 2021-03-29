import 'package:write_story/storages/bool_preference_storage.dart';

class ThemeModeStorage extends BoolPreferenceStorage {
  @override
  String get key {
    return "isDarkMode";
  }
}
