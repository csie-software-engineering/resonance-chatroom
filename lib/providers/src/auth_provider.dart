import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';


class AuthProviders extends ChangeNotifier {
  final FirebaseAuth firebaseAuth;
  final SharedPreferences pref;
  late UserCredential userCredential;

  AuthProviders({
    required this.firebaseAuth,
    required this.pref,
  });

  String? getUserId() {
    return userCredential.user?.uid;
  }

  signInWithAnonymous() async {
    try {
      userCredential = await firebaseAuth.signInAnonymously();
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case "operation-not-allowed":
          print("Anonymous auth hasn't been enabled for this project.");
          break;
        default:
          print("Unknown error.");
      }
    }
  }
  signInWithGoogle() async {
    GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;
    AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );
    userCredential = await firebaseAuth.signInWithCredential(credential);

  }

  signInWithFacebook() async {
    final LoginResult loginResult = await FacebookAuth.instance.login(
        permissions: ['email', 'public_profile', 'user_birthday']
    );

    final OAuthCredential facebookAuthCredential = FacebookAuthProvider.credential(loginResult.accessToken!.token);

    final userData = await FacebookAuth.instance.getUserData();
    userCredential = await firebaseAuth.signInWithCredential(facebookAuthCredential);


  }
  logout() async {
    await FacebookAuth.instance.logOut();
    final GoogleSignIn googleSign = GoogleSignIn();
    await googleSign.signOut();
  }
}