import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:storypad/models/db_backup_model.dart';
import 'package:storypad/models/user_model.dart';
import 'package:storypad/services/apis/firebase_api.dart';
import 'package:storypad/services/apis/google_drive_api.dart';
import 'package:storypad/services/authentication/authentication_service.dart';
import 'package:storypad/services/backups/backup_service.dart';
import 'package:storypad/helpers/app_helper.dart';
import 'package:storypad/services/storages/local_storages/w_database.dart';
import 'package:storypad/constants/config_constant.dart';
import 'package:storypad/mixins/dialog_mixin.dart';
import 'package:storypad/mixins/w_snakbar_mixin.dart';
import 'package:storypad/notifier/home_screen_notifier.dart';
import 'dart:io' as io;

class RemoteDatabaseNotifier with ChangeNotifier, DialogMixin, WSnackBarMixin {
  AuthenticationService auth = AuthenticationService();
  FirebaseApi service = FirebaseApi();

  DbBackupModel? _backup;
  UserModel? user;

  bool useCsv = true;

  String lastImportDate(BuildContext context) => this.backup?.createOn != null
      ? AppHelper.dateFormat(context).format(this.backup!.createOn!.toDate()) +
          ", " +
          AppHelper.timeFormat(context).format(this.backup!.createOn!.toDate())
      : "";

  load() async {
    if (auth.user != null) {
      DbBackupModel? result = await GoogleDriveApi.fetchTxtData();
      if (result == null) {
        result = await service.backup(auth.user!.uid);
        useCsv = false;
      } else {
        useCsv = true;
      }

      if (result != null && result.db != null) {
        this._backup = result;
      } else {
        this._backup = null;
      }
    }
    WidgetsBinding.instance?.addPostFrameCallback((_) => notifyListeners());
  }

  Future<bool> replace(DbBackupModel model) async {
    if (model.db == null) return false;
    String absolute = await getApplicationDocumentsDirectory().then((value) => value.path);
    String dir = absolute + "/story${DateTime.now().toString()}.zip";

    io.File file = io.File(dir);
    file = await file.writeAsString(model.db ?? "");

    String? id = await GoogleDriveApi.uploadAFile(file);
    if (id != null) {
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

    final dbs = await WDatabase.instance.database;
    final bool success = await BackupService.restoreBackup(this.backup!.db!, dbs: dbs!);
    if (showSnackbar == false) return;
    if (success) {
      await context.read(homeScreenProvider).load();
      showSnackBar(
        context: context,
        title: tr("msg.backup.import.success"),
      );
    } else {
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
    if (this.backup != null) {
      int createOn = this.backup?.createOn?.millisecondsSinceEpoch ?? 0;
      double createDate = createOn * 0.001;
      final currentDate = DateTime.now().millisecondsSinceEpoch * 0.001;

      print("$createDate   $currentDate ${currentDate - createDate}");
      if (currentDate - createDate < 60) {
        showSnackBar(
          context: context,
          title: tr("msg.redo_after_1_minute"),
        );
        return;
      }
    }

    final dbs = await WDatabase.instance.database;
    String backup = await BackupService.generateBackup(dbs: dbs!);
    final backupModel = DbBackupModel(
      createOn: Timestamp.now(),
      db: backup,
    );
    final bool success = await this.replace(backupModel);
    if (showSnackbar == false) return;
    if (success) {
      showSnackBar(
        context: context,
        title: tr("msg.backup.export.success"),
      );
    } else {
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
