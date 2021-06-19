import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AppHelper {
  AppHelper._internal();
  static const DAY = const ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

  static DateFormat toNameOfMonth(BuildContext context, {bool fullName = false}) {
    final DateFormat format =
        fullName ? DateFormat.MMMM(context.locale.languageCode) : DateFormat.MMM(context.locale.languageCode);
    return format;
  }

  static DateFormat toFullNameOfMonth(BuildContext context) {
    final DateFormat format = DateFormat.MMMM(context.locale.languageCode);
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

  static DateFormat yM(BuildContext context) {
    return DateFormat.yMMMM(context.locale.languageCode);
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

  static bool isEmail(String string) {
    // Null or empty string is invalid
    if (string.isEmpty) {
      return false;
    }

    const pattern = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
    final regExp = RegExp(pattern);

    if (!regExp.hasMatch(string)) {
      return false;
    }
    return true;
  }

  static DateTime? dateTimeFromIntMap({
    Map<dynamic, dynamic>? json,
    String? key,
  }) {
    if (key == null) return null;
    if (json == null) return null;

    if (json.containsKey(key) && json[key] is int) {
      return DateTime.fromMillisecondsSinceEpoch(json[key]);
    } else {
      return null;
    }
  }

  static int? intFromDateTime({DateTime? dateTime}) {
    if (dateTime == null) return null;
    return dateTime.millisecondsSinceEpoch;
  }

  static bool boolFromIntMap({
    Map<dynamic, dynamic>? json,
    String? key,
  }) {
    if (key == null) return false;
    if (json == null) return false;

    if (json.containsKey(key) && json[key] is int) {
      return json[key] == 1 ? true : false;
    } else {
      return false;
    }
  }

  static bool? boolFromInt(int? value) {
    if (value == null) return false;
    return value == 1 ? true : false;
  }

  static int? intFromBool(bool? value) {
    if (value == null) return 0;
    return value ? 1 : 0;
  }
}
