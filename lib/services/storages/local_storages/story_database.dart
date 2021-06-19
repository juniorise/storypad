import 'package:html_character_entities/html_character_entities.dart';
import 'package:storypad/models/base_model.dart';
import 'package:storypad/models/story_model.dart';
import 'package:storypad/services/storages/local_storages/base_database.dart';

class StoryDatabase extends BaseDatabase {
  String singleQuote = "▘";

  @override
  BaseModel? objectTransformer(Map<dynamic, dynamic>? json) {
    if (json == null) return null;
    return StoryModel.fromJson(json);
  }

  Future<Map<int, StoryModel>> storyById({String? where}) async {
    final list = await super.fetchAll();
    Map<int, StoryModel> map = {};
    list?.forEach((e) {
      if (e is StoryModel) {
        String? _paragraph = e.paragraph != null ? HtmlCharacterEntities.decode(e.paragraph!) : null;
        map[e.id] = e.copyWith(paragraph: _paragraph?.replaceAll(this.singleQuote, "'"));
      }
    });
    return map;
  }

  clearAllStories() async {
    super.delete();
  }

  @override
  String table() {
    return "story";
  }
}
