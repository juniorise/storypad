import 'dart:convert';
import 'package:storypad/models/group_storage_model.dart';
import 'package:storypad/storages/share_preference_storage.dart';

class GroupStorage extends SharePreferenceStorage {
  @override
  String get key => "groupInfo";

  Future<void> writeMap(GroupStorageModel map) async {
    await super.write(jsonEncode(map.toJson()));
  }

  Future<GroupStorageModel?> readMap() async {
    final json = await super.read();
    if (json == null) return null;
    final result = GroupStorageModel.fromJson(jsonDecode(json));
    return result;
  }
}
