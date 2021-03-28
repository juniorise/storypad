import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:write_story/models/db_backup_model.dart';
import 'package:write_story/models/user_model.dart';
import 'package:write_story/services/authentication_service.dart';
import 'package:write_story/services/remote_database_service.dart';

class RemoteDatabaseNotifier with ChangeNotifier {
  RemoteDatabaseService service = RemoteDatabaseService();
  AuthenticationService auth = AuthenticationService();

  DbBackupModel? _backup;

  UserModel? user;

  load() async {
    if (auth.user != null) {
      final result = await service.backupList(auth.user!.uid);
      if (result != null) {
        this._backup = result;
      }
    }

    WidgetsBinding.instance?.addPostFrameCallback((_) {
      notifyListeners();
    });
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

  void reset() {
    this._backup = null;
  }

  DbBackupModel? get backup => this._backup;
}

final remoteDatabaseProvider = ChangeNotifierProvider<RemoteDatabaseNotifier>(
  (ref) {
    return RemoteDatabaseNotifier();
  },
);
