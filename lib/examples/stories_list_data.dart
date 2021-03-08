import 'package:write_your_story/models/story_list_model.dart';

final Map<String, StoryListModel> storyListByDayID = {
  "1": mon,
  "2": tues,
  "3": wed,
  "4": thu,
  "5": fri,
  "6": sat,
  "7": sun,
};

final Map<String, StoryListModel> storyListByMonthID = {
  "1": jan,
  "2": feb,
  "3": mar,
  "4": apr,
  "5": may,
  "6": jun,
  "7": jul,
  "8": aug,
  "9": sep,
  "10": oct,
  "11": nov,
  "12": dec,
};

final StoryListModel mon = StoryListModel(
  id: "1",
  isLeaf: true,
  createOn: DateTime(2020, 1, 28),
  childrenId: ["5", "6", "10", "11"],
);

final StoryListModel tues = StoryListModel(
  id: "2",
  isLeaf: true,
  createOn: DateTime(2020, 1, 2),
  childrenId: ["1", "2", "4"],
);
final StoryListModel wed = StoryListModel(
  id: "3",
  isLeaf: true,
  createOn: DateTime(2020, 1, 3),
  childrenId: ["5", "6", "7"],
);
final StoryListModel thu = StoryListModel(
  id: "4",
  isLeaf: true,
  createOn: DateTime(2020, 1, 4),
  childrenId: ["2", "3", "8"],
);
final StoryListModel fri = StoryListModel(
  id: "5",
  isLeaf: true,
  createOn: DateTime(2020, 1, 5),
  childrenId: ["1", "2", "4"],
);
final StoryListModel sat = StoryListModel(
  id: "6",
  isLeaf: true,
  createOn: DateTime(2020, 1, 6),
  childrenId: ["5", "6", "7"],
);
final StoryListModel sun = StoryListModel(
  id: "7",
  isLeaf: true,
  createOn: DateTime(2020, 1, 7),
  childrenId: ["2", "3", "8"],
);

// JAN
final StoryListModel jan = StoryListModel(
  id: "1",
  childrenId: [
    "1",
    "2",
    "4",
    "5",
    "7",
  ],
  createOn: DateTime(2020, DateTime.january),
  isLeaf: false,
);

final StoryListModel feb = StoryListModel(
  id: "2",
  childrenId: [
    "1",
    "3",
    "4",
    "5",
    "7",
  ],
  createOn: DateTime(2020, DateTime.february),
  isLeaf: false,
);

final StoryListModel mar = StoryListModel(
  id: "3",
  childrenId: [
    "1",
    "2",
    "4",
    "6",
    "7",
  ],
  createOn: DateTime(2020, DateTime.march),
  isLeaf: false,
);

final StoryListModel apr = StoryListModel(
  id: "4",
  childrenId: [
    "1",
    "3",
    "5",
    "6",
    "7",
  ],
  createOn: DateTime(2020, DateTime.april),
  isLeaf: false,
);
final StoryListModel may = StoryListModel(
  id: "5",
  childrenId: [
    "2",
    "3",
    "4",
    "5",
    "6",
  ],
  createOn: DateTime(2020, DateTime.may),
  isLeaf: false,
);

final StoryListModel jun = StoryListModel(
  id: "6",
  childrenId: [
    "1",
    "3",
    "4",
    "6",
    "7",
  ],
  createOn: DateTime(2020, DateTime.june),
  isLeaf: false,
);

final StoryListModel jul = StoryListModel(
  id: "7",
  childrenId: [
    "1",
    "3",
    "4",
    "6",
    "7",
  ],
  createOn: DateTime(2020, DateTime.july),
  isLeaf: false,
);

final StoryListModel aug = StoryListModel(
  id: "8",
  childrenId: [
    "1",
    "3",
    "4",
    "6",
  ],
  createOn: DateTime(2020, DateTime.august),
  isLeaf: false,
);

final StoryListModel sep = StoryListModel(
  id: "9",
  childrenId: [
    "1",
    "2",
    "4",
    "6",
    "7",
  ],
  createOn: DateTime(2020, DateTime.september),
  isLeaf: false,
);
final StoryListModel oct = StoryListModel(
  id: "10",
  childrenId: [
    "1",
    "2",
    "6",
    "7",
  ],
  createOn: DateTime(2020, DateTime.october),
  isLeaf: false,
);

final StoryListModel nov = StoryListModel(
  id: "11",
  childrenId: [
    "1",
    "2",
    "3",
    "4",
  ],
  createOn: DateTime(2020, DateTime.november),
  isLeaf: false,
);
final StoryListModel dec = StoryListModel(
  id: "12",
  childrenId: [
    "4",
    "5",
    "6",
    "7",
  ],
  createOn: DateTime(2020, DateTime.december),
  isLeaf: false,
);
