import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_quill/models/documents/document.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:storypad/helpers/quill_helper.dart';
import 'package:storypad/services/local_storages/databases/story_database.dart';
import 'package:storypad/models/story_model.dart';
import 'package:storypad/services/apis/google_drive_api.dart';

class WStoryTileNotifier extends ChangeNotifier {
  StoryModel story;
  Document? document;
  WStoryTileNotifier(this.story) {
    try {
      final decode = jsonDecode(story.paragraph!);
      document = Document.fromJson(decode);
    } catch (e) {}
  }

  List<String>? files;

  bool _loading = false;
  bool get loading => this._loading;
  set loading(bool value) {
    if (this._loading == value) return;
    this._loading = value;
    notifyListeners();
  }

  load() async {
    files = await QuillHelper.getLocalImages(document);
    notifyListeners();
  }

  Future<bool> uploadImagesToDrive() async {
    String? _tmpParagraph = story.paragraph;
    if (_tmpParagraph == null) return false;

    loading = true;
    int i = 0;

    for (var path in files ?? []) {
      bool exist = await File(path).exists();
      if (exist) {
        final image = await GoogleDriveApi.upload(File(path));
        if (image != null) {
          _tmpParagraph = _tmpParagraph?.replaceAll(path, image);
          i++;
        }
      }
    }

    if (i > 0) {
      StoryDatabase db = StoryDatabase();
      await db.update(
        record: story.copyWith(
          updateOn: DateTime.now(),
          paragraph: _tmpParagraph,
        ),
      );
      loading = false;
      return db.success == true;
    }

    loading = false;
    return false;
  }
}

final wStoryTileProvider = ChangeNotifierProvider.family.autoDispose<WStoryTileNotifier, StoryModel>((ref, story) {
  return WStoryTileNotifier(story)..load();
});
