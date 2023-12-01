import 'package:cloud_firestore/cloud_firestore.dart';

import '../../constants/constants.dart';

class Room {
  final String tag;
  final bool isEnable;
  List<RoomUser> users;

  Room({
    required this.tag,
    required this.isEnable,
    required this.users,
  });

  Map<String, dynamic> toJson() {
    return {
      RoomConstants.tag.value: tag,
      RoomConstants.isEnable.value: isEnable,
      RoomConstants.users.value: users.map((e) => e.toJson()).toList(),
    };
  }

  factory Room.fromJson(Map<String, dynamic> json) {
    String tag = json[RoomConstants.tag.value];
    bool isEnable = json[RoomConstants.isEnable.value];
    List<RoomUser> users = (json[RoomConstants.users.value] as List)
        .map((e) => RoomUser.fromJson(e))
        .toList();
    return Room(
      tag: tag,
      isEnable: isEnable,
      users: users,
    );
  }

  factory Room.fromDocument(DocumentSnapshot<Map<String, dynamic>> doc) =>
      Room.fromJson(doc.data()!);
}

class RoomUser {
  String id;
  bool shareSocialMedia;

  RoomUser({
    required this.id,
    required this.shareSocialMedia,
  });

  Map<String, dynamic> toJson() {
    return {
      RoomUserConstants.id.value: id,
      RoomUserConstants.shareSocialMedia.value: shareSocialMedia,
    };
  }

  factory RoomUser.fromJson(Map<String, dynamic> json) {
    String id = json[RoomUserConstants.id.value];
    bool shareSocialMedia = json[RoomUserConstants.shareSocialMedia.value];
    return RoomUser(
      id: id,
      shareSocialMedia: shareSocialMedia,
    );
  }

  factory RoomUser.fromDocument(DocumentSnapshot<Map<String, dynamic>> doc) =>
      RoomUser.fromJson(doc.data()!);
}