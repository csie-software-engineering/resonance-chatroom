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
  userId,
  activityId,
  tagIds,
  timestamp;

  String get value {
    switch (this) {
      case QueueConstants.userId:
        return "userId";
      case QueueConstants.activityId:
        return "activityId";
      case QueueConstants.tagIds:
        return "tag";
      case QueueConstants.timestamp:
        return "timestamp";
      default:
        throw Exception("Not found value for QueueConstants");
    }
  }
}

enum RoomConstants {
  users,
  tagId,
  topicId,
  isEnable;

  String get value {
    switch (this) {
      case RoomConstants.users:
        return "userIds";
      case RoomConstants.tagId:
        return "tagId";
      case RoomConstants.topicId:
        return "topicId";
      case RoomConstants.isEnable:
        return "isEnable";
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

enum ReportConstants {
  uid,
  idFrom,
  idTo,
  activityId,
  content;

  String get value {
    switch (this) {
      case ReportConstants.uid:
        return "uid";
      case ReportConstants.idFrom:
        return "idFrom";
      case ReportConstants.idTo:
        return "idTo";
      case ReportConstants.activityId:
        return "activityId";
      case ReportConstants.content:
        return "content";
      default:
        throw Exception("Not found value for ReportConstants");
    }
  }
}