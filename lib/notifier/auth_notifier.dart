import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:write_story/services/authentication_service.dart';

class AuthenticatoinNotifier extends ChangeNotifier {
  AuthenticationService? service = AuthenticationService();
  User? user;
  bool isAccountSignedIn = false;

  load() {
    user = service?.user;
    if (user != null) {
      isAccountSignedIn = true;
    } else {
      isAccountSignedIn = false;
    }
    notifyListeners();
  }

  Future<bool> logAccount() async {
    bool? success = await service?.signInWithGoogle();
    if (success == true) {
      await load();
      return true;
    } else {
      await load();
      return false;
    }
  }

  Future<void> signOut() async {
    await service?.signOut();
    load();
  }
}

final authenticatoinProvider = ChangeNotifierProvider<AuthenticatoinNotifier>(
  (ref) {
    return AuthenticatoinNotifier()..load();
  },
);
