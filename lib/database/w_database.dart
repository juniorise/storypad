import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import "package:path/path.dart";
import 'package:write_your_story/models/story_model.dart';

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

  Future<void> updateStory({
    @required StoryModel story,
  }) async {
    String query = '''
    UPDATE story 
    SET title = "${story.title}", 
        paragraph = "${story.paragraph}",
        update_on = ${DateTime.now().millisecondsSinceEpoch}
    WHERE id = ${story.id}
    ''';

    await _database.execute(query);
  }

  Future<void> addStory({
    @required StoryModel story,
  }) async {
    String query = '''
    INSERT INTO "story" (
      title, 
      paragraph, 
      create_on, 
      update_on, 
      is_favorite
    )
    VALUES (
        "${story.title}", 
        "${story.paragraph}", 
        ${DateTime.now().millisecondsSinceEpoch}, 
        ${DateTime.now().millisecondsSinceEpoch}, 
        ${story.isFavorite ? 1 : 0}
    );
    ''';
    await _database.execute(query);
  }

  Future<Map<int, StoryModel>> storyById() async {
    var client = await database;
    List<Map<String, dynamic>> maps = await client.query(
      "story",
      columns: [
        "id",
        "title",
        "paragraph",
        "create_on",
        "is_favorite",
      ],
    );

    final map = Map.fromIterable(maps, key: (e) {
      return int.parse("${e['id']}");
    }, value: (e) {
      return StoryModel.fromJson(e);
    });

    return map;
  }
}
