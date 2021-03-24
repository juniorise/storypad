import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthenticationService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? get user => _auth.currentUser;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<bool> _signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      this._errorMessage = null;
      return true;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
        this._errorMessage = tr("msg.login.user_not_found");
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
        this._errorMessage = tr("msg.login.wrong_password");
      }
      return false;
    }
  }

  Future<bool> createUserWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      this._errorMessage = null;
      return true;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
        this._errorMessage = tr("msg.login.weak_password");
        return false;
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
        return await _signInWithEmailAndPassword(email, password);
      }
    }
    return false;
  }

  Future<bool> signOut() async {
    if (user != null) {
      try {
        await _auth.signOut();
        return true;
      } catch (e) {
        return false;
      }
    }
    return false;
  }
}
