import 'package:resonance_chatroom/models/src/firestore/fs_user.dart';

class User {
  final String id;
  String displayName;
  String? email;
  String? photo;
  final bool isEnabled;
  final List<UserSocialMedia> socialMedia;
  final List<UserActivity> activities;

  User({
    required this.id,
    required this.displayName,
    this.email,
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
        email: email ?? "",
        photo: photo ?? "",
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
  final String id;
  List<String> tagIds;

  UserActivity({
    required this.id,
    this.tagIds = const [],
  });
}

extension UserActivityExtension on UserActivity {
  FSUserActivity toFSUserActivity() => FSUserActivity(
        id: id,
        tagIds: tagIds,
      );
}
