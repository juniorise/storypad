import 'package:flutter/material.dart';
import 'package:storypad/configs/theme_config.dart';
import 'package:easy_localization/easy_localization.dart' as easy;
import 'package:storypad/constants/app_constant.dart';

class TextHelper {
  static double getMaxHeight(BuildContext context) {
    /// get text max height
    final TextStyle? body1 = Theme.of(context).textTheme.bodyText1;
    List<double> heights = [];
    for (var i = 0; i < AppConstant.fontFamilyFallbackDefault.length; i++) {
      final String example = ThemeConfig.fontFamilyFallbackExample[i];
      heights.add(TextHelper.calculateTextHeight(
        example,
        body1?.fontSize,
        body1!.fontWeight!,
        50,
        1,
        context.locale,
      ));
    }

    heights.sort();
    final double maxHeight = heights.last / body1!.fontSize!;
    return maxHeight;
  }

  static double calculateTextHeight(
    String value,
    fontSize,
    FontWeight fontWeight,
    double maxWidth,
    int maxLines,
    Locale locale,
  ) {
    final fontFamilyFallback = AppConstant.fontFamilyFallbackDefault.entries.map((e) => e.value).toList();
    TextPainter painter = TextPainter(
      ///AUTO: If the locale is not specified for Huawei mobile phones, the text height calculated by this method is smaller than the system calculation.
      locale: locale,
      maxLines: maxLines,
      textDirection: TextDirection.ltr,
      text: TextSpan(
        text: value,
        style: TextStyle(
          fontWeight: fontWeight,
          fontSize: fontSize,
          fontFamilyFallback: fontFamilyFallback,
        ),
      ),
    );
    painter.layout(maxWidth: maxWidth);

    ///The width of the text: painter.width
    return painter.height;
  }
}
