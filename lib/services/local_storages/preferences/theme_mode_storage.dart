import 'package:storypad/services/local_storages/preferences/bool_preference_storage.dart';

class ThemeModeStorage extends BoolPreferenceStorage {
  @override
  String get key {
    return "isDarkMode";
  }
}
