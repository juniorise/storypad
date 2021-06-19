import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:storypad/helpers/quill_helper.dart';
import 'package:storypad/mixins/snakbar_mixin.dart';
import 'package:storypad/models/story_model.dart';
import 'package:storypad/notifier/story_detail/story_detail_screen_notifier.dart';

class StoryDetailService with WSnackBar {
  Future<void> onSave({
    required StoryDetailScreenNotifier notifier,
    required BuildContext context,
    required String paragraph,
    required bool insert,
    bool showSnack = true,
  }) async {
    StoryModel draftStory = notifier.draftStory.copyWith(paragraph: paragraph);
    final bool titleEmpty = draftStory.title.trim().isEmpty;

    String _paragraph = "";
    final root = QuillHelper.getRoot(paragraph);
    if (root != null) {
      _paragraph = QuillHelper.toPlainText(root).trim();
    }

    final bool paragraphEmpty = _paragraph.trim().isEmpty;
    if (titleEmpty && paragraphEmpty) {
      if (!showSnack) return;
      await showSnackBar(
        context: context,
        title: tr("validate.title"),
        actionLabel: tr("button.okay"),
        onActionPressed: () {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
        },
      );
    } else {
      ///Insert to database
      bool success;
      if (insert) {
        success = await notifier.addStory(draftStory);
      } else {
        success = await notifier.updateStory(
          draftStory.copyWith(updateOn: DateTime.now()),
        );
      }

      if (success == true) {
        if (showSnack) {
          await showSnackBar(
            context: context,
            title: tr("msg.save.success"),
          );
        }
        notifier.updateInitStory();
      } else {
        if (showSnack) {
          await showSnackBar(
            context: context,
            title: tr("msg.save.fail"),
          );
        }
      }
    }
  }
}
