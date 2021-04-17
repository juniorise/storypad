import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:write_story/notifier/lock_screen_notifier.dart';
import 'package:write_story/screens/lock_screen.dart';
import 'package:write_story/screens/setting_screen.dart';
import 'package:write_story/widgets/w_icon_button.dart';

class LockSettingScreen extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final notifier = useProvider(lockScreenProvider(LockScreenFlowType.UNLOCK));
    return WillPopScope(
      onWillPop: () async {
        ScaffoldMessenger.maybeOf(context)?.removeCurrentSnackBar();
        Navigator.of(context).pop();
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          elevation: 1,
          backgroundColor: Theme.of(context).colorScheme.surface,
          textTheme: Theme.of(context).textTheme,
          title: Text(
            tr("title.lock"),
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          leading: WIconButton(
            iconData: Icons.arrow_back,
            onPressed: () {
              ScaffoldMessenger.maybeOf(context)?.removeCurrentSnackBar();
              Navigator.of(context).pop();
            },
          ),
        ),
        body: ListView(
          children: [
            SizedBox(height: 8.0),
            WListTile(
              iconData: Icons.lock,
              titleText: notifier.storageLockNumberMap == null
                  ? tr("button.passcode.set")
                  : tr("button.passcode.change"),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) {
                      return LockScreenWrapper(
                        notifier.storageLockNumberMap == null
                            ? LockScreenFlowType.SET
                            : LockScreenFlowType.REPLACE,
                      );
                    },
                  ),
                );
              },
            ),
            if (notifier.storageLockNumberMap != null)
              WListTile(
                iconData: Icons.clear,
                forgroundColor: Theme.of(context).colorScheme.error,
                titleText: tr("button.passcode.clear"),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) {
                        return LockScreenWrapper(LockScreenFlowType.RESET);
                      },
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
