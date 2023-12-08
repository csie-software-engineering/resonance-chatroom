import 'package:resonance_chatroom/models/src/firestore/fs_user.dart';

class User {
  final String id;
  String? displayName;
  String? email;
  String? photoUrl;
  bool isEnabled;
  final List<UserSocialMedia> socialMedia;
  final List<UserActivity> activities;

  User({
    required this.id,
    this.displayName,
    this.email,
    this.photoUrl,
    this.isEnabled = true,
    this.socialMedia = const [],
    this.activities = const [],
  });
}

extension UserExtension on User {
  FSUser toFSUser() {
    assert(displayName != null, "User displayName 不能為 null");
    assert(email != null, "User email 不能為 null");
    return FSUser(
      id: id,
      displayName: displayName!,
      email: email!,
      photoUrl: photoUrl ?? "",
      isEnabled: isEnabled,
    );
  }
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
  String? id;
  String? displayName;
  List<UserTag> tags;

  UserActivity({
    this.id,
    this.displayName,
    this.tags = const [],
  });
}

extension UserActivityExtension on UserActivity {
  FSUserActivity toFSUserActivity() {
    assert(id != null, "UserActivity id 不能為 null");
    assert(displayName != null, "UserActivity displayName 不能為 null");
    return FSUserActivity(
      id: id!,
      displayName: displayName!,
    );
  }
}

class UserTag {
  String? id;
  String? displayName;

  UserTag({
    this.id,
    this.displayName,
  });
}

extension UserTagExtension on UserTag {
  FSUserTag toFSUserTag() {
    assert(id != null, "UserTag id 不能為 null");
    assert(displayName != null, "UserTag displayName 不能為 null");
    return FSUserTag(
      id: id!,
      displayName: displayName!,
    );
  }
}
