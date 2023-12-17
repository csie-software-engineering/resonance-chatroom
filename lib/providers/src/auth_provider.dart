import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../providers/src/user_provider.dart';
import "../../models/src/user.dart" as rc_user;

class AuthProvider {
  final FirebaseAuth firebaseAuth;

  static final AuthProvider _instance = AuthProvider._internal(
    FirebaseAuth.instance,
  );

  AuthProvider._internal(this.firebaseAuth);
  factory AuthProvider() => _instance;

  /// 取得 Firebase Auth 使用者
  User? get getFBAUser => firebaseAuth.currentUser;

  /// 取得目前登入的使用者 uid
  String get currentUserId {
    assert(getFBAUser != null, '使用者未登入');
    return getFBAUser!.uid;
  }

  /// 取得目前登入的使用者
  Future<rc_user.User> get currentUser async {
    return await UserProvider().getUser(currentUserId);
  }

  /// 使用匿名登入
  Future<rc_user.User> signInWithAnonymous() async {
    await firebaseAuth.signInAnonymously();
    return await _createOrGetUser(firebaseAuth.currentUser);
  }

  /// 使用 Google 登入
  Future<rc_user.User> signInWithGoogle() async {
    GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;
    AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );
    await firebaseAuth.signInWithCredential(credential);
    return await _createOrGetUser(firebaseAuth.currentUser);
  }

  /// 使用 Facebook 登入
  Future<rc_user.User> signInWithFacebook() async {
    final LoginResult loginResult = await FacebookAuth.instance
        .login(permissions: ['email', 'public_profile', 'user_birthday']);

    final OAuthCredential facebookAuthCredential =
        FacebookAuthProvider.credential(loginResult.accessToken!.token);

    await firebaseAuth.signInWithCredential(facebookAuthCredential);
    return await _createOrGetUser(firebaseAuth.currentUser);
  }

  /// 登出
  Future<void> logout() async {
    await firebaseAuth.signOut();

    if (await GoogleSignIn().isSignedIn()) {
      await GoogleSignIn().signOut();
    }

    if (await FacebookAuth.instance.accessToken != null) {
      await FacebookAuth.instance.logOut();
    }
  }

  /// 創建或取得使用者
  Future<rc_user.User> _createOrGetUser(User? user) async {
    assert(user != null, "User is null");

    return await UserProvider().getUser(user!.uid).catchError((_) async {
      return await UserProvider().addUser(
        rc_user.User(
          uid: user.uid,
          displayName: user.displayName ?? "Guest",
          email: user.email,
          photoUrl: user.photoURL,
        ),
      );
    });
  }
}
