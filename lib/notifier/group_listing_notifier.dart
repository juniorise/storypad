import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:write_story/models/group_storage_model.dart';
import 'package:write_story/services/group_remote_service.dart';

class GroupListingScreenNotifer extends ChangeNotifier {
  GroupRemoteService service = GroupRemoteService();

  List<GroupStorageModel>? _groups;
  List<GroupStorageModel> get groups => this._groups ?? [];

  bool _loading = false;
  bool get loading => this._loading;
  set loading(bool value) {
    this._loading = value;
    notifyListeners();
  }

  String? _selectedGroup;
  String? get selectedGroup => this._selectedGroup;

  load() async {
    loading = true;
    _selectedGroup = await service.fetchSelectedGroup();
    final result = await service.fetchGroupsList();
    if (result != null) {
      _groups = result;
    } else {
      _groups = null;
    }
    loading = false;
  }

  Future<bool> selectedAGroup(String? groupId) async {
    loading = true;
    try {
      await service.setSelectedGroup(groupId);
      await load();
      loading = false;
      return true;
    } catch (e) {
      loading = false;
      return false;
    }
  }

  Future<bool> exitGroup(String? groupId) async {
    loading = true;
    try {
      await service.exitGroup(groupId, _selectedGroup);
      await load();
      loading = false;
      return true;
    } catch (e) {
      loading = false;
      return false;
    }
  }

  Future<bool> createGroup(String groupName) async {
    loading = true;
    try {
      await service.createGroup("$groupName");
      await load();
      loading = false;
      return true;
    } catch (e) {
      loading = false;
      return false;
    }
  }
}

final groupListingProvider =
    ChangeNotifierProvider.autoDispose<GroupListingScreenNotifer>(
  (ref) {
    return GroupListingScreenNotifer()..load();
  },
);
