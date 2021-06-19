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
  final void Function()? onToggleSync;
  final bool readOnly;

  const WStoryTile({
    Key? key,
    required this.story,
    required this.onSaved,
    required this.onTap,
    this.onToggleFavorite,
    this.readOnly = false,
    this.onToggleSync,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _theme = Theme.of(context);

    /// Title
    final _titleWidget = story.title.isNotEmpty
        ? Container(
            padding: const EdgeInsets.only(right: 60),
            width: MediaQuery.of(context).size.width - 16 * 7,
            child: Text(
              story.title,
              style: _theme.textTheme.subtitle1,
              textAlign: TextAlign.start,
            ),
          )
        : const SizedBox();

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
    if (_paragraphText.length > 150) {
      _displayParagraph = _displayParagraph + " ...";
    }

    final _paragraphChild = Container(
      width: MediaQuery.of(context).size.width - 16 * 7,
      child: Text(
        _displayParagraph,
        textAlign: TextAlign.start,
        style: _theme.textTheme.bodyText2?.copyWith(color: _theme.colorScheme.onSurface.withOpacity(0.5)),
      ),
    );

    final _paragraphWidget = _paragraphText.isNotEmpty ? _paragraphChild : const SizedBox();

    final _tileEffects = [
      WTapEffectType.touchableOpacity,
    ];

    var rightButton = Positioned(
      right: 0,
      top: 0,
      child: Row(
        children: [
          AddToDriveButton(story: story),
          if (onToggleFavorite != null)
            _buildFavoriteButton(
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

    return WTapEffect(
      effects: _tileEffects,
      onTap: onTap,
      child: Container(
        width: double.infinity,
        margin: margin,
        child: Material(
          elevation: 0.2,
          color: _theme.colorScheme.surface,
          borderRadius: ConfigConstant.circlarRadius2,
          child: Stack(
            children: [
              Container(
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
                    _titleWidget,
                    if (story.title.isNotEmpty) const SizedBox(height: ConfigConstant.margin0),
                    _paragraphWidget,
                  ],
                ),
              ),
              rightButton,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFavoriteButton({
    required StoryModel story,
    required BuildContext context,
    required void Function() onPressed,
    required bool isActive,
    required IconData iconData,
  }) {
    final favoriteButtonEffect = [
      WTapEffectType.scaleDown,
    ];

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
