import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:write_story/database/w_database.dart';
import 'package:write_story/models/user_model.dart';

class UserModelNotifier extends ChangeNotifier {
  final WDatabase wDatabase = WDatabase.instance;
  bool alreadyHasUser;

  UserModel user;
  String nickname;
  DateTime dob;

  bool isInit = false;

  setInit() {
    this.isInit = true;
    notifyListeners();
  }

  Future<void> load() async {
    final result = await wDatabase.userModel();

    if (result != null) {
      this.user = result;
      alreadyHasUser = true;
    } else {
      alreadyHasUser = false;
    }

    notifyListeners();
  }

  Future<bool> setUser(UserModel user) async {
    final bool success = await wDatabase.setUserModel(user);

    if (success) {
      this.user = user;
      alreadyHasUser = true;
      notifyListeners();
      return true;
    } else {
      alreadyHasUser = true;
      notifyListeners();
      return false;
    }
  }

  setNickname(String nickname) async {
    this.nickname = nickname;
    notifyListeners();
  }

  setDob(DateTime dob) async {
    this.dob = dob;
    notifyListeners();
  }
}

final userModelProvider = ChangeNotifierProvider<UserModelNotifier>((ref) {
  return UserModelNotifier()..load();
});
