import 'package:write_story/storages/bool_preference_storage.dart';

class ListLayoutStorage extends BoolPreferenceStorage {
  @override
  String get key {
    return "isNormalLayout";
  }
}
