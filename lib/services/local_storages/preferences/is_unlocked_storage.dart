import 'package:storypad/services/local_storages/preferences/bool_preference_storage.dart';

class IsUnlockStorage extends BoolPreferenceStorage {
  @override
  String get key {
    return "IsUnlockStorage";
  }
}
