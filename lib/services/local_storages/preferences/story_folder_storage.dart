import 'package:storypad/services/local_storages/preferences/share_preference_storage.dart';

class StoryFolderStorage extends SharePreferenceStorage {
  @override
  String get key => "StoryFolderID";
}
