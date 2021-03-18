import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:write_story/database/w_database.dart';

class HomeScreenNotifier extends ChangeNotifier {
  final WDatabase wDatabase = WDatabase.instance;
  bool isInit = false;

  HomeScreenNotifier() {
    if (!isInit) {
      Future.delayed(Duration(milliseconds: 1000)).then((value) {
        setIsInit(true);
      });
    }
  }

  setIsInit(bool value) {
    this.isInit = value;
    notifyListeners();
  }
}

final homeScreenProvider = ChangeNotifierProvider<HomeScreenNotifier>((ref) {
  return HomeScreenNotifier();
});
