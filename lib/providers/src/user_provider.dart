import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/models.dart';
import '../../constants/constants.dart';

class UserProvider {
  final FirebaseFirestore db;

  UserProvider({
    required this.db,
  });

  /// 添加使用者資料
  ///
  /// [addSocial] 是否添加社群媒體資料
  ///
  /// [addActivity] 是否添加活動及標籤資料
  Future<User?> addUser(
    User user, {
    bool addSocial = false,
    bool addActivity = false,
  }) async {
    var userRef = db
        .collection(FireStoreUserConstants.userCollectionPath.value)
        .doc(user.id);

    var fsUser = user.toFSUser();
    await userRef.set(fsUser.toJson());

    if (addSocial) {
      for (var socialMedia in user.socialMedia) {
        await addUserSocialMedia(user.id, socialMedia);
      }
    }

    if (addActivity) {
      for (var activity in user.activities) {
        await addUserActivity(user.id, activity);
      }
    }

    return await getUser(user.id,
        loadSocial: addSocial, loadActivity: addActivity);
  }

  /// 添加使用者社群媒體資料
  Future<User?> addUserSocialMedia(
    String userId,
    UserSocialMedia socialMedia,
  ) async {
    var userRef = db
        .collection(FireStoreUserConstants.userCollectionPath.value)
        .doc(userId);

    assert((await userRef.get()).exists, "User 不存在");

    var socialMediaRef = userRef
        .collection(FireStoreUserConstants.userSocialMediaCollectionPath.value)
        .doc(socialMedia.displayName);

    var fsUserSocialMedia = socialMedia.toFSUserSocialMedia();
    await socialMediaRef.set(fsUserSocialMedia.toJson());

    return await getUser(userId, loadSocial: true);
  }

  /// 添加使用者活動資料
  ///
  /// [addTag] 是否添加活動標籤資料
  Future<User?> addUserActivity(
    String userId,
    UserActivity activity, {
    bool addTag = false,
  }) async {
    var userRef = db
        .collection(FireStoreUserConstants.userCollectionPath.value)
        .doc(userId);

    assert((await userRef.get()).exists, "User 不存在");

    var activityRef = userRef
        .collection(FireStoreUserConstants.userActivityCollectionPath.value)
        .doc(activity.id);

    var fsUserActivity = activity.toFSUserActivity();
    await activityRef.set(fsUserActivity.toJson());

    if (addTag) {
      for (var tag in activity.tags) {
        await addUserTag(userId, activity.id, tag);
      }
    }

    return await getUser(userId, loadActivity: true);
  }

  /// 添加使用者活動標籤資料
  Future<User?> addUserTag(
    String userId,
    String activityId,
    UserTag tag,
  ) async {
    var userRef = db
        .collection(FireStoreUserConstants.userCollectionPath.value)
        .doc(userId);

    assert((await userRef.get()).exists, "User 不存在");

    var activityRef = userRef
        .collection(FireStoreUserConstants.userActivityCollectionPath.value)
        .doc(activityId);

    assert((await activityRef.get()).exists, "UserActivity 不存在");

    var tagRef = activityRef
        .collection(FireStoreUserConstants.userTagCollectionPath.value)
        .doc(tag.id);

    var fsUserTag = tag.toFSUserTag();
    await tagRef.set(fsUserTag.toJson());

    return await getUser(userId, loadActivity: true);
  }

  /// 刪除(停用)使用者資料
  Future<bool> removeUser(String userId) async {
    var userRef = db
        .collection(FireStoreUserConstants.userCollectionPath.value)
        .doc(userId);

    var userData = await userRef.get();
    if (userData.exists) {
      await userRef.update({
        FSUserConstants.isEnabled.value: false,
      });
      return true;
    }

    return false;
  }

  /// 刪除使用者社群媒體資料
  Future<bool> removeUserSocialMedia(
    String userId,
    String displayName,
  ) async {
    var userRef = db
        .collection(FireStoreUserConstants.userCollectionPath.value)
        .doc(userId);

    var userData = await userRef.get();
    if (userData.exists && userData.get(FSUserConstants.isEnabled.value)) {
      var socialMediaRef = userRef
          .collection(
              FireStoreUserConstants.userSocialMediaCollectionPath.value)
          .doc(displayName);

      var socialMediaData = await socialMediaRef.get();
      if (socialMediaData.exists) {
        await socialMediaRef.delete();
        return true;
      }
    }

    return false;
  }

  /// 刪除使用者活動資料
  Future<bool> removeUserActivity(
    String userId,
    String activityId,
  ) async {
    var userRef = db
        .collection(FireStoreUserConstants.userCollectionPath.value)
        .doc(userId);

    var userData = await userRef.get();
    if (userData.exists && userData.get(FSUserConstants.isEnabled.value)) {
      var activityRef = userRef
          .collection(FireStoreUserConstants.userActivityCollectionPath.value)
          .doc(activityId);

      var activityData = await activityRef.get();
      if (activityData.exists) {
        var userTagData = await activityRef
            .collection(FireStoreUserConstants.userTagCollectionPath.value)
            .get();

        for (var tagData in userTagData.docs) {
          await tagData.reference.delete();
        }

        await activityRef.delete();
        return true;
      }
    }

    return false;
  }

  /// 刪除使用者活動標籤資料
  Future<bool> removeUserTag(
    String userId,
    String activityId,
    String tagId,
  ) async {
    var userRef = db
        .collection(FireStoreUserConstants.userCollectionPath.value)
        .doc(userId);

    var userData = await userRef.get();
    if (userData.exists && userData.get(FSUserConstants.isEnabled.value)) {
      var activityRef = userRef
          .collection(FireStoreUserConstants.userActivityCollectionPath.value)
          .doc(activityId);

      var activityData = await activityRef.get();
      if (activityData.exists) {
        var tagRef = activityRef
            .collection(FireStoreUserConstants.userTagCollectionPath.value)
            .doc(tagId);

        var tagData = await tagRef.get();
        if (tagData.exists) {
          await tagRef.delete();
          return true;
        }
      }
    }

    return false;
  }

  /// 修改(含啟用)使用者資料
  ///
  /// [updateSocial] 是否更新社群媒體資料
  ///
  /// [updateActivity] 是否更新活動及標籤資料
  ///
  /// [updateTag] 是否更新活動標籤資料
  Future<User?> updateUser(
    User user, {
    bool updateSocial = false,
    bool updateActivity = false,
    bool updateTag = false,
  }) async {
    var userRef = db
        .collection(FireStoreUserConstants.userCollectionPath.value)
        .doc(user.id);

    var userData = await userRef.get();
    if (userData.exists) {
      var fsUser = user.toFSUser();
      await userRef.update(fsUser.toJson());

      if (updateSocial) {
        for (var socialMedia in user.socialMedia) {
          await updateUserSocialMedia(user.id, socialMedia);
        }
      }

      if (updateActivity) {
        for (var activity in user.activities) {
          await updateUserActivity(user.id, activity);

          if (updateTag) {
            for (var tag in activity.tags) {
              await updateUserTag(user.id, activity.id, tag);
            }
          }
        }
      }

      return await getUser(
        user.id,
        loadSocial: updateSocial,
        loadActivity: updateActivity,
      );
    }

    return null;
  }

  /// 修改使用者社群媒體資料
  Future<User?> updateUserSocialMedia(
    String userId,
    UserSocialMedia socialMedia,
  ) async {
    var userRef = db
        .collection(FireStoreUserConstants.userCollectionPath.value)
        .doc(userId);

    var userData = await userRef.get();
    if (userData.exists && userData.get(FSUserConstants.isEnabled.value)) {
      var socialMediaRef = userRef
          .collection(
              FireStoreUserConstants.userSocialMediaCollectionPath.value)
          .doc(socialMedia.displayName);

      var socialMediaData = await socialMediaRef.get();
      if (socialMediaData.exists) {
        var fsUserSocialMedia = socialMedia.toFSUserSocialMedia();
        await socialMediaRef.update(fsUserSocialMedia.toJson());
        return await getUser(userId, loadSocial: true);
      }
    }

    return null;
  }

  /// 修改使用者活動資料
  ///
  /// [updateTag] 是否更新活動標籤資料
  Future<User?> updateUserActivity(
    String userId,
    UserActivity activity, {
    bool updateTag = false,
  }) async {
    var userRef = db
        .collection(FireStoreUserConstants.userCollectionPath.value)
        .doc(userId);

    var userData = await userRef.get();
    if (userData.exists && userData.get(FSUserConstants.isEnabled.value)) {
      var activityRef = userRef
          .collection(FireStoreUserConstants.userActivityCollectionPath.value)
          .doc(activity.id);

      var activityData = await activityRef.get();
      if (activityData.exists) {
        var fsUserActivity = activity.toFSUserActivity();
        await activityRef.update(fsUserActivity.toJson());

        if (updateTag) {
          for (var tag in activity.tags) {
            await updateUserTag(userId, activity.id, tag);
          }
        }

        return await getUser(userId, loadActivity: true);
      }
    }

    return null;
  }

  /// 修改使用者活動標籤資料
  Future<User?> updateUserTag(
    String userId,
    String activityId,
    UserTag tag,
  ) async {
    var userRef = db
        .collection(FireStoreUserConstants.userCollectionPath.value)
        .doc(userId);

    var userData = await userRef.get();
    if (userData.exists && userData.get(FSUserConstants.isEnabled.value)) {
      var activityRef = userRef
          .collection(FireStoreUserConstants.userActivityCollectionPath.value)
          .doc(activityId);

      var activityData = await activityRef.get();
      if (activityData.exists) {
        var tagRef = activityRef
            .collection(FireStoreUserConstants.userTagCollectionPath.value)
            .doc(tag.id);

        var tagData = await tagRef.get();
        if (tagData.exists) {
          var fsUserTag = tag.toFSUserTag();
          await tagRef.update(fsUserTag.toJson());
          return await getUser(userId, loadActivity: true);
        }
      }
    }

    return null;
  }

  /// 取得使用者資料
  ///
  /// [loadSocial] 是否載入社群媒體資料
  ///
  /// [loadActivity] 是否載入活動及標籤資料
  Future<User?> getUser(
    String userId, {
    bool loadSocial = false,
    bool loadActivity = false,
  }) async {
    var userRef = db
        .collection(FireStoreUserConstants.userCollectionPath.value)
        .doc(userId);

    var userData = await userRef.get();
    if (userData.exists && userData.get(FSUserConstants.isEnabled.value)) {
      var fsUser = FSUser.fromDocument(userData);
      var user = fsUser.toUser();

      if (loadSocial) {
        var userSocialMediaData = await userRef
            .collection(
                FireStoreUserConstants.userSocialMediaCollectionPath.value)
            .get();

        user.socialMedia.addAll(userSocialMediaData.docs.map((e) {
          var fsUserSocialMedia = FSUserSocialMedia.fromDocument(e);
          var userSocialMedia = fsUserSocialMedia.toUserSocialMedia();

          return userSocialMedia;
        }));
      }

      if (loadActivity) {
        var userActivityData = await userRef
            .collection(FireStoreUserConstants.userActivityCollectionPath.value)
            .get();

        user.activities.addAll(userActivityData.docs.map((e) {
          var fsUserActivity = FSUserActivity.fromDocument(e);
          var userActivity = fsUserActivity.toUserActivity();

          return userActivity;
        }));

        for (var activity in user.activities) {
          var userTagData = await userRef
              .collection(
                  FireStoreUserConstants.userActivityCollectionPath.value)
              .doc(activity.id)
              .collection(FireStoreUserConstants.userTagCollectionPath.value)
              .get();

          activity.tags.addAll(userTagData.docs.map((e) {
            var fsUserTag = FSUserTag.fromDocument(e);
            var userTag = fsUserTag.toUserTag();

            return userTag;
          }));
        }
      }

      return user;
    }

    return null;
  }

  /// 取得使用者社群媒體資料
  Future<List<UserSocialMedia>> getUserSocialMedia(String userId) async {
    var userRef = db
        .collection(FireStoreUserConstants.userCollectionPath.value)
        .doc(userId);

    var userData = await userRef.get();
    if (userData.exists && userData.get(FSUserConstants.isEnabled.value)) {
      var userSocialMediaData = await userRef
          .collection(
              FireStoreUserConstants.userSocialMediaCollectionPath.value)
          .get();

      return userSocialMediaData.docs.map((e) {
        var fsUserSocialMedia = FSUserSocialMedia.fromDocument(e);
        var userSocialMedia = fsUserSocialMedia.toUserSocialMedia();

        return userSocialMedia;
      }).toList();
    }

    return [];
  }

  /// 取得使用者活動資料
  ///
  /// [loadTag] 是否載入活動標籤資料
  Future<UserActivity?> getUserActivity(
    String userId,
    String activityId, {
    bool loadTag = false,
  }) async {
    var userRef = db
        .collection(FireStoreUserConstants.userCollectionPath.value)
        .doc(userId);

    var userData = await userRef.get();

    if (userData.exists && userData.get(FSUserConstants.isEnabled.value)) {
      var userActivityData = await userRef
          .collection(FireStoreUserConstants.userActivityCollectionPath.value)
          .doc(activityId)
          .get();

      if (userActivityData.exists) {
        var fsUserActivity = FSUserActivity.fromDocument(userActivityData);
        var userActivity = fsUserActivity.toUserActivity();

        if (loadTag) {
          var userTagData = await userRef
              .collection(
                  FireStoreUserConstants.userActivityCollectionPath.value)
              .doc(activityId)
              .collection(FireStoreUserConstants.userTagCollectionPath.value)
              .get();

          userActivity.tags.addAll(userTagData.docs.map((e) {
            var fsUserTag = FSUserTag.fromDocument(e);
            var userTag = fsUserTag.toUserTag();

            return userTag;
          }));
        }

        return userActivity;
      }
    }

    return null;
  }
}
