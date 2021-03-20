import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import "package:path/path.dart";
import 'package:write_story/models/story_model.dart';
import 'package:write_story/models/user_model.dart';

class WDatabase {
  WDatabase._privateConstructor();
  static final WDatabase instance = WDatabase._privateConstructor();

  static Database? _database;
  static String deviceId = "os";

  Future<Database?> get database async {
    if (_database != null) return _database;
    _database = await _init();

    return _database;
  }

  Future<Database> _init() async {
    Directory applicationDirectory = await getApplicationDocumentsDirectory();
    String dbPath = join(applicationDirectory.path, "write_story.db");

    bool dbExists = await File(dbPath).exists();

    if (!dbExists) {
      print("No exist yet");

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

    return await openDatabase(dbPath);
  }

  Future<bool> updateStory({
    required StoryModel story,
  }) async {
    final DateTime? updateOn;
    if (story.updateOn != null) {
      updateOn = story.updateOn;
    } else {
      updateOn = DateTime.now();
    }

    print("last data: ${story.paragraph}");
    String query = '''
    UPDATE story 
    SET title = '${story.title}', 
        paragraph = '${story.paragraph}',
        for_date = ${story.forDate.millisecondsSinceEpoch},
        update_on = ${updateOn!.millisecondsSinceEpoch},
        is_favorite = ${story.isFavorite == true ? 1 : 0}
    WHERE id = ${story.id}
    ''';

    try {
      await _database!.execute(query);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> addStory({
    required StoryModel story,
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
        '${story.title}', 
        '${story.paragraph}', 
        ${story.createOn.millisecondsSinceEpoch}, 
        ${story.forDate.millisecondsSinceEpoch}, 
        ${story.updateOn != null ? story.updateOn?.millisecondsSinceEpoch : story.createOn.millisecondsSinceEpoch}, 
        ${story.isFavorite ? 1 : 0}
    )
    ''';

    try {
      await _database!.execute(query);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<Map<int, StoryModel>> storyById() async {
    var client = await database;
    List<Map<String, dynamic>> maps = await client!.query(
      "story",
      columns: [
        "id",
        "title",
        "paragraph",
        "create_on",
        "update_on",
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

  Future<bool> removeStoryById(int id) async {
    try {
      await _database!.delete("story", where: "id = $id");
      return true;
    } catch (e) {
      return false;
    }
  }

  clearAllStories() async {
    await _database!.execute("delete from story");
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

    List<Map<String, dynamic>> maps = await client!.query(
      "user_info",
      columns: [
        "nickname",
        "dob",
        "create_on",
        "update_on",
      ],
      where: "device_id = '$deviceId'",
    );

    if (maps.length > 0) {
      return UserModel.fromJson(maps.first);
    } else {
      return null;
    }
  }
}
