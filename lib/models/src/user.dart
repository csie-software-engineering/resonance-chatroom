import 'package:cloud_firestore/cloud_firestore.dart';

import '../../constants/constants.dart';

class UserTag {
  final String id;
  final String displayName;

  const UserTag({
    required this.id,
    required this.displayName,
  });

  Map<String, dynamic> toJson() => {
        UserTagConstants.id.value: id,
        UserTagConstants.displayName.value: displayName,
      };

  factory UserTag.fromJson(Map<String, dynamic> json) => UserTag(
        id: json[UserTagConstants.id.value],
        displayName: json[UserTagConstants.displayName.value],
      );

  factory UserTag.fromDocument(DocumentSnapshot<Map<String, dynamic>> doc) =>
      UserTag.fromJson(doc.data()!);
}

class UserActivity {
  final String id;
  final String displayName;
  final List<UserTag> tags;

  const UserActivity({
    required this.id,
    required this.displayName,
    required this.tags,
  });

  Map<String, dynamic> toJson() => {
        UserActivityConstants.id.value: id,
        UserActivityConstants.displayName.value: displayName,
        UserActivityConstants.tags.value: tags.map((e) => e.toJson()).toList(),
      };

  factory UserActivity.fromJson(Map<String, dynamic> json) => UserActivity(
        id: json[UserActivityConstants.id.value],
        displayName: json[UserActivityConstants.displayName.value],
        tags: json[UserActivityConstants.tags.value]
            .map<UserTag>((e) => UserTag.fromJson(e))
            .toList(),
      );

  factory UserActivity.fromDocument(
          DocumentSnapshot<Map<String, dynamic>> doc) =>
      UserActivity.fromJson(doc.data()!);
}

class User {
  final String id;
  final String displayName;
  final String photoUrl;
  final String email;
  final List<UserActivity> activities;

  const User({
    required this.id,
    required this.displayName,
    required this.photoUrl,
    required this.email,
    required this.activities,
  });

  Map<String, dynamic> toJson() => {
        UserConstants.id.value: id,
        UserConstants.displayName.value: displayName,
        UserConstants.photoUrl.value: photoUrl,
        UserConstants.email.value: email,
        UserConstants.activities.value:
            activities.map((e) => e.toJson()).toList(),
      };

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json[UserConstants.id.value],
        displayName: json[UserConstants.displayName.value],
        photoUrl: json[UserConstants.photoUrl.value],
        email: json[UserConstants.email.value],
        activities: json[UserConstants.activities.value]
            .map<UserActivity>((e) => UserActivity.fromJson(e))
            .toList(),
      );

  factory User.fromDocument(DocumentSnapshot<Map<String, dynamic>> doc) =>
      User.fromJson(doc.data()!);
}
