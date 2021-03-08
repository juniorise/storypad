import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:write_your_story/app_helper/app_helper.dart';
import 'package:write_your_story/colors.dart';
import 'package:write_your_story/examples/stories_data.dart';
import 'package:write_your_story/examples/stories_list_data.dart';
import 'package:write_your_story/models/story_list_model.dart';
import 'package:write_your_story/models/story_model.dart';
import 'package:write_your_story/widgets/vt_ontap_effect.dart';
import 'package:write_your_story/widgets/vt_tab_view.dart';
import 'package:write_your_story/widgets/w_tabbar.dart';

class HomeScreen extends HookWidget {
  @override
  Widget build(BuildContext context) {
    double statusBarHeight = MediaQuery.of(context).padding.top;

    const padding = const EdgeInsets.symmetric(
      horizontal: 16.0,
      vertical: 8.0,
    );

    final headerSliverBuilder = (context, _) {
      return [buildSliverAppBar(context, statusBarHeight)];
    };

    final body = VTTabView(
      children: List.generate(
        12,
        (index) {
          return ListView(
            key: Key("$index"),
            physics: ClampingScrollPhysics(),
            padding: padding,
            children: storyListByMonthID["${index + 1}"].childrenId.map(
              (id) {
                return buildStoryList(
                  context,
                  storyListByDayID[id],
                );
              },
            ).toList(),
          );
        },
      ),
    );

    return DefaultTabController(
      length: 12,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        body: NestedScrollView(
          headerSliverBuilder: headerSliverBuilder,
          body: body,
        ),
      ),
    );
  }

  SliverAppBar buildSliverAppBar(BuildContext context, double statusBarHeight) {
    final _listOfMonthTab = WTabBar(
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
    );

    return SliverAppBar(
      floating: true,
      pinned: true,
      snap: true,
      forceElevated: true,
      elevation: 1,
      backgroundColor: Theme.of(context).backgroundColor,
      expandedHeight: kToolbarHeight * 2.5,
      centerTitle: false,
      flexibleSpace: buildFlexibleSpaceBar(
        statusBarHeight: statusBarHeight,
        context: context,
      ),
      bottom: _listOfMonthTab,
    );
  }

  FlexibleSpaceBar buildFlexibleSpaceBar({
    double statusBarHeight,
    BuildContext context,
  }) {
    final _theme = Theme.of(context);
    final _textTheme = _theme.textTheme;
    final _headerStyle = _textTheme.headline4;

    final _headerTexts = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: statusBarHeight),
        Text(
          "សួរស្តី Sothea",
          style: _headerStyle.copyWith(color: _theme.primaryColor),
        ),
        Text(
          "ចង់សរសេរអីដែរថ្ងៃនេះ?",
          style: _textTheme.bodyText1,
        ),
      ],
    );

    final _yearText = Text(
      AppHelper.toYear(context).format(
        DateTime.now(),
      ),
      style: _textTheme.headline2.copyWith(color: _theme.disabledColor),
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

  Widget buildStoryList(BuildContext context, StoryListModel model) {
    int dayOfWeek = AppHelper.dayOfWeek(context, model.createOn);
    final Color containerColor = colorsByDay[dayOfWeek];

    final _leftSide = Column(
      children: [
        Text(
          AppHelper.toDay(context).format(model.createOn),
        ),
        Container(
          child: Text(
            AppHelper.toIntDay(context).format(model.createOn),
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: containerColor,
          ),
        )
      ],
    );

    final _rightSide = Expanded(
      child: Column(
        children: [
          const Divider(thickness: 1, indent: 4.0),
          for (int i = 0; i < model.childrenId.length; i++)
            buildStoryTile(
              context: context,
              story: storyByID[model.childrenId[i]],
              margin: EdgeInsets.only(top: i == 0 ? 8.0 : 0, bottom: 8.0),
            ),
        ],
      ),
    );

    final _sizedBox = const SizedBox(width: 16.0);

    return Container(
      margin: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _leftSide,
          _sizedBox,
          _rightSide,
        ],
      ),
    );
  }

  Widget buildStoryTile({
    @required BuildContext context,
    @required StoryModel story,
    EdgeInsets margin = const EdgeInsets.only(bottom: 8.0),
  }) {
    final int paragraphLength = story.paragraph.length;
    int paragraphMaxLines = 0;

    if (paragraphLength <= 100) {
      paragraphMaxLines = 1;
    }

    if (paragraphLength > 100) {
      paragraphMaxLines = 2;
    }

    if (paragraphLength > 200) {
      paragraphMaxLines = 3;
    }

    final _headerText = Padding(
      padding: const EdgeInsets.only(right: 30),
      child: Text(
        story.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.subtitle1,
        textAlign: TextAlign.start,
      ),
    );

    final _paragraph = Text(
      story.paragraph,
      textAlign: TextAlign.start,
      maxLines: paragraphMaxLines,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: Theme.of(context).textTheme.subtitle2.color.withOpacity(0.6),
      ),
    );

    final _favoriteButtonEffect = [
      VTOnTapEffectItem(
        effectType: VTOnTapEffectType.scaleDown,
        active: 0.9,
      )
    ];

    final _favoriteButton = Positioned(
      right: 0,
      top: 0,
      child: VTOnTapEffect(
        effects: _favoriteButtonEffect,
        child: IconButton(
          onPressed: () {},
          icon: Icon(
            story.isFavorite ? Icons.favorite : Icons.favorite_border_rounded,
            color: Theme.of(context).errorColor,
          ),
        ),
      ),
    );

    final padding = const EdgeInsets.symmetric(
      horizontal: 16.0,
      vertical: 8.0,
    );

    final _tileEffects = [
      VTOnTapEffectItem(
        effectType: VTOnTapEffectType.touchableOpacity,
        active: 0.5,
      )
    ];

    return Container(
      margin: margin,
      child: Stack(
        children: [
          VTOnTapEffect(
            effects: _tileEffects,
            child: Container(
              padding: padding,
              color: Theme.of(context).backgroundColor,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _headerText,
                  _paragraph,
                ],
              ),
            ),
          ),
          _favoriteButton,
        ],
      ),
    );
  }
}
