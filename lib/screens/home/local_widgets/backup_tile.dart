import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:storypad/constants/config_constant.dart';
import 'package:storypad/models/db_backup_model.dart';
import 'package:storypad/screens/setting_screen.dart';
import 'package:storypad/widgets/w_list_tile.dart';

class BackupTile extends HookWidget {
  const BackupTile({
    Key? key,
    required this.bottomBarHeight,
    required this.faqNotifier,
    required this.bottomSyncHeight,
    required this.backup,
    required this.date,
    required this.onBackup,
  }) : super(key: key);

  final double bottomBarHeight;
  final ValueNotifier<bool> faqNotifier;
  final double bottomSyncHeight;
  final DbBackupModel backup;
  final String date;
  final Future<void> Function() onBackup;

  @override
  Widget build(BuildContext context) {
    final ValueNotifier<bool> loading = useState(false);

    return Positioned(
      bottom: bottomBarHeight,
      left: 0,
      right: 0,
      child: ValueListenableBuilder(
        valueListenable: faqNotifier,
        child: Consumer(
          builder: (context, watch, child) {
            final titleText = tr(
              "msg.backup.import",
              namedArgs: {"DATE": date},
            ).replaceFirst(": ", ":\n");

            return Column(
              children: [
                const Divider(height: 1),
                WListTile(
                  iconData: Icons.cloud,
                  titleMaxLines: 2,
                  trailing: AnimatedCrossFade(
                    duration: ConfigConstant.fadeDuration,
                    crossFadeState: loading.value == false
                        ? CrossFadeState.showFirst
                        : CrossFadeState.showSecond,
                    secondChild: Stack(
                      alignment: Alignment.center,
                      children: [
                        Opacity(
                          opacity: 0,
                          child: TextButton(
                            child:
                                Text(tr("button.backup.export").toUpperCase()),
                            onPressed: () {},
                          ),
                        ),
                        Transform.scale(
                          scale: 0.5,
                          child: CircularProgressIndicator(),
                        ),
                      ],
                    ),
                    firstChild: TextButton(
                      child: Text(tr("button.backup.export").toUpperCase()),
                      onPressed: () async {
                        loading.value = true;
                        await onBackup();
                        loading.value = false;
                      },
                      style: buildButtonStyle(context),
                    ),
                  ),
                  titleText: titleText,
                  titleStyle: Theme.of(context).textTheme.bodyText2,
                ),
              ],
            );
          },
        ),
        builder: (context, watch, child) {
          return AnimatedContainer(
            duration: ConfigConstant.duration,
            curve: Curves.easeOutQuart,
            decoration:
                BoxDecoration(color: Theme.of(context).colorScheme.surface),
            transform: Matrix4.identity()
              ..translate(
                0.0,
                faqNotifier.value == true ? 1 : bottomSyncHeight,
              ),
            child: child,
          );
        },
      ),
    );
  }
}
