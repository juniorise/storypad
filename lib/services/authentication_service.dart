import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:write_story/storages/auth_header_storage.dart';

class AuthenticationService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? get user => _auth.currentUser;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<bool> signInWithGoogle() async {
    GoogleSignIn? googleSignIn = GoogleSignIn.standard(
      scopes: [drive.DriveApi.driveFileScope],
    );

    GoogleSignInAccount? googleUser = await googleSignIn.signIn();

    if (googleUser == null) {
      this._errorMessage = tr("msg.login.cancel");
      return false;
    }

    AuthHeaderStorage storage = AuthHeaderStorage();
    final authHeaders = await googleUser.authHeaders;
    await storage.write(jsonEncode(authHeaders));

    // Obtain the auth details from the request
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    // Create a new credential
    final GoogleAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    ) as GoogleAuthCredential;

    this._errorMessage = null;

    try {
      // Once signed in, return the UserCredential
      final authCredential = await _auth.signInWithCredential(credential);
      if (authCredential.user?.emailVerified == true) {
        return true;
      } else if (authCredential.user?.emailVerified == true) {
        this._errorMessage = tr("msg.login.email_not_verified");
        return false;
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'account-exists-with-different-credential') {
        this._errorMessage =
            tr("msg.login.account_exists_with_different_credential");
        return false;
      } else if (e.code == 'invalid-credential') {
        this._errorMessage = tr("msg.login.invalid_credential");
        return false;
      }
    }

    this._errorMessage = tr("msg.login.fail");
    return false;
  }

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
