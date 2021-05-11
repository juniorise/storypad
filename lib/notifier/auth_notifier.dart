import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:storypad/mixins/change_notifier_mixin.dart';
import 'package:storypad/services/authentication_service.dart';

class AuthenticatoinNotifier extends ChangeNotifier with ChangeNotifierMixin {
  AuthenticationService? service = AuthenticationService();
  User? get user => service?.user;
  bool get isAccountSignedIn => user != null;

  bool _loading = false;

  setLoading(bool value) {
    this._loading = value;
    notifyListeners();
  }

  Future<bool> logAccount() async {
    setLoading(true);
    bool? success = await service?.signInWithGoogle();
    setLoading(false);
    if (success == true) {
      return true;
    } else {
      return false;
    }
  }

  Future<void> signOut() async {
    await service?.signOut();
    setLoading(false);
  }

  bool get loading => this._loading;
}

final authenticationProvider = ChangeNotifierProvider<AuthenticatoinNotifier>(
  (ref) {
    return AuthenticatoinNotifier();
  },
);
