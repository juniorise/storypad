import 'dart:convert';
import 'package:write_story/models/group_storage_model.dart';
import 'package:write_story/storages/share_preference_storage.dart';

/// Desire list
/// ```
/// [
///   {
///     "group_id": "WkdkfPdk3EKdgPd",
///     "group_name": "Couple",
///   },
///   {
///     "group_id": "KwZkfPdk3EKdgQd",
///     "group_name": "Team",
///   },
/// ]
/// ```
class GroupsSyncStorage extends SharePreferenceStorage {
  @override
  String get key => "GroupsSyncStorage";

  Future<void> writeList(List<GroupStorageModel>? list) async {
    try {
      if (list == null) {
        await super.remove();
        return;
      }
      List<Map<String, dynamic>> listMap = list.map((e) => e.toJson()).toList();
      final encoded = jsonEncode(listMap);
      await super.write(encoded);
    } catch (e) {
      print("GroupsSyncStorage#writeList $e");
    }
  }

  Future<List<GroupStorageModel>?> readList() async {
    try {
      String? encode = await super.read();
      if (encode == null) return null;
      List<dynamic> decoded = jsonDecode(encode);
      List<GroupStorageModel> listModel =
          decoded.map((e) => GroupStorageModel.fromJson(e)).toList();
      return listModel;
    } catch (e) {
      print("GroupsSyncStorage#readList $e");
      return null;
    }
  }
}
