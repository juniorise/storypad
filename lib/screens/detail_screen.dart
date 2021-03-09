import 'package:flutter/material.dart';
import 'package:write_your_story/app_helper/app_helper.dart';
import 'package:write_your_story/examples/stories_list_by_day_data.dart';
import 'package:write_your_story/models/story_list_model.dart';
import 'package:write_your_story/models/story_model.dart';
import 'package:write_your_story/widgets/vt_tab_view.dart';
import 'package:write_your_story/widgets/w_sliver_appbar.dart';

class StoryDetailScreen extends StatelessWidget {
  const StoryDetailScreen({
    Key key,
    @required this.callback,
    @required this.index,
    @required this.storyList,
    @required this.storyListByMonth,
  }) : super(key: key);

  final VoidCallback callback;
  final int index;
  final List<StoryModel> storyList;
  final StoryListModel storyListByMonth;

  @override
  Widget build(BuildContext context) {
    double statusBarHeight = MediaQuery.of(context).padding.top;

    final _storyList =
        globalStoryListByDayId[storyListByMonth.childrenId[index]];

    final headerSliverBuilder = (context, _) {
      return [
        WSliverAppBar(
          statusBarHeight: statusBarHeight,
          backgroundText: AppHelper.toNameOfMonth(context).format(
            storyList[index].createOn,
          ),
          callback: callback,
          titleText: "ថយក្រោយ",
          subtitleText: "ចង់សរសេរអីដែរថ្ងៃនេះ?",
          tabs: List.generate(
            storyListByMonth.childrenId.length,
            (index) {
              return _storyList.createOn.day.toString();
            },
          ),
        ),
      ];
    };

    return DefaultTabController(
      length: storyListByMonth.childrenId.length,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        body: NestedScrollView(
          headerSliverBuilder: headerSliverBuilder,
          body: VTTabView(
            children: List.generate(
              storyListByMonth.childrenId.length,
              (index) {
                return ListView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  children: storyList.map(
                    (e) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8.0),
                        child: Material(
                          elevation: 0.5,
                          child: Container(
                            color: Colors.white,
                            child: Text(e.paragraph),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 8.0,
                            ),
                          ),
                        ),
                      );
                    },
                  ).toList(),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
