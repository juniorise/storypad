import 'package:write_story/examples/stories_data.dart';

void main() async {
  /// generate insert story
  tmpGlbalStoryByID.forEach((key, value) {
    final title = value.title;
    final paragraph = value.paragraph;
    int updateOn;
    if (value.updateOn != null) {
      updateOn = value.updateOn.millisecondsSinceEpoch;
    }

    print('''
    INSERT INTO "story" (
      title, 
      paragraph, 
      create_on, 
      for_date,
      update_on, 
      is_favorite
    )
    VALUES (
        "$title", 
        "$paragraph", 
        ${value.createOn.millisecondsSinceEpoch}, 
        ${value.forDate.millisecondsSinceEpoch}, 
        $updateOn,
        0
    );
    ''');
  });
}
