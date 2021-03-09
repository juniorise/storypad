import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:write_your_story/app_helper/app_helper.dart';
import 'package:write_your_story/examples/stories_data.dart';
import 'package:write_your_story/examples/stories_list_by_day_data.dart';
import 'package:write_your_story/examples/stories_list_by_month_data.dart';
import 'package:write_your_story/models/story_list_model.dart';
import 'package:write_your_story/models/story_model.dart';
import 'package:write_your_story/notifier/database_notifier.dart';
import 'package:write_your_story/notifier/detail_screen_notifier.dart';
import 'package:write_your_story/screens/story_detail_screen.dart';
import 'package:write_your_story/widgets/vt_ontap_effect.dart';
import 'package:write_your_story/widgets/vt_tab_view.dart';
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
    final _storyListInMonth = globalStoryListByMonthID[monthId];

    final tabController = useTabController(
      initialLength: _storyListInMonth.childrenId.length,
      initialIndex: dayIndex,
    );

    final notifier = useProvider(detailScreenNotifier);

    final createOn = globalStoryListByMonthID[monthId].createOn;
    final headerSliverBuilder = (context, _) {
      return [
        WSliverAppBar(
          statusBarHeight: statusBarHeight,
          backgroundText: AppHelper.toNameOfMonth(context).format(createOn),
          titleText: "ថយក្រោយ",
          subtitleText: "ចង់សរសេរអីដែរថ្ងៃនេះ?",
          tabController: tabController,
          callback: () {
            notifier.setClickedOutside(false);
            callback();
          },
          tabs: List.generate(
            _storyListInMonth.childrenId.length,
            (index) {
              int _dayId = _storyListInMonth.childrenId[index];
              DateTime _createOn = globalStoryListByDayId[_dayId].createOn;
              String _dayInt = _createOn.day.toString();

              String _dayName = AppHelper.toDay(context).format(_createOn);
              return _dayName + " " + _dayInt;
            },
          ),
        ),
      ];
    };

    final fabEffects = [
      VTOnTapEffectItem(
        effectType: VTOnTapEffectType.scaleDown,
        active: 0.5,
      ),
      VTOnTapEffectItem(
        effectType: VTOnTapEffectType.touchableOpacity,
        active: 0.1,
      )
    ];

    return WillPopScope(
      onWillPop: () => notifier.setClickedOutside(false),
      child: GestureDetector(
        onTap: () => notifier.setClickedOutside(true),
        child: Scaffold(
          extendBodyBehindAppBar: true,
          floatingActionButton: VTOnTapEffect(
            effects: fabEffects,
            child: FloatingActionButton(
              onPressed: () {},
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              child: const Icon(Icons.add),
              elevation: 0.0,
              highlightElevation: 0.0,
              focusElevation: 0.0,
              hoverElevation: 0.0,
              disabledElevation: 0.0,
            ),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          bottomNavigationBar: BottomAppBar(
            color: Theme.of(context).backgroundColor,
            clipBehavior: Clip.antiAlias,
            shape: CircularNotchedRectangle(),
            child: Container(height: kToolbarHeight),
          ),
          body: NestedScrollView(
            headerSliverBuilder: headerSliverBuilder,
            body: buildVtTabView(
              controller: tabController,
              storyListInMonth: _storyListInMonth,
              notifier: notifier,
              context: context,
            ),
          ),
        ),
      ),
    );
  }

  VTTabView buildVtTabView({
    @required TabController controller,
    @required StoryListModel storyListInMonth,
    @required DetailScreenNotifier notifier,
    @required BuildContext context,
  }) {
    return VTTabView(
      controller: controller,
      children: List.generate(
        storyListInMonth.childrenId.length,
        (_dayIndex) {
          final _dayId = storyListInMonth.childrenId[_dayIndex];
          final _storyListInDay = globalStoryListByDayId[_dayId];

          return ListView(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            children: List.generate(
              _storyListInDay.childrenId.length,
              (_storyIndex) {
                final int _storyId = _storyListInDay.childrenId[_storyIndex];

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
                        transitionType: ContainerTransitionType.fadeThrough,
                        transitionDuration: const Duration(milliseconds: 500),
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
                                effectType: VTOnTapEffectType.touchableOpacity,
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
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _headerText,
                                    const SizedBox(height: 4.0),
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
            ),
          );
        },
      ),
    );
  }
}
