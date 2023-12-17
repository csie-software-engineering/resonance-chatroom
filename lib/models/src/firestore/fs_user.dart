import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../constants/constants.dart';
import '../user.dart';

class FSUser {
  final String uid;
  final String displayName;
  final String photoUrl;
  final String email;
  final bool isEnabled;

  const FSUser({
    required this.uid,
    required this.displayName,
    required this.photoUrl,
    required this.email,
    required this.isEnabled,
  });

  Map<String, dynamic> toJson() => {
        FSUserConstants.uid.value: uid,
        FSUserConstants.displayName.value: displayName,
        FSUserConstants.photoUrl.value: photoUrl,
        FSUserConstants.email.value: email,
        FSUserConstants.isEnabled.value: isEnabled,
      };

  factory FSUser.fromDocument(DocumentSnapshot<Map<String, dynamic>> doc) =>
      FSUser(
        uid: doc.get(FSUserConstants.uid.value),
        displayName: doc.get(FSUserConstants.displayName.value),
        photoUrl: doc.get(FSUserConstants.photoUrl.value),
        email: doc.get(FSUserConstants.email.value),
        isEnabled: doc.get(FSUserConstants.isEnabled.value),
      );

  @override
  String toString() =>
      'FSUser(uid: $uid, displayName: $displayName, photoUrl: $photoUrl, email: $email, isEnabled: $isEnabled)';
}

extension FSUserExtension on FSUser {
  User toUser() {
    var user = User(
      uid: uid,
      displayName: displayName,
      photoUrl: photoUrl.isEmpty ? null : photoUrl,
      email: email.isEmpty ? null : email,
      socialMedia: const [],
      activities: const [],
    );

    user.isEnabled = isEnabled;
    return user;
  }
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

  @override
  String toString() =>
      'FSUserSocialMedia(displayName: $displayName, linkUrl: $linkUrl)';
}

extension FSUserSocialMediaExtension on FSUserSocialMedia {
  UserSocialMedia toUserSocialMedia() => UserSocialMedia(
        displayName: displayName,
        linkUrl: linkUrl,
      );
}

class FSUserActivity {
  final String uid;
  final bool isManager;
  final List<String> tagIds;

  const FSUserActivity({
    required this.uid,
    required this.isManager,
    required this.tagIds,
  });

  Map<String, dynamic> toJson() => {
        FSUserActivityConstants.uid.value: uid,
        FSUserActivityConstants.tagIds.value: tagIds,
      };

  factory FSUserActivity.fromDocument(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) =>
      FSUserActivity(
        uid: doc.get(FSUserActivityConstants.uid.value),
        isManager: doc.get(FSUserActivityConstants.isManager.value),
        tagIds:
            List<String>.from(doc.get(FSUserActivityConstants.tagIds.value)),
      );

  @override
  String toString() => 'FSUserActivity(uid: $uid, tagIds: $tagIds)';
}

extension FSUserActivityExtension on FSUserActivity {
  UserActivity toUserActivity() => UserActivity(
        uid: uid,
        isManager: isManager,
        tagIds: tagIds,
      );
}
