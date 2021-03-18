import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:write_story/app_helper/app_helper.dart';
import 'package:write_story/models/story_model.dart';
import 'package:write_story/notifier/story_detail_screen_notifier.dart';
import 'package:write_story/widgets/vt_ontap_effect.dart';
import 'package:write_story/widgets/w_icon_button.dart';

class StoryDetailScreen extends HookWidget {
  const StoryDetailScreen({
    Key key,
    this.story,
    this.futureId,
    this.forDate,
  })  : assert((story != null && (futureId == null && forDate == null)) ||
            (story == null && (futureId != null && forDate != null))),
        super(key: key);

  final StoryModel story;
  final int futureId;
  final DateTime forDate;

  String getDateLabel(DateTime date, BuildContext context, String label) {
    return "$label: " +
        AppHelper.dateFormat(context).format(date) +
        ", " +
        AppHelper.timeFormat(context).format(date);
  }

  void onPop(BuildContext context, StoryDetailScreenNotifier notifier) {
    notifier.setDraftStory(StoryModel.empty);
    Navigator.of(context).pop(notifier.hasChanged);
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

  @override
  Widget build(BuildContext context) {
    final _theme = Theme.of(context);
    final bool insert = futureId != null;
    final notifier = useProvider(storydetailScreenNotifier);

    final initTitle =
        !insert && notifier.draftStory != null ? notifier.draftStory.title : "";
    final initParagraph = !insert && notifier.draftStory != null
        ? notifier.draftStory.paragraph
        : "";

    notifier
      ..setDraftStory(
        !insert
            ? story
            : StoryModel(
                id: futureId,
                title: initTitle,
                paragraph: initParagraph,
                createOn: DateTime.now(),
                forDate: forDate,
              ),
      );

    final _headerText = TextFormField(
      textAlign: TextAlign.left,
      initialValue: !insert ? story.title ?? "" : notifier.draftStory.title,
      style: _theme.textTheme.subtitle1.copyWith(height: 1.5),
      maxLines: null,
      onChanged: (String value) {
        notifier.setDraftStory(
          notifier.draftStory.copyWith(title: value),
        );
      },
      decoration: InputDecoration(
        hintText: "Your story title...",
        border: InputBorder.none,
      ),
    );

    String _aboutDateText = "";
    if (!insert) {
      _aboutDateText = getDateLabel(story.createOn, context, "Create on") +
          "\n" +
          getDateLabel(story.forDate, context, "For Date");
    }

    if (!insert && story.updateOn != null) {
      _aboutDateText += "\nUpdated on: " +
          AppHelper.dateFormat(context).format(
            story.updateOn,
          ) +
          ", " +
          AppHelper.timeFormat(context).format(
            story.updateOn,
          );
    }

    final _aboutDate = !insert
        ? Text(
            _aboutDateText,
            textAlign: TextAlign.start,
            style: TextStyle(
              color: _theme.textTheme.subtitle2.color.withOpacity(0.6),
            ),
          )
        : const SizedBox();

    final _paragraph = Transform.translate(
      offset: Offset(0, -16),
      child: TextFormField(
        textAlign: TextAlign.start,
        initialValue: !insert ? story.paragraph : notifier.draftStory.paragraph,
        maxLines: null,
        onChanged: (String value) {
          notifier.setDraftStory(
            notifier.draftStory.copyWith(paragraph: value),
          );
        },
        decoration: InputDecoration(
          hintText: "Write your story here...",
          border: InputBorder.none,
        ),
        style: _theme.textTheme.bodyText2.copyWith(
          color: _theme.textTheme.subtitle2.color.withOpacity(0.6),
        ),
      ),
    );

    return WillPopScope(
      onWillPop: () {
        onPop(context, notifier);
        return;
      },
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
          TextEditingController().clear();
        },
        child: Scaffold(
          backgroundColor: _theme.backgroundColor,
          appBar: buildAppBar(
            context,
            _theme,
            insert,
            notifier,
            _aboutDate,
          ),
          body: SingleChildScrollView(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Column(
                children: [
                  _headerText,
                  _paragraph,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  AppBar buildAppBar(
    BuildContext context,
    ThemeData _theme,
    bool insert,
    StoryDetailScreenNotifier notifier,
    Widget _aboutDate,
  ) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      leading: buildAppBarLeadingButton(context, _theme, notifier),
      actions: [
        WIconButton(
          iconData: Icons.date_range_rounded,
          onPressed: () async {
            onPickDate(
              context,
              !insert ? story.forDate : notifier.draftStory.forDate,
            );
          },
        ),
        if (!insert)
          WIconButton(
            iconData: Icons.delete,
            iconColor: _theme.errorColor,
            onPressed: () async => onDelete(
              context: context,
              notifier: notifier,
              insert: insert,
            ),
          ),
        WIconButton(
          iconData: Icons.save,
          iconColor: _theme.primaryColor,
          onPressed: () async {
            if (notifier.draftStory.title.trim().isEmpty) {
              await showSnackBar(
                context: context,
                title: "Title must not empty!",
                actionLabel: "Yes",
                onActionPressed: () {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                },
              );
            } else {
              if (insert) {
                await notifier.addStory(notifier.draftStory);
              } else {
                await notifier.updateStory(
                  notifier.draftStory.copyWith(
                    updateOn: DateTime.now(),
                  ),
                );
              }
            }
          },
        ),
        if (!insert)
          WIconButton(
            iconData: Icons.info,
            onPressed: () async {
              showDialog(
                context: context,
                builder: (context) {
                  return Dialog(
                    child: Container(
                      child: _aboutDate,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                    ),
                  );
                },
              );
            },
          ),
      ],
    );
  }

  SnackBar buildSnackBar(
    String title,
    BuildContext context,
    String actionLabel,
    void onActionPressed(),
  ) {
    return SnackBar(
      content: Text(
        title,
        style: Theme.of(context)
            .textTheme
            .bodyText1
            .copyWith(color: Theme.of(context).backgroundColor),
      ),
      action: onActionPressed != null
          ? SnackBarAction(
              label: actionLabel ?? "Okay",
              textColor: Theme.of(context).backgroundColor,
              onPressed: () async {
                onActionPressed();
              },
            )
          : null,
    );
  }

  VTOnTapEffect buildAppBarLeadingButton(
    BuildContext context,
    ThemeData _theme,
    StoryDetailScreenNotifier notifier,
  ) {
    return VTOnTapEffect(
      effects: [
        VTOnTapEffectItem(
          effectType: VTOnTapEffectType.scaleDown,
          active: 0.9,
        ),
      ],
      child: Container(
        height: kToolbarHeight,
        child: IconButton(
          highlightColor: _theme.disabledColor,
          onPressed: () {
            onPop(context, notifier);
          },
          icon: Icon(
            Icons.cancel,
            color: _theme.primaryColorDark,
            size: 24,
          ),
        ),
      ),
    );
  }

  showSnackBar({
    BuildContext context,
    @required String title,
    String actionLabel,
    VoidCallback onActionPressed,
    VoidCallback onClose,
  }) {
    final snack = buildSnackBar(title, context, actionLabel, onActionPressed);

    ScaffoldMessenger.of(context).showSnackBar(snack).closed.then(
      (value) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        if (onClose != null) onClose();
      },
    );
  }

  Future<void> onDelete({
    BuildContext context,
    StoryDetailScreenNotifier notifier,
    bool insert,
  }) async {
    await showSnackBar(
      context: context,
      title: "Are you sure to delete?",
      actionLabel: "Yes",
      onActionPressed: () async {
        final success = await notifier.removeStoryById(story.id);
        if (success) {
          await Future.delayed(Duration(milliseconds: 350)).then((value) {
            onPop(context, notifier);
          });
        } else {
          await showSnackBar(
            context: context,
            title: "Can not delete!",
            actionLabel: "Try again",
            onActionPressed: () async {
              onDelete(
                context: context,
                notifier: notifier,
                insert: insert,
              );
            },
          );
        }
      },
    );
  }
}
