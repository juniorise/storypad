import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:write_your_story/widgets/w_copied_tab_bar.dart';
import 'package:write_your_story/widgets/w_tab_indicator.dart';

class WTabBar extends HookWidget implements PreferredSizeWidget {
  WTabBar({
    Key key,
    @required this.height,
    @required this.tabs,
    @required this.isInit,
    this.controller,
    this.backgroundColor,
    this.padding = const EdgeInsets.symmetric(vertical: 8.0, horizontal: 0),
  }) : super(key: key);

  final double height;
  final bool isInit;
  final Color backgroundColor;
  final List<String> tabs;
  final TabController controller;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final tabController = this.controller ?? DefaultTabController.of(context);
    final unselectedLabelColor = Theme.of(context).textTheme.bodyText1.color;

    return Theme(
      data: Theme.of(context),
      child: Container(
        padding: EdgeInsets.fromLTRB(
          padding.left,
          padding.top,
          padding.right,
          padding.bottom,
        ),
        height: height + padding.top + padding.bottom,
        color: backgroundColor,
        child: Container(
          height: height + padding.top + padding.bottom,
          alignment: Alignment.center,
          child: Container(
            height: height,
            width: double.infinity,
            child: WCopiedTabBar(
              physics: const BouncingScrollPhysics(),
              controller: tabController,
              isScrollable: true,
              onTap: (index) {},
              unselectedLabelColor: unselectedLabelColor,
              labelColor: isInit ? backgroundColor : unselectedLabelColor,
              labelStyle: Theme.of(context).textTheme.bodyText1,
              indicator: WTabIndicator(
                borderSide: BorderSide(
                  width: height,
                  color: isInit ? unselectedLabelColor : backgroundColor,
                ),
              ),
              tabs: List.generate(
                tabs.length,
                (index) {
                  final text = tabs[index];
                  return AnimatedOpacity(
                    duration: Duration(milliseconds: (index + 1) * 350),
                    opacity: isInit ? 1 : 0,
                    child: Padding(
                      child: Text(text),
                      padding: const EdgeInsets.only(
                        left: 8.0,
                        right: 8.0,
                        top: 2.0,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize {
    return Size.fromHeight(
      this.height + padding.top + padding.bottom,
    );
  }
}
