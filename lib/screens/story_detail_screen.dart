import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_quill/models/documents/document.dart';
import 'package:flutter_quill/widgets/controller.dart';
import 'package:flutter_quill/widgets/default_styles.dart';
import 'package:flutter_quill/widgets/editor.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:write_story/constants/config_constant.dart';
import 'package:write_story/mixins/hook_controller.dart';
import 'package:write_story/mixins/snakbar_mixin.dart';
import 'package:write_story/mixins/story_detail_method_mixin.dart';
import 'package:write_story/models/story_model.dart';
import 'package:write_story/notifier/quill_controller_notifier.dart';
import 'package:write_story/notifier/story_detail_screen_notifier.dart';
import 'package:write_story/notifier/theme_notifier.dart';
import 'package:write_story/screens/ask_for_name_sheet.dart';
import 'package:write_story/services/google_drive_api_service.dart';
import 'package:write_story/services/image_compress_service.dart';
import 'package:write_story/widgets/vt_ontap_effect.dart';
import 'package:write_story/widgets/w_history_button.dart';
import 'package:write_story/widgets/w_icon_button.dart';
import 'package:write_story/widgets/w_quil_toolbar.dart';
import 'package:tuple/tuple.dart';

class StoryDetailScreen extends HookWidget
    with StoryDetailMethodMixin, HookController, WSnackBar {
  StoryDetailScreen({
    Key? key,
    required this.story,
    this.insert = false,
  }) : super(key: key);

  final StoryModel story;
  final bool insert;

  final ValueNotifier<double> headerPaddingTopNotifier =
      ValueNotifier<double>(0);

  final ValueNotifier<bool> imageLoadingNotifier = ValueNotifier<bool>(false);

  final FocusNode focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    print("build detail");
    final _notifier = useProvider(storydetailScreenNotifier(story));
    final readOnlyModeNotifier = useState<bool>(!insert);

    final bottomHeight = MediaQuery.of(context).padding.bottom;
    final statusBarHeight = MediaQuery.of(context).padding.top;

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
      readOnlyModeNotifier: readOnlyModeNotifier,
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
            quillNotifier: quillNotifier,
            readOnlyModeNotifier: readOnlyModeNotifier,
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
          ValueListenableBuilder(
            valueListenable: imageLoadingNotifier,
            builder: (context, value, child) {
              return WLineLoading(loading: imageLoadingNotifier.value);
            },
          ),
          Divider(
            height: 0,
            thickness: 0.1,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: readOnlyModeNotifier,
              builder: (context, value, child) {
                return QuillEditor(
                  placeholder: tr("hint_text.story_detail"),
                  maxHeight: null,
                  controller: quillController,
                  scrollController: scrollController,
                  scrollable: true,
                  focusNode: focusNode,
                  autoFocus: insert,
                  readOnly: readOnlyModeNotifier.value,
                  showCursor: !readOnlyModeNotifier.value,
                  keyboardAppearance: _theme.brightness,
                  enableInteractiveSelection: true,
                  expands: false,
                  textCapitalization: TextCapitalization.sentences,
                  customStyles: DefaultStyles(
                    placeHolder: DefaultTextBlockStyle(
                      _theme.textTheme.bodyText1!.copyWith(
                        color: _theme.colorScheme.onSurface.withOpacity(0.3),
                      ),
                      Tuple2(0.0, 0.0),
                      Tuple2(0.0, 0.0),
                      null,
                    ),
                    paragraph: DefaultTextBlockStyle(
                      _theme.textTheme.bodyText1!.copyWith(
                        color: _theme.colorScheme.onSurface.withOpacity(0.5),
                      ),
                      Tuple2(0.0, 0.0),
                      Tuple2(0.0, 0.0),
                      null,
                    ),
                  ),
                  padding: const EdgeInsets.all(
                    ConfigConstant.margin2,
                  ).copyWith(
                    bottom: kToolbarHeight,
                  ),
                );
              },
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
      readOnlyModeNotifier: readOnlyModeNotifier,
      bottomHeight: bottomHeight,
      statusBarHeight: statusBarHeight,
    );
  }

  Widget buildHeaderTextField({
    required bool insert,
    required StoryDetailScreenNotifier notifier,
    required BuildContext context,
    required ValueChanged<String> onChanged,
    required TextEditingController titleController,
    required ValueNotifier readOnlyModeNotifier,
  }) {
    final _theme = Theme.of(context);
    return Container(
      constraints: BoxConstraints(maxHeight: 250),
      child: ValueListenableBuilder(
        valueListenable: readOnlyModeNotifier,
        builder: (context, value, child) {
          return TextField(
            controller: titleController,
            selectionHeightStyle: BoxHeightStyle.max,
            textAlign: TextAlign.left,
            style: _theme.textTheme.headline6,
            readOnly: readOnlyModeNotifier.value,
            onChanged: onChanged,
            maxLines: null,
            keyboardAppearance: _theme.brightness,
            decoration: InputDecoration(
              hintText: tr("hint_text.title"),
              hintStyle: _theme.textTheme.headline6?.copyWith(
                color: _theme.colorScheme.onSurface.withOpacity(0.3),
              ),
              border: InputBorder.none,
            ),
          );
        },
      ),
    );
  }

  Widget buildDefinedScaffold({
    required BuildContext context,
    required StoryDetailScreenNotifier notifier,
    required Widget body,
    required QuillController controller,
    required ValueNotifier readOnlyModeNotifier,
    required double bottomHeight,
    required double statusBarHeight,
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
        onDoubleTap: readOnlyModeNotifier.value
            ? () {
                readOnlyModeNotifier.value = false;
                focusNode.requestFocus();
              }
            : null,
        child: Scaffold(
          backgroundColor: _theme.colorScheme.surface,
          body: body,
          extendBody: true,
          bottomNavigationBar: ValueListenableBuilder(
            valueListenable: readOnlyModeNotifier,
            child: Container(
              padding: EdgeInsets.only(bottom: bottomHeight),
              child: WQuillToolbar.basic(
                controller: controller,
                toolbarIconSize: ConfigConstant.iconSize2,
                showLink: false,
                showHeaderStyle: false,
                showCodeBlock: true,
                showUnderLineButton: true,
                showHorizontalRule: false,
                showStrikeThrough: false,
                showIndent: false,
                showClearFormat: true,
                showColorButton: false,
                showBackgroundColorButton: false,
                onImagePickCallback: (File _pickImage) async {
                  bool? compress;
                  final Widget dialog = Dialog(
                    child: Wrap(
                      children: [
                        ListTile(
                          leading: AspectRatio(
                            aspectRatio: 1.5 / 2,
                            child: Container(
                              height: double.infinity,
                              child: Icon(Icons.compress),
                            ),
                          ),
                          title: Text(tr("button.compress.yes")),
                          subtitle: Text(tr("msg.compress.yes")),
                          onTap: () {
                            compress = true;
                            Navigator.of(context).pop();
                          },
                        ),
                        const Divider(height: 0),
                        ListTile(
                          leading: AspectRatio(
                            aspectRatio: 1.5 / 2,
                            child: Container(
                              height: double.infinity,
                              child: Icon(Icons.crop_original),
                            ),
                          ),
                          title: Text(tr("button.compress.no")),
                          subtitle: Text(tr("msg.compress.no")),
                          onTap: () {
                            compress = false;
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    ),
                  );

                  if (Platform.isIOS) {
                    await showCupertinoDialog(
                      barrierDismissible: true,
                      context: context,
                      builder: (context) {
                        return dialog;
                      },
                    );
                  } else {
                    await showDialog(
                      context: context,
                      builder: (context) {
                        return dialog;
                      },
                    );
                  }

                  final imageName = await _pickImage.length();

                  final File? image = await ImageCompressService(
                    file: _pickImage,
                    name: imageName.toString(),
                    compress: compress == true,
                  ).exec();

                  if (image?.path.isNotEmpty == true) {
                    notifier.addImagePath(image?.absolute.path);
                  }
                  return image?.path ?? "";
                },
              ),
            ),
            builder: (context, value, child) {
              return AnimatedOpacity(
                opacity: !readOnlyModeNotifier.value ? 1 : 0,
                duration: ConfigConstant.duration,
                child: Container(
                  padding: MediaQuery.of(context).viewInsets,
                  height: readOnlyModeNotifier.value ? bottomHeight : null,
                  color: _theme.colorScheme.background,
                  child: child,
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget buildAppBar({
    required BuildContext context,
    required bool insert,
    required StoryDetailScreenNotifier notifier,
    required QuillControllerNotifer quillNotifier,
    required ValueNotifier readOnlyModeNotifier,
  }) {
    final _theme = Theme.of(context);
    return SliverAppBar(
      backgroundColor: _theme.colorScheme.surface,
      centerTitle: false,
      floating: true,
      elevation: 0.5,
      leading: buildAppBarLeadingButton(context: context, notifier: notifier),
      actions: [
        ValueListenableBuilder(
          valueListenable: readOnlyModeNotifier,
          child: Row(
            children: [
              WHistoryButton(
                icon: Icons.undo_outlined,
                controller: quillNotifier.controller,
                undo: true,
              ),
              WHistoryButton(
                icon: Icons.redo_outlined,
                controller: quillNotifier.controller,
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
            ],
          ),
          builder: (context, value, child) {
            return AnimatedOpacity(
              duration: ConfigConstant.fadeDuration,
              opacity: !readOnlyModeNotifier.value ? 1 : 0,
              child: child,
            );
          },
        ),
        WIconButton(
          iconData: Icons.more_vert,
          onPressed: () {
            showMenu(
              context: context,
              position: RelativeRect.fromLTRB(8.0, 0.0, 0.0, 0.0),
              items: [
                if (!insert)
                  PopupMenuItem(
                    child: VTOnTapEffect(
                      onTap: () async {
                        Navigator.of(context).pop();
                        onDelete(
                          context: context,
                          notifier: notifier,
                          insert: insert,
                          id: story.id,
                        );
                      },
                      child: ListTile(
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: ConfigConstant.margin1,
                        ),
                        leading: Icon(
                          Icons.delete,
                          color: _theme.colorScheme.error,
                        ),
                        title: Text(tr("button.delete")),
                      ),
                    ),
                  ),
                PopupMenuItem(
                  child: VTOnTapEffect(
                    onTap: () async {
                      Navigator.of(context).pop();
                      await onSave(
                        imageLoadingNotifier: imageLoadingNotifier,
                        notifier: notifier,
                        context: context,
                        insert: insert,
                        paragraph: quillNotifier.draftParagraph,
                      );
                    },
                    child: ListTile(
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: ConfigConstant.margin1,
                        ),
                        leading: const Icon(Icons.save),
                        title: Text(tr("button.save"))),
                  ),
                ),
                if (!insert)
                  PopupMenuItem(
                    child: VTOnTapEffect(
                      onTap: () async {
                        Navigator.of(context).pop();
                        final dialog = Dialog(
                          child: buildAboutDateText(
                            context: context,
                            insert: insert,
                            notifier: notifier,
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
                      child: ListTile(
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: ConfigConstant.margin1,
                          ),
                          leading: Icon(Icons.info),
                          title: Text(
                            tr("button.info"),
                          )),
                    ),
                  ),
                PopupMenuItem(
                  child: Consumer(
                    builder: (context, watch, child) {
                      final notifier = watch(themeProvider);
                      return VTOnTapEffect(
                        onTap: () {
                          Navigator.of(context).pop();
                          Future.delayed(ConfigConstant.duration).then(
                            (value) {
                              notifier.toggleTheme();
                            },
                          );
                        },
                        child: ListTile(
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: ConfigConstant.margin1,
                          ),
                          leading: Icon(Icons.nights_stay),
                          title: Text(tr("button.dark_mode")),
                          trailing: Container(
                            child: Switch(
                              value: notifier.isDarkMode == true,
                              onChanged: (bool value) {
                                Navigator.of(context).pop();
                                Future.delayed(ConfigConstant.duration).then(
                                  (value) {
                                    notifier.toggleTheme();
                                  },
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                PopupMenuItem(
                  child: ValueListenableBuilder(
                    valueListenable: readOnlyModeNotifier,
                    builder: (context, value, child) {
                      return VTOnTapEffect(
                        onTap: () {
                          if (readOnlyModeNotifier.value) {
                            focusNode.requestFocus();
                            Navigator.of(context).pop();
                          } else {
                            focusNode.unfocus();
                          }
                          Future.delayed(ConfigConstant.duration).then(
                            (value) {
                              readOnlyModeNotifier.value =
                                  !readOnlyModeNotifier.value;
                            },
                          );
                        },
                        child: ListTile(
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: ConfigConstant.margin1,
                          ),
                          leading: Icon(!readOnlyModeNotifier.value
                              ? Icons.chrome_reader_mode_outlined
                              : Icons.chrome_reader_mode),
                          title: Text(tr("button.read_only")),
                          trailing: Switch(
                            value: readOnlyModeNotifier.value,
                            onChanged: (bool value) {
                              if (readOnlyModeNotifier.value) {
                                focusNode.requestFocus();
                                Navigator.of(context).pop();
                              } else {
                                focusNode.unfocus();
                              }
                              Future.delayed(ConfigConstant.duration).then(
                                (value) {
                                  readOnlyModeNotifier.value =
                                      !readOnlyModeNotifier.value;
                                },
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Container buildListTile(
    BuildContext context,
    Widget title,
    IconData iconData,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ConfigConstant.margin2,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(iconData),
          SizedBox(width: 16.0),
          title,
        ],
      ),
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
    required StoryDetailScreenNotifier notifier,
  }) {
    final _theme = Theme.of(context);
    String? _createOn;
    String? _forDate;
    String? _updateOn;

    if (!insert) {
      _createOn = getDateLabel(
        date: story.createOn,
        context: context,
      );

      _forDate = getDateLabel(
        date: story.forDate,
        context: context,
      );
    }

    if (!insert && story.updateOn != null) {
      _updateOn = getDateLabel(
        date: story.updateOn ?? DateTime.now(),
        context: context,
      );
    }

    final style = TextStyle(
      color: _theme.textTheme.bodyText2?.color?.withOpacity(0.5),
    );

    final aboutDate = !insert
        ? Wrap(
            children: [
              if (_createOn != null)
                Column(
                  children: [
                    ListTile(
                      title: Text(tr("msg.date.create_on")),
                      subtitle: Text(_createOn, style: style),
                      onTap: () {},
                    ),
                    const Divider(height: 0),
                  ],
                ),
              if (_forDate != null)
                Column(
                  children: [
                    ListTile(
                      title: Text(tr("msg.date.for_date")),
                      subtitle: Text(_forDate, style: style),
                      onTap: () {
                        Navigator.of(context).pop();
                        onPickDate(
                          context: context,
                          date: notifier.draftStory.forDate,
                          notifier: notifier,
                        );
                      },
                    ),
                    const Divider(height: 0),
                  ],
                ),
              if (_updateOn != null)
                ListTile(
                  title: Text(tr("msg.date.update_on")),
                  subtitle: Text(_updateOn, style: style),
                  onTap: () {},
                ),
            ],
          )
        : const SizedBox();

    return aboutDate;
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
        final image = await GoogleDriveApiService.upload(File(e));
        if (image != null) {
          i++;
          _tmpParagraph = _tmpParagraph?.replaceAll("$e", image);
        }
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
