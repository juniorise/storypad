import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class HomeScreenNotifier extends ChangeNotifier {
  double remainHeight = 0;
  bool loading = false;

  setRemainHeight(double remainHeight) {
    this.remainHeight = remainHeight;
    notifyListeners();
  }
}

final homeScreenProvider = ChangeNotifierProvider<HomeScreenNotifier>((ref) {
  return HomeScreenNotifier();
});
