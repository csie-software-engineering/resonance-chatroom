import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

class AuthProviders extends ChangeNotifier {
  final FirebaseAuth firebaseAuth;
  final SharedPreferences prefs;

  AuthProviders({
    required this.firebaseAuth,
    required this.prefs,
  });

  signInWithAnonymous() async {
    try {
      final userCredential =
      await FirebaseAuth.instance.signInAnonymously();
      print("Signed in with temporary account.");
      print(userCredential.user?.uid);
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
    UserCredential userCredential =
    await FirebaseAuth.instance.signInWithCredential(credential);
    print(userCredential.user?.displayName);
    print(userCredential.user?.email);

  }
  signInWithFacebook() async {
    // Trigger the sign-in flow
    final LoginResult loginResult = await FacebookAuth.instance.login(
        permissions: ['email', 'public_profile', 'user_birthday']
    );

    // Create a credential from the access token
    final OAuthCredential facebookAuthCredential = FacebookAuthProvider.credential(loginResult.accessToken!.token);

    final userData = await FacebookAuth.instance.getUserData();

    String userEmail = userData['email'];
    print(userEmail);
    // Once signed in, return the UserCredential
    await FirebaseAuth.instance.signInWithCredential(facebookAuthCredential);
  }
  logout() async {
    await FacebookAuth.instance.logOut();
    final GoogleSignIn googleSign = GoogleSignIn();
    await googleSign.signOut();
  }
}