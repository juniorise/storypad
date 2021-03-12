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
        for_date = ${story.forDate.millisecondsSinceEpoch},
        update_on = ${story.updateOn.millisecondsSinceEpoch}
    WHERE id = ${story.id}
    ''';

    await _database.execute(query);
  }

  Future<void> addStory({
    @required StoryModel story,
  }) async {
    String query = '''
    INSERT or REPLACE INTO "story" (
      id,
      title, 
      paragraph, 
      create_on, 
      for_date,
      update_on, 
      is_favorite
    )
    VALUES (
        ${story.id},
        "${story.title}", 
        "${story.paragraph}", 
        ${story.createOn.millisecondsSinceEpoch}, 
        ${story.forDate.millisecondsSinceEpoch}, 
        ${story.updateOn != null ? story.updateOn.millisecondsSinceEpoch : story.createOn.millisecondsSinceEpoch}, 
        ${story.isFavorite ? 1 : 0}
    )
    ''';
    await _database.execute(query);
  }

  Future<int> lastStoryId() async {
    final query = '''
    SELECT id 
    FROM "story" 
    ORDER BY id 
    DESC LIMIT 1
    ''';
    final result = await _database.rawQuery(query);
    final lastValue = result.first.values.first;
    return lastValue;
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
        "for_date",
      ],
    );

    final map = Map.fromIterable(maps, key: (e) {
      return int.parse("${e['id']}");
    }, value: (e) {
      return StoryModel.fromJson(e);
    });

    return map;
  }

  clearAllStories() async {
    await _database.execute("delete from story");
  }
}
