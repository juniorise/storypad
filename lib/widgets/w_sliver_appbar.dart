import 'dart:ui';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:write_story/app_helper/measure_size.dart';
import 'package:write_story/constants/config_constant.dart';
import 'package:write_story/mixins/dialog_mixin.dart';
import 'package:write_story/notifier/appbar_notifier.dart';
import 'package:write_story/notifier/home_screen_notifier.dart';
import 'package:write_story/notifier/user_model_notifier.dart';
import 'package:write_story/sheets/ask_for_name_sheet.dart';
import 'package:write_story/widgets/vt_ontap_effect.dart';
import 'package:write_story/widgets/w_tabbar.dart';

class WSliverAppBar extends HookWidget with DialogMixin {
  const WSliverAppBar({
    Key? key,
    required this.statusBarHeight,
    required this.bottomBarHeight,
    required this.isInit,
    this.tabs,
    this.backgroundText,
    this.tabController,
  }) : super(key: key);

  final double statusBarHeight;
  final double bottomBarHeight;
  final bool isInit;
  final List<String>? tabs;
  final String? backgroundText;
  final TabController? tabController;

  @override
  Widget build(BuildContext context) {
    final notifier = useProvider(appBarProvider);
    final controller = tabController ?? DefaultTabController.of(context);

    final bool hasBottom = tabs != null && tabs!.isNotEmpty;
    return SliverAppBar(
      floating: true,
      pinned: hasBottom ? true : false,
      forceElevated: true,
      elevation: isInit ? 0.5 : 0,
      backgroundColor: Theme.of(context).colorScheme.surface,
      expandedHeight: hasBottom
          ? kToolbarHeight * 2.8
          : kToolbarHeight * 2.8 - kToolbarHeight + 32,
      centerTitle: false,
      automaticallyImplyLeading: false,
      flexibleSpace: AnimatedContainer(
        duration: ConfigConstant.fadeDuration,
        margin: EdgeInsets.only(top: hasBottom ? 0.0 : 16.0),
        child: buildFlexibleSpaceBar(
          context: context,
          notifier: notifier,
        ),
      ),
      bottom: hasBottom
          ? WTabBar(
              controller: controller,
              height: 40,
              backgroundColor: Theme.of(context).colorScheme.surface,
              tabs: tabs ?? [],
              isInit: isInit,
            )
          : null,
    );
  }

  FlexibleSpaceBar buildFlexibleSpaceBar({
    required BuildContext context,
    required AppBarNotifier notifier,
  }) {
    final _theme = Theme.of(context);
    final _textTheme = _theme.textTheme;
    final _headerStyle = _textTheme.headline6;

    final _inited = notifier.headlineWidth != 0;
    double offsetX = _inited ? 0.0 : -8.0;

    final leftSideWidth = notifier.headlineWidth != 0
        ? MediaQuery.of(context).size.width -
            16 * 2 -
            notifier.headlineWidth -
            8
        : kToolbarHeight * 2;

    final _notifier = context.read(userModelProvider);

    final _headerTexts = Container(
      alignment: Alignment.centerLeft,
      margin: EdgeInsets.only(
        top: statusBarHeight >= 20 ? statusBarHeight - 20 : 0,
        bottom: 15,
      ),
      child: AnimatedOpacity(
        opacity: _inited ? 1 : 0,
        curve: Curves.easeInOutQuad,
        duration: const Duration(milliseconds: 1000),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              curve: Curves.easeInOutQuad,
              transform: Matrix4.identity()..translate(offsetX, 0.0),
              duration: const Duration(milliseconds: 650),
              width: leftSideWidth,
              child: Text(
                tr(
                  "title.hello_name",
                  namedArgs: {"USER_NAME": _notifier.user?.nickname ?? ""},
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style:
                    _headerStyle?.copyWith(color: _theme.colorScheme.primary),
              ),
            ),
            const SizedBox(height: ConfigConstant.margin0),
            AnimatedOpacity(
              opacity: _inited ? 1 : 0,
              duration: const Duration(milliseconds: 1000),
              curve: Curves.easeInQuad,
              child: AnimatedContainer(
                curve: Curves.easeInOutQuad,
                duration: const Duration(milliseconds: 500),
                width: leftSideWidth,
                child: Text(
                  tr("subtitle.ask_for_feeling"),
                  style: _textTheme.bodyText1?.copyWith(
                    color: _theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );

    final _yearText = this.backgroundText != null
        ? Container(
            alignment: Alignment.centerRight,
            margin: EdgeInsets.only(
              top: statusBarHeight >= 15 ? statusBarHeight - 20 : 0,
              bottom: 15,
            ),
            child: AnimatedOpacity(
              duration: Duration(milliseconds: 1000),
              curve: Curves.easeInQuad,
              opacity: _inited ? 1 : 0,
              child: MeasureSize(
                onChange: (Size size) {
                  notifier.setHeadlineWidth(size.width);
                },
                child: Text(
                  this.backgroundText!,
                  style: _textTheme.headline2
                      ?.copyWith(color: _theme.disabledColor),
                ),
              ),
            ),
          )
        : const SizedBox();

    final _padding = const EdgeInsets.symmetric(
      horizontal: 16.0,
      vertical: 0.0,
    );

    return FlexibleSpaceBar(
      background: Padding(
        padding: _padding.copyWith(top: 0, bottom: 0),
        child: Stack(
          alignment: Alignment.centerLeft,
          children: [
            VTOnTapEffect(
              onTap: () async {
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
                    );
                  },
                ).then((_) {
                  ScaffoldMessenger.of(askForNameScaffoldKey.currentContext!)
                      .removeCurrentSnackBar();
                });
              },
              effects: [
                VTOnTapEffectItem(
                  effectType: VTOnTapEffectType.touchableOpacity,
                  active: 0.5,
                )
              ],
              child: _headerTexts,
            ),
            VTOnTapEffect(
              onTap: () async {
                final homeNotifier = context.read(homeScreenProvider);
                final years = homeNotifier.availableYears..sort();
                showWDialog(
                  context: context,
                  child: buildYearChooserDialog(years, context),
                );
              },
              effects: [
                VTOnTapEffectItem(
                  effectType: VTOnTapEffectType.touchableOpacity,
                  active: 0.5,
                )
              ],
              child: _yearText,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildYearChooserDialog(List<int> years, BuildContext context) {
    final notifier = context.read(homeScreenProvider);

    return Dialog(
      child: SingleChildScrollView(
        child: Wrap(
          children: List.generate(
            years.length,
            (index) {
              final selected = notifier.currentSelectedYear == years[index];
              return Column(
                children: [
                  ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(
                          index == 0 ? ConfigConstant.radius1 : 0,
                        ),
                        bottom: Radius.circular(
                          index == years.length - 1
                              ? ConfigConstant.radius1
                              : 0,
                        ),
                      ),
                    ),
                    title: Text(
                      years[index].toString(),
                      textAlign: TextAlign.center,
                    ),
                    selected: selected,
                    onTap: () async {
                      onTapVibrate();
                      notifier.setCurrentSelectedYear(years[index]);
                      Navigator.of(context).pop();
                    },
                  ),
                  if (index != years.length - 1) const Divider(height: 0),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
