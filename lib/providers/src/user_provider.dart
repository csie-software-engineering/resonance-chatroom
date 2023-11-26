import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:resonance_chatroom/models/src/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/models.dart';
import '../../constants/constants.dart';

class UserProvider {
  final SharedPreferences pref;
  final FirebaseFirestore firebaseFirestore;

  UserProvider({
    required this.firebaseFirestore,
    required this.pref,
  });

  String? getPref(String key) {
    return pref.getString(key);
  }

  /// 設定使用者資料
  Future<void> setUser(User user) async {
    var ref = firebaseFirestore
        .collection(FirestoreConstants.userCollectionPath.value)
        .doc(user.id);

    await ref.set(user.toJson());
  }

  /// 取得使用者資料
  Future<User?> getUser(String userId) async {
    var ref = firebaseFirestore
        .collection(FirestoreConstants.userCollectionPath.value)
        .doc(userId);

    var user = await ref.get();

    if (user.exists) {
      return User.fromDocument(user);
    }
    else {
      return null;
    }
  }
}
