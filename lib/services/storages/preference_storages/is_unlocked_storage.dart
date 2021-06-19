import 'package:storypad/services/storages/preference_storages//bool_preference_storage.dart';

class IsUnlockStorage extends BoolPreferenceStorage {
  @override
  String get key {
    return "IsUnlockStorage";
  }
}
