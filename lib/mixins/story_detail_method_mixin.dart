import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:write_story/app_helper/app_helper.dart';
import 'package:write_story/models/story_model.dart';
import 'package:write_story/notifier/story_detail_screen_notifier.dart';
import 'package:write_story/services/google_drive_api_service.dart';
import 'package:write_story/widgets/vt_ontap_effect.dart';
import 'package:write_story/widgets/w_snack_bar_action.dart' as w;

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

  SnackBar buildSnackBar({
    required String title,
    required BuildContext context,
    String? actionLabel,
    VoidCallback? onActionPressed,
    bool warning = false,
    bool floating = false,
  }) {
    final style = Theme.of(context)
        .textTheme
        .bodyText1!
        .copyWith(color: Theme.of(context).colorScheme.onSecondary);

    final actions = onActionPressed != null
        ? w.WSnackBarAction(
            label: actionLabel ?? tr("button.okay"),
            warning: warning,
            onPressed: () async {
              onActionPressed();
            },
          )
        : null;

    return SnackBar(
      content: Text(title, style: style),
      action: actions,
      behavior: floating ? SnackBarBehavior.floating : SnackBarBehavior.fixed,
      backgroundColor: Theme.of(context).colorScheme.secondary,
    );
  }

  Future<void> showSnackBar({
    required BuildContext context,
    required String title,
    String? actionLabel,
    VoidCallback? onActionPressed,
    VoidCallback? onClose,
    bool warning = false,
    bool floating = false,
  }) async {
    ScaffoldMessenger.maybeOf(context)?.removeCurrentSnackBar();
    Future.delayed(Duration(microseconds: 0)).then((value) {
      final SnackBar snack = buildSnackBar(
        title: title,
        context: context,
        actionLabel: actionLabel ?? tr("button.okay"),
        onActionPressed: onActionPressed,
        warning: warning,
        floating: floating,
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
      warning: true,
      floating: true,
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
            floating: true,
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
    required ValueNotifier imageLoadingNotifier,
    required StoryDetailScreenNotifier notifier,
    required BuildContext context,
    required String paragraph,
    required bool insert,
  }) async {
    StoryModel draftStory = notifier.draftStory.copyWith(paragraph: paragraph);
    if (draftStory.title.trim().isEmpty) {
      await showSnackBar(
        context: context,
        title: tr("validate.title"),
        actionLabel: tr("button.okay"),
        floating: true,
        onActionPressed: () {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
        },
      );
    } else {
      List<String> imagesPath = [];
      notifier.tmpImagePath.forEach((e) {
        if (paragraph.contains(e)) {
          imagesPath.add(e);
        }
      });
      imageLoadingNotifier.value = true;
      showSnackBar(
        context: context,
        title: tr("msg.drive.loading"),
      );

      int i = 0;
      String? _tmpParagraph = paragraph;
      for (var e in imagesPath) {
        final image = await GoogleDriveApiService.upload(File(e), context);
        if (image != null) {
          i++;
          _tmpParagraph = _tmpParagraph?.replaceAll(e, image);
        } else {}
      }
      draftStory = notifier.draftStory.copyWith(paragraph: _tmpParagraph);

      print("i $i & imagesPath ${imagesPath.length}");
      print("$_tmpParagraph");
      if (i == imagesPath.length) {
        showSnackBar(
          context: context,
          title: tr("msg.drive.uploaded"),
        );
      } else {
        showSnackBar(
          context: context,
          title: tr("msg.drive.fail"),
        );
      }
      imageLoadingNotifier.value = false;

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
        await showSnackBar(
          context: context,
          floating: true,
          title: tr("msg.save.success"),
        );
      } else {
        await showSnackBar(
          context: context,
          floating: true,
          title: tr("msg.save.fail"),
        );
      }
    }
  }
}
