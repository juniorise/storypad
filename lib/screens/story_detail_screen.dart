import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:write_your_story/app_helper/app_helper.dart';
import 'package:write_your_story/models/story_model.dart';
import 'package:write_your_story/notifier/database_notifier.dart';
import 'package:write_your_story/notifier/story_detail_screen_notifier.dart';
import 'package:write_your_story/widgets/vt_ontap_effect.dart';

class StoryDetailScreen extends HookWidget {
  const StoryDetailScreen({
    Key key,
    @required this.callback,
    this.story,
    this.futureId,
  })  : assert((story != null && futureId == null) ||
            (story == null && futureId != null)),
        super(key: key);

  final StoryModel story;
  final VoidCallback callback;
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
              forDate: DateTime.now(),
            ),
      );

    final _headerText = TextFormField(
      textAlign: TextAlign.left,
      initialValue: !insert ? story.title ?? "" : "",
      style: _theme.textTheme.subtitle1,
      maxLines: null,
      onChanged: (String value) {
        notifier.setDraftStory(story.copyWith(title: value));
      },
      decoration: InputDecoration(
        hintText: "Your story title...",
        border: InputBorder.none,
        contentPadding: EdgeInsets.only(top: 12.0),
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
        notifier.setDraftStory(story.copyWith(paragraph: value));
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

    return WillPopScope(
      onWillPop: () {
        callback();
        return;
      },
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
          TextEditingController().clear();
        },
        child: Scaffold(
          backgroundColor: _theme.backgroundColor,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: false,
            leading: VTOnTapEffect(
              onTap: () {
                callback();
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
                    callback();
                  },
                  icon: Icon(
                    Icons.cancel,
                    color: _theme.primaryColorDark,
                    size: 24,
                  ),
                ),
              ),
            ),
            actions: [
              VTOnTapEffect(
                effects: [
                  VTOnTapEffectItem(
                    effectType: VTOnTapEffectType.scaleDown,
                    active: 0.9,
                  ),
                ],
                child: Container(
                  width: kToolbarHeight,
                  child: IconButton(
                    highlightColor: _theme.disabledColor,
                    onPressed: () async {
                      final DateTime forDate = await showDatePicker(
                        context: context,
                        initialDate: story.forDate,
                        firstDate: DateTime(story.forDate.year),
                        lastDate: DateTime(story.forDate.year, 12, 31),
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

                      notifier.setDraftStory(story.copyWith(forDate: forDate));
                    },
                    icon: Icon(
                      Icons.date_range_sharp,
                      color: _theme.primaryColorDark,
                      size: 24,
                    ),
                  ),
                ),
              ),
              if (!insert)
                VTOnTapEffect(
                  effects: [
                    VTOnTapEffectItem(
                      effectType: VTOnTapEffectType.scaleDown,
                      active: 0.9,
                    ),
                  ],
                  child: Container(
                    width: kToolbarHeight,
                    child: IconButton(
                      highlightColor: _theme.disabledColor,
                      onPressed: () async {},
                      icon: Icon(
                        Icons.delete,
                        color: _theme.errorColor,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              VTOnTapEffect(
                onTap: callback,
                effects: [
                  VTOnTapEffectItem(
                    effectType: VTOnTapEffectType.scaleDown,
                    active: 0.9,
                  ),
                ],
                child: Container(
                  width: kToolbarHeight,
                  child: IconButton(
                    highlightColor: _theme.disabledColor,
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
                    icon: Icon(
                      Icons.save,
                      color: _theme.primaryColor,
                      size: 24,
                    ),
                  ),
                ),
              ),
              VTOnTapEffect(
                effects: [
                  VTOnTapEffectItem(
                    effectType: VTOnTapEffectType.scaleDown,
                    active: 0.9,
                  ),
                ],
                child: Container(
                  width: kToolbarHeight,
                  child: IconButton(
                    highlightColor: _theme.disabledColor,
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
                    icon: Icon(
                      Icons.info,
                      size: 24,
                      color: _theme.primaryColorDark,
                    ),
                  ),
                ),
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Wrap(
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
}
