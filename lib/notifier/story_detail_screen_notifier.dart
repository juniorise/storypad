import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:write_your_story/models/story_model.dart';

class StoryDetailScreenNotifier extends ChangeNotifier {
  bool clickedOutside = false;
  bool loading = false;

  StoryModel draftStory;

  setLoading(bool value) {
    this.loading = value;
    notifyListeners();
  }

  setDraftStory(StoryModel story) {
    // print(story.forDate);
    this.draftStory = story;
  }
}

final storydetailScreenNotifier =
    ChangeNotifierProvider<StoryDetailScreenNotifier>(
  (ref) {
    return StoryDetailScreenNotifier();
  },
);
