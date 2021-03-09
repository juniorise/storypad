import 'package:write_your_story/examples/stories_data.dart';
import 'package:write_your_story/examples/stories_list_by_day_data.dart';
import 'package:write_your_story/examples/stories_list_by_month_data.dart';

void main() async {
  /// generate insert story
  int i = 1;
  tmpGlbalStoryByID.forEach((key, value) {
    final createOn = value.createOn.millisecondsSinceEpoch;
    final title = value.title;
    final paragraph = value.paragraph;

    print(
      '''INSERT INTO "story" VALUES ($i,'$title','$paragraph',$createOn,0);''',
    );
    i++;
  });

  /// generate insert story list in month
  i = 1;
  globalStoryListByMonthID.forEach((key, value) {
    final createOn = value.createOn.millisecondsSinceEpoch;
    final childrenId = value.childrenId.toString();
    print(
      '''INSERT INTO "story_list" VALUES ($i,'$childrenId',$createOn,0);''',
    );
    i++;
  });

  /// generate insert story list in day
  globalStoryListByDayId.forEach((key, value) {
    final createOn = value.createOn.millisecondsSinceEpoch;
    final childrenId = value.childrenId.toString();
    print(
      '''INSERT INTO "story_list" VALUES ($i,'$childrenId',$createOn,1);''',
    );
    i++;
  });
}
