import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:storypad/models/group_storage_model.dart';
import 'package:storypad/models/member_model.dart';
import 'package:storypad/services/authentication_service.dart';
import 'package:storypad/services/group_remote_service.dart';

class MembersInfoNotifier extends ChangeNotifier {
  GroupStorageModel? get group => this._group;
  GroupStorageModel? _group;
  GroupRemoteService service = GroupRemoteService();

  bool _loading = false;
  bool get loading => this._loading;
  set loading(bool value) {
    this._loading = value;
    notifyListeners();
  }

  AuthenticationService auth = AuthenticationService();
  bool get isAdmin {
    if (_group?.admin == null) return false;
    if (auth.user?.email == null) return false;
    return _group?.admin == auth.user?.email;
  }

  Stream<List<MemberModel>> fetchMembers() {
    return service.fetchMembers(_group?.groupId);
  }

  load() async {
    loading = true;
    final selectedGroup = await service.fetchSelectedGroup();
    if (selectedGroup == null) {
      _group = null;
      loading = false;
      notifyListeners();
      return;
    }
    _group = await service.fetchGroup(selectedGroup);
    loading = false;
  }

  Future<void> addUserToGroup(String email) async {
    if (group == null) return;
    if (group?.groupId == null) return;
    await service.addUserToGroup(
      email.toLowerCase(),
      group!.groupId!,
      group!.groupName!,
    );
    await load();
  }
}

final membersInfoProvider =
    ChangeNotifierProvider.autoDispose<MembersInfoNotifier>(
  (_) {
    return MembersInfoNotifier()..load();
  },
);
