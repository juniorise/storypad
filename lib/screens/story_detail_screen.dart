import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_quill/models/documents/document.dart';
import 'package:flutter_quill/widgets/controller.dart';
import 'package:flutter_quill/widgets/default_styles.dart';
import 'package:flutter_quill/widgets/editor.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:write_story/constants/config_constant.dart';
import 'package:write_story/mixins/hook_controller.dart';
import 'package:write_story/mixins/story_detail_method_mixin.dart';
import 'package:write_story/models/story_model.dart';
import 'package:write_story/notifier/quill_controller_notifier.dart';
import 'package:write_story/notifier/story_detail_screen_notifier.dart';
import 'package:write_story/widgets/w_history_button.dart';
import 'package:write_story/widgets/w_icon_button.dart';
import 'package:write_story/widgets/w_quil_toolbar.dart';
import 'package:tuple/tuple.dart';

class StoryDetailScreen extends HookWidget
    with StoryDetailMethodMixin, HookController {
  StoryDetailScreen({
    Key? key,
    required this.story,
    this.insert = false,
  }) : super(key: key);

  final StoryModel story;
  final bool insert;

  final ValueNotifier<double> headerPaddingTopNotifier =
      ValueNotifier<double>(0);

  final FocusNode focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    print("build detail");
    final _notifier = useProvider(storydetailScreenNotifier(story));

    Document? doc;
    try {
      List<dynamic>? json = jsonDecode(_notifier.draftStory.paragraph!);
      doc = Document.fromJson(json!);
    } catch (e) {}

    final quillController = useQuillController(
      document: doc != null ? doc : null,
      selection: doc != null ? TextSelection.collapsed(offset: 0) : null,
      isBasic: doc != null ? false : true,
    );

    final quillNotifier = useProvider(quillControllerProvider(quillController));

    final scrollController = useScrollController();
    final sliverController = useScrollController();

    scrollController.addListener(() {
      sliverController.jumpTo(scrollController.offset);
    });

    sliverController.addListener(() {
      double top = lerpDouble(0, MediaQuery.of(context).viewPadding.top,
          sliverController.offset / sliverController.position.maxScrollExtent)!;
      headerPaddingTopNotifier.value = top;
    });

    final titleController =
        useTextEditingController(text: _notifier.draftStory.title);

    final _headerText = buildHeaderTextField(
      insert: insert,
      notifier: _notifier,
      context: context,
      onChanged: (String value) {
        _notifier.setDraftStory(_notifier.draftStory.copyWith(title: value));
      },
      titleController: titleController,
    );

    final _theme = Theme.of(context);

    final _scaffoldBody = NestedScrollView(
      controller: sliverController,
      headerSliverBuilder: (context, val) {
        return [
          buildAppBar(
            context: context,
            insert: insert,
            notifier: _notifier,
            controller: quillController,
            paragraph: quillNotifier.draftParagraph,
          ),
        ];
      },
      body: Column(
        children: [
          ValueListenableBuilder(
            valueListenable: headerPaddingTopNotifier,
            builder: (context, value, child) {
              return Padding(
                child: _headerText,
                padding:
                    EdgeInsets.symmetric(horizontal: ConfigConstant.margin2)
                        .copyWith(top: headerPaddingTopNotifier.value),
              );
            },
          ),
          const Divider(height: 0),
          Expanded(
            child: QuillEditor(
              placeholder: tr("hint_text.story_detail"),
              maxHeight: null,
              controller: quillController,
              scrollController: scrollController,
              scrollable: true,
              focusNode: focusNode,
              autoFocus: false,
              readOnly: false,
              showCursor: true,
              keyboardAppearance: _theme.brightness,
              enableInteractiveSelection: true,
              expands: false,
              textCapitalization: TextCapitalization.sentences,
              customStyles: DefaultStyles(
                placeHolder: DefaultTextBlockStyle(
                  _theme.textTheme.bodyText1!.copyWith(
                    color: _theme.primaryColorDark.withOpacity(0.3),
                  ),
                  Tuple2(0.0, 0.0),
                  Tuple2(0.0, 0.0),
                  null,
                ),
                paragraph: DefaultTextBlockStyle(
                  Theme.of(context).textTheme.bodyText1!,
                  Tuple2(0.0, 0.0),
                  Tuple2(0.0, 0.0),
                  null,
                ),
              ),
              padding: const EdgeInsets.all(ConfigConstant.margin2)
                  .copyWith(bottom: 48.0 + 16.0),
            ),
          ),
        ],
      ),
    );

    return buildDefinedScaffold(
      context: context,
      notifier: _notifier,
      body: _scaffoldBody,
      controller: quillController,
    );
  }

  Widget buildHeaderTextField({
    required bool insert,
    required StoryDetailScreenNotifier notifier,
    required BuildContext context,
    required ValueChanged<String> onChanged,
    required TextEditingController titleController,
  }) {
    final _theme = Theme.of(context);
    return Container(
      constraints: BoxConstraints(maxHeight: 250),
      child: TextField(
        controller: titleController,
        selectionHeightStyle: BoxHeightStyle.max,
        textAlign: TextAlign.left,
        style: _theme.textTheme.headline6,
        onChanged: onChanged,
        maxLines: null,
        keyboardAppearance: _theme.brightness,
        decoration: InputDecoration(
          hintText: tr("hint_text.title"),
          hintStyle: _theme.textTheme.headline6?.copyWith(
            color: _theme.primaryColorDark.withOpacity(0.3),
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }

  WillPopScope buildDefinedScaffold({
    required BuildContext context,
    required StoryDetailScreenNotifier notifier,
    required Widget body,
    required QuillController controller,
  }) {
    final _theme = Theme.of(context);
    return WillPopScope(
      onWillPop: () async {
        onPopNavigator(
          context: context,
          notifier: notifier,
        );
        return false;
      },
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
          TextEditingController().clear();
        },
        child: Scaffold(
          backgroundColor: _theme.backgroundColor,
          body: body,
          extendBody: true,
          bottomNavigationBar: Container(
            color: _theme.scaffoldBackgroundColor,
            child: SafeArea(
              child: Padding(
                padding: MediaQuery.of(context).viewInsets,
                child: WQuillToolbar.basic(
                  controller: controller,
                  toolbarIconSize: ConfigConstant.iconSize2,
                  showLink: false,
                  showHeaderStyle: false,
                  showCodeBlock: false,
                  showUnderLineButton: true,
                  showHorizontalRule: false,
                  showStrikeThrough: false,
                  showIndent: false,
                  showClearFormat: true,
                  showColorButton: false,
                  showBackgroundColorButton: false,
                  onImagePickCallback: (File image) async {
                    return image.path;
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildAppBar({
    required BuildContext context,
    required bool insert,
    required StoryDetailScreenNotifier notifier,
    required QuillController controller,
    required String paragraph,
  }) {
    final _theme = Theme.of(context);

    return SliverAppBar(
      backgroundColor: _theme.backgroundColor,
      centerTitle: false,
      floating: true,
      elevation: 0.5,
      leading: buildAppBarLeadingButton(context: context, notifier: notifier),
      actions: [
        WHistoryButton(
          icon: Icons.undo_outlined,
          controller: controller,
          undo: true,
        ),
        WHistoryButton(
          icon: Icons.redo_outlined,
          controller: controller,
          undo: false,
        ),
        WIconButton(
          iconData: Icons.date_range_rounded,
          onPressed: () async {
            onPickDate(
              context: context,
              date: notifier.draftStory.forDate,
              notifier: notifier,
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
              paragraph: paragraph,
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
                  padding: ConfigConstant.layoutPadding,
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

  Widget buildAppBarLeadingButton({
    required BuildContext context,
    required StoryDetailScreenNotifier notifier,
  }) {
    return WIconButton(
      iconData: Icons.clear,
      onPressed: () {
        onPopNavigator(
          context: context,
          notifier: notifier,
        );
      },
    );
  }

  Widget buildAboutDateText({
    required BuildContext context,
    required bool insert,
  }) {
    final _theme = Theme.of(context);
    String _aboutDateText = "";
    if (!insert) {
      _aboutDateText = getDateLabel(
            date: story.createOn,
            context: context,
            labelKey: "msg.date.create_on",
          ) +
          "\n" +
          getDateLabel(
            date: story.forDate,
            context: context,
            labelKey: "msg.date.for_date",
          );
    }

    if (!insert && story.updateOn != null) {
      _aboutDateText += "\n" +
          getDateLabel(
            date: story.updateOn ?? DateTime.now(),
            context: context,
            labelKey: "msg.date.update_on",
          );
    }

    final aboutDate = !insert
        ? Text(
            _aboutDateText,
            textAlign: TextAlign.start,
            style: TextStyle(
              color: _theme.textTheme.subtitle2?.color?.withOpacity(0.6),
            ),
          )
        : const SizedBox();

    return aboutDate;
  }
}
