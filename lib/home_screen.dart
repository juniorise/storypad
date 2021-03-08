import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:write_your_story/w_tabbar.dart';

class AppHelper {
  static DateFormat toMonth(BuildContext context) {
    final DateFormat format = DateFormat.MMM(context.locale.languageCode);
    return format;
  }

  static DateFormat toYear(BuildContext context) {
    final DateFormat format = DateFormat.y(context.locale.languageCode);
    return format;
  }

  static DateFormat dateFormat(BuildContext context) {
    return DateFormat.yMMMMd(context.locale.languageCode);
  }

  static DateFormat timeFormat(BuildContext context) {
    return DateFormat.Hms(context.locale.languageCode);
  }
}

class HomeScreenNotifier extends ChangeNotifier {
  double remainHeight = 0;

  setRemainHeight(double remainHeight) {
    this.remainHeight = remainHeight;
    notifyListeners();
  }
}

final homeScreenProvider = ChangeNotifierProvider<HomeScreenNotifier>((ref) {
  return HomeScreenNotifier();
});

class HomeScreen extends HookWidget {
  @override
  Widget build(BuildContext context) {
    double statusBarHeight = MediaQuery.of(context).padding.top;
    return DefaultTabController(
      length: 12,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        body: NestedScrollView(
          physics: BouncingScrollPhysics(),
          headerSliverBuilder: (context, bo) {
            return [
              SliverAppBar(
                floating: true,
                pinned: true,
                snap: true,
                forceElevated: true,
                elevation: 1,
                backgroundColor: Theme.of(context).backgroundColor,
                expandedHeight: kToolbarHeight * 2.5,
                centerTitle: false,
                flexibleSpace: FlexibleSpaceBar(
                  background: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: statusBarHeight),
                            Text(
                              "សួរស្តី Sothea",
                              style: Theme.of(context)
                                  .textTheme
                                  .headline4
                                  .copyWith(
                                      color: Theme.of(context).primaryColor),
                            ),
                            Text(
                              "ចង់សរសេរអីដែរថ្ងៃនេះ?",
                              style: Theme.of(context).textTheme.bodyText1,
                            ),
                          ],
                        ),
                        Text(
                          AppHelper.toYear(context).format(
                            DateTime.now(),
                          ),
                          style: Theme.of(context)
                              .textTheme
                              .headline2
                              .copyWith(color: Theme.of(context).disabledColor),
                        ),
                      ],
                    ),
                  ),
                ),
                bottom: WTabBar(
                  height: 40,
                  color: Theme.of(context).backgroundColor,
                  tabs: List.generate(
                    12,
                    (index) {
                      final text = AppHelper.toMonth(context).format(
                        DateTime(2020, index + 1),
                      );
                      return text;
                    },
                  ),
                ),
              )
            ];
          },
          body: TabBarView(
            children: List.generate(
              12,
              (index) {
                return Center(
                  child: Text("Testing"),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
