import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:storypad/mixins/change_notifier_mixin.dart';
import 'package:storypad/models/db_backup_model.dart';
import 'package:storypad/models/user_model.dart';
import 'package:storypad/services/authentication_service.dart';
import 'package:storypad/services/remote_database_service.dart';
import 'package:storypad/app_helper/app_helper.dart';
import 'package:storypad/database/w_database.dart';
import 'package:storypad/constants/config_constant.dart';
import 'package:storypad/mixins/dialog_mixin.dart';
import 'package:storypad/widgets/vt_ontap_effect.dart';
import 'package:storypad/mixins/snakbar_mixin.dart';
import 'package:storypad/notifier/home_screen_notifier.dart';

class RemoteDatabaseNotifier
    with ChangeNotifier, DialogMixin, WSnackBar, ChangeNotifierMixin {
  RemoteDatabaseService service = RemoteDatabaseService();
  AuthenticationService auth = AuthenticationService();

  DbBackupModel? _backup;
  UserModel? user;

  String lastImportDate(BuildContext context) => this.backup?.createOn != null
      ? AppHelper.dateFormat(context).format(this.backup!.createOn!.toDate()) +
          ", " +
          AppHelper.timeFormat(context).format(this.backup!.createOn!.toDate())
      : "";

  load() async {
    if (auth.user != null) {
      final result = await service.backup(auth.user!.uid);
      if (result != null && result.db != null) {
        this._backup = result;
      } else {
        this._backup = null;
      }
    }
    WidgetsBinding.instance?.addPostFrameCallback((_) => notifyListeners());
  }

  Future<bool> replace(DbBackupModel model) async {
    final result = await service.insertDatabase(auth.user!.uid, model);
    if (result == true) {
      await load();
      notifyListeners();
      return true;
    } else {
      notifyListeners();
      return false;
    }
  }

  void reset() => this._backup = null;
  DbBackupModel? get backup => this._backup;

  Future<void> restoreFromCloud({
    required BuildContext context,
    bool showSnackbar = true,
  }) async {
    if (this.backup == null) return;
    final database = WDatabase.instance;
    bool? hasClick;
    final dialog = Dialog(
      child: Wrap(
        children: [
          ListTile(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(ConfigConstant.radius1),
              ),
            ),
            title: Text(
              tr("msg.backup.import.replace"),
              textAlign: TextAlign.center,
            ),
            onTap: () async {
              hasClick = true;
              await database.clearAllStories();
              await database.clearAllSync();
              Navigator.of(context).pop();
            },
          ),
          const Divider(height: 0),
          ListTile(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(ConfigConstant.radius1),
              ),
            ),
            title: Text(
              tr("msg.backup.import.no_replace"),
              textAlign: TextAlign.center,
            ),
            onTap: () {
              hasClick = true;
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );

    await showWDialog(context: context, child: dialog);
    if (hasClick == null) return;

    final bool success = await database.restoreBackup(this.backup!.db!);
    if (showSnackbar == false) return;
    if (success) {
      onTapVibrate();
      await context.read(homeScreenProvider).load();
      showSnackBar(
        context: context,
        title: tr("msg.backup.import.success"),
      );
    } else {
      onTapVibrate();
      showSnackBar(
        context: context,
        title: tr("msg.backup.import.fail"),
      );
    }
  }

  Future<void> backupToCloud({
    required BuildContext context,
    bool showSnackbar = true,
  }) async {
    final database = WDatabase.instance;
    String backup = await database.generateBackup();
    final backupModel = DbBackupModel(
      createOn: Timestamp.now(),
      db: backup,
    );
    final bool success = await this.replace(backupModel);
    if (showSnackbar == false) return;
    if (success) {
      onTapVibrate();
      showSnackBar(
        context: context,
        title: tr("msg.backup.export.success"),
      );
    } else {
      onTapVibrate();
      showSnackBar(
        context: context,
        title: tr("msg.backup.export.fail"),
      );
    }
  }
}

final remoteDatabaseProvider = ChangeNotifierProvider<RemoteDatabaseNotifier>(
  (ref) {
    return RemoteDatabaseNotifier()..load();
  },
);
