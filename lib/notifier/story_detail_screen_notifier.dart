import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:write_your_story/models/story_model.dart';

class StoryDetailScreenNotifier extends ChangeNotifier {
  bool clickedOutside = false;
  bool loading = false;

  StoryModel draftStory;

  String headerText;
  String paragraph;

  setLoading(bool value) {
    this.loading = value;
    notifyListeners();
  }

  setDraftStory(StoryModel story) {
    this.draftStory = story;
    notifyListeners();
  }

  setHeaderText(String title) {
    this.headerText = title;
  }

  setParagraph(String paragraph) {
    this.paragraph = paragraph;
  }
}

final storydetailScreenNotifier =
    ChangeNotifierProvider<StoryDetailScreenNotifier>(
  (ref) {
    return StoryDetailScreenNotifier();
  },
);
