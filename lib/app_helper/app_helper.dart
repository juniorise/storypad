import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AppHelper {
  static const DAY = const ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

  static DateFormat toNameOfMonth(BuildContext context) {
    final DateFormat format = DateFormat.MMM(context.locale.languageCode);
    return format;
  }

  static DateFormat toYear(BuildContext context) {
    final DateFormat format = DateFormat.y(context.locale.languageCode);
    return format;
  }

  static DateFormat toDay(BuildContext context) {
    final DateFormat format = DateFormat.E(context.locale.languageCode);
    return format;
  }

  static DateFormat toIntDay(BuildContext context) {
    final DateFormat format = DateFormat.d(context.locale.languageCode);
    return format;
  }

  static DateFormat dateFormat(BuildContext context) {
    return DateFormat.yMd(context.locale.languageCode);
  }

  static DateFormat timeFormat(BuildContext context) {
    return DateFormat.jm(context.locale.languageCode);
  }

  static int dayOfWeek(BuildContext context, DateTime dateTime) {
    final result = DateFormat.E("en").format(dateTime);
    for (int i = 0; i < DAY.length; i++) {
      if (result == DAY[i]) return i == 0 ? 7 : i;
    }
    return 1;
  }
}
