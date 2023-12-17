import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:resonance_chatroom/constants/constants.dart';

class Activity {
  final String ownerId;
  String activityId;
  String activityName;
  String activityInfo;
  String startDate;
  String endDate;
  final bool isEnabled;
  String activityPhoto;
  final List<String> managers;

  Activity({
    required this.ownerId,
    this.activityId = "",
    required this.activityName,
    required this.activityInfo,
    required this.startDate,
    required this.endDate,
    this.isEnabled = true,
    required this.activityPhoto,
    this.managers = const []
  });

  Map<String, dynamic> toJson() {
    return {
      ActivityConstants.ownerId.value: ownerId,
      ActivityConstants.activityId.value: activityId,
      ActivityConstants.activityName.value: activityName,
      ActivityConstants.activityInfo.value: activityInfo,
      ActivityConstants.startDate.value: startDate,
      ActivityConstants.endDate.value: endDate,
      ActivityConstants.isEnabled.value: isEnabled,
      ActivityConstants.activityPhoto.value: activityPhoto,
      ActivityConstants.managers.value: managers
    };
  }

  factory Activity.fromDocument(DocumentSnapshot doc) {
    String ownerId = doc.get(ActivityConstants.ownerId.value);
    String activityId = doc.get(ActivityConstants.activityId.value);
    String activityName = doc.get(ActivityConstants.activityName.value);
    String activityInfo = doc.get(ActivityConstants.activityInfo.value);
    String startDate = doc.get(ActivityConstants.startDate.value);
    String endDate = doc.get(ActivityConstants.endDate.value);
    bool isEnabled = doc.get(ActivityConstants.isEnabled.value);
    String activityPhoto = doc.get(ActivityConstants.activityPhoto.value);
    List<dynamic> managers = doc.get(ActivityConstants.managers.value);
    return Activity(
      ownerId: ownerId,
      activityId: activityId,
      activityName: activityName,
      activityInfo: activityInfo,
      startDate: startDate,
      endDate: endDate,
      isEnabled: isEnabled,
      activityPhoto: activityPhoto,
      managers: managers.cast<String>()
    );
  }
}

class Tag {
  final String activityId;
  String tagName;
  final String tagId;

  Tag({
    required this.activityId,
    this.tagName = "",
    required this.tagId,
  });

  Map<String, dynamic> toJson() {
    return {
      TagConstants.activityId.value: activityId,
      TagConstants.tagName.value: tagName,
      TagConstants.tagId.value: tagId,
    };
  }

  factory Tag.fromDocument(DocumentSnapshot doc) {
    String activityId = doc.get(TagConstants.activityId.value);
    String tagName = doc.get(TagConstants.tagName.value);
    String tagId = doc.get(TagConstants.tagId.value);
    return Tag(
      activityId: activityId,
      tagName: tagName,
      tagId: tagId,
    );
  }
}

class Topic {
  final String activityId;
  final String tagId;
  String topicName;
  final String topicId;

  Topic({
    required this.activityId,
    required this.tagId,
    this.topicName = "",
    required this.topicId,
  });

  Map<String, dynamic> toJson() {
    return {
      TopicConstants.activityId.value: activityId,
      TopicConstants.tagId.value: tagId,
      TopicConstants.topicName.value: topicName,
      TopicConstants.topicId.value: topicId,
    };
  }

  factory Topic.fromDocument(DocumentSnapshot doc) {
    String activityId = doc.get(TopicConstants.activityId.value);
    String tagId = doc.get(TopicConstants.tagId.value);
    String topicName = doc.get(TopicConstants.topicName.value);
    String topicId = doc.get(TopicConstants.topicId.value);
    return Topic(
      activityId: activityId,
      tagId: tagId,
      topicName: topicName,
      topicId: topicId,
    );
  }
}

class Question {
  final String activityId;
  final String tagId;
  final String topicId;
  final String questionId;
  String questionName;
  final List<String> choices;


  Question({
    required this.activityId,
    required this.tagId,
    required this.topicId,
    required this.questionId,
    this.questionName = "",
    required this.choices,
  });

  Map<String, dynamic> toJson() {
    return {
      QuestionConstants.activityId.value: activityId,
      QuestionConstants.tagId.value: tagId,
      QuestionConstants.topicId.value: topicId,
      QuestionConstants.questionId.value: questionId,
      QuestionConstants.questionName.value: questionName,
      QuestionConstants.choices.value: choices,
    };
  }

  factory Question.fromDocument(DocumentSnapshot doc) {
    String activityId = doc.get(QuestionConstants.activityId.value);
    String tagId = doc.get(QuestionConstants.tagId.value);
    String topicId = doc.get(QuestionConstants.topicId.value);
    String questionId = doc.get(QuestionConstants.questionId.value);
    String questionName = doc.get(QuestionConstants.questionName.value);
    List<dynamic> choices = doc.get(QuestionConstants.choices.value);
    return Question(
      activityId: activityId,
      tagId: tagId,
      topicId: topicId,
      questionId: questionId,
      questionName: questionName,
      choices: choices.cast<String>(),
    );
  }
}

class Review{
  final String choice;
  final List<String> userList;

  const Review({
    required this.choice,
    required this.userList
  });

  Map<String, dynamic> toJson() {
    return {
      QuestionConstants.choice.value: choice,
      QuestionConstants.userList.value: userList
    };
  }

  factory Review.fromDocument(DocumentSnapshot doc) {
    String choice = doc.get(QuestionConstants.choice.value);
    List<dynamic> userList = doc.get(QuestionConstants.userList.value);
    return Review(
        choice: choice,
        userList: userList.cast<String>()
    );
  }
}