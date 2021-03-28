import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_quill/models/documents/document.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:write_story/app_helper/app_helper.dart';
import 'package:write_story/colors.dart';
import 'package:write_story/constants/config_constant.dart';
import 'package:write_story/mixins/hook_controller.dart';
import 'package:write_story/models/story_list_model.dart';
import 'package:write_story/models/story_model.dart';
import 'package:write_story/notifier/home_screen_notifier.dart';
import 'package:write_story/notifier/tab_controller_notifier.dart';
import 'package:write_story/screens/ask_for_name_sheet.dart';
import 'package:write_story/screens/story_detail_screen.dart';
import 'package:write_story/widgets/vt_ontap_effect.dart';
import 'package:write_story/widgets/vt_tab_view.dart';
import 'package:write_story/widgets/w_more_faq_button.dart';
import 'package:write_story/widgets/w_no_data.dart';
import 'package:write_story/widgets/w_sliver_appbar.dart';

class HomeScreen extends HookWidget with HookController {
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
  }) {
    return WillPopScope(
      onWillPop: () async {
        return closeFaq();
      },
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
          TextEditingController().clear();
          closeFaq();
        },
        child: DefaultTabController(
          length: controller.length,
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
                )
              ],
              body: VTTabView(
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
                          controller.animateTo(date.month - 1,
                              curve: Curves.easeInQuart);
                        }
                      },
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
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
            onSettingPressed: () {
              closeFaq();
              showModalBottomSheet(
                isDismissible: true,
                context: context,
                enableDrag: true,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) {
                  return AskForNameSheet(
                    statusBarHeight: statusBarHeight,
                    bottomBarHeight: bottomBarHeight,
                    intTapIndex: 1,
                  );
                },
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
  }) {
    return WSliverAppBar(
      statusBarHeight: statusBarHeight,
      bottomBarHeight: bottomBarHeight,
      backgroundText: notifier.currentSelectedYear.toString(),
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
      final monthName = AppHelper.toNameOfMonth(context)
          .format(DateTime(DateTime.now().year, monthId));
      return buildFadeInOnInit(
        child: WNoData(monthName: monthName),
      );
    }

    return ListView(
      padding: ConfigConstant.layoutPadding,
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
        const Opacity(
          opacity: 0,
          child: const Text("អាទិត្យ", style: TextStyle(height: 0)),
        ),
        Column(
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: ConfigConstant.margin0),
              child: Text(dayName),
            ),
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
    /// Title
    final _titleWidget = Container(
      padding: const EdgeInsets.only(right: 30),
      width: MediaQuery.of(context).size.width - 16 * 7,
      child: Text(
        story.title,
        style: Theme.of(context).textTheme.subtitle1,
        textAlign: TextAlign.start,
      ),
    );

    String? paragraph;

    try {
      final decode = jsonDecode(story.paragraph!);
      final document = Document.fromJson(decode);
      paragraph = document.toPlainText().trim();
    } catch (e) {}

    /// Paragraph
    final String _paragraphText = paragraph ?? "${story.paragraph}";
    final _paragraphChild = Container(
      width: MediaQuery.of(context).size.width - 16 * 7,
      child: Text(
        _paragraphText,
        textAlign: TextAlign.start,
        style: TextStyle(
          color: Theme.of(context).textTheme.subtitle2!.color!.withOpacity(0.6),
        ),
      ),
    );

    final _paragraphWidget =
        _paragraphText.isNotEmpty ? _paragraphChild : const SizedBox();

    // Favorite button
    final _favoriteButton = buildFavoriteButton(
      notifier: notifier,
      story: story,
      context: context,
    );

    final _tileEffects = [
      VTOnTapEffectItem(
        effectType: VTOnTapEffectType.touchableOpacity,
        active: 0.3,
      ),
    ];

    return VTOnTapEffect(
      effects: _tileEffects,
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
      child: Container(
        width: double.infinity,
        margin: margin,
        child: Material(
          elevation: 0.5,
          color: Theme.of(context).backgroundColor,
          child: Stack(
            children: [
              Container(
                padding: ConfigConstant.layoutPadding,
                width: double.infinity,
                child: Wrap(
                  direction: Axis.vertical,
                  alignment: WrapAlignment.start,
                  crossAxisAlignment: WrapCrossAlignment.start,
                  children: [
                    _titleWidget,
                    const SizedBox(height: ConfigConstant.margin0),
                    _paragraphWidget,
                  ],
                ),
              ),
              _favoriteButton,
            ],
          ),
        ),
      ),
    );
  }

  Widget buildFavoriteButton({
    required HomeScreenNotifier notifier,
    required StoryModel story,
    required BuildContext context,
  }) {
    final favoriteButtonEffect = [
      VTOnTapEffectItem(
        effectType: VTOnTapEffectType.scaleDown,
        active: 0.9,
      )
    ];

    return Positioned(
      right: 0,
      top: 0,
      child: VTOnTapEffect(
        onTap: () async {
          closeFaq();
          await notifier.toggleFavorite(story.id);
        },
        effects: favoriteButtonEffect,
        child: IconButton(
          onPressed: () async {
            closeFaq();
            await notifier.toggleFavorite(story.id);
          },
          iconSize: 20,
          icon: Icon(
            story.isFavorite == true
                ? Icons.favorite
                : Icons.favorite_border_rounded,
            color: story.isFavorite == true
                ? Theme.of(context).errorColor
                : Theme.of(context).dividerColor,
          ),
        ),
      ),
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
          .copyWith(color: Theme.of(context).backgroundColor);

      final actions = onActionPressed != null
          ? SnackBarAction(
              label: actionLabel ?? tr("button.okay"),
              textColor: Theme.of(context).backgroundColor,
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
