import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:resonance_chatroom/utils/src/time.dart';

import '../../constants/constants.dart';
import '../../models/models.dart';
import '../../providers/providers.dart';
import '../../models/src/firestore/fs_user.dart';

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
      loadSocial: addSocial,
      loadActivityWithHosted: addActivity,
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

    return await getUser(loadSocial: true);
  }

  /// 添加(覆寫)使用者活動資料
  Future<UserActivity> addUserActivity(
    UserActivity activity, {
    String? userId,
    Transaction? transaction,
  }) async {
    userId ??= AuthProvider().currentUserId;
    final userRef = db
        .collection(FireStoreUserConstants.userCollectionPath.value)
        .doc(userId);

    final userData = await userRef.get();
    if (!userData.exists) throw Exception("使用者不存在");

    assert(activity.isManager != true || !AuthProvider().fbaUser!.isAnonymous,
        "匿名使用者不能管理活動");

    final collection = activity.isManager
        ? FireStoreUserConstants.userHostedActivityCollectionPath.value
        : FireStoreUserConstants.userJoinedActivityCollectionPath.value;
    final activityRef = userRef.collection(collection).doc(activity.uid);

    final fsUserActivity = activity.toFSUserActivity();
    transaction != null
        ? transaction.set(activityRef, fsUserActivity.toJson())
        : await activityRef.set(fsUserActivity.toJson());

    return await getUserActivity(activity.uid,
        userId: userId, isManager: activity.isManager);
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
    if (!userData.exists) throw Exception("使用者不存在");
    if (!userData.get(FSUserConstants.isEnabled.value))
      throw Exception("使用者已被停用");

    final socialMediaRef = userRef
        .collection(FireStoreUserConstants.userSocialMediaCollectionPath.value)
        .doc(displayName);

    assert((await socialMediaRef.get()).exists, "使用者未添加該社群媒體");
    await socialMediaRef.delete();
  }

  /// 刪除使用者活動資料
  Future<void> removeUserActivity(
    String activityId, {
    String? userId,
    required bool isManager,
  }) async {
    userId ??= AuthProvider().currentUserId;
    final userRef = db
        .collection(FireStoreUserConstants.userCollectionPath.value)
        .doc(userId);

    final userData = await userRef.get();
    if (!userData.exists) throw Exception("使用者不存在");
    if (!userData.get(FSUserConstants.isEnabled.value))
      throw Exception("使用者已被停用");

    final collection = isManager
        ? FireStoreUserConstants.userHostedActivityCollectionPath.value
        : FireStoreUserConstants.userJoinedActivityCollectionPath.value;
    final activityRef = userRef.collection(collection).doc(activityId);

    assert((await activityRef.get()).exists, "使用者未參加/舉辦該活動");
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
    if (!userData.exists) throw Exception("使用者不存在");

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
      loadSocial: updateSocial,
      loadActivityWithHosted: updateActivity,
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
    if (!userData.exists) throw Exception("使用者不存在");
    if (!userData.get(FSUserConstants.isEnabled.value))
      throw Exception("使用者已被停用");

    final socialMediaRef = userRef
        .collection(FireStoreUserConstants.userSocialMediaCollectionPath.value)
        .doc(socialMedia.displayName);

    final socialMediaData = await socialMediaRef.get();
    assert(socialMediaData.exists, "使用者社群媒體不存在");

    final fsUserSocialMedia = socialMedia.toFSUserSocialMedia();
    transaction != null
        ? transaction.update(socialMediaRef, fsUserSocialMedia.toJson())
        : await socialMediaRef.update(fsUserSocialMedia.toJson());

    return await getUser(loadSocial: true);
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
    if (!userData.exists) throw Exception("使用者不存在");
    if (!userData.get(FSUserConstants.isEnabled.value))
      throw Exception("使用者已被停用");

    final collection = activity.isManager
        ? FireStoreUserConstants.userHostedActivityCollectionPath.value
        : FireStoreUserConstants.userJoinedActivityCollectionPath.value;
    final activityRef = userRef.collection(collection).doc(activity.uid);

    assert((await activityRef.get()).exists, "使用者未參加該活動");

    final fsUserActivity = activity.toFSUserActivity();
    transaction != null
        ? transaction.update(activityRef, fsUserActivity.toJsonWithOutPoint())
        : await activityRef.update(fsUserActivity.toJsonWithOutPoint());

    return await getUserActivity(activity.uid, isManager: activity.isManager);
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
    if (!userData.exists) throw Exception("使用者不存在");
    if (!userData.get(FSUserConstants.isEnabled.value))
      throw Exception("使用者已被停用");

    final activityRef = userRef
        .collection(
            FireStoreUserConstants.userJoinedActivityCollectionPath.value)
        .doc(activityId);

    assert((await activityRef.get()).exists, "使用者未參加該活動");

    await activityRef.update({
      FSUserActivityConstants.tagIds.value: tagIds,
    });

    return await getUser(loadActivityWithHosted: true);
  }

  /// 取得使用者資料
  ///
  /// [userId] 使用者ID，預設為目前登入者
  ///
  /// [loadSocial] 是否載入社群媒體資料
  ///
  /// [loadActivityWithHosted] null => 不載入活動資料，true => 載入舉辦活動資料，false => 載入參加活動資料
  Future<User> getUser({
    String? userId,
    bool loadSocial = false,
    bool? loadActivityWithHosted,
  }) async {
    userId ??= AuthProvider().currentUserId;
    final userRef = db
        .collection(FireStoreUserConstants.userCollectionPath.value)
        .doc(userId);

    final userData = await userRef.get();
    if (!userData.exists) throw Exception("使用者不存在"); // 這應該是 assertion ?

    final fsUser = FSUser.fromDocument(userData);
    final user = fsUser.toUser();

    if (loadSocial) {
      user.socialMedia.addAll(await getUserSocialMedium(userId: userId));
    }

    if (loadActivityWithHosted != null) {
      if (loadActivityWithHosted) {
        user.activities.addAll(await getUserActivities(isManager: true));
      } else {
        user.activities.addAll(await getUserActivities(isManager: false));
      }
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
    if (!userData.exists) throw Exception("使用者不存在");
    if (!userData.get(FSUserConstants.isEnabled.value))
      throw Exception("使用者已被停用");

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
  /// [userId] 使用者ID，預設為目前登入者
  Future<List<UserSocialMedia>> getUserSocialMedium({String? userId}) async {
    userId ??= AuthProvider().currentUserId;
    final userRef = db
        .collection(FireStoreUserConstants.userCollectionPath.value)
        .doc(userId);

    final userData = await userRef.get();
    if (!userData.exists) throw Exception("使用者不存在");
    if (!userData.get(FSUserConstants.isEnabled.value))
      throw Exception("使用者已被停用");
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
  Future<UserActivity> getUserActivity(
    String activityId, {
    String? userId,
    required bool isManager,
  }) async {
    userId ??= AuthProvider().currentUserId;
    final userRef = db
        .collection(FireStoreUserConstants.userCollectionPath.value)
        .doc(userId);

    final userData = await userRef.get();
    if (!userData.exists) throw Exception("使用者不存在");
    if (!userData.get(FSUserConstants.isEnabled.value)) {
      throw Exception("使用者已被停用");
    }

    final collection = isManager
        ? FireStoreUserConstants.userHostedActivityCollectionPath.value
        : FireStoreUserConstants.userJoinedActivityCollectionPath.value;
    final userActivityData =
        await userRef.collection(collection).doc(activityId).get();

    assert(userActivityData.exists, "使用者未參加/舉辦該活動");
    final fsUserActivity = FSUserActivity.fromDocument(userActivityData);
    final userActivity = fsUserActivity.toUserActivity();

    return userActivity;
  }

  /// 取得使用者所有活動資料(僅能取得自己的資料)
  Future<List<UserActivity>> getUserActivities({
    required bool isManager,
    bool? outdated,
  }) async {
    final userId = AuthProvider().currentUserId;
    final userRef = db
        .collection(FireStoreUserConstants.userCollectionPath.value)
        .doc(userId);

    final userData = await userRef.get();
    if (!userData.exists) throw Exception("使用者不存在");
    if (!userData.get(FSUserConstants.isEnabled.value))
      throw Exception("使用者已被停用");

    final collection = isManager
        ? FireStoreUserConstants.userHostedActivityCollectionPath.value
        : FireStoreUserConstants.userJoinedActivityCollectionPath.value;
    final userActivitiesData = await userRef.collection(collection).get();

    var activities = userActivitiesData.docs.map((e) {
      final fsUserActivity = FSUserActivity.fromDocument(e);
      return fsUserActivity.toUserActivity();
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

  /// 取得使用者尚未參加的活動資料(僅能取得自己的資料)
  Future<List<Activity>> getUserNotJoinedActivities({
    bool? outdated,
  }) async {
    final userId = AuthProvider().currentUserId;
    final userRef = db
        .collection(FireStoreUserConstants.userCollectionPath.value)
        .doc(userId);
    final userActivitiesData = await userRef
        .collection(
            FireStoreUserConstants.userJoinedActivityCollectionPath.value)
        .get();

    final allActivities = await ActivityProvider().getAllActivities();
    var activities = allActivities
        .where((aa) => !userActivitiesData.docs
            .map((e) => FSUserActivity.fromDocument(e).toUserActivity().uid)
            .contains(aa.uid))
        .toList();

    if (outdated != null) {
      return outdated
          ? activities
              .where((a) => a.endDate.toEpochTime().isBefore(DateTime.now()))
              .toList()
          : activities
              .where((a) => a.endDate.toEpochTime().isAfter(DateTime.now()))
              .toList();
    }

    return activities;
  }

  ///取得使用者活動點數(僅能取得自己的資料)
  Future<int> getUserActivityPoint(String activityId) async {
    final activity = await getUserActivity(activityId, isManager: false);
    return activity.point;
  }

  ///增加使用者活動點數
  Future<void> addUserActivityPoint(String activityId) async {
    final userId = AuthProvider().currentUserId;
    final userRef = db
        .collection(FireStoreUserConstants.userCollectionPath.value)
        .doc(userId);

    final userData = await userRef.get();
    if (!userData.exists) throw Exception("使用者不存在");
    if (!userData.get(FSUserConstants.isEnabled.value))
      throw Exception("使用者已被停用");

    final userActivityRef = userRef
        .collection(
            FireStoreUserConstants.userJoinedActivityCollectionPath.value)
        .doc(activityId);

    assert((await userActivityRef.get()).exists, "使用者未參加該活動");

    await userActivityRef.update({
      FSUserActivityConstants.point.value: FieldValue.increment(1),
    });
  }

  ///扣除使用者活動點數
  Future<void> minusUserActivityPoint(String activityId, int val) async {
    // assert(val > 0, "不能扣除小於1的值");
    if(val <= 0) {
      throw const FormatException("不能扣除小於1的值");
    }
    final userId = AuthProvider().currentUserId;
    final userRef = db
        .collection(FireStoreUserConstants.userCollectionPath.value)
        .doc(userId);

    final userData = await userRef.get();
    if (!userData.exists) throw Exception("使用者不存在");
    if (!userData.get(FSUserConstants.isEnabled.value))
      throw Exception("使用者已被停用");

    final userActivityRef = userRef
        .collection(
            FireStoreUserConstants.userJoinedActivityCollectionPath.value)
        .doc(activityId);

    final activity = await userActivityRef.get();
    assert(activity.exists, "使用者未參加該活動");
    assert(activity.get(FSUserActivityConstants.point.value) >= val,
        "使用者沒有足夠多的點數");

    await userActivityRef.update({
      FSUserActivityConstants.point.value: FieldValue.increment(-val),
    });
  }
}
