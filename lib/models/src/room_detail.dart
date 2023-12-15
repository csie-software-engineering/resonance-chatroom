import 'package:cloud_firestore/cloud_firestore.dart';

import '../../constants/constants.dart';

class Room {
  List<RoomUser> users;
  final String tag;
  final bool isEnable;

  Room({
    required this.users,
    required this.tag,
    required this.isEnable,
  });

  Map<String, dynamic> toJson() {
    return {
      RoomConstants.users.value: users.map((e) => e.toJson()).toList(),
      RoomConstants.tag.value: tag,
      RoomConstants.isEnable.value: isEnable,
    };
  }

  factory Room.fromJson(Map<String, dynamic> json) {
    List<RoomUser> users = (json[RoomConstants.users.value] as List)
        .map((e) => RoomUser.fromJson(e))
        .toList();
    String tag = json[RoomConstants.tag.value];
    bool isEnable = json[RoomConstants.isEnable.value];
    return Room(
      users: users,
      tag: tag,
      isEnable: isEnable,
    );
  }

  factory Room.fromDocument(DocumentSnapshot<Map<String, dynamic>> doc) =>
      Room.fromJson(doc.data()!);

  @override
  String toString() =>
      'Room(users: $users, tag: $tag, isEnable: $isEnable)';
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

  @override
  String toString() =>
      'RoomUser(id: $id, shareSocialMedia: $shareSocialMedia)';
}