import 'package:sqflite/sqflite.dart';
import 'package:storypad/models/base_model.dart';
import 'package:storypad/services/local_storages/databases/w_database.dart';

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

  Future<BaseModel?> fetchOne({int? id, String? where}) async {
    return await _beforeExec((database) async {
      final _where = where ?? (id != null ? "id = $id" : null);
      List<Map<dynamic, dynamic>>? result = await database?.query(table(), where: _where);
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
      var rt = itemsTransformer(result);
      return rt;
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

  Future<void> update({required BaseModel record, String? where}) async {
    _beforeExec((database) async {
      final _where = where ?? "id = ${record.id}";
      count = await database?.update(
        table(),
        record.toJson(),
        where: _where,
      );
    });
  }

  Future<void> delete({int? id, String? where}) async {
    _beforeExec((database) async {
      final _where = where ?? (id != null ? "id = $id" : null);
      count = await database?.delete(
        table(),
        where: _where,
      );
    });
  }

  List<BaseModel>? itemsTransformer(List<Map<dynamic, dynamic>>? list) {
    if (list == null) return null;
    List<BaseModel?> items = list.map((json) {
      return objectTransformer(json);
    }).toList();
    List<BaseModel> result = [];
    items.forEach((e) {
      if (e is BaseModel) result.add(e);
    });
    return result;
  }

  BaseModel? objectTransformer(Map<dynamic, dynamic>? json);
  String table();
}
