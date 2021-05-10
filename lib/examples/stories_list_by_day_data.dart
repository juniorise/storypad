import 'package:storypad/models/story_list_model.dart';

final Map<int, StoryListModel> tmpGlobalStoryListByDayId = {
  1: StoryListModel(
    id: 1,
    isLeaf: true,
    forDate: DateTime(2020, 1, 1),
    childrenId: [5, 6, 10, 11],
  ),
  2: StoryListModel(
    id: 2,
    isLeaf: true,
    forDate: DateTime(2020, 1, 2),
    childrenId: [1, 2, 4, 5],
  ),
  3: StoryListModel(
    id: 3,
    isLeaf: true,
    forDate: DateTime(2020, 1, 3),
    childrenId: [5, 6, 7],
  ),
  4: StoryListModel(
    id: 4,
    isLeaf: true,
    forDate: DateTime(2020, 1, 9),
    childrenId: [2, 3, 8],
  ),
  5: StoryListModel(
    id: 5,
    isLeaf: true,
    forDate: DateTime(2020, 1, 12),
    childrenId: [1, 2, 4],
  ),
  6: StoryListModel(
    id: 6,
    isLeaf: true,
    forDate: DateTime(2020, 1, 19),
    childrenId: [5, 6, 7],
  ),
  7: StoryListModel(
    id: 7,
    isLeaf: true,
    forDate: DateTime(2020, 1, 20),
    childrenId: [2, 3, 8],
  ),
};
