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
    this.controller,
    this.color,
    this.padding = const EdgeInsets.symmetric(vertical: 8.0, horizontal: 0),
  }) : super(key: key);

  final double height;
  final Color color;
  final List<String> tabs;
  final TabController controller;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final tabController = this.controller ?? DefaultTabController.of(context);
    final scrollController = useScrollController();

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
        color: color,
        child: Container(
          height: height + padding.top + padding.bottom,
          alignment: Alignment.center,
          child: Container(
            height: height,
            child: WCopiedTabBar(
              physics: const BouncingScrollPhysics(),
              scrollController: scrollController,
              controller: tabController,
              isScrollable: true,
              onTap: (index) {},
              unselectedLabelColor: Theme.of(context).textTheme.bodyText1.color,
              labelColor: Colors.white,
              labelStyle: Theme.of(context).textTheme.bodyText1,
              indicator: WTabIndicator(
                borderSide: BorderSide(width: height),
              ),
              tabs: tabs
                  .map(
                    (text) => Padding(
                      padding: const EdgeInsets.only(
                        left: 8.0,
                        right: 8.0,
                        top: 2.0,
                      ),
                      child: Text(text),
                    ),
                  )
                  .toList(),
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
