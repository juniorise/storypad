import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:storypad/database/w_database.dart';
import 'package:storypad/mixins/change_notifier_mixin.dart';
import 'package:storypad/models/story_model.dart';
import 'package:storypad/services/google_drive_api_service.dart';

class StoryDetailScreenNotifier extends ChangeNotifier
    with ChangeNotifierMixin {
  final WDatabase wDatabase = WDatabase.instance;
  StoryModel draftStory;
  bool hasChanged = false;
  int? imageLength;

  OverlayEntry? floating;

  String? _loadingUrl;
  String? get loadingUrl => this._loadingUrl;

  bool _paragraphIsFocused = false;
  bool get paragraphIsFocused => this._paragraphIsFocused;
  set paragraphIsFocused(bool value) {
    if (value == this._paragraphIsFocused) return;
    this._paragraphIsFocused = value;
    notifyListeners();
  }

  double _toolbarHeight = kToolbarHeight;
  double get toolbarHeight => this._toolbarHeight;
  set toolbarHeight(double value) {
    if (value == _toolbarHeight) return;
    _toolbarHeight = value;
    notifyListeners();
  }

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

final storydetailScreenNotifier = ChangeNotifierProvider.family
    .autoDispose<StoryDetailScreenNotifier, StoryModel>(
  (ref, story) {
    return StoryDetailScreenNotifier(story);
  },
);
