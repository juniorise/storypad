import 'package:storypad/storages/bool_preference_storage.dart';

class IsUnlockStorage extends BoolPreferenceStorage {
  @override
  String get key {
    return "IsUnlockStorage";
  }
}
