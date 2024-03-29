import 'dart:io';
import 'dart:ui';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:storypad/helpers/app_helper.dart';
import 'package:storypad/constants/colors.dart';
import 'package:storypad/constants/config_constant.dart';
import 'package:storypad/mixins/dialog_mixin.dart';
import 'package:storypad/mixins/hook_controller.dart';
import 'package:storypad/models/story_list_model.dart';
import 'package:storypad/models/story_model.dart';
import 'package:storypad/notifier/home_screen_notifier.dart';
import 'package:storypad/notifier/tab_controller_notifier.dart';
import 'package:storypad/notifier/theme_notifier.dart';
import 'package:storypad/screens/home/local_widgets/faq_button.dart';
import 'package:storypad/screens/setting/setting_screen.dart';
import 'package:storypad/screens/story_detail/story_detail_screen.dart';
import 'package:storypad/widgets/w_story_tile.dart';
import 'package:storypad/widgets/w_tab_view.dart';
import 'package:storypad/widgets/w_no_data.dart';
import 'package:storypad/widgets/w_sliver_appbar.dart';
import 'package:storypad/widgets/w_tap_effect.dart';
import 'package:url_launcher/url_launcher.dart';
import 'local_widgets/backup_tile.dart';

class HomeScreen extends HookWidget with HookController, DialogMixin {
  static final now = DateTime.now();

  closeFaq(ValueNotifier<bool> faqNotifier) {
    if (faqNotifier.value) {
      faqNotifier.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    print("Build HomeScreen");

    final faqNotifier = useState<bool>(false);
    final alertNotifier = useState<bool>(true);
    final _notifier = useProvider(homeScreenProvider);

    final controller = useTabController(
      initialLength: 12,
      initialIndex: _notifier.currentIndex,
    );

    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final double bottomBarHeight = MediaQuery.of(context).padding.bottom;

    final Widget scaffold = buildScaffold(
      context: context,
      notifier: _notifier,
      controller: controller,
      statusBarHeight: statusBarHeight,
      bottomBarHeight: bottomBarHeight,
      faqNotifier: faqNotifier,
      alertNotifier: alertNotifier,
    );

    final fadeScaffold = buildFadeInitAnimationBackground(
      context: context,
      scaffold: scaffold,
      notifier: _notifier,
    );

    final bottomSyncHeight = kBottomNavigationBarHeight + bottomBarHeight;

    return Scaffold(
      body: Material(
        color: Theme.of(context).colorScheme.surface,
        child: Stack(
          children: [
            BackupTile(
              bottomBarHeight: bottomBarHeight,
              faqNotifier: faqNotifier,
              bottomSyncHeight: bottomSyncHeight,
            ),
            AnimatedContainer(
              transform: Matrix4.identity()..translate(0.0, faqNotifier.value ? -bottomSyncHeight : 0),
              curve: Curves.easeOutQuart,
              duration: ConfigConstant.duration,
              child: fadeScaffold,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildScaffold({
    required BuildContext context,
    required HomeScreenNotifier notifier,
    required TabController controller,
    required double statusBarHeight,
    required double bottomBarHeight,
    required ValueNotifier<bool> faqNotifier,
    required ValueNotifier<bool> alertNotifier,
  }) {
    return WillPopScope(
      onWillPop: () async {
        if (faqNotifier.value) {
        } else {
          if (Platform.isAndroid) {
            SystemChannels.platform.invokeMethod('SystemNavigator.pop');
          }
        }
        return closeFaq(faqNotifier);
      },
      child: GestureDetector(
        onTap: () {
          if (FocusScope.of(context).hasFocus) {
            FocusScope.of(context).unfocus();
            TextEditingController().clear();
          }
          closeFaq(faqNotifier);
        },
        child: Scaffold(
          backgroundColor: Colors.transparent,
          floatingActionButton: buildMoreFaq(
            statusBarHeight,
            bottomBarHeight,
            notifier,
            controller,
            faqNotifier,
            context,
          ),
          resizeToAvoidBottomInset: false,
          body: Consumer(
            child: Column(
              children: [
                buildNormalList(controller, notifier, context, faqNotifier),
                buildDayList(controller, context, notifier, faqNotifier),
              ],
            ),
            builder: (context, watch, column) {
              final themeNotifier = watch(themeProvider);
              return NestedScrollView(
                headerSliverBuilder: (context, _) => [
                  buildHeaderAppBar(
                    isInit: notifier.inited,
                    controller: controller,
                    statusBarHeight: statusBarHeight,
                    context: context,
                    notifier: notifier,
                    bottomBarHeight: bottomBarHeight,
                    themeNotifier: themeNotifier,
                  ),
                  SliverToBoxAdapter(
                    child: AnimatedCrossFade(
                      crossFadeState: alertNotifier.value ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                      duration: ConfigConstant.fadeDuration,
                      sizeCurve: Curves.ease,
                      firstChild: SizedBox(width: double.infinity),
                      secondChild: Container(
                        padding: EdgeInsets.all(ConfigConstant.margin0),
                        color: Theme.of(context).colorScheme.error,
                        child: Stack(
                          children: [
                            Container(
                              width: double.infinity,
                              child: RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(
                                  text: "StoryPad is going to be ending its service. ",
                                  style: Theme.of(context).textTheme.caption?.copyWith(
                                        color: Theme.of(context).colorScheme.onError,
                                      ),
                                  children: [
                                    WidgetSpan(
                                      child: WTapEffect(
                                        child: Text(
                                          "Learn more",
                                          style: Theme.of(context).textTheme.caption?.copyWith(
                                                color: Theme.of(context).colorScheme.onError,
                                                decoration: TextDecoration.underline,
                                                decorationColor: Theme.of(context).colorScheme.onError,
                                              ),
                                        ),
                                        onTap: () {
                                          launch(
                                              'https://docs.google.com/document/d/13c1x8H94_FtiGRG3BUutwfHMPprwBcBsywz4CUMIbv4');
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Positioned(
                              right: 0,
                              child: WTapEffect(
                                onTap: () {
                                  alertNotifier.value = !alertNotifier.value;
                                },
                                child: Icon(
                                  Icons.clear,
                                  color: Theme.of(context).colorScheme.onError,
                                  size: ConfigConstant.iconSize1,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  )
                ],
                body: Builder(
                  builder: (context) {
                    if (themeNotifier.isNormalList) {
                      return (column as Column).children.first;
                    } else {
                      return (column as Column).children.last;
                    }
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  WTabView buildDayList(
    TabController controller,
    BuildContext context,
    HomeScreenNotifier notifier,
    ValueNotifier<bool> faqNotifier,
  ) {
    return WTabView(
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
            faqNotifier: faqNotifier,
          );
        },
      ),
    );
  }

  Widget buildNormalList(
    TabController controller,
    HomeScreenNotifier notifier,
    BuildContext context,
    ValueNotifier<bool> faqNotifier,
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
                  notifier: notifier,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_storyListModel != null && _storyListModel.childrenId.isNotEmpty)
                        buildDateMonthHeader(context, _storyListModel),
                      Column(
                        children: List.generate(
                          storiesInMonthIds.length,
                          (storyByDayIndex) {
                            final int storyByIndex = storiesInMonthIds[storyByDayIndex];
                            final StoryListModel? storyInMonth = notifier.storyListByDayId?[storyByIndex];
                            final List<int> storyInDayIds = storyInMonth?.childrenId ?? [];
                            return Column(
                              children: List.generate(
                                storyInDayIds.length,
                                (index) {
                                  final StoryModel story = notifier.storyById![storyInDayIds[index]]!;
                                  return buildStoryTile(
                                    context: context,
                                    story: story,
                                    notifier: notifier,
                                    faqNotifier: faqNotifier,
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

  Column buildDateMonthHeader(BuildContext context, StoryListModel _storyListModel) {
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
                  AppHelper.toFullNameOfMonth(context).format(_storyListModel.forDate),
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
    TabController controller,
    ValueNotifier<bool> faqNotifier,
    BuildContext context,
  ) {
    return buildFadeInOnInit(
      notifier: notifier,
      child: FaqButton(
        faqNotifier: faqNotifier,
        onSettingPressed: () {
          closeFaq(faqNotifier);
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) {
                return SettingScreen();
              },
            ),
          );
        },
        onAddStoryPressed: () async {
          final _tabNotifier = context.read(tabControllerProvider(controller));
          closeFaq(faqNotifier);
          final forDate = DateTime(
            notifier.currentSelectedYear,
            _tabNotifier.currentIndex + 1,
            now.day,
          );
          final dynamic date = await Navigator.of(context, rootNavigator: true).push(
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
    required ValueNotifier<bool> faqNotifier,
  }) {
    final storyListByMonthId = notifier.storyListByMonthID;

    // fetching data
    List<int>? storiesInMonthIds = [];
    bool storiesNotNull =
        storyListByMonthId != null && storyListByMonthId.containsKey(monthId) && storyListByMonthId[monthId] != null;

    if (storiesNotNull) {
      storiesInMonthIds = storyListByMonthId[monthId]?.childrenId;
    }

    // showing if data is empty
    bool noData = storiesInMonthIds == null || (storiesInMonthIds.length == 0);
    if (noData) {
      final monthName = AppHelper.toNameOfMonth(context, fullName: true).format(DateTime(DateTime.now().year, monthId));
      return buildFadeInOnInit(
        child: WNoData(monthName: monthName),
        notifier: notifier,
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
            faqNotifier: faqNotifier,
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
    required ValueNotifier<bool> faqNotifier,
  }) {
    // fetching data
    final Map<int, StoryListModel>? storyListByDayId = notifier.storyListByDayId;
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
      faqNotifier: faqNotifier,
    );

    final _sizedBox = const SizedBox(width: 8.0);
    final Duration duration = Duration(milliseconds: (dayIndex + 3) * 350);

    return Container(
      margin: const EdgeInsets.only(bottom: 4.0),
      child: buildFadeInOnInit(
        duration: duration,
        notifier: notifier,
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
    required ValueNotifier<bool> faqNotifier,
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
                    bottom: _storyIndex != childrenId.length - 1 ? ConfigConstant.margin1 : 0.0,
                  ),
                  faqNotifier: faqNotifier,
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
    final String dayName = AppHelper.toDay(context).format(storyListByDay.forDate);

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
                      color: Theme.of(context).colorScheme.onBackground.withOpacity(0.5),
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
    required ValueNotifier<bool> faqNotifier,
  }) {
    return WStoryTile(
      story: story,
      onSaved: onSaved,
      readOnly: false,
      onTap: () async {
        closeFaq(faqNotifier);
        final dynamic selected = await Navigator.of(
          context,
          rootNavigator: true,
        ).push(
          CupertinoPageRoute(
            fullscreenDialog: true,
            builder: (context) {
              return StoryDetailScreen(story: story);
            },
          ),
        );
        if (selected != null && selected is DateTime) onSaved(selected);
      },
      onToggleFavorite: () async {
        closeFaq(faqNotifier);

        await notifier.toggleFavorite(story.id);
      },
    );
  }

  Widget buildFadeInitAnimationBackground({
    required BuildContext context,
    required Widget scaffold,
    required HomeScreenNotifier notifier,
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
          notifier: notifier,
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
    required HomeScreenNotifier notifier,
  }) {
    return AnimatedOpacity(
      duration: duration,
      opacity: notifier.inited ? 1 : 0,
      child: child,
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
      final style = Theme.of(context).textTheme.bodyText1!.copyWith(color: Theme.of(context).colorScheme.background);

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
