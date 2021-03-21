import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class TabControllerNotifier with ChangeNotifier {
  final TabController controller;
  int _currentIndex = 0;

  TabControllerNotifier(this.controller) {
    this._currentIndex = controller.index;
    print(currentIndex);
    notifyListeners();

    controller.addListener(() {
      this._currentIndex = controller.index;
      print(this.currentIndex);
      notifyListeners();
    });
  }

  int get currentIndex => this._currentIndex;
}

final tabControllerProvider =
    ChangeNotifierProvider.family<TabControllerNotifier, TabController>(
  (ref, controller) {
    return TabControllerNotifier(controller);
  },
);
