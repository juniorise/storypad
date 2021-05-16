import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:storypad/mixins/change_notifier_mixin.dart';

class HeaderNotifier extends ChangeNotifier with ChangeNotifierMixin {
  double _headerPaddingTop = 0;
  double get headerPaddingTop => this._headerPaddingTop;
  set headerPaddingTop(double value) {
    if (this._headerPaddingTop == value) return;
    this._headerPaddingTop = value;
    notifyListeners();
  }

  double _headerHeight = 0;
  double get headerHeight => this._headerHeight;
  set headerHeight(double value) {
    if (this._headerHeight == value) return;
    this._headerHeight = value;
    notifyListeners();
  }
}

final headerProvider = ChangeNotifierProvider.autoDispose<HeaderNotifier>(
  (ref) {
    return HeaderNotifier();
  },
);
