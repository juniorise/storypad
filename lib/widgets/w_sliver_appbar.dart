import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:write_your_story/app_helper/app_helper.dart';
import 'package:write_your_story/app_helper/measure_size.dart';
import 'package:write_your_story/notifier/appbar_notifier.dart';
import 'package:write_your_story/widgets/vt_ontap_effect.dart';
import 'package:write_your_story/widgets/w_tabbar.dart';

class WSliverAppBar extends HookWidget {
  const WSliverAppBar({
    Key key,
    @required this.statusBarHeight,
    this.callback,
  }) : super(key: key);

  final double statusBarHeight;
  final Function callback;

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
      expandedHeight: kToolbarHeight * 2.5,
      centerTitle: false,
      automaticallyImplyLeading: false,
      flexibleSpace: buildFlexibleSpaceBar(
        statusBarHeight: statusBarHeight,
        context: context,
        notifier: notifier,
      ),
      bottom: WTabBar(
        height: 40,
        color: Theme.of(context).backgroundColor,
        tabs: List.generate(
          12,
          (index) {
            return AppHelper.toNameOfMonth(context).format(
              DateTime(2020, index + 1),
            );
          },
        ),
      ),
    );
  }

  FlexibleSpaceBar buildFlexibleSpaceBar({
    double statusBarHeight,
    BuildContext context,
    AppBarNotifier notifier,
  }) {
    final _theme = Theme.of(context);
    final _textTheme = _theme.textTheme;
    final _headerStyle = _textTheme.headline4;

    final _inited = notifier.headlineWidth != 0;
    final _headerTexts = Expanded(
      child: AnimatedOpacity(
        opacity: _inited ? 1 : 0,
        curve: Curves.easeInOutQuad,
        duration: const Duration(milliseconds: 1000),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: statusBarHeight),
            Stack(
              children: [
                if (callback != null)
                  Transform.translate(
                    offset: const Offset(-16.0, -3.0),
                    child: VTOnTapEffect(
                      effects: [
                        VTOnTapEffectItem(
                          effectType: VTOnTapEffectType.scaleDown,
                          active: 0.8,
                        ),
                        VTOnTapEffectItem(
                          effectType: VTOnTapEffectType.touchableOpacity,
                          active: 0.8,
                        )
                      ],
                      child: IconButton(
                        highlightColor: _theme.disabledColor,
                        iconSize: 24,
                        onPressed: callback,
                        icon: Icon(
                          Icons.arrow_left,
                          color: _theme.primaryColor,
                        ),
                      ),
                    ),
                  ),
                AnimatedContainer(
                  curve: Curves.easeInOutQuad,
                  transform: Matrix4.identity()
                    ..translate(_inited ? 0.0 : -8.0, 0.0),
                  duration: const Duration(milliseconds: 500),
                  child: Container(
                    padding: EdgeInsets.only(
                      left: this.callback != null ? 28 : 0,
                      right: 10,
                    ),
                    child: Text(
                      "ជួបបុរសក្នុងក្តីស្រមៃដកដកថដកកក",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: _headerStyle.copyWith(color: _theme.primaryColor),
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
                "ចង់សរសេរអីដែរថ្ងៃនេះ?",
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
          AppHelper.toYear(context).format(
            DateTime.now(),
          ),
          style: _textTheme.headline2.copyWith(color: _theme.disabledColor),
        ),
      ),
    );

    final _padding = const EdgeInsets.symmetric(
      horizontal: 16.0,
      vertical: 8.0,
    );

    return FlexibleSpaceBar(
      background: Padding(
        padding: _padding,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _headerTexts,
            _yearText,
          ],
        ),
      ),
    );
  }
}
