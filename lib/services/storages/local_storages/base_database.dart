import 'package:sqflite/sqflite.dart';
import 'package:storypad/models/base_model.dart';
import 'package:storypad/services/storages/local_storages/w_database.dart';

abstract class BaseDatabase {
  bool? success;
  int? count;
  Object? error;

  _beforeExec(Future<dynamic> Function(Database? database) body) async {
    success = true;
    error = null;
    count = null;
    try {
      final database = await WDatabase.instance.database;
      return await body(database);
    } catch (e) {
      error = e;
      success = false;
    }
  }

  Future<BaseModel?> fetchOne({required int id}) async {
    return _beforeExec((database) async {
      List<Map<dynamic, dynamic>>? result = await database?.query(table(), where: "id = $id");
      if (result == null) return null;
      if (result.isEmpty) return null;
      return objectTransformer(result.first);
    });
  }

  Future<List<BaseModel>?> fetchAll() async {
    return await _beforeExec((database) async {
      List<Map<dynamic, dynamic>>? result = await database?.query(table());
      if (result == null) return null;
      if (result.isEmpty) return null;
      return itemsTransformer(result);
    });
  }

  Future<void> create({required BaseModel record}) async {
    _beforeExec((database) async {
      count = await database?.insert(
        table(),
        record.toJson(),
      );
    });
  }

  Future<void> update({required BaseModel record}) async {
    _beforeExec((database) async {
      count = await database?.update(
        table(),
        record.toJson(),
        where: "id = ${record.id}",
      );
    });
  }

  Future<void> delete({int? id}) async {
    _beforeExec((database) async {
      final where = id != null ? "id = $id" : null;
      count = await database?.delete(
        table(),
        where: where,
      );
    });
  }

  List<BaseModel>? itemsTransformer(List<Map<dynamic, dynamic>>? list) {
    if (list == null) return null;
    List<BaseModel?> items = list.map((json) {
      return objectTransformer(json);
    }).toList();
    items.removeWhere((element) => element == null);
    return items as List<BaseModel>?;
  }

  BaseModel? objectTransformer(Map<dynamic, dynamic>? json);
  String table();
}
