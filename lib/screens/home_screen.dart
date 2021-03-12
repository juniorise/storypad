import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:write_your_story/app_helper/app_helper.dart';
import 'package:write_your_story/colors.dart';
import 'package:write_your_story/models/story_list_model.dart';
import 'package:write_your_story/models/story_model.dart';
import 'package:write_your_story/notifier/database_notifier.dart';
import 'package:write_your_story/screens/detail_screen.dart';
import 'package:write_your_story/widgets/vt_ontap_effect.dart';
import 'package:write_your_story/widgets/vt_tab_view.dart';
import 'package:write_your_story/widgets/w_sliver_appbar.dart';

class HomeScreen extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    final database = useProvider(databaseProvider);
    return DefaultTabController(
      length: 12,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        body: NestedScrollView(
          headerSliverBuilder: (context, _) {
            return [
              buildHeaderAppBar(
                statusBarHeight: statusBarHeight,
                context: context,
              ),
            ];
          },
          body: VTTabView(
            physics: const BouncingScrollPhysics(),
            children: List.generate(
              12,
              (index) {
                final int monthID = index + 1;
                return buildStoryInMonth(
                  monthId: monthID,
                  context: context,
                  storyListByMonthId: database.storyListByMonthID,
                  storyListByDayId: database.storyListByDayId,
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  EdgeInsets get padding {
    return const EdgeInsets.symmetric(
      horizontal: 16.0,
      vertical: 8.0,
    );
  }

  WSliverAppBar buildHeaderAppBar({
    double statusBarHeight,
    BuildContext context,
  }) {
    return WSliverAppBar(
      statusBarHeight: statusBarHeight,
      titleText: "សួរស្តីសុធា",
      subtitleText: "ចង់សរសេរអីដែរថ្ងៃនេះ?",
      backgroundText: DateTime.now().year.toString(),
      tabs: List.generate(
        12,
        (index) {
          return AppHelper.toNameOfMonth(context).format(
            DateTime(2020, index + 1),
          );
        },
      ),
    );
  }

  ListView buildStoryInMonth({
    @required int monthId,
    @required BuildContext context,
    @required Map<int, StoryListModel> storyListByMonthId,
    @required Map<int, StoryListModel> storyListByDayId,
  }) {
    List<int> storiesInMonthIds = [];

    if (storyListByMonthId != null &&
        storyListByMonthId.containsKey(monthId) &&
        storyListByMonthId[monthId] != null) {
      storiesInMonthIds = storyListByMonthId[monthId].childrenId;
    }

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: padding,
      children: List.generate(
        storiesInMonthIds.length,
        (_dayIndex) {
          int dayId = storiesInMonthIds[_dayIndex];
          return buildStoryInDay(
            context: context,
            dayId: dayId,
            dayIndex: _dayIndex,
            monthId: monthId,
            storyListByDayId: storyListByDayId,
          );
        },
      ),
    );
  }

  Widget buildStoryInDay({
    @required BuildContext context,
    @required int monthId,
    @required int dayId,
    @required int dayIndex,
    @required Map<int, StoryListModel> storyListByDayId,
  }) {
    final StoryListModel _storyListByDay = storyListByDayId[dayId];
    if (_storyListByDay == null) return SizedBox();

    final int dayOfWeek = AppHelper.dayOfWeek(
      context,
      _storyListByDay.createOn,
    );

    final Color containerColor = colorsByDay[dayOfWeek];

    /// if locale is km => dayName is ចន្ទ​​ អង្គារ​ ...
    /// if locale is en => dayName is Mon, Tue ...
    final String _dayName =
        AppHelper.toDay(context).format(_storyListByDay.createOn);

    final _leftSide = Column(
      children: [
        Text(
          _dayName,
        ),
        const SizedBox(height: 4.0),
        Stack(
          children: [
            Container(
              height: 30,
              width: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: containerColor,
              ),
            ),
            Positioned(
              top: 3,
              left: 0,
              right: 0,
              bottom: 0,
              child: Text(
                _storyListByDay.createOn.day.toString(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context).backgroundColor,
                ),
              ),
            ),
          ],
        )
      ],
    );

    final _rightSide = Expanded(
      child: Column(
        children: [
          const SizedBox(height: 4.0),
          Divider(
            thickness: 1,
            indent: 4.0,
            color: Theme.of(context).disabledColor,
          ),
          Column(
            children: List.generate(
              _storyListByDay.childrenId.length,
              (_storyIndex) {
                final int _storyId = _storyListByDay.childrenId[_storyIndex];
                return buildStoryTile(
                  context: context,
                  storyId: _storyId,
                  storyIndex: _storyIndex,
                  dayIndex: dayIndex,
                  dayId: dayId,
                  monthId: monthId,
                  margin: EdgeInsets.only(
                    top: _storyIndex == 0 ? 8.0 : 0,
                    bottom: 8.0,
                  ),
                );
              },
            ),
          )
        ],
      ),
    );

    final _sizedBox = const SizedBox(width: 16.0);
    return Container(
      margin: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _leftSide,
          _sizedBox,
          _rightSide,
        ],
      ),
    );
  }

  Widget buildStoryTile({
    @required BuildContext context,
    @required int monthId,
    @required int storyId,
    @required int dayId,
    @required int dayIndex,
    @required int storyIndex,
    EdgeInsets margin = const EdgeInsets.only(bottom: 8.0),
  }) {
    final _favoriteButtonEffect = [
      VTOnTapEffectItem(
        effectType: VTOnTapEffectType.scaleDown,
        active: 0.9,
      )
    ];

    final _tileEffects = [
      VTOnTapEffectItem(
        effectType: VTOnTapEffectType.touchableOpacity,
        active: 0.5,
      )
    ];

    return Consumer(
      builder: (context, watch, child) {
        final databaseNotifer = watch(databaseProvider);

        StoryModel story;
        int _paragraphMaxLines = 1;

        if (databaseNotifer.storyById != null) {
          story = databaseNotifer.storyById[storyId];
          int _paragraphLength = story.paragraph.length;
          if (_paragraphLength <= 100) {
            _paragraphMaxLines = 1;
          }

          if (_paragraphLength > 100) {
            _paragraphMaxLines = 2;
          }

          if (_paragraphLength > 200) {
            _paragraphMaxLines = 3;
          }
        }

        final _headerText = Padding(
          padding: const EdgeInsets.only(right: 30),
          child: Text(
            story != null ? story.title ?? "" : "",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.subtitle1,
            textAlign: TextAlign.start,
          ),
        );

        final _paragraph = Text(
          story != null ? story.paragraph ?? "" : "",
          textAlign: TextAlign.start,
          maxLines: _paragraphMaxLines,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Theme.of(context).textTheme.subtitle2.color.withOpacity(0.6),
          ),
        );

        final _favoriteButton = Positioned(
          right: 0,
          top: 0,
          child: VTOnTapEffect(
            effects: _favoriteButtonEffect,
            child: IconButton(
              onPressed: () {},
              iconSize: 20,
              icon: Icon(
                story != null && story.isFavorite
                    ? Icons.favorite
                    : Icons.favorite_border_rounded,
                color: Theme.of(context).dividerColor,
              ),
            ),
          ),
        );

        return AnimatedOpacity(
          duration: const Duration(milliseconds: 500),
          opacity: databaseNotifer.loading ? 0 : 1,
          child: VTOnTapEffect(
            effects: _tileEffects,
            child: Container(
              width: double.infinity,
              margin: margin,
              child: Stack(
                children: [
                  OpenContainer(
                    transitionType: ContainerTransitionType.fadeThrough,
                    transitionDuration: const Duration(milliseconds: 500),
                    openElevation: 0.0,
                    closedElevation: 0.5,
                    openBuilder: (context, callback) {
                      print(
                        "monthId $monthId ,dayId: $dayId, dayIndex: $dayIndex, storyIndex: $storyIndex ",
                      );
                      return DetailScreen(
                        callback: callback,
                        monthId: monthId,
                        dayIndex: dayIndex,
                        storyIndex: storyIndex,
                      );
                    },
                    closedBuilder: (context, callback) {
                      return Container(
                        padding: padding,
                        color: Theme.of(context).backgroundColor,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _headerText,
                            _paragraph,
                          ],
                        ),
                      );
                    },
                  ),
                  _favoriteButton,
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
