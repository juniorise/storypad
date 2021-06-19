import 'dart:convert' as convert;
import 'package:sqflite/sqlite_api.dart';
import 'package:storypad/services/encrypt/encrypt_service.dart';

class BackupService {
  BackupService._internal();
  static Future<String> generateBackup({
    bool isEncrypted = true,
    required Database dbs,
  }) async {
    List data = [];
    final List<String> tables = ["user_info", "story"];
    List<Map<String, dynamic>> listMaps = [];

    for (var i = 0; i < tables.length; i++) {
      listMaps = await dbs.query(tables[i]);
      data.add(listMaps);
    }

    List<List<dynamic>> backups = [tables, data];

    String backup;
    if (isEncrypted) {
      String json = convert.jsonEncode(backups);
      backup = EncryptService.encryptToString(json);
    } else {
      String csv = convert.jsonEncode(backups);
      backup = csv;
    }

    return backup;
  }

  static Future<bool> restoreBackup(
    String backup, {
    bool isEncrypted = true,
    required Database dbs,
  }) async {
    try {
      Batch batch = dbs.batch();
      List json = convert.jsonDecode(isEncrypted ? EncryptService.decryptToString(backup) : backup);

      for (var i = 0; i < json[0].length; i++) {
        for (var k = 0; k < json[1][i].length; k++) {
          batch.insert(
            json[0][i],
            json[1][i][k],
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      }

      await batch.commit(continueOnError: false, noResult: true);
      print('RESTORE BACKUP');
      return true;
    } catch (e) {
      return false;
    }
  }
}
