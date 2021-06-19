import 'package:storypad/services/local_storages/preferences/bool_preference_storage.dart';

class ListLayoutStorage extends BoolPreferenceStorage {
  @override
  String get key {
    return "isNormalLayout";
  }
}
