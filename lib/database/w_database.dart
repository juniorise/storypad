import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import "package:path/path.dart";

class WDatabase {
  WDatabase._privateConstructor();
  static final WDatabase instance = WDatabase._privateConstructor();

  static Database _database;
  Future<Database> get database async {
    if (_database != null) return _database;
    _database = await _init();
    return _database;
  }

  Future<Database> _init() async {
    Directory applicationDirectory = await getApplicationDocumentsDirectory();
    String dbPath = join(applicationDirectory.path, "write_your_story.db");

    bool dbExists = await File(dbPath).exists();

    if (!dbExists) {
      // copy from asset
      ByteData data = await rootBundle.load(
        join("assets/database", "write_your_story.db"),
      );

      List<int> bytes = data.buffer.asUint8List(
        data.offsetInBytes,
        data.lengthInBytes,
      );

      // write and flush the bytes written
      await File(dbPath).writeAsBytes(bytes, flush: true);
    }

    return await openDatabase(dbPath);
  }

  Future<List> storyListByID() async {
    var dbClient = await database;
    List<Map<String, dynamic>> maps = await dbClient.query(
      "story",
      columns: ["id", "title"],
    );

    return maps;
  }
}
