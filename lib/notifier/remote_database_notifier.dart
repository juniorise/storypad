import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:storypad/mixins/change_notifier_mixin.dart';
import 'package:storypad/models/db_backup_model.dart';
import 'package:storypad/models/user_model.dart';
import 'package:storypad/services/authentication_service.dart';
import 'package:storypad/services/google_drive_api_service.dart';
import 'package:storypad/services/remote_database_service.dart';
import 'package:storypad/app_helper/app_helper.dart';
import 'package:storypad/database/w_database.dart';
import 'package:storypad/constants/config_constant.dart';
import 'package:storypad/mixins/dialog_mixin.dart';
import 'package:storypad/widgets/vt_ontap_effect.dart';
import 'package:storypad/mixins/snakbar_mixin.dart';
import 'package:storypad/notifier/home_screen_notifier.dart';
import 'dart:io' as io;

class RemoteDatabaseNotifier with ChangeNotifier, DialogMixin, WSnackBar, ChangeNotifierMixin {
  RemoteDatabaseService service = RemoteDatabaseService();
  AuthenticationService auth = AuthenticationService();

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
      DbBackupModel? result = await GoogleDriveApiService.fetchTxtData();
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

    String? id = await GoogleDriveApiService.uploadAFile(file);
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
