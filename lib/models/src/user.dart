import 'package:resonance_chatroom/models/src/firestore/fs_user.dart';

class User {
  final String id;
  final String displayName;
  final String email;
  final String? photo;
  final bool isEnabled;
  final List<UserSocialMedia> socialMedia;
  final List<UserActivity> activities;

  User({
    required this.id,
    required this.displayName,
    required this.email,
    this.photo,
    this.isEnabled = true,
    this.socialMedia = const [],
    this.activities = const [],
  });
}

extension UserExtension on User {
  FSUser toFSUser() => FSUser(
        id: id,
        displayName: displayName,
        email: email,
        photo: photo ?? "",
        isEnabled: isEnabled,
      );
}

class UserSocialMedia {
  String displayName;
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
  String id;
  String displayName;
  List<UserTag> tags;

  UserActivity({
    required this.id,
    required this.displayName,
    this.tags = const [],
  });
}

extension UserActivityExtension on UserActivity {
  FSUserActivity toFSUserActivity() => FSUserActivity(
        id: id,
        displayName: displayName,
      );
}

class UserTag {
  final String id;
  final String displayName;

  UserTag({
    required this.id,
    required this.displayName,
  });
}

extension UserTagExtension on UserTag {
  FSUserTag toFSUserTag() => FSUserTag(
        id: id,
        displayName: displayName,
      );
}
