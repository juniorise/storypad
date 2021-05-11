import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:storypad/app_helper/app_helper.dart';
import 'package:storypad/notifier/story_detail_screen_notifier.dart';

mixin StoryDetailMethodMixin {
  String getDateLabel({
    required DateTime date,
    required BuildContext context,
  }) {
    final _date = AppHelper.dateFormat(context).format(date);
    final _time = AppHelper.timeFormat(context).format(date);
    return _date + ", " + _time;
  }

  void onPopNavigator({
    required BuildContext context,
    required StoryDetailScreenNotifier notifier,
  }) async {
    ScaffoldMessenger.maybeOf(context)?.removeCurrentSnackBar();
    final draftStoryDate =
        notifier.hasChanged ? notifier.draftStory.forDate : null;
    Navigator.of(context).pop(draftStoryDate);
  }

  Container buildIosDatePicker({
    required BuildContext context,
    required DateTime tempPickedDate,
    required DateTime firstDate,
    required DateTime lastDate,
    required DateTime date,
  }) {
    final Widget actionButtons = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        CupertinoButton(
          child: Text(tr("button.cancel")),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        CupertinoButton(
          child: Text(tr("button.done")),
          onPressed: () {
            Navigator.of(context).pop(tempPickedDate);
          },
        ),
      ],
    );

    return Container(
      height: 250,
      child: Column(
        children: <Widget>[
          actionButtons,
          const Divider(height: 0),
          Expanded(
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
        ],
      ),
    );
  }

  Future<void> onPickDate({
    required BuildContext context,
    required DateTime date,
    required StoryDetailScreenNotifier notifier,
    required bool readOnly,
  }) async {
    if (FocusScope.of(context).hasFocus) {
      FocusScope.of(context).unfocus();
      TextEditingController().clear();
    }

    final _theme = Theme.of(context);

    final now = DateTime.now().year;
    DateTime firstDate = DateTime(1900);
    DateTime lastDate = DateTime(now + 50);

    DateTime? forDate;
    if (Platform.isIOS) {
      forDate = await showModalBottomSheet<DateTime>(
        context: context,
        builder: (context) {
          DateTime tempPickedDate = DateTime.now();
          return buildIosDatePicker(
            date: notifier.draftStory.forDate,
            context: context,
            lastDate: lastDate,
            firstDate: firstDate,
            tempPickedDate: tempPickedDate,
          );
        },
      );
    } else {
      forDate = await showDatePicker(
        context: context,
        initialDate: notifier.draftStory.forDate,
        firstDate: firstDate,
        initialDatePickerMode: DatePickerMode.day,
        lastDate: lastDate,
        builder: (BuildContext context, Widget? child) {
          return Theme(
            child: child ?? const SizedBox(),
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

    if (readOnly) return;

    if (forDate != null) {
      notifier.setDraftStory(
        notifier.draftStory.copyWith(forDate: forDate),
      );
    }
  }
}
