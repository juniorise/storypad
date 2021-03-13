import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:write_your_story/app_helper/app_helper.dart';
import 'package:write_your_story/models/story_model.dart';
import 'package:write_your_story/notifier/database_notifier.dart';
import 'package:write_your_story/notifier/story_detail_screen_notifier.dart';
import 'package:write_your_story/widgets/vt_ontap_effect.dart';
import 'package:write_your_story/widgets/w_icon_button.dart';

class StoryDetailScreen extends HookWidget {
  const StoryDetailScreen({
    Key key,
    this.story,
    this.futureId,
  })  : assert((story != null && futureId == null) ||
            (story == null && futureId != null)),
        super(key: key);

  final StoryModel story;
  final int futureId;

  String getDateLabel(DateTime date, BuildContext context, String label) {
    return "$label: " +
        AppHelper.dateFormat(context).format(date) +
        ", " +
        AppHelper.timeFormat(context).format(date);
  }

  @override
  Widget build(BuildContext context) {
    final _theme = Theme.of(context);
    final bool insert = futureId != null;
    final database = useProvider(databaseProvider);
    final notifier = useProvider(storydetailScreenNotifier)
      ..setDraftStory(
        story ??
            StoryModel(
              id: futureId,
              title: "",
              paragraph: "",
              createOn: DateTime.now(),
              forDate: DateTime.fromMillisecondsSinceEpoch(futureId),
            ),
      );

    final _headerText = TextFormField(
      textAlign: TextAlign.left,
      initialValue: !insert ? story.title ?? "" : "",
      style: _theme.textTheme.subtitle1,
      maxLines: null,
      onChanged: (String value) {
        notifier.setDraftStory(
          notifier.draftStory.copyWith(
            title: value.trim(),
          ),
        );
      },
      decoration: InputDecoration(
        hintText: "Your story title...",
        border: InputBorder.none,
        contentPadding: const EdgeInsets.only(top: 12.0),
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

    final _paragraph = TextFormField(
      textAlign: TextAlign.start,
      initialValue: !insert ? story.paragraph : "",
      maxLines: null,
      onChanged: (String value) {
        notifier.setDraftStory(
          notifier.draftStory.copyWith(
            paragraph: value.trim(),
          ),
        );
      },
      decoration: InputDecoration(
        hintText: "Write your story here...",
        border: InputBorder.none,
        contentPadding: EdgeInsets.zero,
      ),
      style: _theme.textTheme.bodyText2.copyWith(
        color: _theme.textTheme.subtitle2.color.withOpacity(0.6),
      ),
    );

    return GestureDetector(
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
          database,
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
    );
  }

  AppBar buildAppBar(
    BuildContext context,
    ThemeData _theme,
    bool insert,
    StoryDetailScreenNotifier notifier,
    DatabaseNotifier database,
    Widget _aboutDate,
  ) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      leading: buildAppBarLeadingButton(context, _theme),
      actions: [
        WIconButton(
          iconData: Icons.date_range_rounded,
          onPressed: () async {
            notifier.onPickDate(
              context,
              !insert ? story.forDate : notifier.draftStory.forDate,
            );
          },
        ),
        if (!insert)
          WIconButton(
            iconData: Icons.delete,
            onPressed: () {},
            iconColor: _theme.errorColor,
          ),
        WIconButton(
          iconData: Icons.save,
          iconColor: _theme.primaryColor,
          onPressed: () async {
            if (insert) {
              await database.insertStory(notifier.draftStory);
            } else {
              await database.updateStory(
                notifier.draftStory.copyWith(
                  updateOn: DateTime.now(),
                ),
              );
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

  VTOnTapEffect buildAppBarLeadingButton(
      BuildContext context, ThemeData _theme) {
    return VTOnTapEffect(
      onTap: () {
        Navigator.of(context).pop();
      },
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
            Navigator.of(context).pop();
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
}
