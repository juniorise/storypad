import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:write_story/app_helper/measure_size.dart';
import 'package:write_story/notifier/appbar_notifier.dart';
import 'package:write_story/notifier/user_model_notifier.dart';
import 'package:write_story/screens/ask_for_name_sheet.dart';
import 'package:write_story/widgets/vt_ontap_effect.dart';
import 'package:write_story/widgets/w_tabbar.dart';

class WSliverAppBar extends HookWidget {
  const WSliverAppBar({
    Key key,
    @required this.titleText,
    @required this.subtitleText,
    @required this.statusBarHeight,
    @required this.isInit,
    this.tabs,
    this.backgroundText,
    this.tabController,
  }) : super(key: key);

  final double statusBarHeight;
  final bool isInit;
  final List<String> tabs;
  final String titleText;
  final String subtitleText;
  final String backgroundText;
  final TabController tabController;

  @override
  Widget build(BuildContext context) {
    final notifier = useProvider(appBarProvider);
    final controller = tabController ?? DefaultTabController.of(context);

    return SliverAppBar(
      floating: true,
      pinned: true,
      forceElevated: true,
      elevation: isInit ? 0.5 : 0,
      backgroundColor: Theme.of(context).backgroundColor,
      expandedHeight: kToolbarHeight * 2.8,
      centerTitle: false,
      automaticallyImplyLeading: false,
      flexibleSpace: buildFlexibleSpaceBar(
        context: context,
        notifier: notifier,
      ),
      bottom: this.tabs != null && tabs.isNotEmpty
          ? WTabBar(
              controller: controller,
              height: 40,
              backgroundColor: Theme.of(context).backgroundColor,
              tabs: tabs,
              isInit: isInit,
            )
          : null,
    );
  }

  FlexibleSpaceBar buildFlexibleSpaceBar({
    BuildContext context,
    AppBarNotifier notifier,
  }) {
    final _theme = Theme.of(context);
    final _textTheme = _theme.textTheme;
    final _headerStyle = _textTheme.headline4;

    final _inited = notifier.headlineWidth != 0;
    double offsetX = _inited ? 0.0 : -8.0;

    final leftSideWidth = notifier.headlineWidth != 0
        ? MediaQuery.of(context).size.width -
            16 * 2 -
            notifier.headlineWidth -
            16
        : kToolbarHeight * 2;

    final _notifier = context.read(userModelProvider);

    final _headerTexts = AnimatedOpacity(
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
              this.titleText + "${_notifier.user.nickname}",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: _headerStyle.copyWith(color: _theme.primaryColor),
            ),
          ),
          AnimatedOpacity(
            opacity: _inited ? 1 : 0,
            duration: const Duration(milliseconds: 1000),
            curve: Curves.easeInQuad,
            child: AnimatedContainer(
              curve: Curves.easeInOutQuad,
              duration: const Duration(milliseconds: 500),
              width: leftSideWidth,
              child: Text(
                this.subtitleText,
                style: _textTheme.bodyText1,
                overflow: TextOverflow.fade,
              ),
            ),
          )
        ],
      ),
    );

    final _yearText = this.backgroundText != null
        ? AnimatedOpacity(
            duration: Duration(milliseconds: 1000),
            curve: Curves.easeInQuad,
            opacity: _inited ? 1 : 0,
            child: MeasureSize(
              onChange: (Size size) {
                notifier.setHeadlineWidth(size.width);
              },
              child: Text(
                this.backgroundText,
                style:
                    _textTheme.headline2.copyWith(color: _theme.disabledColor),
              ),
            ),
          )
        : null;

    final _padding = const EdgeInsets.symmetric(
      horizontal: 16.0,
      vertical: 0.0,
    );

    return FlexibleSpaceBar(
      background: Padding(
        padding: _padding.copyWith(top: 0, bottom: 16),
        child: Stack(
          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
          // crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            VTOnTapEffect(
              onTap: () async {
                showModalBottomSheet(
                  isDismissible: false,
                  context: context,
                  enableDrag: true,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) {
                    return AskForNameSheet();
                  },
                );
              },
              effects: [
                VTOnTapEffectItem(
                  effectType: VTOnTapEffectType.touchableOpacity,
                  active: 0.5,
                )
              ],
              child: _headerTexts,
            ),
            Positioned(
                  right: 0,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    alignment: Alignment.centerRight,
                    decoration: BoxDecoration(color: Colors.white),
                    child: _yearText,
                  ),
                ) ??
                const SizedBox(),
          ],
        ),
      ),
    );
  }
}
