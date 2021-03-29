import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:write_story/app_helper/app_helper.dart';
import 'package:write_story/notifier/story_detail_screen_notifier.dart';
import 'package:write_story/widgets/vt_ontap_effect.dart';

mixin StoryDetailMethodMixin {
  String getDateLabel({
    required DateTime date,
    required BuildContext context,
    required String labelKey,
  }) {
    final _date = AppHelper.dateFormat(context).format(date);
    final _time = AppHelper.timeFormat(context).format(date);
    return tr(labelKey, namedArgs: {"DATE": _date + ", " + _time});
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

  SnackBar buildSnackBar({
    required String title,
    required BuildContext context,
    String? actionLabel,
    VoidCallback? onActionPressed,
  }) {
    final style = Theme.of(context)
        .textTheme
        .bodyText1!
        .copyWith(color: Theme.of(context).colorScheme.onSecondary);

    final actions = onActionPressed != null
        ? SnackBarAction(
            label: actionLabel ?? tr("button.okay"),
            textColor: Theme.of(context).colorScheme.onSecondary,
            onPressed: () async {
              onActionPressed();
            },
          )
        : null;

    return SnackBar(
      content: Text(title, style: style),
      action: actions,
      backgroundColor: Theme.of(context).colorScheme.secondary,
    );
  }

  Future<void> showSnackBar({
    required BuildContext context,
    required String title,
    String? actionLabel,
    VoidCallback? onActionPressed,
    VoidCallback? onClose,
  }) async {
    ScaffoldMessenger.maybeOf(context)?.removeCurrentSnackBar();
    Future.delayed(Duration(microseconds: 0)).then((value) {
      final SnackBar snack = buildSnackBar(
        title: title,
        context: context,
        actionLabel: actionLabel ?? tr("button.okay"),
        onActionPressed: onActionPressed,
      );

      onTapVibrate();
      ScaffoldMessenger.of(context).showSnackBar(snack).closed.then(
        (value) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          if (onClose != null) onClose();
        },
      );
    });
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
  }) async {
    FocusScope.of(context).unfocus();
    TextEditingController().clear();

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
        initialDatePickerMode: DatePickerMode.year,
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

    if (forDate != null) {
      notifier.setDraftStory(
        notifier.draftStory.copyWith(forDate: forDate),
      );
    }
  }

  Future<void> onDelete({
    required BuildContext context,
    required StoryDetailScreenNotifier notifier,
    required bool insert,
    required int id,
  }) async {
    await showSnackBar(
      context: context,
      title: tr("msg.delete.warning"),
      actionLabel: tr("button.okay"),
      onActionPressed: () async {
        final success = await notifier.removeStoryById(id);
        if (success) {
          await Future.delayed(Duration(milliseconds: 350)).then((value) {
            onPopNavigator(
              context: context,
              notifier: notifier,
            );
          });
        } else {
          await showSnackBar(
            context: context,
            title: tr("msg.delete.fail"),
            actionLabel: tr("button.try_again"),
            onActionPressed: () async {
              onDelete(
                context: context,
                notifier: notifier,
                insert: insert,
                id: id,
              );
            },
          );
        }
      },
    );
  }

  Future<void> onSave({
    required StoryDetailScreenNotifier notifier,
    required BuildContext context,
    required String paragraph,
    required bool insert,
  }) async {
    final draftStory = notifier.draftStory.copyWith(paragraph: paragraph);
    if (draftStory.title.trim().isEmpty) {
      await showSnackBar(
        context: context,
        title: tr("validate.title"),
        actionLabel: tr("button.okay"),
        onActionPressed: () {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
        },
      );
    } else {
      bool success;
      if (insert) {
        success = await notifier.addStory(draftStory);
      } else {
        success = await notifier.updateStory(
          draftStory.copyWith(updateOn: DateTime.now()),
        );
      }

      if (success == true) {
        await showSnackBar(
          context: context,
          title: tr("msg.save.success"),
        );
      } else {
        await showSnackBar(
          context: context,
          title: tr("msg.save.fail"),
        );
      }
    }
  }
}
