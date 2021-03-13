import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:write_your_story/database/w_database.dart';
import 'package:write_your_story/models/story_list_model.dart';
import 'package:write_your_story/models/story_model.dart';

class DatabaseNotifier extends ChangeNotifier {
  final WDatabase wDatabase = WDatabase.instance;

  Map<int, StoryModel> _storyById;
  Map<int, StoryListModel> _storyListByDayId;
  Map<int, StoryListModel> _storyListByMonthID;

  bool loading = false;

  load() async {
    setLoading(true);
    final result = await wDatabase.storyById();

    if (result != null) {
      this._storyById = result;
      _setStoryListByDayId();
      _setStoryListByMonthID();
    }

    Future.delayed(Duration(milliseconds: 250)).then((value) {
      setLoading(false);
    });
  }

  updateStory(StoryModel story) async {
    await wDatabase.updateStory(story: story);
    this._storyById[story.id] = story;
    await load();
  }

  insertStory(StoryModel story) async {
    await wDatabase.addStory(story: story);
    await load();
  }

  clearAllStoryies() async {
    await wDatabase.clearAllStories();
  }

  _setStoryListByDayId() {
    final Map<DateTime, List<StoryModel>> _groupByDay = {};
    final Map<DateTime, List<StoryModel>> _sortedGroupByDay = {};

    // Fetch data from unsorted api
    this.storyById.entries.forEach((story) {
      final forDate = story.value.forDate;
      final key = DateTime(
        forDate.year,
        forDate.month,
        forDate.day,
      );

      if (_groupByDay.containsKey(key)) {
        _groupByDay[key].add(story.value);
      } else {
        _groupByDay[key] = [story.value];
      }
    });

    // Sort data by date
    _groupByDay.entries.map((e) => e.key).toList()
      ..sort((a, b) {
        return a.compareTo(b);
      })
      ..forEach((date) {
        _sortedGroupByDay[date] = _groupByDay[date];
      });

    // Add them to each month
    int i = 1;
    final Map<int, StoryListModel> _mapStoryListByDayId = {};
    _sortedGroupByDay.entries.forEach((storyList) {
      _mapStoryListByDayId[i] = StoryListModel(
        id: i++,
        isLeaf: true,
        forDate: storyList.key,
        childrenId: storyList.value.map((e) {
          return e.id;
        }).toList(),
      );
    });

    if (_mapStoryListByDayId != null && _mapStoryListByDayId.isNotEmpty) {
      this._storyListByDayId = _mapStoryListByDayId;
    }
  }

  _setStoryListByMonthID() {
    final Map<DateTime, List<StoryListModel>> _groupByMonth = {};
    final Map<DateTime, List<StoryListModel>> _sortedGroupByMonth = {};

    if (this._storyListByDayId != null &&
        this._storyListByDayId.entries != null &&
        this._storyListByDayId.entries.isNotEmpty) {
      this._storyListByDayId.entries.forEach((storyList) {
        final forDate = storyList.value.forDate;

        final key = DateTime(
          forDate.year,
          forDate.month,
        );

        if (_groupByMonth.containsKey(key)) {
          _groupByMonth[key].add(storyList.value);
        } else {
          _groupByMonth[key] = [storyList.value];
        }
      });

      // Sort data by date
      _groupByMonth.entries.map((e) => e.key).toList()
        ..sort((a, b) {
          return a.compareTo(b);
        })
        ..forEach((date) {
          _sortedGroupByMonth[date] = _groupByMonth[date];
        });

      final Map<int, StoryListModel> _mapStoryListByMonthId = {};
      for (int i = 1; i <= 12; i++) {
        _mapStoryListByMonthId[i] = StoryListModel(
          id: i,
          isLeaf: false,
          childrenId: [],
          forDate: DateTime(2021, i),
        );
      }

      _groupByMonth.entries.forEach((storyList) {
        final id = storyList.key.month;

        final childrenId = storyList.value.map((e) {
          return e.id;
        }).toList();

        _mapStoryListByMonthId[id] = StoryListModel(
          id: id,
          childrenId: childrenId,
          forDate: storyList.key,
          isLeaf: false,
        );
      });

      if (_mapStoryListByMonthId != null && _mapStoryListByMonthId.isNotEmpty) {
        this._storyListByMonthID = _mapStoryListByMonthId;
      }
    }
  }

  setLoading(bool value) {
    this.loading = value;
    notifyListeners();
  }

  void clearDb(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Are you sure to clear database?",
          style: Theme.of(context)
              .textTheme
              .bodyText1
              .copyWith(color: Theme.of(context).backgroundColor),
        ),
        action: SnackBarAction(
          label: "Yes",
          textColor: Theme.of(context).backgroundColor,
          onPressed: () async {
            final database = context.read(databaseProvider);
            await database.clearAllStoryies();
          },
        ),
      ),
    );
  }

  /// ```
  /// {
  ///   1: StoryModel(
  ///     id: 1,
  ///     title: "7 Colors of dress for every single day of the week",
  ///     paragraph: "We can choose color of our cloth to fit the day in the week.",
  ///     createOn: DateTime(2020, 1, 2),
  ///   ),
  ///   2: StoryModel(
  ///     id: 2,
  ///     title: "Khmer traditional dress is​ very popular for all girls in the world",
  ///     paragraph: "Khmer dress is not just popular in the country but also worldwide. ",
  ///     createOn: DateTime(2020, 1, 3),
  ///   ),
  /// }
  /// ```
  Map<int, StoryModel> get storyById => this._storyById;

  /// ```
  /// {
  ///   1: StoryListModel(
  ///     id: 1,
  ///     isLeaf: true,
  ///     createOn: DateTime(2020, 1, 1),
  ///     childrenId: [5, 6, 10, 11],
  ///   ),
  ///   2: StoryListModel(
  ///     id: 2,
  ///     isLeaf: true,
  ///     createOn: DateTime(2020, 1, 2),
  ///     childrenId: [1, 2, 4, 5],
  ///   ),
  /// }
  /// ```
  Map<int, StoryListModel> get storyListByDayId => this._storyListByDayId;

  /// ```
  /// {
  ///   1: StoryListModel(
  ///     id: 1,
  ///     childrenId: [
  ///       2,
  ///       4,
  ///       5,
  ///       8,
  ///     ],
  ///     createOn: DateTime(2020, DateTime.january),
  ///     isLeaf: false,
  ///   ),
  ///   2: StoryListModel(
  ///     id: 2,
  ///     childrenId: [
  ///       1,
  ///       3,
  ///       5,
  ///       8,
  ///     ],
  ///     createOn: DateTime(2020, DateTime.february),
  ///     isLeaf: false,
  ///   ),
  /// }
  /// ```
  Map<int, StoryListModel> get storyListByMonthID => this._storyListByMonthID;
}

final databaseProvider = ChangeNotifierProvider<DatabaseNotifier>(
  (ref) {
    return DatabaseNotifier()..load();
  },
);
