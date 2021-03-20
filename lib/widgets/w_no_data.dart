import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class WNoData extends StatelessWidget {
  const WNoData({
    Key key,
    @required this.monthName,
  }) : super(key: key);

  final String monthName;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
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
                Image.asset(
                  "assets/illustrations/thinking-woman.png",
                  width: imageSize,
                  height: imageSize,
                ),
                const SizedBox(height: 16.0),
                Container(
                  width: constrant.maxWidth / 2,
                  child: Text(
                    tr(
                      "click_plus_to_add_data_to",
                      namedArgs: {'month': monthName},
                    ),
                    textAlign: tablet ? TextAlign.start : TextAlign.center,
                    style: TextStyle(
                        color: Theme.of(context)
                            .textTheme
                            .bodyText1
                            .color
                            .withOpacity(0.5)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
