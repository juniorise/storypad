import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:write_story/constants/config_constant.dart';
import 'package:write_story/mixins/hook_controller.dart';
import 'package:write_story/models/feeling_emoji_model.dart';
import 'package:write_story/widgets/vt_ontap_effect.dart';
import 'package:write_story/widgets/w_behavior.dart';
import 'package:write_story/widgets/w_icon_button.dart';
import 'package:write_story/widgets/w_overlay_entry_button.dart';

/// IMPORTANT:
/// - feeling and emoji type are same
/// - last index is reset button emoji
class EmojiPickerButton extends HookWidget with HookController {
  const EmojiPickerButton({
    Key? key,
    required this.currentFeelingModel,
    required this.onPickedEmoji,
  }) : super(key: key);

  final FeelingEmojiModel? currentFeelingModel;
  final ValueChanged<String?> onPickedEmoji;

  @override
  Widget build(BuildContext context) {
    final _scrollController = useAutoScrollController();
    final rowLength = 3;
    final _map = FeelingEmojiModel.getIndexMap(rowLength);
    final List<FeelingEmojiModel> _emojies = feelingEmojiList;

    return WOverlayEntryButton(
      floatingBuilder: (context, callback) {
        return Material(
          color: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.background,
              borderRadius: ConfigConstant.circlarRadius2,
              border: Border.all(
                color:
                    Theme.of(context).colorScheme.onBackground.withOpacity(0.1),
                width: 1,
              ),
            ),
            constraints: BoxConstraints(maxHeight: 300),
            child: ScrollConfiguration(
              behavior: WBehavior(),
              child: SingleChildScrollView(
                controller: _scrollController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(
                    _map.length,
                    (c) {
                      final List<int> childIndex = _map[c] ?? [];
                      return AutoScrollTag(
                        index: c,
                        controller: _scrollController,
                        key: ValueKey(c),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            childIndex.length,
                            (r) {
                              final FeelingEmojiModel? emoji;
                              emoji = _emojies[childIndex[r]];

                              final isSelected =
                                  currentFeelingModel?.type == emoji.type;

                              return VTOnTapEffect(
                                onTap: () {
                                  callback();

                                  /// if path is empty, use default icon
                                  /// which mean it is reseted
                                  /// last index is reset emoji button
                                  onPickedEmoji(
                                    isSelected ? null : emoji?.type,
                                  );
                                },
                                child: Container(
                                  width: kToolbarHeight * 1.8,
                                  color: isSelected
                                      ? Theme.of(context).colorScheme.surface
                                      : Colors.transparent,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16.0,
                                    horizontal: 8.0,
                                  ),
                                  alignment: Alignment.center,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        emoji.localPath!,
                                        height: 32,
                                      ),
                                      const SizedBox(height: 8.0),
                                      Text(
                                        emoji.type!.replaceAll("_", "\n"),
                                        textAlign: TextAlign.center,
                                        softWrap: false,
                                        maxLines: 2,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        );
      },
      childBuilder: (context, key, callback) {
        return Container(
          height: 48,
          width: 48,
          alignment: Alignment.center,
          child: Container(
            padding: EdgeInsets.all(4),
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.background,
              shape: BoxShape.circle,
            ),
            child: WIconButton(
              key: key,
              size: 44,
              iconImage: currentFeelingModel?.localPath != null
                  ? currentFeelingModel?.localPath
                  : null,
              iconData: currentFeelingModel?.localPath != null
                  ? null
                  : Icons.tag_faces_sharp,
              onPressed: () {
                /// find column index to scroll to
                int index = 0;
                for (int i = 0; i < _emojies.length; i++) {
                  if (_emojies[i].type == currentFeelingModel?.type) {
                    index = i;
                    break;
                  }
                }

                for (int i = 0; i < _map.length; i++) {
                  if (_map[i]?.contains(index) == true) {
                    index = i;
                    break;
                  }
                }

                callback();
                if (index != 0) _scrollController.scrollToIndex(index);
              },
            ),
          ),
        );
      },
    );
  }
}
