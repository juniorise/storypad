import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:write_story/models/db_backup_model.dart';
import 'package:write_story/models/user_model.dart';
import 'package:write_story/services/authentication_service.dart';
import 'package:write_story/services/remote_database_service.dart';

class RemoteDatabaseNotifier with ChangeNotifier {
  RemoteDatabaseService service = RemoteDatabaseService();
  AuthenticationService auth = AuthenticationService();

  List<DbBackupModel> _backups = [];

  UserModel? user;

  load() async {
    if (auth.user != null) {
      final result = await service.backupList(auth.user!.uid);
      if (result != null && result.isNotEmpty) {
        this._backups = result;
      }
    }
    notifyListeners();
  }

  Future<void> add(DbBackupModel model) async {
    final result = await service.insertDatabase(auth.user!.uid, model);
    if (result == true) {
      await load();
    } else {
      notifyListeners();
    }
  }

  void reset() {
    this._backups.clear();
  }

  List<DbBackupModel> get backups => this._backups;
}

final remoteDatabaseProvider = ChangeNotifierProvider<RemoteDatabaseNotifier>(
  (ref) {
    return RemoteDatabaseNotifier();
  },
);
