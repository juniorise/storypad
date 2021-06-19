import 'package:storypad/models/base_model.dart';
import 'package:storypad/models/user_model.dart';
import 'package:storypad/services/local_storages/databases/base_database.dart';

class UserDatabase extends BaseDatabase {
  @override
  BaseModel? objectTransformer(Map<dynamic, dynamic>? json) {
    return UserModel.fromJson(json ?? {});
  }

  @override
  String table() {
    return "user_info";
  }
}
