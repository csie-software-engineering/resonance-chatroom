import 'package:resonance_chatroom/models/src/firestore/fs_user.dart';

class User {
  final String uid;
  String displayName;
  String? email;
  String? photoUrl;
  final bool isEnabled;
  final List<UserSocialMedia> socialMedia;
  final List<UserActivity> activities;

  User({
    required this.uid,
    required this.displayName,
    this.email,
    this.photoUrl,
    this.isEnabled = true,
    this.socialMedia = const [],
    this.activities = const [],
  });
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
}

extension UserSocialMediaExtension on UserSocialMedia {
  FSUserSocialMedia toFSUserSocialMedia() => FSUserSocialMedia(
        displayName: displayName,
        linkUrl: linkUrl,
      );
}

class UserActivity {
  final String uid;
  List<String> tagIds;

  UserActivity({
    required this.uid,
    this.tagIds = const [],
  });
}

extension UserActivityExtension on UserActivity {
  FSUserActivity toFSUserActivity() => FSUserActivity(
        uid: uid,
        tagIds: tagIds,
      );
}
