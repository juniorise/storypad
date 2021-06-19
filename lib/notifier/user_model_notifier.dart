import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:storypad/services/local_storages/databases/user_database.dart';
import 'package:storypad/notifier/base_notifier.dart';
import 'package:storypad/models/user_model.dart';
import 'package:storypad/services/authentication/authentication_service.dart';

class UserModelNotifier extends BaseNotifier {
  UserDatabase db = UserDatabase();
  bool? alreadyHasUser;

  UserModel? user;
  String? nickname;
  DateTime? dob;

  bool isInit = false;
  bool firstTime = true;

  setInit() {
    this.isInit = true;
    notifyListeners();
  }

  Future<void> load({bool inited = true}) async {
    final result = await db.fetchOne();

    if (result != null && result is UserModel) {
      this.user = result;
      firstTime = true;
      alreadyHasUser = true;
    } else {
      firstTime = false;
      alreadyHasUser = false;
    }

    if (!inited) {
      final auth = AuthenticationService();
      if (await auth.googleSignIn.isSignedIn()) auth.signInSilently();
    }

    notifyListeners();
  }

  Future<bool> setUser(UserModel user) async {
    if (this.alreadyHasUser == true) {
      await db.update(
        record: user,
        where: "device_id = '${user.deviceId}'",
      );
    } else {
      await db.create(record: user);
    }

    if (db.success == true) await load();
    return db.success == true;
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
  return UserModelNotifier()..load(inited: false);
});
