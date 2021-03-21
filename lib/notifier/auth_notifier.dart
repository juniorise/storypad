import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:write_story/services/authentication_service.dart';

class AuthenticatoinNotifier extends ChangeNotifier {
  AuthenticationService? service = AuthenticationService();
  User? user;

  bool isAccountSignedIn = false;

  String _email = "";
  String _password = "";

  setEmail(String email) {
    this._email = email;
  }

  setPassword(String password) {
    this._password = password;
  }

  load() {
    user = service?.user;
    if (user != null) {
      isAccountSignedIn = true;
    } else {
      isAccountSignedIn = false;
    }
    notifyListeners();
  }

  Future<void> logAccount(String email, String password) async {
    await service?.createUserWithEmailAndPassword(email, password);
    load();
  }

  Future<void> signOut() async {
    await service?.signOut();
    load();
  }

  String get email => this._email;
  String get password => this._password;
}

final authenticatoinProvider = ChangeNotifierProvider<AuthenticatoinNotifier>(
  (ref) {
    return AuthenticatoinNotifier()..load();
  },
);
