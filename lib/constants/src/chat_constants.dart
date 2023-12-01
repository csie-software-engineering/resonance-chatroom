enum MessageConstants {
  idFrom,
  idTo,
  timestamp,
  content,
  type;

  String get value {
    switch (this) {
      case MessageConstants.idFrom:
        return "idFrom";
      case MessageConstants.idTo:
        return "idTo";
      case MessageConstants.timestamp:
        return "timestamp";
      case MessageConstants.content:
        return "content";
      case MessageConstants.type:
        return "type";
      default:
        throw Exception("Not found value for MessageConstants");
    }
  }
}

enum QueueConstants {
  activityId,
  tag,
  userId,
  timestamp;

  String get value {
    switch (this) {
      case QueueConstants.activityId:
        return "activityId";
      case QueueConstants.tag:
        return "tag";
      case QueueConstants.userId:
        return "userId";
      case QueueConstants.timestamp:
        return "timestamp";
      default:
        throw Exception("Not found value for QueueConstants");
    }
  }
}

enum RoomConstants {
  tag,
  isEnable,
  users;

  String get value {
    switch (this) {
      case RoomConstants.tag:
        return "tag";
      case RoomConstants.isEnable:
        return "isEnable";
      case RoomConstants.users:
        return "users";
      default:
        throw Exception("Not found value for RoomConstants");
    }
  }
}

enum RoomUserConstants {
  id,
  shareSocialMedia;

  String get value {
    switch (this) {
      case RoomUserConstants.id:
        return "id";
      case RoomUserConstants.shareSocialMedia:
        return "shareSocialMedia";
      default:
        throw Exception("Not found value for RoomUserConstants");
    }
  }
}
