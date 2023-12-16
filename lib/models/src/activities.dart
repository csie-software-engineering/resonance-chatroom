import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:resonance_chatroom/constants/constants.dart';

class Activity {
  late String uid;
  late String ownerId;
  String activityName;
  String activityInfo;
  String startDate;
  String endDate;
  String activityPhoto;
  late bool isEnabled;
  final List<String> managers;

  Activity({
    required this.activityName,
    required this.activityInfo,
    required this.startDate,
    required this.endDate,
    required this.activityPhoto,
    this.managers = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      ActivityConstants.ownerId.value: ownerId,
      ActivityConstants.uid.value: uid,
      ActivityConstants.activityName.value: activityName,
      ActivityConstants.activityInfo.value: activityInfo,
      ActivityConstants.startDate.value: startDate,
      ActivityConstants.endDate.value: endDate,
      ActivityConstants.isEnabled.value: isEnabled,
      ActivityConstants.activityPhoto.value: activityPhoto,
      ActivityConstants.managers.value: managers,
    };
  }

  factory Activity.fromDocument(DocumentSnapshot doc) {
    String ownerId = doc.get(ActivityConstants.ownerId.value);
    String activityId = doc.get(ActivityConstants.uid.value);
    String activityName = doc.get(ActivityConstants.activityName.value);
    String activityInfo = doc.get(ActivityConstants.activityInfo.value);
    String startDate = doc.get(ActivityConstants.startDate.value);
    String endDate = doc.get(ActivityConstants.endDate.value);
    bool isEnabled = doc.get(ActivityConstants.isEnabled.value);
    String activityPhoto = doc.get(ActivityConstants.activityPhoto.value);
    List<dynamic> managers = doc.get(ActivityConstants.managers.value);

    var activity = Activity(
      activityName: activityName,
      activityInfo: activityInfo,
      startDate: startDate,
      endDate: endDate,
      activityPhoto: activityPhoto,
      managers: managers.cast<String>()
    );

    activity.uid = activityId;
    activity.ownerId = ownerId;
    activity.isEnabled = isEnabled;
    return activity;
  }
}

class Tag {
  late String uid;
  final String activityId;
  String tagName;

  Tag({
    required this.activityId,
    required this.tagName,
  });

  Map<String, dynamic> toJson() {
    return {
      TagConstants.uid.value: uid,
      TagConstants.activityId.value: activityId,
      TagConstants.tagName.value: tagName,
    };
  }

  factory Tag.fromDocument(DocumentSnapshot doc) {
    String uid = doc.get(TagConstants.uid.value);
    String activityId = doc.get(TagConstants.activityId.value);
    String tagName = doc.get(TagConstants.tagName.value);

    var tag = Tag(
      activityId: activityId,
      tagName: tagName,
    );

    tag.uid = uid;
    return tag;
  }
}

class Topic {
  late String uid;
  final String activityId;
  final String tagId;
  String topicName;

  Topic({
    required this.activityId,
    required this.tagId,
    required this.topicName,
  });

  Map<String, dynamic> toJson() {
    return {
      TopicConstants.uid.value: uid,
      TopicConstants.activityId.value: activityId,
      TopicConstants.tagId.value: tagId,
      TopicConstants.topicName.value: topicName,
    };
  }

  factory Topic.fromDocument(DocumentSnapshot doc) {
    String activityId = doc.get(TopicConstants.activityId.value);
    String tagId = doc.get(TopicConstants.tagId.value);
    String topicName = doc.get(TopicConstants.topicName.value);
    String topicId = doc.get(TopicConstants.uid.value);

    var topic = Topic(
      activityId: activityId,
      tagId: tagId,
      topicName: topicName,
    );

    topic.uid = topicId;
    return topic;
  }
}

class Question {
  late String uid;
  final String activityId;
  final String tagId;
  final String topicId;
  String questionName;
  final List<String> choices;


  Question({
    required this.activityId,
    required this.tagId,
    required this.topicId,
    required this.questionName,
    required this.choices,
  });

  Map<String, dynamic> toJson() {
    return {
      QuestionConstants.activityId.value: activityId,
      QuestionConstants.tagId.value: tagId,
      QuestionConstants.topicId.value: topicId,
      QuestionConstants.questionId.value: uid,
      QuestionConstants.questionName.value: questionName,
      QuestionConstants.choices.value: choices,
    };
  }

  factory Question.fromDocument(DocumentSnapshot doc) {
    String uid = doc.get(QuestionConstants.questionId.value);
    String activityId = doc.get(QuestionConstants.activityId.value);
    String tagId = doc.get(QuestionConstants.tagId.value);
    String topicId = doc.get(QuestionConstants.topicId.value);
    String questionName = doc.get(QuestionConstants.questionName.value);
    List<dynamic> choices = doc.get(QuestionConstants.choices.value);

    var question = Question(
      activityId: activityId,
      tagId: tagId,
      topicId: topicId,
      questionName: questionName,
      choices: choices.cast<String>(),
    );

    question.uid = uid;
    return question;
  }
}

class Reply{
  final String email;
  final String choice;

  const Reply({
    required this.email,
    required this.choice,
  });

  Map<String, dynamic> toJson() {
    return {
      ReplyConstants.choice.value: choice,
      ReplyConstants.email.value: email
    };
  }

  factory Reply.fromDocument(DocumentSnapshot doc) {
    String email = doc.get(ReplyConstants.email.value);
    String choice = doc.get(ReplyConstants.choice.value);
    return Reply(
        email: email,
        choice: choice,
    );
  }
}