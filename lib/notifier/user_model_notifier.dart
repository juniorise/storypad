import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:storypad/services/storages/local_storages/w_database.dart';
import 'package:storypad/notifier/base_notifier.dart';
import 'package:storypad/models/user_model.dart';
import 'package:storypad/services/authentication/authentication_service.dart';

class UserModelNotifier extends BaseNotifier {
  final WDatabase wDatabase = WDatabase.instance;
  bool? alreadyHasUser;

  UserModel? user;
  String? nickname;
  DateTime? dob;

  bool isInit = false;
  bool loading = true;

  bool firstTime = true;

  setInit() {
    this.isInit = true;
    notifyListeners();
  }

  Future<void> load() async {
    final result = await wDatabase.userModel();

    if (result != null && result is UserModel) {
      this.user = result;
      firstTime = true;
      alreadyHasUser = true;
    } else {
      firstTime = false;
      alreadyHasUser = false;
    }

    final auth = AuthenticationService();
    try {
      if (await auth.googleSignIn.isSignedIn()) {
        auth.signInSilently();
      }
    } catch (e) {}
    loading = false;
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
