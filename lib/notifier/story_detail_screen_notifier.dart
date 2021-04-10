import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:write_story/database/w_database.dart';
import 'package:write_story/models/story_model.dart';
import 'package:write_story/services/google_drive_api_service.dart';

class StoryDetailScreenNotifier extends ChangeNotifier {
  final WDatabase wDatabase = WDatabase.instance;
  StoryModel draftStory;
  bool hasChanged = false;
  int? imageLength;

  OverlayEntry? floating;

  String? _loadingUrl;
  String? get loadingUrl => this._loadingUrl;

  setLoadingUrl(String imageUrl) {
    this._loadingUrl = imageUrl;
    notifyListeners();
  }

  StoryDetailScreenNotifier(this.draftStory);

  final List<String> tmpImagePath = [];
  void addImagePath(String? path) {
    if (path != null && !this.tmpImagePath.contains(path)) {
      this.tmpImagePath.add(path);
    }
  }

  Future<bool> updateStory(StoryModel story) async {
    final success = await wDatabase.updateStory(story: story);
    if (success) {
      this.hasChanged = true;
    }
    return success;
  }

  Future<bool> addStory(StoryModel story) async {
    final success = await wDatabase.addStory(story: story);
    if (success) {
      this.hasChanged = true;
    }
    return success;
  }

  void setDraftStory(StoryModel story) {
    this.draftStory = story;
  }

  Future<bool> removeStoryById(int id) async {
    final success = await wDatabase.removeStoryById(id);
    if (success) {
      this.hasChanged = true;
    }
    return success;
  }

  retryLoadImage() async {
    final driveApi = await GoogleDriveApiService.getDriveApi();
    await GoogleDriveApiService.setFolderId(driveApi, grentPermission: false);
    notifyListeners();
  }
}

final storydetailScreenNotifier =
    ChangeNotifierProvider.family<StoryDetailScreenNotifier, StoryModel>(
  (ref, story) {
    return StoryDetailScreenNotifier(story);
  },
);
