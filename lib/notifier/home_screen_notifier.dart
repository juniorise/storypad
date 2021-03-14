import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:write_story/models/index_model.dart';

class HomeScreenNotifier extends ChangeNotifier {
  /// Since we wrap paragraph with Wrap Widget and when it is click
  /// paragraph start showing unexpected ui.
  ///
  /// Solution is hide them when story tile is clicked
  /// and show them back when navigate or pop back.
  // int lastNavigatorToStoryId = 1;
  bool showParagraphById = true;
  IndexModel lastIndexes;

  /// Use to fade in widget smoother
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

  // setLastNavigatorToStoryId(int value) {
  //   this.lastNavigatorToStoryId = value;
  // }

  setLastIndexesModel(IndexModel lastIndex) {
    this.lastIndexes = lastIndex;
    notifyListeners();
  }

  setShowParagraphById(bool value) {
    this.showParagraphById = value;
    notifyListeners();
  }
}

final homeScreenProvider = ChangeNotifierProvider<HomeScreenNotifier>((ref) {
  return HomeScreenNotifier();
});
