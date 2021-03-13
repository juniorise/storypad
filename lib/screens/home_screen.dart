import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:write_your_story/app_helper/app_helper.dart';
import 'package:write_your_story/app_helper/measure_size.dart';
import 'package:write_your_story/colors.dart';
import 'package:write_your_story/mixins/hook_controller.dart';
import 'package:write_your_story/models/index_model.dart';
import 'package:write_your_story/models/story_list_model.dart';
import 'package:write_your_story/models/story_model.dart';
import 'package:write_your_story/notifier/database_notifier.dart';
import 'package:write_your_story/notifier/home_screen_notifier.dart';
import 'package:write_your_story/screens/story_detail_screen.dart';
import 'package:write_your_story/widgets/vt_ontap_effect.dart';
import 'package:write_your_story/widgets/vt_tab_view.dart';
import 'package:write_your_story/widgets/w_add_to_story_fab.dart';
import 'package:write_your_story/widgets/w_no_data.dart';
import 'package:write_your_story/widgets/w_sliver_appbar.dart';

class HomeScreen extends HookWidget with HookController {
  final ValueNotifier<DateTime> dateTimeNotifier = ValueNotifier(DateTime(
    DateTime.now().year,
    1,
    DateTime.now().day,
  ));

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final database = useProvider(databaseProvider);

    final controller = useTabController(initialLength: 12, initialIndex: 0);
    context.read(homeScreenProvider);

    final now = DateTime.now();

    controller.addListener(() {
      dateTimeNotifier.value = DateTime(
        now.year,
        controller.index + 1,
        now.day,
        now.hour,
        now.minute,
      );
    });

    final floatingActionButton = buildFadeInOnInit(
      child: ValueListenableBuilder(
        valueListenable: dateTimeNotifier,
        builder: (context, value, child) {
          return AddToStoryFAB(forDate: value);
        },
      ),
    );

    final scaffold = GestureDetector(
      onDoubleTap: () => database.clearDb(context),
      child: DefaultTabController(
        length: 12,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          extendBodyBehindAppBar: true,
          floatingActionButton: floatingActionButton,
          body: Consumer(
            child: VTTabView(
              controller: controller,
              physics: const BouncingScrollPhysics(),
              children: List.generate(
                12,
                (index) {
                  final int monthID = index + 1;
                  return buildStoryInMonth(
                    monthId: monthID,
                    context: context,
                    database: database,
                  );
                },
              ),
            ),
            builder: (context, watch, bodyInConsumer) {
              final _notifier = watch(homeScreenProvider);
              return NestedScrollView(
                body: bodyInConsumer,
                physics: BouncingScrollPhysics(),
                headerSliverBuilder: (context, _) {
                  return [
                    buildHeaderAppBar(
                      isInit: _notifier.isInit,
                      controller: controller,
                      statusBarHeight: statusBarHeight,
                      context: context,
                    ),
                  ];
                },
              );
            },
          ),
        ),
      ),
    );

    return Stack(
      children: [
        /// we use this to animation background
        Container(
          color: Colors.white,
          width: double.infinity,
          height: double.infinity,
        ),
        buildFadeInOnInit(
          child: Container(
            width: double.infinity,
            height: double.infinity,
            color: Theme.of(context).scaffoldBackgroundColor,
          ),
        ),

        scaffold,
      ],
    );
  }

  Widget buildHeaderAppBar({
    @required TabController controller,
    @required double statusBarHeight,
    @required BuildContext context,
    @required bool isInit,
  }) {
    return WSliverAppBar(
      statusBarHeight: statusBarHeight,
      titleText: "សួរស្តីសុធា",
      subtitleText: "ចង់សរសេរអីដែរថ្ងៃនេះ?",
      backgroundText: DateTime.now().year.toString(),
      tabController: controller,
      isInit: isInit,
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

  Widget buildStoryInMonth({
    @required int monthId, // month index == monthId - 1
    @required BuildContext context,
    @required DatabaseNotifier database,
  }) {
    final storyListByMonthId = database.storyListByMonthID;

    List<int> storiesInMonthIds = [];

    if (storyListByMonthId != null &&
        storyListByMonthId.containsKey(monthId) &&
        storyListByMonthId[monthId] != null) {
      storiesInMonthIds = storyListByMonthId[monthId].childrenId;
    }

    if (storiesInMonthIds == null ||
        (storiesInMonthIds != null && storiesInMonthIds.length == 0)) {
      final monthName = AppHelper.toNameOfMonth(context)
          .format(DateTime(DateTime.now().year, monthId));

      return buildFadeInOnInit(
        child: Consumer(
          child: WNoData(monthName: monthName),
          builder: (context, watch, child) {
            final _notifier = watch(homeScreenProvider);
            return AnimatedOpacity(
              opacity: _notifier.showParagraphById ? 1 : 0,
              duration: const Duration(milliseconds: 650),
              child: child,
            );
          },
        ),
      );
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
            database: database,
          );
        },
      ),
    );
  }

  Widget buildStoryInDay({
    @required int dayId,
    @required int monthId, // monthIndex == monthId - 1
    @required int dayIndex,
    @required BuildContext context,
    @required DatabaseNotifier database,
  }) {
    final Map<int, StoryListModel> storyListByDayId = database.storyListByDayId;
    final StoryListModel _storyListByDay = storyListByDayId[dayId];

    if (_storyListByDay == null) return const SizedBox();

    final _leftSide = buildDayContainer(
      context: context,
      storyListByDay: _storyListByDay,
    );

    final _rightSide = buildStoryListTiles(
      context,
      _storyListByDay,
      database,
      dayIndex,
      monthId,
    );

    final _sizedBox = const SizedBox(width: 8.0);

    final Duration duration = Duration(milliseconds: (dayIndex + 3) * 350);
    return Container(
      margin: const EdgeInsets.only(bottom: 4.0),
      child: buildFadeInOnInit(
        duration: duration,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _leftSide,
            _sizedBox,
            _rightSide,
          ],
        ),
      ),
    );
  }

  Expanded buildStoryListTiles(
    BuildContext context,
    StoryListModel _storyListByDay,
    DatabaseNotifier database,
    int dayIndex,
    int monthId,
  ) {
    return Expanded(
      child: Column(
        children: [
          const SizedBox(height: 4.0),
          Divider(
            thickness: 1,
            indent: 4.0,
          ),
          Column(
            children: List.generate(
              _storyListByDay.childrenId.length,
              (_storyIndex) {
                final childrenId = _storyListByDay.childrenId;
                final int _storyId = childrenId[_storyIndex];
                return buildStoryTile(
                  context: context,
                  story: database.storyById[_storyId],
                  indexes: IndexModel(
                    storyIndex: _storyIndex,
                    dayIndex: dayIndex,
                    monthIndex: monthId - 1,
                  ),
                  margin: EdgeInsets.only(
                    top: _storyIndex == 0 ? 8.0 : 0,
                    bottom: _storyIndex != childrenId.length - 1 ? 8.0 : 0.0,
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }

  Column buildDayContainer({
    @required BuildContext context,
    @required StoryListModel storyListByDay,
  }) {
    /// if locale is km => dayName is ចន្ទ​​ អង្គារ​ ...
    /// if locale is en => dayName is Mon, Tue ...
    final String dayName =
        AppHelper.toDay(context).format(storyListByDay.forDate);

    final int dayOfWeek = AppHelper.dayOfWeek(
      context,
      storyListByDay.forDate,
    );

    final Color containerColor = colorsByDay[dayOfWeek];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        /// Since អាទិត្យ is biggest text,
        /// we used it for size other widget
        const Opacity(
          opacity: 0,
          child: const Text("អាទិត្យ", style: TextStyle(height: 0)),
        ),
        MeasureSize(
          onChange: (Size size) {
            final _notifier = context.read(homeScreenProvider);

            if (!_notifier.isInit) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _notifier.setIsInit(true);
              });
            }
          },
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: 4.0),
                child: Text(dayName),
              ),
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
                      storyListByDay.forDate.day.toString(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Theme.of(context).backgroundColor,
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget buildStoryTile({
    @required BuildContext context,
    @required StoryModel story,
    @required IndexModel indexes,
    EdgeInsets margin = const EdgeInsets.only(bottom: 8.0),
  }) {
    /// Title
    final _titleChild = Container(
      padding: const EdgeInsets.only(right: 30),
      width: MediaQuery.of(context).size.width - 16 * 7,
      child: Text(
        story != null ? story.title ?? "" : "",
        style: Theme.of(context).textTheme.subtitle1.copyWith(height: 1.28),
        textAlign: TextAlign.start,
      ),
    );
    final _titleWidget = buildFadeInOnPopBack(
      child: _titleChild,
      indexes: indexes,
    );

    /// Paragraph
    final _paragraphText = story != null ? story.paragraph ?? "" : "";
    final _paragraphChild = Container(
      width: MediaQuery.of(context).size.width - 16 * 7,
      child: Text(
        _paragraphText,
        textAlign: TextAlign.start,
        style: TextStyle(
          color: Theme.of(context).textTheme.subtitle2.color.withOpacity(0.6),
        ),
      ),
    );
    final _paragraphWidget = _paragraphText.isNotEmpty
        ? buildFadeInOnPopBack(child: _paragraphChild, indexes: indexes)
        : const SizedBox();

    // Favorite button
    final _favoriteButtonEffect = [
      VTOnTapEffectItem(
        effectType: VTOnTapEffectType.scaleDown,
        active: 0.9,
      )
    ];
    final _favoriteButton = Positioned(
      right: 0,
      top: 0,
      child: VTOnTapEffect(
        effects: _favoriteButtonEffect,
        child: IconButton(
          onPressed: () async {
            final database = context.read(databaseProvider);
            await database.toggleFavorite(story);
          },
          iconSize: 20,
          icon: Icon(
            story != null && story.isFavorite == true
                ? Icons.favorite
                : Icons.favorite_border_rounded,
            color: story != null && story.isFavorite == true
                ? Theme.of(context).errorColor
                : Theme.of(context).dividerColor,
          ),
        ),
      ),
    );

    return Container(
      width: double.infinity,
      margin: margin,
      child: OpenContainer(
        transitionType: ContainerTransitionType.fadeThrough,
        transitionDuration: const Duration(milliseconds: 650),
        openElevation: 0.0,
        closedElevation: 0.5,
        closedColor: Theme.of(context).backgroundColor,
        openColor: Theme.of(context).backgroundColor,
        closedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4.0),
        ),
        openShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(0),
        ),
        onClosed: (val) {
          Future.delayed(Duration(milliseconds: 650)).then((value) {
            final _notifier = context.read(homeScreenProvider);
            _notifier.setShowParagraphById(true);
          });
        },
        openBuilder: (context, callback) {
          return StoryDetailScreen(
            story: story,
            callback: callback,
          );
        },
        closedBuilder: (context, callback) {
          final _tileEffects = [
            VTOnTapEffectItem(
              effectType: VTOnTapEffectType.touchableOpacity,
              active: 0.5,
            )
          ];
          return VTOnTapEffect(
            effects: _tileEffects,
            onTap: () {
              final _notifier = context.read(homeScreenProvider);

              _notifier.setShowParagraphById(false);
              _notifier.setLastIndexesModel(indexes);

              Future.delayed(Duration(milliseconds: 65)).then((value) {
                callback();
              });
            },
            child: Stack(
              children: [
                Container(
                  padding: padding,
                  color: Theme.of(context).backgroundColor,
                  width: double.infinity,
                  child: Wrap(
                    direction: Axis.vertical,
                    alignment: WrapAlignment.start,
                    crossAxisAlignment: WrapCrossAlignment.start,
                    children: [
                      _titleWidget,
                      const SizedBox(height: 4.0),
                      _paragraphWidget,
                    ],
                  ),
                ),
                _favoriteButton,
              ],
            ),
          );
        },
      ),
    );
  }

  Consumer buildFadeInOnInit({
    @required Widget child,
    Duration duration = const Duration(milliseconds: 350),
  }) {
    return Consumer(
      child: child,
      builder: (context, watch, child) {
        final _notifier = watch(homeScreenProvider);
        return AnimatedOpacity(
          duration: duration,
          opacity: _notifier.isInit ? 1 : 0,
          child: child,
        );
      },
    );
  }

  Consumer buildFadeInOnPopBack({
    @required Widget child,
    @required IndexModel indexes,
  }) {
    return Consumer(
      child: child,
      builder: (context, watch, child) {
        final _notifier = watch(homeScreenProvider);
        final bool isLastSelected = indexes == _notifier.lastIndexes;
        double opacity = 1;

        if (isLastSelected) {
          if (_notifier.showParagraphById)
            opacity = 1;
          else
            opacity = 0;
        }

        int durationValue;

        /// opacity == 1 mean that it is navigating back,
        /// so we want a slow animation duration
        ///
        /// opacity == 0 mean that we click to navigate
        /// to other screen
        /// so we need faster animation duration
        if (opacity == 1) {
          durationValue = 350;
        } else {
          durationValue = 65;
        }

        return AnimatedOpacity(
          duration: Duration(milliseconds: durationValue),
          opacity: opacity,
          child: child,
        );
      },
    );
  }

  EdgeInsets get padding {
    return const EdgeInsets.symmetric(
      horizontal: 16.0,
      vertical: 8.0,
    );
  }
}
