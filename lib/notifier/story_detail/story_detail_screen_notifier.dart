import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:storypad/services/storages/local_storages/w_database.dart';
import 'package:storypad/mixins/change_notifier_mixin.dart';
import 'package:storypad/mixins/schedule_mixin.dart';
import 'package:storypad/models/story_model.dart';
import 'package:storypad/services/google_drive_api_service.dart';
import 'package:storypad/services/storages/preference_storages//auto_save_bool_storage.dart';

class StoryDetailScreenNotifier extends ChangeNotifier with ChangeNotifierMixin, ScheduleMixin, WidgetsBindingObserver {
  StoryDetailScreenNotifier(this.draftStory, this.initStory) {
    WidgetsBinding.instance?.addObserver(this);
  }

  final WDatabase wDatabase = WDatabase.instance;
  StoryModel initStory;
  StoryModel draftStory;
  bool hasChanged = false;
  int? imageLength;

  OverlayEntry? floating;

  String? _loadingUrl;
  String? get loadingUrl => this._loadingUrl;

  double _toolbarOpacity = 0.0;
  double get toolbarOpacity => this._toolbarOpacity;

  bool _paragraphIsFocused = false;
  bool get paragraphIsFocused => this._paragraphIsFocused;
  void setSaragraphIsFocused(bool value, {bool keyboardOpen = false}) {
    if (value == this._paragraphIsFocused) return;
    this._paragraphIsFocused = value;
    notifyListeners();
    return;
  }

  double _toolbarHeight = kToolbarHeight;
  double get toolbarHeight => this._toolbarHeight;
  set toolbarHeight(double value) {
    if (value == _toolbarHeight) return;
    _toolbarHeight = value;
  }

  setLoadingUrl(String imageUrl) {
    this._loadingUrl = imageUrl;
    notifyListeners();
  }

  updateInitStory() {
    this.initStory = this.draftStory;
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

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.paused) {
      final bool? autoSave = await AutoSaveBoolStorage().getBool();
      if (onSave != null && autoSave == true) {
        this.onSave!();
      }
    }
    super.didChangeAppLifecycleState(state);
  }

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    super.dispose();
  }

  void Function()? onSave;
  void addOnPauseCallBack(void Function() onSave) {
    if (this.onSave == null) this.onSave = onSave;
  }
}

final storydetailScreenNotifier = ChangeNotifierProvider.family.autoDispose<StoryDetailScreenNotifier, StoryModel>(
  (ref, story) {
    return StoryDetailScreenNotifier(story, story);
  },
);
