import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:write_story/mixins/story_detail_method_mixin.dart';
import 'package:write_story/models/story_model.dart';
import 'package:write_story/notifier/story_detail_screen_notifier.dart';
import 'package:write_story/widgets/vt_ontap_effect.dart';
import 'package:write_story/widgets/w_icon_button.dart';

class StoryDetailScreen extends HookWidget with StoryDetailMethodMixin {
  StoryDetailScreen({
    Key key,
    this.story,
    this.futureId,
    this.forDate,
  })  : assert((story != null && (futureId == null && forDate == null)) ||
            (story == null && (futureId != null && forDate != null))),
        super(key: key);

  /// [story] must be null if
  /// [futureId] and [forDate] is not null
  final StoryModel story;

  /// if [futureId] not null
  /// which mean that this screen
  /// is inserting new story
  final int futureId;

  /// [forDate] must be null,
  /// if [story] is not null
  final DateTime forDate;

  final ValueNotifier<bool> isEditing = ValueNotifier<bool>(false);

  @override
  Widget build(BuildContext context) {
    print("build detail");

    final bool insert = futureId != null;
    final _notifier = useProvider(storydetailScreenNotifier);

    final initTitle = !insert && _notifier.draftStory != null
        ? _notifier.draftStory.title
        : "";

    final initParagraph = !insert && _notifier.draftStory != null
        ? _notifier.draftStory.paragraph
        : "";

    final draftStory = StoryModel(
      id: futureId,
      title: initTitle,
      paragraph: initParagraph,
      createOn: DateTime.now(),
      forDate: forDate,
    );

    _notifier..setDraftStory(!insert ? story : draftStory);

    final _headerText = buildHeaderTextField(
      insert: insert,
      notifier: _notifier,
      context: context,
    );

    final _paragraph = buildParagraphTextField(
      insert: insert,
      notifier: _notifier,
      context: context,
    );

    final _scaffoldBody = NestedScrollView(
      headerSliverBuilder: (context, val) {
        return [
          buildAppBar(
            context: context,
            insert: insert,
            notifier: _notifier,
          ),
        ];
      },
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
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
    );

    return buildDefinedScaffold(
      context: context,
      notifier: _notifier,
      body: _scaffoldBody,
    );
  }

  TextFormField buildHeaderTextField({
    @required bool insert,
    @required StoryDetailScreenNotifier notifier,
    @required BuildContext context,
  }) {
    final _theme = Theme.of(context);
    return TextFormField(
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
  }

  Transform buildParagraphTextField({
    @required bool insert,
    @required StoryDetailScreenNotifier notifier,
    @required BuildContext context,
  }) {
    final _theme = Theme.of(context);
    return Transform.translate(
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
  }

  WillPopScope buildDefinedScaffold({
    @required BuildContext context,
    @required StoryDetailScreenNotifier notifier,
    @required Widget body,
  }) {
    final _theme = Theme.of(context);
    return WillPopScope(
      onWillPop: () {
        onPopNavigator(
          context: context,
          notifier: notifier,
        );
        return;
      },
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
          TextEditingController().clear();
        },
        child: Scaffold(
          backgroundColor: _theme.backgroundColor,
          body: body,
        ),
      ),
    );
  }

  Widget buildAppBar({
    BuildContext context,
    bool insert,
    StoryDetailScreenNotifier notifier,
  }) {
    final _theme = Theme.of(context);

    return SliverAppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      floating: true,
      leading: buildAppBarLeadingButton(context: context, notifier: notifier),
      actions: [
        WIconButton(
          iconData: Icons.date_range_rounded,
          onPressed: () async {
            onPickDate(
              context: context,
              date: !insert ? story.forDate : notifier.draftStory.forDate,
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
              id: story.id,
            ),
          ),
        WIconButton(
          iconData: Icons.save,
          iconColor: _theme.primaryColor,
          onPressed: () async {
            await onSave(
              notifier: notifier,
              context: context,
              insert: insert,
            );
          },
        ),
        if (!insert)
          WIconButton(
            iconData: Icons.info,
            onPressed: () async {
              final dialog = Dialog(
                child: Container(
                  child: buildAboutDateText(
                    context: context,
                    insert: insert,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                ),
              );
              if (Platform.isIOS) {
                showCupertinoDialog(
                  barrierDismissible: true,
                  context: context,
                  builder: (context) {
                    return dialog;
                  },
                );
              } else {
                showDialog(
                  context: context,
                  builder: (context) {
                    return dialog;
                  },
                );
              }
            },
          ),
      ],
    );
  }

  VTOnTapEffect buildAppBarLeadingButton({
    @required BuildContext context,
    @required StoryDetailScreenNotifier notifier,
  }) {
    final _theme = Theme.of(context);
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
            onPopNavigator(
              context: context,
              notifier: notifier,
            );
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

  Widget buildAboutDateText({
    @required BuildContext context,
    @required bool insert,
  }) {
    final _theme = Theme.of(context);
    String _aboutDateText = "";
    if (!insert) {
      _aboutDateText = getDateLabel(
            date: story.createOn,
            context: context,
            label: "Create on",
          ) +
          "\n" +
          getDateLabel(
            date: story.forDate,
            context: context,
            label: "For Date",
          );
    }

    if (!insert && story.updateOn != null) {
      _aboutDateText += "\n" +
          getDateLabel(
            date: story.updateOn,
            context: context,
            label: "Update on",
          );
    }

    final aboutDate = !insert
        ? Text(
            _aboutDateText,
            textAlign: TextAlign.start,
            style: TextStyle(
              color: _theme.textTheme.subtitle2.color.withOpacity(0.6),
            ),
          )
        : const SizedBox();

    return aboutDate;
  }
}
