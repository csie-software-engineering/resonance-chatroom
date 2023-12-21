import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:resonance_chatroom/utils/src/time.dart';

import '../../constants/constants.dart';
import '../../models/models.dart';
import '../../providers/providers.dart';

class UserProvider {
  final FirebaseFirestore db;

  static final UserProvider _instance = UserProvider._internal(
    FirebaseFirestore.instance,
  );

  UserProvider._internal(this.db);
  factory UserProvider() => _instance;

  /// 添加(覆寫)使用者資料(僅能添加自己的資料)
  ///
  /// [addSocial] 是否添加社群媒體資料
  ///
  /// [addActivity] 是否添加活動及標籤資料
  Future<User> addUser(
    User user, {
    bool addSocial = false,
    bool addActivity = false,
  }) async {
    assert(user.uid == AuthProvider().currentUserId, '使用者ID與登入者不符合');
    final userRef = db
        .collection(FireStoreUserConstants.userCollectionPath.value)
        .doc(user.uid);

    user.isEnabled = true;
    final fsUser = user.toFSUser();

    await db.runTransaction((transaction) async {
      transaction.set(userRef, fsUser.toJson());

      if (addSocial) {
        for (final socialMedia in user.socialMedia) {
          await addUserSocialMedia(
            socialMedia,
            transaction: transaction,
          );
        }
      }

      if (addActivity) {
        for (final activity in user.activities) {
          await addUserActivity(activity, transaction: transaction);
        }
      }
    });

    return await getUser(
      userId: user.uid,
      loadSocial: addSocial,
      loadActivity: addActivity,
    );
  }

  /// 添加(覆寫)使用者社群媒體資料(僅能添加自己的資料)
  Future<User> addUserSocialMedia(
    UserSocialMedia socialMedia, {
    Transaction? transaction,
  }) async {
    final userId = AuthProvider().currentUserId;
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

    return await getUser(userId: userId, loadSocial: true);
  }

  /// 添加(覆寫)使用者活動資料(僅能添加自己的資料)
  Future<UserActivity> addUserActivity(
    UserActivity activity, {
    Transaction? transaction,
  }) async {
    final userId = AuthProvider().currentUserId;
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

    return await getUserActivity(activity.uid);
  }

  /// 刪除(停用)使用者資料(僅能停用自己的資料)
  Future<void> removeUser() async {
    final userId = AuthProvider().currentUserId;
    final userRef = db
        .collection(FireStoreUserConstants.userCollectionPath.value)
        .doc(userId);

    assert((await userRef.get()).exists, "使用者不存在");

    await userRef.update({
      FSUserConstants.isEnabled.value: false,
    });
  }

  /// 刪除使用者社群媒體資料(僅能刪除自己的資料)
  Future<void> removeUserSocialMedia(String displayName) async {
    final userId = AuthProvider().currentUserId;
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

  /// 刪除使用者活動資料(僅能刪除自己的資料)
  Future<void> removeUserActivity(String activityId) async {
    final userId = AuthProvider().currentUserId;
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

  /// 修改(含啟用)使用者資料(僅能修改自己的資料)
  ///
  /// [user] 使用者資料
  ///
  /// [updateSocial] 是否更新社群媒體資料
  ///
  /// [updateActivity] 是否更新活動及標籤資料
  Future<User> updateUser(
    User user, {
    bool updateSocial = false,
    bool updateActivity = false,
  }) async {
    assert(user.uid == AuthProvider().currentUserId, '使用者ID與登入者不符合');
    final userRef = db
        .collection(FireStoreUserConstants.userCollectionPath.value)
        .doc(user.uid);

    final userData = await userRef.get();
    assert(userData.exists, "使用者不存在");

    user.isEnabled = true;
    final fsUser = user.toFSUser();

    await db.runTransaction((transaction) async {
      transaction.update(userRef, fsUser.toJson());

      if (updateSocial) {
        for (final socialMedia in user.socialMedia) {
          await updateUserSocialMedia(
            socialMedia,
            transaction: transaction,
          );
        }
      }

      if (updateActivity) {
        for (final activity in user.activities) {
          await updateUserActivity(
            activity,
            transaction: transaction,
          );
        }
      }
    });

    return await getUser(
      userId: user.uid,
      loadSocial: updateSocial,
      loadActivity: updateActivity,
    );
  }

  /// 修改使用者社群媒體資料(僅能修改自己的資料)
  Future<User> updateUserSocialMedia(
    UserSocialMedia socialMedia, {
    Transaction? transaction,
  }) async {
    final userId = AuthProvider().currentUserId;
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

    return await getUser(userId: userId, loadSocial: true);
  }

  /// 修改使用者活動資料(僅能修改自己的資料)
  Future<UserActivity> updateUserActivity(
    UserActivity activity, {
    Transaction? transaction,
  }) async {
    final userId = AuthProvider().currentUserId;
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

    return await getUserActivity(activity.uid);
  }

  /// 修改使用者活動標籤資料(僅能修改自己的資料)
  Future<User> updateUserTag(
    String activityId,
    List<String> tagIds,
  ) async {
    final userId = AuthProvider().currentUserId;
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

    return await getUser(userId: userId, loadActivity: true);
  }

  /// 取得使用者資料
  ///
  /// [userId] 使用者ID，預設為目前登入者
  ///
  /// [loadSocial] 是否載入社群媒體資料
  ///
  /// [loadActivity] 是否載入活動及標籤資料
  Future<User> getUser({
    String? userId,
    bool loadSocial = false,
    bool loadActivity = false,
  }) async {
    userId ??= AuthProvider().currentUserId;
    final userRef = db
        .collection(FireStoreUserConstants.userCollectionPath.value)
        .doc(userId);

    final userData = await userRef.get();
    assert(userData.exists, "使用者不存在");

    final fsUser = FSUser.fromDocument(userData);
    final user = fsUser.toUser();

    if (loadSocial) {
      user.socialMedia.addAll(await getUserSocialMedium(userId));
    }

    if (loadActivity) {
      user.activities.addAll(await getUserActivities());
    }

    return user;
  }

  /// 取得使用者社群媒體資料
  ///
  /// [userId] 使用者ID
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
  ///
  /// [userId] 使用者ID
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

  /// 取得使用者活動資料(僅能取得自己的資料)
  Future<UserActivity> getUserActivity(String activityId) async {
    final userId = AuthProvider().currentUserId;
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

  /// 取得使用者所有活動資料(僅能取得自己的資料)
  Future<List<UserActivity>> getUserActivities({bool? isManager, bool? outdated}) async {
    final userId = AuthProvider().currentUserId;
    final userRef = db
        .collection(FireStoreUserConstants.userCollectionPath.value)
        .doc(userId);

    final userData = await userRef.get();
    assert(userData.exists, "使用者不存在");
    assert(userData.get(FSUserConstants.isEnabled.value), "使用者已被停用");

    final userActivityRef = userRef
        .collection(FireStoreUserConstants.userActivityCollectionPath.value);

    final userActivityData = isManager != null
        ? await userActivityRef
            .where(FSUserActivityConstants.isManager.value, isEqualTo: isManager)
            .get()
        : await userActivityRef.get();

    var activities = userActivityData.docs.map((e) {
      final fsUserActivity = FSUserActivity.fromDocument(e);
      final userActivity = fsUserActivity.toUserActivity();

      return userActivity;
    }).toList();

    if (outdated != null) {
      final allActivities = await ActivityProvider().getAllActivities();
      return outdated
          ? activities
              .where((ua) => allActivities
                  .firstWhere((aa) => aa.uid == ua.uid)
                  .endDate
                  .toEpochTime()
                  .isBefore(DateTime.now()))
              .toList()
          : activities
              .where((ua) => allActivities
                  .firstWhere((aa) => aa.uid == ua.uid)
                  .endDate
                  .toEpochTime()
                  .isAfter(DateTime.now()))
              .toList();
    }

    return activities;
  }

  ///取得使用者活動點數(僅能取得自己的資料)
  Future<int> getUserActivityPoint(String activityId) async{
    final activity = await getUserActivity(activityId);
    return activity.point;
  }

  ///增加使用者活動點數
  Future<void> addUserActivityPoint(String activityId) async{
    final activity = await getUserActivity(activityId);
    activity.point++;
    await updateUserActivity(activity);
  }

  ///扣除使用者活動點數
  Future<void> minusUserActivityPoint(String activityId, int val) async{
    assert(val > 0, "不能扣除小於1的值");
    final activity = await getUserActivity(activityId);
    assert(activity.point >= val, "使用者沒有足夠多的點數");
    activity.point -= val;
    await updateUserActivity(activity);
  }
}
