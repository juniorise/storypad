import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:storypad/database/w_database.dart';
import 'package:storypad/mixins/change_notifier_mixin.dart';
import 'package:storypad/models/story_list_model.dart';
import 'package:storypad/models/story_model.dart';

class HomeScreenNotifier extends ChangeNotifier with ChangeNotifierMixin {
  final WDatabase wDatabase = WDatabase.instance;

  Map<int, StoryModel>? _storyById;
  Map<int, StoryListModel>? _storyListByDayId;
  Map<int, StoryListModel>? _storyListByMonthID;
  List<int> availableYears = [];

  int currentSelectedYear = DateTime.now().year;
  int currentIndex = DateTime.now().month - 1;

  setCurrentIndex(int index) {
    this.currentIndex = index;
    notifyListeners();
  }

  bool inited = false;

  HomeScreenNotifier() {
    if (!inited) {
      Future.delayed(Duration(milliseconds: 1000)).then((value) {
        setinited(true);
      });
    }
  }

  setinited(bool value) {
    this.inited = value;
    notifyListeners();
  }

  Future<void> setCurrentSelectedYear(int year) async {
    if (this.currentSelectedYear != year) {
      this.currentSelectedYear = year;
    }
    await load();
  }

  Future<void> load() async {
    final Map<int, StoryModel>? result = await wDatabase.storyById();

    if (result != null) {
      this._storyById = result;
      _setStoryListByDayId();
      _setStoryListByMonthID();
    }

    notifyListeners();
  }

  _setStoryListByDayId() {
    final Map<DateTime, List<StoryModel>> _groupByDay = {};
    final Map<DateTime, List<StoryModel>> _sortedGroupByDay = {};

    final Map<int, List<int>> _storiesInYear = {};
    availableYears.clear();

    // Fetch data from unsorted api
    this.storyById!.entries.forEach((story) {
      final forDate = story.value.forDate;
      final key = DateTime(
        forDate.year,
        forDate.month,
        forDate.day,
      );

      if (key.year == currentSelectedYear) {
        if (_groupByDay.containsKey(key)) {
          _groupByDay[key]?.add(story.value);
        } else {
          _groupByDay[key] = [story.value];
        }
      }

      /// set all story in year to `_storiesInYear` year
      if (_storiesInYear.containsKey(key.year)) {
        _storiesInYear[key.year]?.add(story.value.id);
      } else {
        _storiesInYear[key.year] = [story.value.id];
      }
    });

    // check if story in year
    // has value in it or not
    _storiesInYear.forEach((key, List<int>? value) {
      if (value!.length > 0 && !availableYears.contains(key)) {
        availableYears.add(key);
      }
    });

    // if available year is empty, add a default
    if (availableYears.length == 0) {
      final currentYear = DateTime.now().year;
      availableYears.add(currentYear);
    }

    // Sort data by date
    _groupByDay.entries.map((e) => e.key).toList()
      ..sort((a, b) {
        return a.compareTo(b);
      })
      ..forEach((date) {
        _sortedGroupByDay[date] = _groupByDay[date]!;
      });

    // Add them to each month
    int i = 1;
    final Map<int, StoryListModel>? _mapStoryListByDayId = {};
    _sortedGroupByDay.entries.forEach((storyList) {
      _mapStoryListByDayId?[i] = StoryListModel(
        id: i++,
        isLeaf: true,
        forDate: storyList.key,
        childrenId: storyList.value.map((e) {
          return e.id;
        }).toList(),
      );
    });

    this._storyListByDayId = _mapStoryListByDayId ?? {};
  }

  _setStoryListByMonthID() {
    final Map<DateTime, List<StoryListModel>?> _groupByMonth = {};
    final Map<DateTime, List<StoryListModel>?> _sortedGroupByMonth = {};

    if (this._storyListByDayId!.entries.isNotEmpty) {
      this._storyListByDayId!.entries.forEach((storyList) {
        final forDate = storyList.value.forDate;

        final key = DateTime(
          forDate.year,
          forDate.month,
        );

        if (_groupByMonth.containsKey(key)) {
          _groupByMonth[key]?.add(storyList.value);
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
    }

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

      final childrenId = storyList.value?.map((e) {
        return e.id;
      }).toList();

      _mapStoryListByMonthId[id] = StoryListModel(
        id: id,
        childrenId: childrenId ?? [],
        forDate: storyList.key,
        isLeaf: false,
      );
    });

    this._storyListByMonthID = _mapStoryListByMonthId;
  }

  Future<void> toggleFavorite(int storyId) async {
    final story = this._storyById![storyId];
    final result = story!.copyWith(isFavorite: !story.isFavorite);

    this._storyById?[storyId] = result;
    notifyListeners();

    await wDatabase.updateStory(story: result);
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
  Map<int, StoryModel>? get storyById => this._storyById;

  List<StoryModel>? get storyByIdAsList {
    List<StoryModel> _storyList = [];

    this._storyById?.entries.forEach((e) {
      if (e.value.forDate.year == currentSelectedYear) {
        _storyList.add(e.value);
      }
    });

    _storyList.sort(
      (a, b) {
        return (b.isFavorite ? 1 : 0).compareTo((a.isFavorite ? 1 : 0));
      },
    );

    return _storyList;
  }

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
  Map<int, StoryListModel>? get storyListByDayId => this._storyListByDayId;

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
  Map<int, StoryListModel>? get storyListByMonthID => this._storyListByMonthID;
}

final homeScreenProvider = ChangeNotifierProvider<HomeScreenNotifier>((ref) {
  return HomeScreenNotifier()..load();
});
