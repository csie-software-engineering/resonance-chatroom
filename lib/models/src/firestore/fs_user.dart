import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../constants/constants.dart';
import '../user.dart';

class FSUser {
  final String id;
  final String displayName;
  final String photo;
  final String email;
  final bool isEnabled;

  const FSUser({
    required this.id,
    required this.displayName,
    required this.photo,
    required this.email,
    required this.isEnabled,
  });

  Map<String, dynamic> toJson() => {
        FSUserConstants.id.value: id,
        FSUserConstants.displayName.value: displayName,
        FSUserConstants.photoUrl.value: photo,
        FSUserConstants.email.value: email,
        FSUserConstants.isEnabled.value: isEnabled,
      };

  factory FSUser.fromDocument(DocumentSnapshot<Map<String, dynamic>> doc) =>
      FSUser(
        id: doc.get(FSUserConstants.id.value),
        displayName: doc.get(FSUserConstants.displayName.value),
        photo: doc.get(FSUserConstants.photoUrl.value),
        email: doc.get(FSUserConstants.email.value),
        isEnabled: doc.get(FSUserConstants.isEnabled.value),
      );
}

extension FSUserExtension on FSUser {
  User toUser() => User(
        id: id,
        displayName: displayName,
        photo: photo.isEmpty ? null : photo,
        email: email.isEmpty ? null : email,
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
  final List<String> tagIds;

  const FSUserActivity({
    required this.id,
    required this.tagIds,
  });

  Map<String, dynamic> toJson() => {
        FSUserActivityConstants.id.value: id,
        FSUserActivityConstants.tagIds.value: tagIds,
      };

  factory FSUserActivity.fromDocument(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) =>
      FSUserActivity(
        id: doc.get(FSUserActivityConstants.id.value),
        tagIds: List<String>.from(doc.get(FSUserActivityConstants.tagIds.value)),
      );
}

extension FSUserActivityExtension on FSUserActivity {
  UserActivity toUserActivity() => UserActivity(
        id: id,
        tagIds: tagIds,
      );
}