import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:write_story/models/db_backup_model.dart';

class RemoteDatabaseService {
  static FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static CollectionReference _users = _firestore.collection("users");

  Future<List<DbBackupModel>?> backupList(String uid) async {
    List<DbBackupModel> remoteBackups = [];

    await _users.doc(uid).collection("backups").get().then(
      (QuerySnapshot? value) async {
        if (value != null && value.size > 0 && value.docs.length > 0) {
          value.docs.forEach(
            (e) {
              final json = e.data();
              if (json != null) {
                final DbBackupModel result = DbBackupModel.fromJson(json);
                if (result is DbBackupModel) {
                  remoteBackups.add(result);
                }
              }
            },
          );
        }
      },
    );

    List<DbBackupModel>? result;
    if (remoteBackups.isNotEmpty) result = remoteBackups;
    return result;
  }

  /// User can only backup one 1 month, otherwise will be replace this current month
  Future<bool> insertDatabase(String uid, DbBackupModel backup) async {
    final now = DateTime.now();
    final docId = DateTime(now.year, now.month);
    try {
      await _users
          .doc(uid)
          .collection("backups")
          .doc("${docId.millisecondsSinceEpoch}")
          .set(backup.toJson());
      return true;
    } catch (e) {
      return false;
    }
  }
}
