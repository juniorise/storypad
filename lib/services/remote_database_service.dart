import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:storypad/models/db_backup_model.dart';

class RemoteDatabaseService {
  static FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static CollectionReference _users = _firestore.collection("users");

  Future<DbBackupModel?> backup(String uid) async {
    DbBackupModel? remoteBackup;

    await _users.doc(uid).get().then((e) {
      final json = e.data();
      if (json != null) {
        final DbBackupModel result = DbBackupModel.fromJson(json);
        if (result is DbBackupModel) {
          remoteBackup = result;
        }
      }
    });

    return remoteBackup;
  }

  /// User can only backup one 1 month, otherwise will be replace this current month
  Future<bool> insertDatabase(String uid, DbBackupModel backup) async {
    try {
      await _users.doc(uid).update(backup.toJson());
      return true;
    } catch (e) {
      return false;
    }
  }
}
