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

enum RoomDetailConstants {
  tag,
  isShowSocialMedia,
  isEnable;

  String get value {
    switch (this) {
      case RoomDetailConstants.tag:
        return "tag";
      case RoomDetailConstants.isEnable:
        return "isEnable";
      case RoomDetailConstants.isShowSocialMedia:
        return "isShowSocialMedia";
      default:
        throw Exception("Not found value for RoomDetailConstants");
    }
  }
}
