import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:storypad/constants/config_constant.dart';
import 'package:storypad/mixins/w_snakbar_mixin.dart';
import 'package:storypad/models/story_model.dart';
import 'package:storypad/notifier/home_screen_notifier.dart';
import 'package:storypad/notifier/w_story_tile_notifier.dart';
import 'package:storypad/widgets/w_icon_button.dart';

class AddToDriveButton extends HookWidget with WSnackBarMixin {
  const AddToDriveButton({Key? key, required this.story}) : super(key: key);
  final StoryModel story;

  @override
  Widget build(BuildContext context) {
    final notifier = useProvider(wStoryTileProvider(story));

    final button = AnimatedCrossFade(
      duration: ConfigConstant.fadeDuration,
      crossFadeState: notifier.loading == true ? CrossFadeState.showSecond : CrossFadeState.showFirst,
      firstChild: WIconButton(
        onPressed: () async {
          showSnackBar(
            context: context,
            title: tr("msg.drive.loading"),
          );
          bool uploaded = await notifier.uploadImagesToDrive();
          if (uploaded) {
            context.read(homeScreenProvider).load();
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
        },
        size: 40,
        iconSize: 20,
        iconData: Icons.add_to_drive,
        iconColor: Theme.of(context).dividerColor,
      ),
      secondChild: Container(
        width: 48,
        alignment: Alignment.center,
        child: Container(
          width: 20,
          padding: EdgeInsets.all(4.0),
          child: AspectRatio(
            aspectRatio: 1,
            child: CircularProgressIndicator(
              strokeWidth: 1.5,
            ),
          ),
        ),
      ),
    );

    return AnimatedCrossFade(
      crossFadeState: notifier.files?.isNotEmpty == true ? CrossFadeState.showFirst : CrossFadeState.showSecond,
      firstChild: button,
      secondChild: const SizedBox(),
      duration: ConfigConstant.fadeDuration,
    );
  }
}
