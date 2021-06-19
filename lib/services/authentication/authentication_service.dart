import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:storypad/services/local_storages/preferences/auth_header_storage.dart';

class AuthenticationService {
  GoogleSignIn googleSignIn = GoogleSignIn.standard(
    scopes: [drive.DriveApi.driveFileScope],
  );

  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? get user => _auth.currentUser;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<bool> signInSilently() async {
    try {
      GoogleSignInAccount? googleUser = await googleSignIn.signInSilently();
      if (googleUser == null) return false;
      _setAuthHeader(googleUser);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> signInWithGoogle() async {
    this._errorMessage = null;

    if (await this.googleSignIn.isSignedIn()) await googleSignIn.signOut();
    GoogleSignInAccount? googleUser;

    googleUser = await googleSignIn.signIn();

    if (googleUser == null) {
      this._errorMessage = tr("msg.login.cancel");
      return false;
    }

    await _setAuthHeader(googleUser);

    // Obtain the auth details from the request
    GoogleSignInAuthentication? googleAuth;

    try {
      googleAuth = await googleUser.authentication;
    } catch (e) {
      this._errorMessage = tr("msg.login.fail");
      return false;
    }

    // Create a new credential
    final GoogleAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    ) as GoogleAuthCredential;

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
        this._errorMessage = tr("msg.login.account_exists_with_different_credential");
        return false;
      } else if (e.code == 'invalid-credential') {
        this._errorMessage = tr("msg.login.invalid_credential");
        return false;
      }
    }

    this._errorMessage = tr("msg.login.fail");
    return false;
  }

  Future<void> _setAuthHeader(GoogleSignInAccount googleUser) async {
    AuthHeaderStorage storage = AuthHeaderStorage();
    final authHeaders = await googleUser.authHeaders;
    await storage.write(jsonEncode(authHeaders));
  }

  Future<bool> signOut() async {
    if (user != null) {
      try {
        await _auth.signOut();
        _auth.currentUser?.delete();
        await AuthHeaderStorage().remove();
        return true;
      } catch (e) {
        return false;
      }
    }
    return false;
  }
}
