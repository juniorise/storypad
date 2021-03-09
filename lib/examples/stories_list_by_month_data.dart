import 'package:write_your_story/models/story_list_model.dart';

final Map<String, StoryListModel> globalStoryListByMonthID = {
  "1": StoryListModel(
    id: "1",
    childrenId: [
      "2",
      "4",
      "5",
      "7",
    ],
    createOn: DateTime(2020, DateTime.january),
    isLeaf: false,
  ),
  "2": StoryListModel(
    id: "2",
    childrenId: [
      "1",
      "3",
      "5",
      "7",
    ],
    createOn: DateTime(2020, DateTime.february),
    isLeaf: false,
  ),
  "3": StoryListModel(
    id: "3",
    childrenId: [
      "2",
      "4",
      "6",
      "7",
    ],
    createOn: DateTime(2020, DateTime.march),
    isLeaf: false,
  ),
  "4": StoryListModel(
    id: "4",
    childrenId: [
      "1",
      "3",
      "5",
      "7",
    ],
    createOn: DateTime(2020, DateTime.april),
    isLeaf: false,
  ),
  "5": StoryListModel(
    id: "5",
    childrenId: [
      "2",
      "4",
      "5",
      "6",
    ],
    createOn: DateTime(2020, DateTime.may),
    isLeaf: false,
  ),
  "6": StoryListModel(
    id: "6",
    childrenId: [
      "1",
      "3",
      "6",
      "7",
    ],
    createOn: DateTime(2020, DateTime.june),
    isLeaf: false,
  ),
  "7": StoryListModel(
    id: "7",
    childrenId: [
      "3",
      "4",
      "6",
      "7",
    ],
    createOn: DateTime(2020, DateTime.july),
    isLeaf: false,
  ),
  "8": StoryListModel(
    id: "8",
    childrenId: [
      "1",
      "3",
      "4",
      "6",
    ],
    createOn: DateTime(2020, DateTime.august),
    isLeaf: false,
  ),
  "9": StoryListModel(
    id: "9",
    childrenId: [
      "2",
      "4",
      "6",
      "7",
    ],
    createOn: DateTime(2020, DateTime.september),
    isLeaf: false,
  ),
  "10": StoryListModel(
    id: "10",
    childrenId: [
      "1",
      "2",
      "6",
      "7",
    ],
    createOn: DateTime(2020, DateTime.october),
    isLeaf: false,
  ),
  "11": StoryListModel(
    id: "11",
    childrenId: [
      "2",
      "3",
      "4",
    ],
    createOn: DateTime(2020, DateTime.november),
    isLeaf: false,
  ),
  "12": StoryListModel(
    id: "12",
    childrenId: [
      "4",
      "5",
      "6",
      "7",
    ],
    createOn: DateTime(2020, DateTime.december),
    isLeaf: false,
  ),
};
