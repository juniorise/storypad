import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:write_your_story/database/w_database.dart';
import 'package:write_your_story/models/story_model.dart';

class DatabaseNotifier extends ChangeNotifier {
  final WDatabase wDatabase = WDatabase.instance;

  Map<int, StoryModel> storyById;
  bool loading = false;

  load() async {
    setLoading(true);
    final result = await wDatabase.storyById();

    if (result != null) {
      this.storyById = result;
    }

    setLoading(false);
  }

  setLoading(bool value) {
    this.loading = value;
    notifyListeners();
  }
}

final databaseProvider = ChangeNotifierProvider<DatabaseNotifier>(
  (ref) {
    return DatabaseNotifier()..load();
  },
);
