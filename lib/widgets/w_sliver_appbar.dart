import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:write_your_story/app_helper/measure_size.dart';
import 'package:write_your_story/notifier/appbar_notifier.dart';
import 'package:write_your_story/widgets/vt_ontap_effect.dart';
import 'package:write_your_story/widgets/w_tabbar.dart';

class WSliverAppBar extends HookWidget {
  const WSliverAppBar({
    Key key,
    @required this.tabs,
    @required this.titleText,
    @required this.subtitleText,
    @required this.statusBarHeight,
    @required this.backgroundText,
    this.callback,
  }) : super(key: key);

  final double statusBarHeight;
  final Function callback;
  final List<String> tabs;
  final String titleText;
  final String subtitleText;
  final String backgroundText;

  @override
  Widget build(BuildContext context) {
    final notifier = useProvider(appBarProvider);

    return SliverAppBar(
      floating: true,
      pinned: true,
      snap: true,
      forceElevated: true,
      elevation: 1,
      backgroundColor: Theme.of(context).backgroundColor,
      expandedHeight: kToolbarHeight * 2.8,
      centerTitle: false,
      automaticallyImplyLeading: false,
      flexibleSpace: buildFlexibleSpaceBar(
        context: context,
        notifier: notifier,
      ),
      bottom: WTabBar(
        height: 40,
        color: Theme.of(context).backgroundColor,
        tabs: tabs,
      ),
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

    if (this.callback != null) {
      offsetX = -16.0;
    }
    final _headerTexts = Expanded(
      child: AnimatedOpacity(
        opacity: _inited ? 1 : 0,
        curve: Curves.easeInOutQuad,
        duration: const Duration(milliseconds: 1000),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              children: [
                AnimatedContainer(
                  curve: Curves.easeInOutQuad,
                  transform: Matrix4.identity()..translate(offsetX, 0.0),
                  duration: const Duration(milliseconds: 500),
                  child: Container(
                    padding: const EdgeInsets.only(right: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 24),
                        if (callback != null)
                          Container(
                            height: 24,
                            child: VTOnTapEffect(
                              effects: [
                                VTOnTapEffectItem(
                                  effectType: VTOnTapEffectType.scaleDown,
                                  active: 0.8,
                                ),
                                VTOnTapEffectItem(
                                  effectType:
                                      VTOnTapEffectType.touchableOpacity,
                                  active: 0.8,
                                )
                              ],
                              child: IconButton(
                                highlightColor: _theme.disabledColor,
                                iconSize: 20,
                                padding: EdgeInsets.zero,
                                onPressed: callback,
                                icon: Icon(
                                  Icons.arrow_left,
                                  color: _theme.primaryColor,
                                ),
                              ),
                            ),
                          ),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 350),
                          transform: Matrix4.identity()
                            ..translate(
                                this.callback != null ? -4.0 : 0.0, 0.0),
                          child: Text(
                            this.titleText,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: _headerStyle.copyWith(
                                color: _theme.primaryColor),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            AnimatedOpacity(
              opacity: _inited ? 1 : 0,
              duration: const Duration(milliseconds: 1000),
              curve: Curves.easeInQuad,
              child: Text(
                this.subtitleText,
                style: _textTheme.bodyText1,
              ),
            )
          ],
        ),
      ),
    );

    final _yearText = AnimatedOpacity(
      duration: Duration(milliseconds: 1000),
      curve: Curves.easeInQuad,
      opacity: _inited ? 1 : 0,
      child: MeasureSize(
        onChange: (Size size) {
          notifier.setHeadlineWidth(size.width);
        },
        child: Text(
          this.backgroundText,
          style: _textTheme.headline2.copyWith(color: _theme.disabledColor),
        ),
      ),
    );

    final _padding = const EdgeInsets.symmetric(
      horizontal: 16.0,
      vertical: 0.0,
    );

    return FlexibleSpaceBar(
      background: Padding(
        padding: _padding.copyWith(top: 0, bottom: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _headerTexts,
            _yearText,
          ],
        ),
      ),
    );
  }
}
