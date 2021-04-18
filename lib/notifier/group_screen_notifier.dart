import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:write_story/database/w_database.dart';
import 'package:write_story/models/group_storage_model.dart';
import 'package:write_story/models/member_model.dart';
import 'package:write_story/models/pending_model.dart';
import 'package:write_story/models/story_model.dart';
import 'package:write_story/services/authentication_service.dart';
import 'package:write_story/services/group_remote_service.dart';

class GroupScreenNotifier extends ChangeNotifier {
  GroupRemoteService service = GroupRemoteService();
  GroupStorageModel? _groupModel;
  GroupStorageModel? get groupModel => this._groupModel;

  bool _loading = false;
  bool get loading => this._loading;
  set loading(bool value) {
    this._loading = value;
    notifyListeners();
  }

  WDatabase wDatabase = WDatabase.instance;
  List<StoryModel> get storyByIdAsList {
    return this._storyById?.entries.map((e) {
          return e.value;
        }).toList() ??
        [];
  }

  Stream<PendingModel>? hasPending() {
    return service.hasPending();
  }

  Stream<List<MemberModel>> fetchMembers() {
    return service.fetchMembers(this._groupModel?.groupId);
  }

  Map<int, StoryModel>? _storyById;
  load() async {
    loading = true;
    final Map<int, StoryModel>? result =
        await wDatabase.storyById(where: "`is_share` = 1");
    if (result != null) {
      this._storyById = result;
      notifyListeners();
    }

    final String? groupId = await service.fetchSelectedGroup();
    if (groupId == null) {
      this._groupModel = null;
      loading = false;
      return;
    }

    if (this._storyById != null) {
      await service.syncEncryptStories(groupId, this._storyById);
    }

    final GroupStorageModel? groupModel = await service.fetchGroup(groupId);
    if (groupModel != null) {
      this._groupModel = groupModel;
    }
    loading = false;
  }

  Future<bool> hasGroup() async {
    List<GroupStorageModel>? groups = await service.fetchGroupsList();
    if (groups == null) {
      return false;
    } else {
      return true;
    }
  }

  Future<void> toggleShare(int storyId) async {
    final story = this._storyById![storyId];
    final result = story!.copyWith(isShare: !story.isShare);

    this._storyById?[storyId] = result;
    notifyListeners();

    await wDatabase.updateStory(story: result);
    load();
  }

  Future<bool> addUserToGroup(String email) async {
    if (this._groupModel?.groupId == null) return false;
    await service.addUserToGroup(
      email,
      this._groupModel!.groupId!,
      this._groupModel?.groupName ?? "",
    );
    await load();
    return true;
  }

  Future<void> cancelPending(PendingModel pendingModel) async {
    await service.cancelPending(pendingModel);
    await load();
  }

  Future<void> acceptPending(PendingModel pendingModel) async {
    await service.acceptPending(pendingModel);
    await load();
  }

  String? get email => AuthenticationService().user?.email;
}

final groupScreenProvider =
    ChangeNotifierProvider.autoDispose<GroupScreenNotifier>((_) {
  return GroupScreenNotifier()..load();
});
