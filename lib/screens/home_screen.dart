import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:write_story/app_helper/app_helper.dart';
import 'package:write_story/colors/colors.dart';
import 'package:write_story/constants/config_constant.dart';
import 'package:write_story/mixins/dialog_mixin.dart';
import 'package:write_story/mixins/hook_controller.dart';
import 'package:write_story/models/story_list_model.dart';
import 'package:write_story/models/story_model.dart';
import 'package:write_story/notifier/home_screen_notifier.dart';
import 'package:write_story/notifier/tab_controller_notifier.dart';
import 'package:write_story/notifier/theme_notifier.dart';
import 'package:write_story/screens/group_screen.dart';
import 'package:write_story/screens/setting_screen.dart';
import 'package:write_story/screens/story_detail_screen.dart';
import 'package:write_story/widgets/w_story_tile.dart';
import 'package:write_story/widgets/vt_ontap_effect.dart';
import 'package:write_story/widgets/vt_tab_view.dart';
import 'package:write_story/widgets/w_more_faq_button.dart';
import 'package:write_story/widgets/w_no_data.dart';
import 'package:write_story/widgets/w_sliver_appbar.dart';

class HomeScreen extends HookWidget with HookController, DialogMixin {
  static final now = DateTime.now();

  final ValueNotifier<bool> faqNotifier = ValueNotifier<bool>(false);

  closeFaq() {
    if (faqNotifier.value) {
      faqNotifier.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final bottomBarHeight = MediaQuery.of(context).padding.bottom;

    final _notifier = useProvider(homeScreenProvider);
    final _themeNotifier = useProvider(themeProvider);

    final controller = useTabController(
      initialLength: 12,
      initialIndex: _notifier.currentIndex,
    );

    final _tabNotifier = useProvider(tabControllerProvider(controller));

    final Widget scaffold = buildScaffold(
      context: context,
      notifier: _notifier,
      controller: controller,
      statusBarHeight: statusBarHeight,
      tabNotifier: _tabNotifier,
      bottomBarHeight: bottomBarHeight,
      themeNotifier: _themeNotifier,
    );

    return buildFadeInitAnimationBackground(
      context: context,
      scaffold: scaffold,
    );
  }

  Widget buildScaffold({
    required BuildContext context,
    required HomeScreenNotifier notifier,
    required TabController controller,
    required double statusBarHeight,
    required TabControllerNotifier tabNotifier,
    required double bottomBarHeight,
    required ThemeNotifier themeNotifier,
  }) {
    return WillPopScope(
      onWillPop: () async {
        if (faqNotifier.value) {
        } else {
          if (Platform.isAndroid) {
            SystemChannels.platform.invokeMethod('SystemNavigator.pop');
          }
        }

        return closeFaq();
      },
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
          TextEditingController().clear();
          closeFaq();
        },
        child: Scaffold(
          backgroundColor: Colors.transparent,
          floatingActionButton: buildMoreFaq(
            statusBarHeight,
            bottomBarHeight,
            notifier,
            tabNotifier,
            controller,
          ),
          resizeToAvoidBottomInset: false,
          body: NestedScrollView(
            headerSliverBuilder: (context, _) => [
              buildHeaderAppBar(
                isInit: notifier.inited,
                controller: controller,
                statusBarHeight: statusBarHeight,
                context: context,
                notifier: notifier,
                bottomBarHeight: bottomBarHeight,
                themeNotifier: themeNotifier,
              )
            ],
            body: Consumer(
              builder: (context, _, child) {
                if (themeNotifier.isNormalList) {
                  return buildNormalList(controller, notifier, context);
                } else {
                  return buildDayList(controller, context, notifier);
                }
              },
            ),
          ),
        ),
      ),
    );
  }

  VTTabView buildDayList(
    TabController controller,
    BuildContext context,
    HomeScreenNotifier notifier,
  ) {
    return VTTabView(
      controller: controller,
      children: List.generate(
        controller.length,
        (index) {
          final int monthID = index + 1;
          return buildStoryInMonth(
            monthId: monthID,
            context: context,
            notifier: notifier,
            onSaved: (DateTime? date) async {
              if (date != null) {
                notifier.setCurrentSelectedYear(date.year);
                controller.animateTo(date.month - 1, curve: Curves.easeInQuart);
              }
            },
          );
        },
      ),
    );
  }

  Widget buildNormalList(
    TabController controller,
    HomeScreenNotifier notifier,
    BuildContext context,
  ) {
    return notifier.storyByIdAsList!.length > 0
        ? ListView(
            padding: ConfigConstant.layoutPadding.copyWith(
              top: 0,
              bottom: kToolbarHeight * 2,
            ),
            children: List.generate(
              controller.length,
              (monthIndex) {
                final int monthId = monthIndex + 1;
                final storyListByMonthId = notifier.storyListByMonthID;
                StoryListModel? _storyListModel;

                // fetching data
                List<int> storiesInMonthIds = [];
                bool storiesNotNull = storyListByMonthId != null &&
                    storyListByMonthId.containsKey(monthId) &&
                    storyListByMonthId[monthId] != null;

                if (storiesNotNull) {
                  _storyListModel = storyListByMonthId[monthId];
                  storiesInMonthIds = _storyListModel?.childrenId ?? [];
                }

                return buildFadeInOnInit(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_storyListModel != null &&
                          _storyListModel.childrenId.isNotEmpty)
                        buildDateMonthHeader(context, _storyListModel),
                      Column(
                        children: List.generate(
                          storiesInMonthIds.length,
                          (storyByDayIndex) {
                            final int storyByIndex =
                                storiesInMonthIds[storyByDayIndex];
                            final StoryListModel? storyInMonth =
                                notifier.storyListByDayId?[storyByIndex];
                            final List<int> storyInDayIds =
                                storyInMonth?.childrenId ?? [];
                            return Column(
                              children: List.generate(
                                storyInDayIds.length,
                                (index) {
                                  final StoryModel story = notifier
                                      .storyById![storyInDayIds[index]]!;
                                  return buildStoryTile(
                                    context: context,
                                    story: story,
                                    notifier: notifier,
                                    onSaved: (DateTime? date) async {
                                      if (date != null) {
                                        await notifier.setCurrentSelectedYear(
                                          date.year,
                                        );
                                      }
                                    },
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          )
        : WNoData();
  }

  Column buildDateMonthHeader(
      BuildContext context, StoryListModel _storyListModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: ConfigConstant.margin2),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(child: const Divider(endIndent: 8)),
            Material(
              elevation: 0.3,
              borderRadius: BorderRadius.circular(100),
              color: Theme.of(context).colorScheme.surface,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: ConfigConstant.margin2,
                  vertical: ConfigConstant.margin0,
                ),
                child: Text(
                  AppHelper.toFullNameOfMonth(context)
                      .format(_storyListModel.forDate),
                ),
              ),
            ),
            Expanded(child: const Divider(indent: 8)),
          ],
        ),
        const SizedBox(height: ConfigConstant.margin1),
      ],
    );
  }

  Widget buildMoreFaq(
    double statusBarHeight,
    double bottomBarHeight,
    HomeScreenNotifier notifier,
    TabControllerNotifier tabNotifier,
    TabController controller,
  ) {
    return buildFadeInOnInit(
      child: ValueListenableBuilder(
        valueListenable: faqNotifier,
        builder: (context, value, child) {
          return WMoreFaqButton(
            faqNotifier: faqNotifier,
            onGroupPressed: () async {
              closeFaq();
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) {
                    return GroupScreen();
                  },
                ),
              );
              await notifier.load();
            },
            onSettingPressed: () {
              closeFaq();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) {
                    return SettingScreen();
                  },
                ),
              );
            },
            onAddStoryPressed: () async {
              closeFaq();
              final forDate = DateTime(
                notifier.currentSelectedYear,
                tabNotifier.currentIndex + 1,
                now.day,
              );
              final dynamic date =
                  await Navigator.of(context, rootNavigator: true).push(
                MaterialPageRoute(
                  fullscreenDialog: true,
                  builder: (context) {
                    return StoryDetailScreen(
                      story: StoryModel.empty.copyWith(forDate: forDate),
                      insert: true,
                    );
                  },
                ),
              );
              if (date != null) {
                notifier.setCurrentSelectedYear(date.year);
                controller.animateTo(date.month - 1, curve: Curves.easeInQuart);
              }
            },
          );
        },
      ),
    );
  }

  Widget buildHeaderAppBar({
    required TabController controller,
    required double statusBarHeight,
    required double bottomBarHeight,
    required BuildContext context,
    required bool isInit,
    required HomeScreenNotifier notifier,
    required ThemeNotifier themeNotifier,
  }) {
    return WSliverAppBar(
      statusBarHeight: statusBarHeight,
      bottomBarHeight: bottomBarHeight,
      backgroundText: notifier.currentSelectedYear.toString(),
      tabController: controller,
      isInit: isInit,
      tabs: themeNotifier.isNormalList
          ? null
          : List.generate(
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
    required int monthId, // month index == monthId - 1
    required BuildContext context,
    required HomeScreenNotifier notifier,
    required ValueChanged<DateTime> onSaved,
  }) {
    final storyListByMonthId = notifier.storyListByMonthID;

    // fetching data
    List<int>? storiesInMonthIds = [];
    bool storiesNotNull = storyListByMonthId != null &&
        storyListByMonthId.containsKey(monthId) &&
        storyListByMonthId[monthId] != null;

    if (storiesNotNull) {
      storiesInMonthIds = storyListByMonthId[monthId]?.childrenId;
    }

    // showing if data is empty
    bool noData = storiesInMonthIds == null || (storiesInMonthIds.length == 0);
    if (noData) {
      final monthName = AppHelper.toNameOfMonth(context, fullName: true)
          .format(DateTime(DateTime.now().year, monthId));
      return buildFadeInOnInit(
        child: WNoData(monthName: monthName),
      );
    }

    return ListView(
      padding: ConfigConstant.layoutPadding.copyWith(
        bottom: kToolbarHeight * 2,
      ),
      children: List.generate(
        storiesInMonthIds.length,
        (_dayIndex) {
          int dayId = storiesInMonthIds![_dayIndex];
          return buildStoryInDay(
            context: context,
            dayId: dayId,
            dayIndex: _dayIndex,
            notifier: notifier,
            onSaved: onSaved,
          );
        },
      ),
    );
  }

  Widget buildStoryInDay({
    required int dayId,
    required int dayIndex,
    required BuildContext context,
    required HomeScreenNotifier notifier,
    required ValueChanged<DateTime> onSaved,
  }) {
    // fetching data
    final Map<int, StoryListModel>? storyListByDayId =
        notifier.storyListByDayId;
    final StoryListModel? _storyListByDay = storyListByDayId?[dayId];

    if (_storyListByDay == null) return const SizedBox();

    final _leftSide = buildDayContainer(
      context: context,
      storyListByDay: _storyListByDay,
    );

    final _rightSide = buildStoryListTiles(
      context: context,
      storyListByDay: _storyListByDay,
      notifier: notifier,
      onSaved: onSaved,
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

  Widget buildStoryListTiles({
    required BuildContext context,
    required StoryListModel storyListByDay,
    required HomeScreenNotifier notifier,
    required ValueChanged<DateTime> onSaved,
  }) {
    final _theme = Theme.of(context);
    return Expanded(
      child: Column(
        children: [
          const SizedBox(height: 4.0),
          Divider(
            thickness: 0.05,
            color: _theme.colorScheme.onBackground,
          ),
          Column(
            children: List.generate(
              storyListByDay.childrenId.length,
              (_storyIndex) {
                final childrenId = storyListByDay.childrenId;
                final int _storyId = childrenId[_storyIndex];

                final story = notifier.storyById?[_storyId];
                return buildStoryTile(
                  onSaved: onSaved,
                  context: context,
                  story: story!,
                  notifier: notifier,
                  margin: EdgeInsets.only(
                    top: _storyIndex == 0 ? ConfigConstant.margin1 : 0.0,
                    bottom: _storyIndex != childrenId.length - 1
                        ? ConfigConstant.margin1
                        : 0.0,
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }

  Widget buildDayContainer({
    required BuildContext context,
    required StoryListModel storyListByDay,
  }) {
    /// if locale is km => dayName is ចន្ទ​​ អង្គារ​ ...
    /// if locale is en => dayName is Mon, Tue ...
    final String dayName =
        AppHelper.toDay(context).format(storyListByDay.forDate);

    /// get stand color of the week
    final int dayOfWeek = AppHelper.dayOfWeek(context, storyListByDay.forDate);
    final Color standColor = colorsByDay[dayOfWeek]!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        /// Since អាទិត្យ is biggest text,
        /// we used it for size other widget
        Opacity(
          opacity: 0,
          child: Text(
            "អាទិត្យ",
            style: Theme.of(context).textTheme.bodyText2?.copyWith(height: 0),
          ),
        ),
        Column(
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: ConfigConstant.margin0),
              child: Text(
                dayName,
                style: Theme.of(context).textTheme.bodyText2?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onBackground
                          .withOpacity(0.5),
                    ),
              ),
            ),
            const SizedBox(height: 2.0),
            Stack(
              children: [
                Container(
                  height: 30,
                  width: 30,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: standColor,
                  ),
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    height: 30,
                    alignment: Alignment.center,
                    child: Text(
                      storyListByDay.forDate.day.toString(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ],
    );
  }

  Widget buildStoryTile({
    required BuildContext context,
    required StoryModel story,
    required HomeScreenNotifier notifier,
    EdgeInsets margin = const EdgeInsets.only(bottom: ConfigConstant.margin1),
    required ValueChanged<DateTime> onSaved,
  }) {
    return WStoryTile(
      story: story,
      onSaved: onSaved,
      onToggleShare: () async {
        closeFaq();
        onTapVibrate();
        print("TEST");
        await notifier.toggleShare(story.id);
      },
      onTap: () async {
        closeFaq();
        final dynamic selected = await Navigator.of(
          context,
          rootNavigator: true,
        ).push(
          MaterialPageRoute(
            fullscreenDialog: true,
            builder: (context) {
              return StoryDetailScreen(story: story);
            },
          ),
        );
        if (selected != null && selected is DateTime) onSaved(selected);
      },
      onToggleFavorite: () async {
        closeFaq();
        onTapVibrate();
        await notifier.toggleFavorite(story.id);
      },
    );
  }

  Widget buildFadeInitAnimationBackground({
    required BuildContext context,
    required Widget scaffold,
  }) {
    return Stack(
      children: [
        /// we use this to animation background
        Container(
          color: Theme.of(context).colorScheme.surface,
          width: double.infinity,
          height: double.infinity,
        ),
        buildFadeInOnInit(
          child: Container(
            width: double.infinity,
            height: double.infinity,
            color: Theme.of(context).colorScheme.background,
          ),
        ),
        scaffold,
      ],
    );
  }

  Widget buildFadeInOnInit({
    required Widget child,
    Duration duration = const Duration(milliseconds: 350),
  }) {
    return Consumer(
      child: child,
      builder: (context, watch, child) {
        final _notifier = watch(homeScreenProvider);
        return AnimatedOpacity(
          duration: duration,
          opacity: _notifier.inited ? 1 : 0,
          child: child,
        );
      },
    );
  }

  Future<void> showSnackBar({
    required BuildContext context,
    required String title,
    String? actionLabel,
    VoidCallback? onActionPressed,
    VoidCallback? onClose,
  }) async {
    SnackBar buildSnackBar({
      required String title,
      required BuildContext context,
      String? actionLabel,
      VoidCallback? onActionPressed,
    }) {
      final style = Theme.of(context)
          .textTheme
          .bodyText1!
          .copyWith(color: Theme.of(context).colorScheme.background);

      final actions = onActionPressed != null
          ? SnackBarAction(
              label: actionLabel ?? tr("button.okay"),
              textColor: Theme.of(context).colorScheme.background,
              onPressed: () async {
                onActionPressed();
              },
            )
          : null;

      return SnackBar(
        content: Text(title, style: style),
        action: actions,
      );
    }

    final SnackBar snack = buildSnackBar(
      title: title,
      context: context,
      actionLabel: actionLabel!,
      onActionPressed: onActionPressed,
    );

    ScaffoldMessenger.of(context).showSnackBar(snack).closed.then(
      (value) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        if (onClose != null) onClose();
      },
    );
  }
}
