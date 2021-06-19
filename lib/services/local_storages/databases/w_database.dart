import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import "package:path/path.dart";
import 'package:storypad/models/user_model.dart';

class WDatabase {
  WDatabase._privateConstructor();
  static final WDatabase instance = WDatabase._privateConstructor();

  static Database? _database;
  static String deviceId = "os";
  static String singleQuote = "▘";

  Future<Database?> get database async {
    if (_database != null) return _database;
    _database = await _init();
    return _database;
  }

  Future<Database> _init() async {
    Directory applicationDirectory = await getApplicationDocumentsDirectory();
    String dbPath = join(applicationDirectory.path, "write_story.db");
    bool dbExists = await File(dbPath).exists();
    if (!dbExists) _onDbExist(dbPath);
    return await openDatabase(dbPath, onOpen: _onOpen, version: 3);
  }

  _onDbExist(String dbPath) async {
    // copy from asset
    ByteData data = await rootBundle.load(
      join("assets/database", "write_story.db"),
    );

    List<int> bytes = data.buffer.asUint8List(
      data.offsetInBytes,
      data.lengthInBytes,
    );

    // write and flush the bytes written
    await File(dbPath).writeAsBytes(bytes, flush: true);
  }

  _onOpen(database) async {
    /// add new feeling column if not existed
    try {
      await database.rawQuery("SELECT feeling from story;");
    } catch (e) {
      await database.execute("ALTER TABLE story ADD COLUMN feeling char(50);");
    }
  }

  Future<bool> setUserModel(UserModel user) async {
    final dob = user.dob?.millisecondsSinceEpoch;
    String query = '''
    INSERT or REPLACE INTO "user_info" (
      device_id,
      nickname,
      dob,
      create_on,
      update_on
    )
    VALUES (
      "$deviceId",
      "${user.nickname}",
      $dob,
      ${user.createOn.millisecondsSinceEpoch},
      ${user.updateOn?.millisecondsSinceEpoch}
    )
    ''';

    try {
      final Database? client = await database;
      await client?.execute(query);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<UserModel?> userModel() async {
    final client = await database;
    List<Map<String, dynamic>>? maps;

    try {
      maps = await client!.query(
        "user_info",
        columns: [
          "nickname",
          "dob",
          "create_on",
          "update_on",
        ],
        where: "device_id = '$deviceId'",
      );
    } catch (e) {}

    if (maps?.isNotEmpty == true) {
      return UserModel.fromJson(maps!.first);
    } else {
      return null;
    }
  }
}
