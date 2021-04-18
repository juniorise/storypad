import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:write_story/models/group_storage_model.dart';
import 'package:write_story/services/group_remote_service.dart';

class GroupListingScreenNotifer extends ChangeNotifier {
  GroupRemoteService service = GroupRemoteService();

  List<GroupStorageModel>? _groups;
  List<GroupStorageModel> get groups => this._groups ?? [];

  String? _selectedGroup;
  String? get selectedGroup => this._selectedGroup;

  load() async {
    _selectedGroup = await service.fetchSelectedGroup();
    final result = await service.fetchGroupsList();
    if (result != null) {
      _groups = result;
    } else {
      _groups = null;
    }
    notifyListeners();
  }

  Future<void> selectedAGroup(String? groupId) async {
    service.setSelectedGroup(groupId);
    await load();
  }

  Future<void> exitGroup(String? groupId) async {
    await service.exitGroup(groupId, _selectedGroup);
    await load();
  }

  Future<bool> createGroup(String groupName) async {
    final result = await service.createGroup("$groupName");
    if (result == null) return false;
    await load();
    return true;
  }
}

final groupListingProvider =
    ChangeNotifierProvider.autoDispose<GroupListingScreenNotifer>(
  (ref) {
    return GroupListingScreenNotifer()..load();
  },
);
