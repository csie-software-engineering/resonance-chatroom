enum ActivityConstants {
  activityName,
  ownerId,
  activityId,
  activityInfo,
  startDate,
  endDate,
  activityPhoto,
  isEnabled,
  managers;

  String get value {
    switch (this) {
      case ActivityConstants.activityName:
        return "activityName";
      case ActivityConstants.ownerId:
        return "ownerId";
      case ActivityConstants.activityId:
        return "activityId";
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
  activityId,
  tagId,
  tagName;

  String get value {
    switch (this) {
      case TagConstants.activityId:
        return "activityId";
      case TagConstants.tagId:
        return "tagId";
      case TagConstants.tagName:
        return "tagName";
      default:
        throw Exception("Not found value for TagConstants");
    }
  }
}

enum TopicConstants{
  activityId,
  tagId,
  topicName,
  topicId;

  String get value {
    switch (this) {
      case TopicConstants.activityId:
        return "activityId";
      case TopicConstants.tagId:
        return "tagId";
      case TopicConstants.topicId:
        return "topicId";
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
  choices,
  choice,
  userList;

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
      case QuestionConstants.choice:
        return "choice";
      case QuestionConstants.userList:
        return "userList";
      default:
        throw Exception("Not found value for QuestionConstants");
    }
  }
}