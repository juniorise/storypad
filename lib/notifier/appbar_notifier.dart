import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:storypad/mixins/change_notifier_mixin.dart';

class AppBarNotifier extends ChangeNotifier with ChangeNotifierMixin {
  double headlineWidth = 0;
  double headerHeight = 0;

  setHeadlineWidth(double width) {
    this.headlineWidth = width;
    notifyListeners();
  }

  void setHeaderHeight(double height) {
    this.headerHeight = height;
    notifyListeners();
  }
}

final appBarProvider = ChangeNotifierProvider<AppBarNotifier>((ref) {
  return AppBarNotifier();
});
