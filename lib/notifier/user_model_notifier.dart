import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:write_story/database/w_database.dart';
import 'package:write_story/models/user_model.dart';

class UserModelNotifier extends ChangeNotifier {
  final WDatabase wDatabase = WDatabase.instance;
  bool loading = false;
  bool alreadyHasUser;

  UserModel user;
  String nickname;
  DateTime dob;

  bool isInit = false;

  setInit() {
    this.isInit = true;
    notifyListeners();
  }

  load() async {
    setLoading(true);
    final result = await wDatabase.userModel();

    if (result != null) {
      this.user = result;
      alreadyHasUser = true;
    } else {
      alreadyHasUser = false;
    }

    setLoading(false);
  }

  Future<bool> setUser(UserModel user) async {
    try {
      await wDatabase.setUserModel(user);
      this.user = user;
      alreadyHasUser = true;
      notifyListeners();

      return true;
    } catch (e) {
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

  setLoading(bool value) {
    this.loading = value;
    notifyListeners();
  }
}

final userModelProvider = ChangeNotifierProvider<UserModelNotifier>((ref) {
  return UserModelNotifier()..load();
});
