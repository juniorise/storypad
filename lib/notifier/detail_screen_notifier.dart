import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class DetailScreenNotifier extends ChangeNotifier {
  bool clickedOutside = false;

  setClickedOutside(bool clickedOutside) {
    if (this.clickedOutside != clickedOutside) {
      this.clickedOutside = clickedOutside;
      notifyListeners();
    }
  }
}

final detailScreenNotifier = ChangeNotifierProvider<DetailScreenNotifier>(
  (ref) {
    return DetailScreenNotifier();
  },
);
