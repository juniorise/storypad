import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_quill/models/documents/document.dart';
import 'package:flutter_quill/models/documents/nodes/leaf.dart' as leaf;
import 'package:flutter_quill/widgets/controller.dart';
import 'package:flutter_quill/widgets/default_styles.dart';
import 'package:flutter_quill/widgets/editor.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:share/share.dart';
import 'package:storypad/helpers/measure_size.dart';
import 'package:storypad/helpers/quill_helper.dart';
import 'package:storypad/constants/config_constant.dart';
import 'package:storypad/mixins/dialog_mixin.dart';
import 'package:storypad/mixins/hook_controller.dart';
import 'package:storypad/mixins/snakbar_mixin.dart';
import 'package:storypad/mixins/story_detail_method_mixin.dart';
import 'package:storypad/models/feeling_emoji_model.dart';
import 'package:storypad/models/story_model.dart';
import 'package:storypad/notifier/story_detail/header_notifer.dart';
import 'package:storypad/notifier/story_detail/image_load_notifier.dart';
import 'package:storypad/notifier/quill_controller_notifier.dart';
import 'package:storypad/notifier/story_detail/story_detail_screen_notifier.dart';
import 'package:storypad/notifier/theme_notifier.dart';
import 'package:storypad/services/story_detail_service.dart';
import 'package:storypad/sheets/ask_for_name_sheet.dart';
import 'package:storypad/sheets/image_viewer_sheet.dart';
import 'package:storypad/services/image_compress_service.dart';
import 'package:storypad/widgets/vt_ontap_effect.dart';
import 'package:storypad/widgets/w_emoji_picker_button.dart';
import 'package:storypad/widgets/w_history_button.dart';
import 'package:storypad/widgets/w_icon_button.dart';
import 'package:storypad/widgets/w_quil_toolbar.dart';
import 'package:tuple/tuple.dart';

class StoryDetailScreen extends HookWidget with StoryDetailMethodMixin, HookController, WSnackBar, DialogMixin {
  StoryDetailScreen({
    Key? key,
    required this.story,
    this.insert = false,
    this.forceReadOnly = false,
  }) : super(key: key);

  final StoryModel story;
  final bool insert;
  final bool forceReadOnly;

  @override
  Widget build(BuildContext context) {
    print("Build StoryDetailScreen");

    final _notifier = useProvider(storydetailScreenNotifier(story));
    final readOnlyModeNotifier = useState<bool>(!insert);
    final focusNode = useFocusNode();

    final screenPadding = MediaQuery.of(context).padding;
    final bottomHeight = screenPadding.bottom;
    final statusBarHeight = screenPadding.top;

    focusNode.addListener(() {
      bool _keyboardVisible = MediaQuery.of(context).viewInsets.bottom != 0;
      if (focusNode.hasFocus) {
        _notifier.setSaragraphIsFocused(true, keyboardOpen: _keyboardVisible);
      } else {
        _notifier.setSaragraphIsFocused(false);
      }
    });

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

    quillController.addListener(() {
      _notifier.setDraftStory(
        _notifier.draftStory.copyWith(paragraph: quillNotifier.draftParagraph),
      );
    });

    _notifier.addOnPauseCallBack(
      () => StoryDetailService().onSave(
        notifier: _notifier,
        context: context,
        paragraph: quillNotifier.draftParagraph,
        insert: insert,
        showSnack: false,
      ),
    );

    final scrollController = useScrollController();

    scrollController.addListener(() {
      final headNotifier = context.read(headerProvider);
      double minValue = scrollController.offset;
      double maxHeight = kToolbarHeight > headNotifier.headerHeight ? kToolbarHeight : headNotifier.headerHeight;
      if (minValue >= maxHeight) minValue = maxHeight;
      if (minValue <= 0) minValue = 0;
      headNotifier.headerPaddingTop = minValue / maxHeight;
    });

    final titleController = useTextEditingController(text: _notifier.draftStory.title);

    final _headerText = buildHeaderTextField(
      insert: insert,
      notifier: _notifier,
      readOnlyModeNotifier: readOnlyModeNotifier,
      context: context,
      onChanged: (String value) {
        _notifier.setDraftStory(_notifier.draftStory.copyWith(title: value));
      },
      onHeightChange: (double value) {
        final headNotifier = context.read(headerProvider);
        headNotifier.headerHeight = value;
      },
      titleController: titleController,
    );

    final _theme = Theme.of(context);
    final _scaffoldBody = Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: buildAppBar(
        context: context,
        insert: insert,
        notifier: _notifier,
        quillNotifier: quillNotifier,
        readOnlyModeNotifier: readOnlyModeNotifier,
        focusNode: focusNode,
        titleController: titleController,
        top: MediaQuery.of(context).viewPadding.top,
        scrollController: scrollController,
      ),
      body: Column(
        children: [
          Consumer(
            builder: (context, watch, child) {
              final headNotifier = watch(headerProvider);
              double top = lerpDouble(
                0,
                headNotifier.headerHeight,
                headNotifier.headerPaddingTop,
              )!;

              double height = lerpDouble(
                headNotifier.headerHeight,
                0,
                headNotifier.headerPaddingTop,
              )!;

              return Opacity(
                opacity: max(0, 1 - headNotifier.headerPaddingTop * 2),
                child: ClipPath(
                  child: ValueListenableBuilder(
                    valueListenable: headNotifier.inited && scrollController.hasClients
                        ? scrollController.position.isScrollingNotifier
                        : readOnlyModeNotifier,
                    child: Container(height: height, child: Wrap(children: [_headerText])),
                    builder: (context, bool? isScrolling, child) {
                      return AnimatedContainer(
                        curve: Curves.linearToEaseOut,
                        duration: isScrolling == true ? Duration.zero : ConfigConstant.fadeDuration,
                        transform: Matrix4.identity()..translate(0.0, -top),
                        padding: const EdgeInsets.symmetric(
                          horizontal: ConfigConstant.margin2,
                        ),
                        child: child,
                      );
                    },
                  ),
                ),
              );
            },
          ),
          buildDivider(context),
          Expanded(
            child: Scrollbar(
              showTrackOnHover: true,
              child: GestureDetector(
                onVerticalDragUpdate: (detail) {
                  final headNotifier = context.read(headerProvider);
                  if (scrollController.offset == 0 && headNotifier.headerPaddingTop != 0) {
                    headNotifier.headerPaddingTop = 0;
                  }
                },
                child: QuillEditor(
                  scrollBottomInset: ConfigConstant.objectHeight1,
                  placeholder: tr("hint_text.story_detail"),
                  maxHeight: null,
                  controller: quillController,
                  scrollController: scrollController,
                  scrollable: true,
                  focusNode: focusNode,
                  autoFocus: true,
                  readOnly: readOnlyModeNotifier.value,
                  showCursor: !readOnlyModeNotifier.value,
                  keyboardAppearance: _theme.colorScheme.brightness,
                  enableInteractiveSelection: true,
                  expands: false,
                  embedBuilder: (BuildContext context, leaf.Embed node) {
                    return _embedBuilder(
                      context: context,
                      node: node,
                      notifier: _notifier,
                      screenPadding: screenPadding,
                      readOnlyModeNotifier: readOnlyModeNotifier,
                      quillNotifier: quillNotifier,
                    );
                  },
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
                      _theme.textTheme.bodyText1!,
                      Tuple2(0.0, 0.0),
                      Tuple2(0.0, 0.0),
                      null,
                    ),
                  ),
                  padding: const EdgeInsets.all(
                    ConfigConstant.margin2,
                  ).copyWith(
                    bottom: kToolbarHeight * 2,
                  ),
                ),
              ),
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
      quillNotifier: quillNotifier,
    );
  }

  Divider buildDivider(BuildContext context) {
    return Divider(
      height: 0,
      thickness: 0.1,
      color: Theme.of(context).colorScheme.onSurface,
    );
  }

  Widget _embedBuilder({
    required BuildContext context,
    required leaf.Embed node,
    required StoryDetailScreenNotifier notifier,
    required EdgeInsets screenPadding,
    required ValueNotifier readOnlyModeNotifier,
    required QuillControllerNotifer quillNotifier,
  }) {
    bool isDarkMode = Theme.of(context).colorScheme.brightness == Brightness.dark;

    assert(!kIsWeb, 'Please provide EmbedBuilder for Web');
    switch (node.value.type) {
      case 'image':
        bool error = false;
        Widget imageChild;
        String imageUrl = _standardizeImageUrl(node.value.data);
        if (imageUrl.startsWith('http')) {
          imageChild = Consumer(
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.background,
              ),
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Container(
                width: 150,
                child: Column(
                  children: [
                    Image.asset(
                      isDarkMode
                          ? "assets/illustrations/error-cloud.png"
                          : "assets/illustrations/error-cloud-light.png",
                      width: 100,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Image may be deleted or marked as private or not internet connection",
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      child: Text("Retry"),
                      onPressed: () async {
                        final imageLoadNotifier = context.read(imageLoadProvider);
                        imageLoadNotifier.imageRetry = true;
                        notifier.setLoadingUrl(imageUrl);
                        await _clearCache(imageUrl);
                        await notifier.retryLoadImage();
                        await notifier.retryLoadImage();
                        imageLoadNotifier.imageRetry = false;
                      },
                    ),
                  ],
                ),
              ),
            ),
            builder: (context, watch, errorBuilder) {
              final imageLoadNotifier = watch(imageLoadProvider);
              return imageLoadNotifier.imageRetry && notifier.loadingUrl == imageUrl
                  ? errorBuilder ?? const SizedBox()
                  : CachedNetworkImage(
                      key: UniqueKey(),
                      imageUrl: imageUrl,
                      errorWidget: (context, _, __) {
                        error = true;
                        return errorBuilder ?? const SizedBox();
                      },
                    );
            },
          );
        } else if (isBase64(imageUrl)) {
          imageChild = Image.memory(base64.decode(imageUrl));
        } else {
          imageChild = Image.file(File(imageUrl));
        }
        return VTOnTapEffect(
          child: ClipRRect(
            borderRadius: ConfigConstant.circlarRadius1,
            child: imageChild,
          ),
          vibrate: !error,
          onTap: () async {
            if (!error && readOnlyModeNotifier.value) {
              showImageViewerSheet(
                context,
                imageChild,
                screenPadding,
                imageUrl,
              );
            }
          },
        );
      default:
        throw UnimplementedError('Embeddable type "${node.value.type}" is not supported by default embed '
            'builder of QuillEditor. You must pass your own builder function to '
            'embedBuilder property of QuillEditor or QuillField widgets.');
    }
  }

  showImageViewerSheet(
    BuildContext context,
    Widget imageChild,
    EdgeInsets screenPadding,
    String? imageUrl,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black.withOpacity(0),
      isScrollControlled: true,
      useRootNavigator: true,
      builder: (_) {
        return ImageViewer(
          imageChild: imageChild,
          screenPadding: screenPadding,
          onShareImage: imageUrl != null
              ? () async {
                  onTapVibrate();
                  final file = await _findPath(imageUrl);
                  await Share.shareFiles([file.path]);
                }
              : null,
        );
      },
    ).then((value) {
      ScaffoldMessenger.maybeOf(context)?.removeCurrentSnackBar();
    });
  }

  Future<File> _findPath(String imageUrl) async {
    final cache = DefaultCacheManager();
    return await cache.getSingleFile(imageUrl);
  }

  Future<void> _clearCache(String imageUrl) async {
    await CachedNetworkImage.evictFromCache(imageUrl);
  }

  Widget buildHeaderTextField({
    required bool insert,
    required StoryDetailScreenNotifier notifier,
    required BuildContext context,
    required ValueChanged<String> onChanged,
    required TextEditingController titleController,
    required ValueNotifier readOnlyModeNotifier,
    required ValueChanged<double> onHeightChange,
  }) {
    final _theme = Theme.of(context);
    return MeasureSize(
      onChange: (Size size) {
        onHeightChange(size.height);
      },
      child: Container(
        constraints: const BoxConstraints(maxHeight: 250),
        child: TextField(
          keyboardType: TextInputType.multiline,
          readOnly: readOnlyModeNotifier.value,
          controller: titleController,
          selectionHeightStyle: BoxHeightStyle.max,
          textAlign: TextAlign.left,
          style: _theme.textTheme.headline6,
          onChanged: onChanged,
          maxLines: null,
          autofocus: true,
          keyboardAppearance: _theme.colorScheme.brightness,
          decoration: InputDecoration(
            hintText: tr("hint_text.title"),
            hintStyle: _theme.textTheme.headline6?.copyWith(
              color: _theme.colorScheme.onSurface.withOpacity(0.3),
            ),
            border: InputBorder.none,
          ),
        ),
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
    required QuillControllerNotifer quillNotifier,
  }) {
    final _theme = Theme.of(context);

    final toolbar = MeasureSize(
      onChange: (Size size) {
        notifier.toolbarHeight = size.height;
      },
      child: WQuillToolbar.basic(
        controller: controller,
        toolbarIconSize: ConfigConstant.iconSize2,
        showLink: true,
        showHeaderStyle: true,
        showCodeBlock: true,
        showBoldButton: true,
        showItalicButton: true,
        showListBullets: true,
        showListCheck: true,
        showListNumbers: true,
        showQuote: true,
        showUnderLineButton: true,
        showHorizontalRule: false,
        showStrikeThrough: true,
        showIndent: false,
        showClearFormat: true,
        showColorButton: true,
        showBackgroundColorButton: true,
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
                      child: const Icon(Icons.compress),
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
                      child: const Icon(Icons.crop_original),
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
          await showWDialog(context: context, child: dialog);
          if (compress == null) return "";
          final imageName = await _pickImage.length();

          final File? image = await ImageCompressService(
            file: _pickImage,
            name: imageName.toString(),
            compress: compress == true,
          ).exec();

          return image?.path ?? "";
        },
      ),
    );

    return WillPopScope(
      onWillPop: () async {
        onPopNavigator(
          context: context,
          notifier: notifier,
          onSavedPressed: () async {
            await StoryDetailService().onSave(
              notifier: notifier,
              context: context,
              paragraph: quillNotifier.draftParagraph,
              insert: insert,
            );
          },
        );
        return false;
      },
      child: GestureDetector(
        onTap: () {
          if (FocusScope.of(context).hasFocus) {
            FocusScope.of(context).unfocus();
            TextEditingController().clear();
          }
        },
        onDoubleTap: forceReadOnly
            ? null
            : readOnlyModeNotifier.value
                ? () => readOnlyModeNotifier.value = false
                : null,
        child: Scaffold(
          backgroundColor: _theme.colorScheme.surface,
          body: Stack(
            children: [
              body,
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Builder(
                  builder: (context) {
                    final bool hide = readOnlyModeNotifier.value || !notifier.paragraphIsFocused;
                    return IgnorePointer(
                      ignoring: hide,
                      child: AnimatedOpacity(
                        opacity: hide ? 0 : 1,
                        duration: ConfigConstant.fadeDuration,
                        curve: Curves.fastOutSlowIn,
                        child: toolbar,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          extendBody: true,
        ),
      ),
    );
  }

  AppBar buildAppBar({
    required BuildContext context,
    required bool insert,
    required StoryDetailScreenNotifier notifier,
    required QuillControllerNotifer quillNotifier,
    required ValueNotifier readOnlyModeNotifier,
    required FocusNode focusNode,
    required TextEditingController titleController,
    required double top,
    required ScrollController scrollController,
  }) {
    final _theme = Theme.of(context);
    return AppBar(
      backgroundColor: _theme.colorScheme.surface,
      centerTitle: false,
      elevation: 0.0,
      titleSpacing: 0.0,
      title: VTOnTapEffect(
        onTap: () {
          scrollController
              .animateTo(
            0,
            duration: ConfigConstant.fadeDuration,
            curve: Curves.linearToEaseOut,
          )
              .then((_) {
            final headNotifier = context.read(headerProvider);
            headNotifier.headerPaddingTop = 0;
          });
        },
        child: Consumer(
          builder: (context, watch, child) {
            final headNotifier = watch(headerProvider);
            double ox = lerpDouble(kToolbarHeight, 0, headNotifier.headerPaddingTop)!;
            return Opacity(
              opacity: headNotifier.headerPaddingTop,
              child: Transform.translate(
                offset: Offset(0.0, ox),
                child: Text(
                  titleController.text,
                  style: _theme.textTheme.headline6,
                  maxLines: 1,
                  softWrap: true,
                ),
              ),
            );
          },
        ),
      ),
      flexibleSpace: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: kToolbarHeight - 4),
          child: Column(
            children: [
              Consumer(builder: (context, watch, child) {
                final imageLoadNotifier = watch(imageLoadProvider);
                return WLineLoading(
                  loading: imageLoadNotifier.imageLoading || imageLoadNotifier.imageRetry,
                );
              }),
              Consumer(
                builder: (context, watch, child) {
                  final headNotifier = watch(headerProvider);
                  return AnimatedOpacity(
                    duration: ConfigConstant.fadeDuration,
                    opacity: min(1, headNotifier.headerPaddingTop * 2),
                    child: buildDivider(context),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      leading: buildAppBarLeadingButton(
        context: context,
        notifier: notifier,
        quillNotifier: quillNotifier,
      ),
      actions: buildAppBarActionsButtonsList(
        context: context,
        insert: insert,
        notifier: notifier,
        quillNotifier: quillNotifier,
        readOnlyModeNotifier: readOnlyModeNotifier,
        focusNode: focusNode,
      ),
    );
  }

  List<Widget> buildAppBarActionsButtonsList({
    required BuildContext context,
    required bool insert,
    required StoryDetailScreenNotifier notifier,
    required QuillControllerNotifer quillNotifier,
    required ValueNotifier readOnlyModeNotifier,
    required FocusNode focusNode,
  }) {
    final String? currentFeeling = notifier.draftStory.feeling;
    final FeelingEmojiModel? currentFeelingModel =
        currentFeeling != null ? FeelingEmojiModel(type: currentFeeling) : null;
    return [
      Wrap(
        runAlignment: WrapAlignment.center,
        children: [
          AnimatedCrossFade(
            firstChild: Row(
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
              ],
            ),
            secondChild: SizedBox(),
            crossFadeState: !readOnlyModeNotifier.value && notifier.paragraphIsFocused
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            duration: ConfigConstant.fadeDuration,
          ),
          WIconButton(
            iconData: Icons.date_range_rounded,
            onPressed: () {
              onPickDate(
                context: context,
                date: notifier.draftStory.forDate,
                notifier: notifier,
                readOnly: forceReadOnly,
              );
            },
          ),
          EmojiPickerButton(
            currentFeelingModel: currentFeelingModel,
            onPickedEmoji: (String? emojiType) {
              if (forceReadOnly) return;
              notifier.setDraftStory(
                StoryModel(
                  title: notifier.draftStory.title,
                  paragraph: notifier.draftStory.paragraph,
                  createOn: notifier.draftStory.createOn,
                  id: notifier.draftStory.id,
                  updateOn: notifier.draftStory.updateOn,
                  forDate: notifier.draftStory.forDate,
                  isFavorite: notifier.draftStory.isFavorite,
                  feeling: emojiType?.isEmpty == true ? null : emojiType,
                ),
              );
              notifier.setLoadingUrl("");
            },
          ),
          buildMoreVertButton(context, insert, notifier, quillNotifier, readOnlyModeNotifier, focusNode),
        ],
      ),
    ];
  }

  WIconButton buildMoreVertButton(
    BuildContext context,
    bool insert,
    StoryDetailScreenNotifier notifier,
    QuillControllerNotifer quillNotifier,
    ValueNotifier readOnlyModeNotifier,
    FocusNode focusNode,
  ) {
    return WIconButton(
      iconData: Icons.more_vert,
      onPressed: () {
        final _theme = Theme.of(context);
        bool showDelete = true;
        bool showSave = true;
        bool showInfo = true;
        bool showShare = true;
        bool showDarkMode = true;
        bool showReadOnly = true;

        showDelete = !insert;
        showInfo = !insert;

        if (forceReadOnly) {
          showSave = false;
          showDelete = false;
          showReadOnly = false;
        }

        showMenu(
          context: context,
          position: RelativeRect.fromLTRB(8.0, 0.0, 0.0, 0.0),
          items: [
            if (showDelete)
              PopupMenuItem(
                child: VTOnTapEffect(
                  onTap: () async {
                    Navigator.of(context).pop();
                    onDelete(
                      context: context,
                      notifier: notifier,
                      insert: insert,
                      id: story.id,
                      quillNotifier: quillNotifier,
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
            if (showSave)
              PopupMenuItem(
                child: VTOnTapEffect(
                  onTap: () async {
                    Navigator.of(context).pop();
                    await StoryDetailService().onSave(
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
            if (showInfo)
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
                    showWDialog(
                      context: context,
                      child: dialog,
                    );
                  },
                  child: ListTile(
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: ConfigConstant.margin1,
                    ),
                    leading: Icon(Icons.info),
                    title: Text(
                      tr("button.info"),
                    ),
                  ),
                ),
              ),
            if (showShare)
              PopupMenuItem(
                child: VTOnTapEffect(
                  onTap: () async {
                    Navigator.of(context).pop();
                    final title = notifier.draftStory.title;
                    final root = quillNotifier.controller.document.root;
                    final shareText = QuillHelper.toPlainText(root);
                    await Share.share(title + "\n$shareText");
                  },
                  child: ListTile(
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: ConfigConstant.margin1,
                    ),
                    leading: Icon(Icons.share),
                    title: Text(tr("button.share")),
                  ),
                ),
              ),
            if (showDarkMode)
              PopupMenuItem(
                child: Consumer(
                  builder: (context, watch, child) {
                    final notifier = watch(themeProvider);
                    return VTOnTapEffect(
                      onTap: () {
                        Navigator.of(context).pop();
                        Future.delayed(ConfigConstant.duration).then(
                          (value) {
                            onTapVibrate();
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
                                  onTapVibrate();
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
            if (showReadOnly)
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
                            readOnlyModeNotifier.value = !readOnlyModeNotifier.value;
                          },
                        );
                      },
                      child: ListTile(
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: ConfigConstant.margin1,
                        ),
                        leading: Icon(
                            !readOnlyModeNotifier.value ? Icons.chrome_reader_mode_outlined : Icons.chrome_reader_mode),
                        title: Text(tr("button.read_only")),
                        trailing: Switch(
                          value: readOnlyModeNotifier.value,
                          onChanged: (bool value) {
                            if (readOnlyModeNotifier.value) {
                              focusNode.requestFocus();
                              Navigator.of(context).pop();
                              readOnlyModeNotifier.value = !readOnlyModeNotifier.value;
                            } else {
                              readOnlyModeNotifier.value = !readOnlyModeNotifier.value;
                              focusNode.unfocus();
                            }
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
    required QuillControllerNotifer quillNotifier,
  }) {
    return WIconButton(
      iconData: Icons.clear,
      onPressed: () {
        onPopNavigator(
          context: context,
          notifier: notifier,
          onSavedPressed: () async {
            await StoryDetailService().onSave(
              notifier: notifier,
              context: context,
              paragraph: quillNotifier.draftParagraph,
              insert: insert,
            );
          },
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
                        if (forceReadOnly) return;
                        Navigator.of(context).pop();
                        onPickDate(
                          context: context,
                          date: notifier.draftStory.forDate,
                          notifier: notifier,
                          readOnly: forceReadOnly,
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
    required QuillControllerNotifer quillNotifier,
  }) async {
    await showSnackBar(
      context: context,
      title: tr("msg.delete.warning"),
      actionLabel: tr("button.okay"),
      warning: true,
      onActionPressed: () async {
        final success = await notifier.removeStoryById(id);
        if (success) {
          await Future.delayed(Duration(milliseconds: 350)).then((value) {
            onPopNavigator(
              context: context,
              notifier: notifier,
              onSavedPressed: null,
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
                quillNotifier: quillNotifier,
              );
            },
          );
        }
      },
    );
  }
}

/// check if a string is base64 encoded
bool isBase64(String str) {
  RegExp _base64 = RegExp(r'^(?:[A-Za-z0-9+\/]{4})*(?:[A-Za-z0-9+\/]{2}==|[A-Za-z0-9+\/]{3}=|[A-Za-z0-9+\/]{4})$');
  return _base64.hasMatch(str);
}

String _standardizeImageUrl(String url) {
  if (url.contains('base64')) {
    return url.split(',')[1];
  }
  return url;
}
