import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:write_your_story/app_helper/app_helper.dart';
import 'package:write_your_story/models/story_list_model.dart';
import 'package:write_your_story/models/story_model.dart';
import 'package:write_your_story/notifier/database_notifier.dart';
import 'package:write_your_story/notifier/detail_screen_notifier.dart';
import 'package:write_your_story/screens/story_detail_screen.dart';
import 'package:write_your_story/widgets/vt_ontap_effect.dart';
import 'package:write_your_story/widgets/vt_tab_view.dart';
import 'package:write_your_story/widgets/w_add_to_story_fab.dart';
import 'package:write_your_story/widgets/w_sliver_appbar.dart';

class DetailScreen extends HookWidget {
  const DetailScreen({
    Key key,
    @required this.callback,
    @required this.monthId,
    @required this.storyIndex,
    @required this.dayIndex,
  }) : super(key: key);

  final VoidCallback callback;
  final int monthId;
  final int dayIndex;
  final int storyIndex;

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    final notifier = useProvider(detailScreenNotifier);
    final database = useProvider(databaseProvider);

    final _storyListInMonth = database.storyListByMonthID[monthId];
    final forDate = database.storyListByMonthID[monthId].forDate;

    final _tabLength = getValidLength(
      _storyListInMonth.childrenId,
      database.storyListByDayId,
    );

    final tabController = useTabController(
      initialLength: _tabLength,
      initialIndex: dayIndex,
    );

    final headerSliverBuilder = (context, _) {
      return [
        WSliverAppBar(
          statusBarHeight: statusBarHeight,
          backgroundText: AppHelper.toNameOfMonth(context).format(forDate),
          titleText: "ថយក្រោយ",
          subtitleText: "ចង់សរសេរអីដែរថ្ងៃនេះ?",
          tabController: tabController,
          callback: () {
            notifier.setClickedOutside(false);
            callback();
          },
          tabs: buildTabs(
            _storyListInMonth,
            context,
            database.storyListByDayId,
          ),
        ),
      ];
    };

    return WillPopScope(
      onWillPop: () => notifier.setClickedOutside(false),
      child: GestureDetector(
        onTap: () => notifier.setClickedOutside(true),
        child: Scaffold(
          extendBodyBehindAppBar: true,
          floatingActionButton: AddToStoryFAB(),
          body: NestedScrollView(
            headerSliverBuilder: headerSliverBuilder,
            body: buildVtTabView(
              context: context,
              notifier: notifier,
              controller: tabController,
              storyListInMonth: _storyListInMonth,
              storyListByDayId: database.storyListByDayId,
            ),
          ),
        ),
      ),
    );
  }

  List<String> buildTabs(
    StoryListModel _storyListInMonth,
    BuildContext context,
    Map<int, StoryListModel> _storyListByDayId,
  ) {
    List<String> tabs = [];
    _storyListInMonth.childrenId.forEach(
      (int _dayId) {
        if (_storyListByDayId.containsKey(_dayId)) {
          DateTime _forDate = _storyListByDayId[_dayId].forDate;
          String _dayInt = _forDate.day.toString();
          String _dayName = AppHelper.toDay(context).format(_forDate);
          tabs.add(_dayName + " " + _dayInt);
        }
      },
    );
    return tabs;
  }

  int getValidLength(
    List<int> childrenId,
    Map<int, StoryListModel> _storyListByDayId,
  ) {
    int i = 0;
    childrenId.forEach((int _dayId) {
      if (_storyListByDayId.containsKey(_dayId)) i++;
    });
    return i;
  }

  VTTabView buildVtTabView({
    @required TabController controller,
    @required StoryListModel storyListInMonth,
    @required Map<int, StoryListModel> storyListByDayId,
    @required DetailScreenNotifier notifier,
    @required BuildContext context,
  }) {
    return VTTabView(
      controller: controller,
      children: buildTabChildren(
        storyListInMonth,
        notifier,
        storyListByDayId,
      ),
    );
  }

  List<Widget> buildTabChildren(
    StoryListModel storyListInMonth,
    DetailScreenNotifier notifier,
    Map<int, StoryListModel> _storyListByDayId,
  ) {
    List<Widget> list = [];

    for (int _dayIndex = 0;
        _dayIndex < storyListInMonth.childrenId.length;
        _dayIndex++) {
      final _dayId = storyListInMonth.childrenId[_dayIndex];

      if (_storyListByDayId.containsKey(_dayId)) {
        final _storyListInDay = _storyListByDayId[_dayId];

        bool _storyNotEmpty = _storyListInDay != null &&
            _storyListInDay.childrenId != null &&
            _storyListInDay.childrenId.isNotEmpty;

        list.add(
          ListView(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            children: _storyNotEmpty
                ? List.generate(
                    _storyListInDay.childrenId.length,
                    (_storyIndex) {
                      final int _storyId =
                          _storyListInDay.childrenId[_storyIndex];

                      bool selected = _storyIndex == this.storyIndex &&
                          this.dayIndex == _dayIndex;

                      double opacity = 1;

                      if (selected) opacity = 1;
                      if (!selected) opacity = 0.5;
                      if (notifier.clickedOutside) opacity = 1;

                      return Consumer(
                        builder: (context, watch, child) {
                          final databaseNotifier = watch(databaseProvider);

                          final StoryModel _story =
                              databaseNotifier.storyById[_storyId];

                          final _headerText = Text(
                            _story.title,
                            style: Theme.of(context)
                                .textTheme
                                .subtitle1
                                .copyWith(height: 1.28),
                            textAlign: TextAlign.start,
                          );

                          final _paragraph = Text(
                            _story.paragraph,
                            textAlign: TextAlign.start,
                            style: TextStyle(
                              color: Theme.of(context)
                                  .textTheme
                                  .subtitle2
                                  .color
                                  .withOpacity(0.6),
                            ),
                          );
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8.0),
                            child: OpenContainer(
                              transitionType:
                                  ContainerTransitionType.fadeThrough,
                              transitionDuration:
                                  const Duration(milliseconds: 500),
                              openElevation: 0.0,
                              closedElevation: 0.5,
                              openBuilder: (context, callback) {
                                return StoryDetailScreen(
                                  story: _story,
                                  callback: callback,
                                );
                              },
                              closedBuilder: (context, callback) {
                                return VTOnTapEffect(
                                  onTap: () {
                                    notifier.setClickedOutside(true);
                                    callback();
                                  },
                                  effects: [
                                    VTOnTapEffectItem(
                                      effectType:
                                          VTOnTapEffectType.touchableOpacity,
                                      active: 0.5,
                                    )
                                  ],
                                  child: AnimatedOpacity(
                                    duration: const Duration(milliseconds: 350),
                                    opacity: opacity,
                                    child: Container(
                                      color: Theme.of(context).backgroundColor,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0,
                                        vertical: 8.0,
                                      ),
                                      child: Wrap(
                                        children: [
                                          _headerText,
                                          _paragraph,
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      );
                    },
                  )
                : [],
          ),
        );
      }
    }

    return list;
  }
}
