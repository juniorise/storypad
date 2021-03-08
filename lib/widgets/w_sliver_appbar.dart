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

    final _headerTexts = AnimatedContainer(
      width: notifier.headlineWidth == 0
          ? 0
          : MediaQuery.of(context).size.width -
              notifier.headlineWidth -
              16 * 2 -
              8.0,
      duration: const Duration(milliseconds: 250),
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
                    onTap: () {
                      callback();
                    },
                    child: IconButton(
                      icon: Icon(Icons.arrow_left),
                      highlightColor: Theme.of(context).disabledColor,
                      iconSize: 24,
                      onPressed: () {
                        callback();
                      },
                    ),
                  ),
                ),
              Container(
                padding: EdgeInsets.only(left: this.callback != null ? 28 : 0),
                child: Text(
                  "ជួបបុរសក្នុងក្តីស្រមៃដកដកថដកកក",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _headerStyle.copyWith(color: _theme.primaryColor),
                ),
              ),
            ],
          ),
          Text(
            "ចង់សរសេរអីដែរថ្ងៃនេះ?",
            style: _textTheme.bodyText1,
          )
        ],
      ),
    );

    final _yearText = MeasureSize(
      onChange: (Size size) {
        notifier.setHeadlineWidth(size.width);
      },
      child: Text(
        AppHelper.toYear(context).format(
          DateTime.now(),
        ),
        style: _textTheme.headline2.copyWith(color: _theme.disabledColor),
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
