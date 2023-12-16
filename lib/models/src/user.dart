import 'package:resonance_chatroom/models/src/firestore/fs_user.dart';

class User {
  final String uid;
  String displayName;
  String? email;
  String? photoUrl;
  late bool isEnabled;
  final List<UserSocialMedia> socialMedia;
  final List<UserActivity> activities;

  User({
    required this.uid,
    required this.displayName,
    this.email,
    this.photoUrl,
    this.socialMedia = const [],
    this.activities = const [],
  });

  @override
  String toString() =>
      'User(uid: $uid, displayName: $displayName, email: $email, photoUrl: $photoUrl, isEnabled: $isEnabled)';
}

extension UserExtension on User {
  FSUser toFSUser() => FSUser(
        uid: uid,
        displayName: displayName,
        email: email ?? "",
        photoUrl: photoUrl ?? "",
        isEnabled: isEnabled,
      );
}

class UserSocialMedia {
  final String displayName;
  String linkUrl;

  UserSocialMedia({
    required this.displayName,
    required this.linkUrl,
  });

  @override
  String toString() =>
      'UserSocialMedia(displayName: $displayName, linkUrl: $linkUrl)';
}

extension UserSocialMediaExtension on UserSocialMedia {
  FSUserSocialMedia toFSUserSocialMedia() => FSUserSocialMedia(
        displayName: displayName,
        linkUrl: linkUrl,
      );
}

class UserActivity {
  final String uid;
  final bool isManager;
  List<String> tagIds;

  UserActivity({
    required this.uid,
    required this.isManager,
    this.tagIds = const [],
  });

  @override
  String toString() => 'UserActivity(uid: $uid, host: $isManager, tagIds: $tagIds)';
}

extension UserActivityExtension on UserActivity {
  FSUserActivity toFSUserActivity() => FSUserActivity(
        uid: uid,
        isManager: isManager,
        tagIds: tagIds,
      );
}
