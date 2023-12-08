import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../constants/constants.dart';
import '../user.dart';

class FSUser {
  final String id;
  final String displayName;
  final String photoUrl;
  final String email;
  final bool isEnabled;

  const FSUser({
    required this.id,
    required this.displayName,
    required this.photoUrl,
    required this.email,
    this.isEnabled = true,
  });

  Map<String, dynamic> toJson() => {
        FSUserConstants.id.value: id,
        FSUserConstants.displayName.value: displayName,
        FSUserConstants.photoUrl.value: photoUrl,
        FSUserConstants.email.value: email,
        FSUserConstants.isEnabled.value: isEnabled,
      };

  factory FSUser.fromDocument(DocumentSnapshot<Map<String, dynamic>> doc) =>
      FSUser(
        id: doc.get(FSUserConstants.id.value),
        displayName: doc.get(FSUserConstants.displayName.value),
        photoUrl: doc.get(FSUserConstants.photoUrl.value),
        email: doc.get(FSUserConstants.email.value),
        isEnabled: doc.get(FSUserConstants.isEnabled.value),
      );
}

extension FSUserExtension on FSUser {
  User toUser() => User(
        id: id,
        displayName: displayName,
        photoUrl: photoUrl,
        email: email,
        socialMedia: [],
        activities: [],
      );
}

class FSUserSocialMedia {
  final String displayName;
  final String linkUrl;

  const FSUserSocialMedia({
    required this.displayName,
    required this.linkUrl,
  });

  Map<String, dynamic> toJson() => {
        FSUserSocialMediaConstants.displayName.value: displayName,
        FSUserSocialMediaConstants.linkUrl.value: linkUrl,
      };

  factory FSUserSocialMedia.fromDocument(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) =>
      FSUserSocialMedia(
        displayName: doc.get(FSUserSocialMediaConstants.displayName.value),
        linkUrl: doc.get(FSUserSocialMediaConstants.linkUrl.value),
      );
}

extension FSUserSocialMediaExtension on FSUserSocialMedia {
  UserSocialMedia toUserSocialMedia() => UserSocialMedia(
        displayName: displayName,
        linkUrl: linkUrl,
      );
}

class FSUserActivity {
  final String id;
  final String displayName;

  const FSUserActivity({
    required this.id,
    required this.displayName,
  });

  Map<String, dynamic> toJson() => {
        FSUserActivityConstants.id.value: id,
        FSUserActivityConstants.displayName.value: displayName,
      };

  factory FSUserActivity.fromDocument(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) =>
      FSUserActivity(
        id: doc.get(FSUserActivityConstants.id.value),
        displayName: doc.get(FSUserActivityConstants.displayName.value),
      );
}

extension FSUserActivityExtension on FSUserActivity {
  UserActivity toUserActivity() => UserActivity(
        id: id,
        displayName: displayName,
        tags: [],
      );
}

class FSUserTag {
  final String id;
  final String displayName;

  const FSUserTag({
    required this.id,
    required this.displayName,
  });

  Map<String, dynamic> toJson() => {
        FSUserTagConstants.id.value: id,
        FSUserTagConstants.displayName.value: displayName,
      };

  factory FSUserTag.fromDocument(DocumentSnapshot<Map<String, dynamic>> doc) =>
      FSUserTag(
        id: doc.get(FSUserTagConstants.id.value),
        displayName: doc.get(FSUserTagConstants.displayName.value),
      );
}

extension FSUserTagExtension on FSUserTag {
  UserTag toUserTag() => UserTag(
        id: id,
        displayName: displayName,
      );
}
