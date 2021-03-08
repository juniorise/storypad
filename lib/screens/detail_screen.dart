import 'package:flutter/material.dart';
import 'package:write_your_story/widgets/vt_tab_view.dart';
import 'package:write_your_story/widgets/w_sliver_appbar.dart';

class StoryDetailScreen extends StatelessWidget {
  const StoryDetailScreen({
    Key key,
    @required this.callback,
  }) : super(key: key);

  final VoidCallback callback;

  @override
  Widget build(BuildContext context) {
    double statusBarHeight = MediaQuery.of(context).padding.top;

    final headerSliverBuilder = (context, _) {
      return [
        WSliverAppBar(
          statusBarHeight: statusBarHeight,
          backgroundText: "មករា",
          callback: callback,
          titleText: "ថយក្រោយ",
          subtitleText: "ចង់សរសេរអីដែរថ្ងៃនេះ?",
          tabs: List.generate(12, (index) => "$index"),
        ),
      ];
    };

    return DefaultTabController(
      length: 12,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        body: NestedScrollView(
          headerSliverBuilder: headerSliverBuilder,
          body: VTTabView(
            children: List.generate(
              12,
              (index) {
                return Center(child: Text("WOWOW"));
              },
            ),
          ),
        ),
      ),
    );
  }
}
