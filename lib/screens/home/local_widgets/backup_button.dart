import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:storypad/constants/config_constant.dart';
import 'package:storypad/mixins/w_snakbar_mixin.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:storypad/notifier/remote_database_notifier.dart';
import 'package:storypad/screens/setting_screen.dart';

class BackupButton extends HookWidget with WSnackBarMixin {
  const BackupButton({
    Key? key,
    this.right,
    this.left,
    required this.isSignedIn,
  }) : super(key: key);

  final double? right;
  final double? left;
  final bool isSignedIn;

  @override
  Widget build(BuildContext context) {
    final loadingNotifier = useState<bool>(false);
    return AnimatedCrossFade(
      duration: ConfigConstant.fadeDuration,
      crossFadeState: loadingNotifier.value == false ? CrossFadeState.showFirst : CrossFadeState.showSecond,
      firstChild: buildTextButton(context, loadingNotifier),
      secondChild: Stack(
        children: [
          Opacity(opacity: 0, child: buildTextButton(context, loadingNotifier)),
          Positioned(
            right: right,
            left: left,
            child: Transform.scale(
              scale: 0.5,
              child: CircularProgressIndicator(),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTextButton(BuildContext context, ValueNotifier<bool> loadingNotifier) {
    return Wrap(
      children: [
        TextButton.icon(
          style: buildButtonStyle(context),
          icon: Icon(Icons.add_to_drive, size: 16),
          label: isSignedIn
              ? Text(tr("button.backup.export").toUpperCase(), maxLines: 1, softWrap: true)
              : Text(tr("button.open_setting")),
          onPressed: () async {
            if (isSignedIn) {
              loadingNotifier.value = true;
              final dbNotifier = context.read(remoteDatabaseProvider);
              await dbNotifier.backupToCloud(context: context);
              loadingNotifier.value = false;
            } else {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) {
                  return SettingScreen();
                },
              ));
            }
          },
        ),
      ],
    );
  }

  ButtonStyle buildButtonStyle(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ButtonStyle(
      backgroundColor: MaterialStateProperty.resolveWith(
        (states) {
          if (states.contains(MaterialState.pressed) ||
              states.contains(MaterialState.focused) ||
              states.contains(MaterialState.hovered) ||
              states.contains(MaterialState.selected)) {
            return colorScheme.secondaryVariant;
          } else {
            return colorScheme.secondary;
          }
        },
      ),
      foregroundColor: MaterialStateProperty.resolveWith(
        (states) {
          if (states.contains(MaterialState.pressed) ||
              states.contains(MaterialState.focused) ||
              states.contains(MaterialState.hovered) ||
              states.contains(MaterialState.selected)) {
            return colorScheme.onPrimary;
          } else {
            return colorScheme.onSecondary;
          }
        },
      ),
    );
  }
}
