import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class WNoData extends StatelessWidget {
  const WNoData({
    Key? key,
    required this.monthName,
  }) : super(key: key);

  final String monthName;

  @override
  Widget build(BuildContext context) {
    final deprecated = LayoutBuilder(
      builder: (context, constrant) {
        bool tablet = constrant.maxWidth > constrant.maxHeight;

        final imageSize =
            tablet ? constrant.maxHeight : constrant.maxWidth / 1.5;
        return SingleChildScrollView(
          child: Container(
            height: constrant.maxHeight,
            width: constrant.maxWidth,
            padding: EdgeInsets.only(bottom: tablet ? 0 : kToolbarHeight * 3),
            child: Wrap(
              direction: tablet ? Axis.vertical : Axis.vertical,
              crossAxisAlignment:
                  tablet ? WrapCrossAlignment.start : WrapCrossAlignment.center,
              alignment: WrapAlignment.center,
              runAlignment: tablet ? WrapAlignment.start : WrapAlignment.center,
              children: [
                ImageIcon(
                  AssetImage("assets/illustrations/thinking-woman.png"),
                  size: imageSize,
                ),
                const SizedBox(height: 16.0),
                Container(
                  width: constrant.maxWidth / 2,
                  child: Text(
                    tr(
                      "msg.story.empty",
                      namedArgs: {'MONTH_NAME': monthName},
                    ),
                    textAlign: tablet ? TextAlign.start : TextAlign.center,
                    style: TextStyle(
                        color: Theme.of(context)
                            .textTheme
                            .bodyText1!
                            .color!
                            .withOpacity(0.6)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
    print(deprecated);
    return LayoutBuilder(
      builder: (context, constrant) {
        bool tablet = constrant.maxWidth > constrant.maxHeight;

        return Center(
          child: Container(
            width: constrant.maxWidth / 2,
            child: Text(
              tr(
                "msg.story.empty",
                namedArgs: {'MONTH_NAME': monthName},
              ),
              textAlign: tablet ? TextAlign.start : TextAlign.center,
              style: Theme.of(context).textTheme.bodyText1?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onBackground
                        .withOpacity(0.6),
                  ),
            ),
          ),
        );
      },
    );
  }
}
