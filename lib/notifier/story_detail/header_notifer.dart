import 'package:flutter/cupertino.dart';
import 'package:storypad/notifier/base_notifier.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class HeaderNotifier extends BaseNotifier {
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
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      _inited = true;
      notifyListeners();
    });
  }

  bool _inited = false;
  bool get inited => this._inited;
}

final headerProvider = ChangeNotifierProvider.autoDispose<HeaderNotifier>(
  (ref) {
    return HeaderNotifier();
  },
);
