import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:write_story/services/authentication_service.dart';

class AuthenticatoinNotifier extends ChangeNotifier {
  AuthenticationService? service = AuthenticationService();
  User? user;
  bool isAccountSignedIn = false;

  bool _loading = false;

  load() {
    user = service?.user;
    if (user != null) {
      isAccountSignedIn = true;
    } else {
      isAccountSignedIn = false;
    }
    notifyListeners();
  }

  setLoading(bool value) {
    this._loading = value;
    notifyListeners();
  }

  Future<bool> logAccount() async {
    setLoading(true);

    bool? success = await service?.signInWithGoogle();
    await load();

    setLoading(false);
    if (success == true) {
      return true;
    } else {
      return false;
    }
  }

  Future<void> signOut() async {
    await service?.signOut();
    load();
  }

  bool get loading => this._loading;
}

final authenticatoinProvider = ChangeNotifierProvider<AuthenticatoinNotifier>(
  (ref) {
    return AuthenticatoinNotifier()..load();
  },
);
