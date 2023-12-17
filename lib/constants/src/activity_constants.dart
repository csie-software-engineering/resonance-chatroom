enum ActivityConstants {
  uid,
  activityName,
  ownerId,
  activityInfo,
  startDate,
  endDate,
  activityPhoto,
  isEnabled,
  managers;

  String get value {
    switch (this) {
      case ActivityConstants.uid:
        return "uid";
      case ActivityConstants.activityName:
        return "activityName";
      case ActivityConstants.ownerId:
        return "ownerId";
      case ActivityConstants.activityInfo:
        return "activityInfo";
      case ActivityConstants.startDate:
        return "startDate";
      case ActivityConstants.endDate:
        return "endDate";
      case ActivityConstants.activityPhoto:
        return "activityPhoto";
      case ActivityConstants.isEnabled:
        return "isEnabled";
      case ActivityConstants.managers:
        return "managers";
      default:
        throw Exception("Not found value for ActivityConstants");
    }
  }
}

enum TagConstants{
  uid,
  activityId,
  tagName;

  String get value {
    switch (this) {
      case TagConstants.uid:
        return "uid";
      case TagConstants.activityId:
        return "activityId";
      case TagConstants.tagName:
        return "tagName";
      default:
        throw Exception("Not found value for TagConstants");
    }
  }
}

enum TopicConstants{
  uid,
  activityId,
  tagId,
  topicName;

  String get value {
    switch (this) {
      case TopicConstants.uid:
        return "uid";
      case TopicConstants.activityId:
        return "activityId";
      case TopicConstants.tagId:
        return "tagId";
      case TopicConstants.topicName:
        return "topicName";
      default:
        throw Exception("Not found value for TopicConstants");
    }
  }
}

enum QuestionConstants{
  activityId,
  tagId,
  topicId,
  questionId,
  questionName,
  choices;

  String get value {
    switch (this) {
      case QuestionConstants.activityId:
        return "activityId";
      case QuestionConstants.tagId:
        return "tagId";
      case QuestionConstants.topicId:
        return "topicId";
      case QuestionConstants.questionId:
        return "questionId";
      case QuestionConstants.questionName:
        return "questionName";
      case QuestionConstants.choices:
        return "choices";
      default:
        throw Exception("Not found value for QuestionConstants");
    }
  }
}

enum ReplyConstants{
  choice,
  email;

  String get value {
    switch (this) {
      case ReplyConstants.choice:
        return "choice";
      case ReplyConstants.email:
        return "email";
      default:
        throw Exception("Not found value for ReviewConstants");
    }
  }
}