import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:storypad/constants/config_constant.dart';
import 'package:storypad/models/db_backup_model.dart';
import 'package:storypad/notifier/auth_notifier.dart';
import 'package:storypad/notifier/remote_database_notifier.dart';
import 'package:storypad/screens/home/local_widgets/backup_button.dart';
import 'package:storypad/widgets/w_list_tile.dart';

class BackupTile extends HookWidget {
  const BackupTile({
    Key? key,
    required this.bottomBarHeight,
    required this.faqNotifier,
    required this.bottomSyncHeight,
  }) : super(key: key);

  final double bottomBarHeight;
  final ValueNotifier<bool> faqNotifier;
  final double bottomSyncHeight;

  @override
  Widget build(BuildContext context) {
    final authNotifier = useProvider(authenticationProvider);
    final dbNotifier = useProvider(remoteDatabaseProvider);

    String date = dbNotifier.lastImportDate(context);
    DbBackupModel? backup = dbNotifier.backup;

    return Positioned(
      bottom: bottomBarHeight,
      left: 0,
      right: 0,
      child: AnimatedContainer(
        duration: ConfigConstant.duration,
        curve: Curves.easeOutQuart,
        decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface),
        transform: Matrix4.identity()..translate(0.0, faqNotifier.value == true ? 1 : bottomSyncHeight),
        child: Consumer(
          builder: (context, watch, child) {
            final titleText = !authNotifier.isAccountSignedIn
                ? "Sign in to backup"
                : backup?.name ?? tr("msg.backup.import", namedArgs: {"DATE": date}).replaceFirst(": ", ":\n");

            return Column(
              children: [
                const Divider(height: 1),
                WListTile(
                  iconData: Icons.cloud,
                  titleMaxLines: 2,
                  trailing: BackupButton(right: 0, isSignedIn: authNotifier.isAccountSignedIn),
                  titleText: titleText,
                  titleStyle: Theme.of(context).textTheme.bodyText2,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
