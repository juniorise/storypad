import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:write_story/models/story_model.dart';

class StoryDetailScreenNotifier extends ChangeNotifier {
  StoryModel draftStory;

  setDraftStory(StoryModel story) {
    this.draftStory = story;
  }

  Future<void> onPickDate(
    BuildContext context,
    DateTime date,
  ) async {
    final _theme = Theme.of(context);
    final notifier = context.read(storydetailScreenNotifier);

    DateTime forDate;

    final firstDate = DateTime(date.year);
    final lastDate = DateTime(date.year, 12, 31);

    if (Platform.isIOS) {
      forDate = await showModalBottomSheet<DateTime>(
        context: context,
        builder: (context) {
          DateTime tempPickedDate;
          return buildIosDatePicker(
            context,
            tempPickedDate,
            firstDate,
            lastDate,
            date,
          );
        },
      );
    } else {
      forDate = await showDatePicker(
        context: context,
        initialDate: date,
        firstDate: firstDate,
        lastDate: lastDate,
        builder: (BuildContext context, Widget child) {
          return Theme(
            child: child,
            data: _theme.copyWith(
              splashColor: Colors.transparent,
              colorScheme: _theme.colorScheme.copyWith(
                primary: _theme.primaryColor,
                secondary: Colors.red,
              ),
            ),
          );
        },
      );
    }

    notifier.setDraftStory(
      notifier.draftStory.copyWith(forDate: forDate ?? date),
    );
  }

  Container buildIosDatePicker(
    BuildContext context,
    DateTime tempPickedDate,
    DateTime firstDate,
    DateTime lastDate,
    DateTime date,
  ) {
    return Container(
      height: 250,
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              CupertinoButton(
                child: Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              CupertinoButton(
                child: Text('Done'),
                onPressed: () {
                  Navigator.of(context).pop(tempPickedDate);
                },
              ),
            ],
          ),
          const Divider(height: 0),
          Expanded(
            child: Container(
              child: CupertinoDatePicker(
                minimumDate: firstDate,
                maximumDate: lastDate,
                initialDateTime: date,
                mode: CupertinoDatePickerMode.date,
                onDateTimeChanged: (DateTime dateTime) {
                  tempPickedDate = dateTime;
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

final storydetailScreenNotifier =
    ChangeNotifierProvider<StoryDetailScreenNotifier>(
  (ref) {
    return StoryDetailScreenNotifier();
  },
);
