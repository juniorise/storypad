import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_quill/models/documents/document.dart';
import 'package:storypad/helpers/quill_helper.dart';
import 'package:storypad/constants/config_constant.dart';
import 'package:storypad/mixins/dialog_mixin.dart';
import 'package:storypad/models/story_model.dart';
import 'package:storypad/widgets/add_to_drive_button.dart';
import 'package:storypad/widgets/w_tap_effect.dart';
import 'package:storypad/widgets/w_icon_button.dart';

class WStoryTile extends HookWidget with DialogMixin {
  final StoryModel story;
  final void Function() onTap;
  final ValueChanged<DateTime> onSaved;
  final EdgeInsets margin = const EdgeInsets.only(bottom: ConfigConstant.margin1);
  final void Function()? onToggleFavorite;
  final bool readOnly;

  const WStoryTile({
    Key? key,
    required this.story,
    required this.onSaved,
    required this.onTap,
    this.onToggleFavorite,
    this.readOnly = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: margin,
      child: Stack(
        children: [
          buildTileContent(context: context),
          buildActionButtons(context: context),
        ],
      ),
    );
  }

  Widget buildTileContent({required BuildContext context}) {
    _Paragraph _paragraph = _Paragraph.getParagraph(story);
    final _theme = Theme.of(context);
    return WTapEffect(
      onTap: onTap,
      child: Material(
        elevation: 0.2,
        color: _theme.colorScheme.surface,
        borderRadius: ConfigConstant.circlarRadius2,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: ConfigConstant.margin2,
            vertical: ConfigConstant.margin1 + 4,
          ),
          width: double.infinity,
          child: Wrap(
            direction: Axis.vertical,
            alignment: WrapAlignment.start,
            crossAxisAlignment: WrapCrossAlignment.start,
            children: [
              titleWidget(context: context),
              SizedBox(height: story.title.isNotEmpty ? ConfigConstant.margin0 : 0),
              paragraphWidget(
                displayParagraph: _paragraph.displayParagraph,
                context: context,
                paragraphIsEmpty: !_paragraph.paragraphText.isNotEmpty,
              ),
            ],
          ),
        ),
      ),
    );
  }

  buildActionButtons({required BuildContext context}) {
    return Positioned(
      right: 0,
      top: 0,
      child: Row(
        children: [
          AddToDriveButton(story: story),
          buildFavoriteButton(
            story: story,
            context: context,
            onPressed: onToggleFavorite ?? () {},
            isActive: story.isFavorite,
            iconData: story.isFavorite ? Icons.favorite : Icons.favorite_border_rounded,
          ),
          const SizedBox(width: 4.0)
        ],
      ),
    );
  }

  Widget paragraphWidget({
    required BuildContext context,
    required String displayParagraph,
    required bool paragraphIsEmpty,
  }) {
    final _theme = Theme.of(context);
    if (paragraphIsEmpty) return const SizedBox();
    return Container(
      width: MediaQuery.of(context).size.width - 16 * 7,
      child: Text(
        displayParagraph,
        textAlign: TextAlign.start,
        style: _theme.textTheme.bodyText2?.copyWith(color: _theme.colorScheme.onSurface.withOpacity(0.5)),
      ),
    );
  }

  /// Title
  Widget titleWidget({required BuildContext context}) {
    final _theme = Theme.of(context);
    if (story.title.isNotEmpty) {
      return Container(
        padding: const EdgeInsets.only(right: 60),
        width: MediaQuery.of(context).size.width - 16 * 7,
        child: Text(
          story.title,
          style: _theme.textTheme.subtitle1,
          textAlign: TextAlign.start,
        ),
      );
    } else {
      return const SizedBox();
    }
  }

  Widget buildFavoriteButton({
    required StoryModel story,
    required BuildContext context,
    required void Function() onPressed,
    required bool isActive,
    required IconData iconData,
  }) {
    final favoriteButtonEffect = [WTapEffectType.scaleDown];
    return WTapEffect(
      onTap: onPressed,
      effects: favoriteButtonEffect,
      child: WIconButton(
        onPressed: onPressed,
        size: 40,
        iconSize: 20,
        iconData: iconData,
        iconColor: isActive ? Theme.of(context).colorScheme.error : Theme.of(context).dividerColor,
      ),
    );
  }
}

class _Paragraph {
  final String displayParagraph;
  final String paragraphText;
  _Paragraph(this.displayParagraph, this.paragraphText);

  static _Paragraph getParagraph(StoryModel story) {
    String? paragraph;
    Document? document;

    try {
      final decode = jsonDecode(story.paragraph!);
      document = Document.fromJson(decode);
      paragraph = QuillHelper.toPlainText(document.root).trim();
    } catch (e) {}

    /// Paragraph
    String _paragraphText = paragraph ?? "${story.paragraph}";
    String _displayParagraph = _paragraphText.characters.take(150).toString();
    if (_paragraphText.length > 150) _displayParagraph = _displayParagraph + " ...";

    return _Paragraph(_displayParagraph, _paragraphText);
  }
}
