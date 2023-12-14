import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/models.dart';
import '../../constants/constants.dart';

class UserProvider {
  final FirebaseFirestore db;

  UserProvider({
    required this.db,
  });

  /// 添加(覆寫)使用者資料
  ///
  /// [addSocial] 是否添加社群媒體資料
  ///
  /// [addActivity] 是否添加活動及標籤資料
  Future<User> addUser(
    User user, {
    bool addSocial = false,
    bool addActivity = false,
  }) async {
    final userRef = db
        .collection(FireStoreUserConstants.userCollectionPath.value)
        .doc(user.uid);

    final fsUser = user.toFSUser();

    await db.runTransaction((transaction) async {
      transaction.set(userRef, fsUser.toJson());

      if (addSocial) {
        for (final socialMedia in user.socialMedia) {
          await addUserSocialMedia(
            user.uid,
            socialMedia,
            transaction: transaction,
          );
        }
      }

      if (addActivity) {
        for (final activity in user.activities) {
          await addUserActivity(user.uid, activity, transaction: transaction);
        }
      }
    });

    return await getUser(
      user.uid,
      loadSocial: addSocial,
      loadActivity: addActivity,
    );
  }

  /// 添加(覆寫)使用者社群媒體資料
  Future<User> addUserSocialMedia(
    String userId,
    UserSocialMedia socialMedia, {
    Transaction? transaction,
  }) async {
    final userRef = db
        .collection(FireStoreUserConstants.userCollectionPath.value)
        .doc(userId);

    assert((await userRef.get()).exists, "使用者不存在");

    final socialMediaRef = userRef
        .collection(FireStoreUserConstants.userSocialMediaCollectionPath.value)
        .doc(socialMedia.displayName);

    final fsUserSocialMedia = socialMedia.toFSUserSocialMedia();
    transaction != null
        ? transaction.set(socialMediaRef, fsUserSocialMedia.toJson())
        : await socialMediaRef.set(fsUserSocialMedia.toJson());

    return await getUser(userId, loadSocial: true);
  }

  /// 添加(覆寫)使用者活動資料
  Future<UserActivity> addUserActivity(
    String userId,
    UserActivity activity, {
    Transaction? transaction,
  }) async {
    final userRef = db
        .collection(FireStoreUserConstants.userCollectionPath.value)
        .doc(userId);

    assert((await userRef.get()).exists, "使用者不存在");

    final activityRef = userRef
        .collection(FireStoreUserConstants.userActivityCollectionPath.value)
        .doc(activity.uid);

    final fsUserActivity = activity.toFSUserActivity();
    transaction != null
        ? transaction.set(activityRef, fsUserActivity.toJson())
        : await activityRef.set(fsUserActivity.toJson());

    return await getUserActivity(userId, activity.uid);
  }

  /// 刪除(停用)使用者資料
  Future<void> removeUser(String userId) async {
    final userRef = db
        .collection(FireStoreUserConstants.userCollectionPath.value)
        .doc(userId);

    assert((await userRef.get()).exists, "使用者不存在");

    await userRef.update({
      FSUserConstants.isEnabled.value: false,
    });
  }

  /// 刪除使用者社群媒體資料
  Future<void> removeUserSocialMedia(String userId, String displayName) async {
    final userRef = db
        .collection(FireStoreUserConstants.userCollectionPath.value)
        .doc(userId);

    final userData = await userRef.get();
    assert(userData.exists, "使用者不存在");
    assert(userData.get(FSUserConstants.isEnabled.value), "使用者已被停用");

    final socialMediaRef = userRef
        .collection(FireStoreUserConstants.userSocialMediaCollectionPath.value)
        .doc(displayName);

    assert((await socialMediaRef.get()).exists, "使用者未添加該社群媒體");
    await socialMediaRef.delete();
  }

  /// 刪除使用者活動資料
  Future<void> removeUserActivity(
    String userId,
    String activityId,
  ) async {
    final userRef = db
        .collection(FireStoreUserConstants.userCollectionPath.value)
        .doc(userId);

    final userData = await userRef.get();
    assert(userData.exists, "使用者不存在");
    assert(userData.get(FSUserConstants.isEnabled.value), "使用者已被停用");

    final activityRef = userRef
        .collection(FireStoreUserConstants.userActivityCollectionPath.value)
        .doc(activityId);

    assert((await activityRef.get()).exists, "使用者未參加該活動");
    await activityRef.delete();
  }

  /// 修改(含啟用)使用者資料
  ///
  /// [updateSocial] 是否更新社群媒體資料
  ///
  /// [updateActivity] 是否更新活動及標籤資料
  Future<User> updateUser(
    User user, {
    bool updateSocial = false,
    bool updateActivity = false,
  }) async {
    final userRef = db
        .collection(FireStoreUserConstants.userCollectionPath.value)
        .doc(user.uid);

    final userData = await userRef.get();
    assert(userData.exists, "使用者不存在");

    final fsUser = user.toFSUser();

    await db.runTransaction((transaction) async {
      transaction.update(userRef, fsUser.toJson());

      if (updateSocial) {
        for (final socialMedia in user.socialMedia) {
          await updateUserSocialMedia(
            user.uid,
            socialMedia,
            transaction: transaction,
          );
        }
      }

      if (updateActivity) {
        for (final activity in user.activities) {
          await updateUserActivity(user.uid, activity, transaction: transaction);
        }
      }
    });

    return await getUser(
      user.uid,
      loadSocial: updateSocial,
      loadActivity: updateActivity,
    );
  }

  /// 修改使用者社群媒體資料
  Future<User> updateUserSocialMedia(
    String userId,
    UserSocialMedia socialMedia, {
    Transaction? transaction,
  }) async {
    final userRef = db
        .collection(FireStoreUserConstants.userCollectionPath.value)
        .doc(userId);

    final userData = await userRef.get();
    assert(userData.exists, "使用者不存在");
    assert(userData.get(FSUserConstants.isEnabled.value), "使用者已被停用");

    final socialMediaRef = userRef
        .collection(FireStoreUserConstants.userSocialMediaCollectionPath.value)
        .doc(socialMedia.displayName);

    final socialMediaData = await socialMediaRef.get();
    assert(socialMediaData.exists, "使用者社群媒體不存在");

    final fsUserSocialMedia = socialMedia.toFSUserSocialMedia();
    transaction != null
        ? transaction.update(socialMediaRef, fsUserSocialMedia.toJson())
        : await socialMediaRef.update(fsUserSocialMedia.toJson());

    return await getUser(userId, loadSocial: true);
  }

  /// 修改使用者活動資料
  Future<UserActivity> updateUserActivity(
    String userId,
    UserActivity activity, {
    Transaction? transaction,
  }) async {
    final userRef = db
        .collection(FireStoreUserConstants.userCollectionPath.value)
        .doc(userId);

    final userData = await userRef.get();
    assert(userData.exists, "使用者不存在");
    assert(userData.get(FSUserConstants.isEnabled.value), "使用者已被停用");

    final activityRef = userRef
        .collection(FireStoreUserConstants.userActivityCollectionPath.value)
        .doc(activity.uid);

    assert((await activityRef.get()).exists, "使用者未參加該活動");

    final fsUserActivity = activity.toFSUserActivity();
    transaction != null
        ? transaction.update(activityRef, fsUserActivity.toJson())
        : await activityRef.update(fsUserActivity.toJson());

    return await getUserActivity(userId, activity.uid);
  }

  /// 修改使用者活動標籤資料
  Future<User> updateUserTag(
    String userId,
    String activityId,
    List<String> tagIds,
  ) async {
    final userRef = db
        .collection(FireStoreUserConstants.userCollectionPath.value)
        .doc(userId);

    final userData = await userRef.get();
    assert(userData.exists, "使用者不存在");
    assert(userData.get(FSUserConstants.isEnabled.value), "使用者已被停用");

    final activityRef = userRef
        .collection(FireStoreUserConstants.userActivityCollectionPath.value)
        .doc(activityId);

    assert((await activityRef.get()).exists, "使用者未參加該活動");

    await activityRef.update({
      FSUserActivityConstants.tagIds.value: tagIds,
    });

    return await getUser(userId, loadActivity: true);
  }

  /// 取得使用者資料
  ///
  /// [loadSocial] 是否載入社群媒體資料
  ///
  /// [loadActivity] 是否載入活動及標籤資料
  Future<User> getUser(
    String userId, {
    bool loadSocial = false,
    bool loadActivity = false,
  }) async {
    final userRef = db
        .collection(FireStoreUserConstants.userCollectionPath.value)
        .doc(userId);

    final userData = await userRef.get();
    assert(userData.exists, "使用者不存在");
    assert(userData.get(FSUserConstants.isEnabled.value), "使用者已被停用");

    final fsUser = FSUser.fromDocument(userData);
    final user = fsUser.toUser();

    if (loadSocial) {
      user.socialMedia.addAll(await getUserSocialMedium(userId));
    }

    if (loadActivity) {
      user.activities.addAll(await getUserActivities(userId));
    }

    return user;
  }

  /// 取得使用者社群媒體資料
  Future<UserSocialMedia> getUserSocialMedia(
    String userId,
    String displayName,
  ) async {
    final userRef = db
        .collection(FireStoreUserConstants.userCollectionPath.value)
        .doc(userId);

    final userData = await userRef.get();
    assert(userData.exists, "使用者不存在");
    assert(userData.get(FSUserConstants.isEnabled.value), "使用者已被停用");

    final userSocialMediaData = await userRef
        .collection(FireStoreUserConstants.userSocialMediaCollectionPath.value)
        .doc(displayName)
        .get();

    assert(userSocialMediaData.exists, "使用者未添加該社群媒體");
    final fsUserSocialMedia =
        FSUserSocialMedia.fromDocument(userSocialMediaData);

    final userSocialMedia = fsUserSocialMedia.toUserSocialMedia();

    return userSocialMedia;
  }

  /// 取得使用者所有社群媒體資料
  Future<List<UserSocialMedia>> getUserSocialMedium(String userId) async {
    final userRef = db
        .collection(FireStoreUserConstants.userCollectionPath.value)
        .doc(userId);

    final userData = await userRef.get();
    assert(userData.exists, "使用者不存在");
    assert(userData.get(FSUserConstants.isEnabled.value), "使用者已被停用");
    final userSocialMediaData = await userRef
        .collection(FireStoreUserConstants.userSocialMediaCollectionPath.value)
        .get();

    return userSocialMediaData.docs.map((e) {
      final fsUserSocialMedia = FSUserSocialMedia.fromDocument(e);
      final userSocialMedia = fsUserSocialMedia.toUserSocialMedia();

      return userSocialMedia;
    }).toList();
  }

  /// 取得使用者活動資料
  Future<UserActivity> getUserActivity(String userId, String activityId) async {
    final userRef = db
        .collection(FireStoreUserConstants.userCollectionPath.value)
        .doc(userId);

    final userData = await userRef.get();
    assert(userData.exists, "使用者不存在");
    assert(userData.get(FSUserConstants.isEnabled.value), "使用者已被停用");

    final userActivityData = await userRef
        .collection(FireStoreUserConstants.userActivityCollectionPath.value)
        .doc(activityId)
        .get();

    assert(userActivityData.exists, "使用者未參加該活動");
    final fsUserActivity = FSUserActivity.fromDocument(userActivityData);
    final userActivity = fsUserActivity.toUserActivity();

    return userActivity;
  }

  /// 取得使用者所有活動資料
  Future<List<UserActivity>> getUserActivities(String userId) async {
    final userRef = db
        .collection(FireStoreUserConstants.userCollectionPath.value)
        .doc(userId);

    final userData = await userRef.get();
    assert(userData.exists, "使用者不存在");
    assert(userData.get(FSUserConstants.isEnabled.value), "使用者已被停用");
    final userActivityData = await userRef
        .collection(FireStoreUserConstants.userActivityCollectionPath.value)
        .get();

    return userActivityData.docs.map((e) {
      final fsUserActivity = FSUserActivity.fromDocument(e);
      final userActivity = fsUserActivity.toUserActivity();

      return userActivity;
    }).toList();
  }
}
