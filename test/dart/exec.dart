import 'package:write_your_story/examples/stories_data.dart';

void main() async {
  /// generate insert story
  tmpGlbalStoryByID.forEach((key, value) {
    final title = value.title;
    final paragraph = value.paragraph;
    int updateOn = null;
    if (value.updateOn != null) {
      updateOn = value.updateOn.millisecondsSinceEpoch;
    }

    print('''
    INSERT INTO "story" (
      title, 
      paragraph, 
      create_on, 
      update_on, 
      is_favorite
    )
    VALUES (
        "$title", 
        "$paragraph", 
        ${value.createOn.millisecondsSinceEpoch}, 
        $updateOn, 
        0
    );
    ''');
  });
}
