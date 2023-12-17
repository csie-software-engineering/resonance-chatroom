import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:resonance_chatroom/constants/constants.dart';
import 'package:resonance_chatroom/models/models.dart';

import '../../utils/src/uuid.dart';

class SetActivityProvider {
  final FirebaseFirestore db;

  static final SetActivityProvider _instance = SetActivityProvider._internal(
    FirebaseFirestore.instance,
  );

  SetActivityProvider._internal(this.db);
  factory SetActivityProvider() => _instance;

  ///設置新活動
  Future<Activity?> setNewActivity(Activity activityData, String userId) async {
    String activityId = generateUuid();
    DocumentReference documentReference = db
        .collection(FirestoreConstants.activityCollectionPath.value)
        .doc(activityId);

    activityData.activityId = activityId;
    await documentReference.set(activityData.toJson());

    return getActivity(activityId, userId);
  }

  ///獲取自己主辦的活動
  Future<List<Activity>?> getAllActivity(String userId) async {
    var docQuery = db
        .collection(FirestoreConstants.activityCollectionPath.value)
        .where('ownerId', isEqualTo: userId)
        .where('isEnabled', isEqualTo: true);

    if ((await docQuery.count().get()).count > 0) {
      var activityDocs = (await docQuery.get()).docs;
      List<Activity> activityList = [];
      for (var activityDoc in activityDocs) {
        var activityData = await activityDoc.reference.get();
        activityList.add(Activity.fromDocument(activityData));
      }
      return activityList;
    } else {
      log("You don't own any activities.");
      return null;
    }
  }

  ///取得活動
  Future<Activity?> getActivity(String activityId, String userId) async {
    if (!await _isManager(activityId, userId)) {
      log("you are not manager.");
      return null;
    }
    DocumentReference documentReference = db
        .collection(FirestoreConstants.activityCollectionPath.value)
        .doc(activityId);

    var activityData = await documentReference.get();
    if (activityData.exists) {
      return Activity.fromDocument(activityData);
    } else {
      return null;
    }
  }

  ///編輯活動
  Future<void> editActivity(
      String activityId, Activity activity, String userId) async {
    if (!await _isManager(activityId, userId)) {
      log("you are not manager.");
      return;
    }

    DocumentReference documentReference = db
        .collection(FirestoreConstants.activityCollectionPath.value)
        .doc(activityId);

    await documentReference.update({
      ActivityConstants.activityName.value: activity.activityName,
      ActivityConstants.activityInfo.value: activity.activityInfo,
      ActivityConstants.startDate.value: activity.startDate,
      ActivityConstants.endDate.value: activity.endDate,
      ActivityConstants.activityPhoto.value: activity.activityPhoto
    });
  }

  ///刪除活動
  Future<void> deleteActivity(String activityId, String userId) async {
    DocumentReference documentReference = db
        .collection(FirestoreConstants.activityCollectionPath.value)
        .doc(activityId);

    var activityData = Activity.fromDocument(await documentReference.get());
    if (activityData.ownerId == userId) {
      await documentReference
          .update({ActivityConstants.isEnabled.value: false});
    }
    else {
      log("You are not owner. Can't delete.");
    }
  }

  ///查詢是否為管理者
  Future<bool> _isManager(String activityId, String userId) async {
    DocumentReference documentReference = db
        .collection(FirestoreConstants.activityCollectionPath.value)
        .doc(activityId);

    var activityData = Activity.fromDocument(await documentReference.get());
    for (var manager in activityData.managers) {
      if (manager == userId) return true;
    }
    return false;
  }

  ///增加管理者
  Future<void> addManagers(
      String activityId, String nowUser, String addUser) async {
    DocumentReference documentReference = db
        .collection(FirestoreConstants.activityCollectionPath.value)
        .doc(activityId);

    var activityData = Activity.fromDocument(await documentReference.get());
    if (activityData.ownerId == nowUser) {
      if (await _isManager(activityId, addUser)) {
        log("This user is already manager.");
        return;
      }
      activityData.managers.add(addUser);
      await documentReference.set(activityData.toJson());
    }
    else {
      log("You are not Owner");
    }
  }

  ///刪除管理者
  Future<void> deleteManagers(
      String activityId, String nowUser, String deleteUser) async {
    DocumentReference documentReference = db
        .collection(FirestoreConstants.activityCollectionPath.value)
        .doc(activityId);

    var activityData = Activity.fromDocument(await documentReference.get());
    if (activityData.ownerId == nowUser) {
      if (nowUser == deleteUser) {
        log("Can't delete the owner.");
        return;
      }
      if (await _isManager(activityId, deleteUser)) {
        activityData.managers.remove(deleteUser);
        await documentReference.set(activityData.toJson());
        return;
      }
      log("Can't not find the user.");
    }
    else {
      log("You are not Owner");
    }
  }

  ///新增標籤
  Future<String> addNewTag(
    String activityId,
    String tagName,
    String userId,
  ) async {
    if (!await _isManager(activityId, userId)) {
      log("you are not manager.");
      return "";
    }
    String tagId = generateUuid();
    var tagData = Tag(activityId: activityId, tagName: tagName, tagId: tagId);
    DocumentReference documentReference = db
        .collection(FirestoreConstants.activityCollectionPath.value)
        .doc(activityId)
        .collection(FirestoreConstants.tagCollectionPath.value)
        .doc(tagId);

    await documentReference.set(tagData.toJson());
    await documentReference.update({TagConstants.tagId.value: tagId});
    return tagId;
  }

  ///取得標籤
  // Future<Tag?> getTag(String activityId, String tagId, String userId) async {
  //   if (!await _isManager(activityId, userId)) {
  //     log("you are not manager.");
  //     return null;
  //   }
  //   DocumentReference documentReference = db
  //       .collection(FirestoreConstants.activityCollectionPath.value)
  //       .doc(activityId)
  //       .collection(FirestoreConstants.tagCollectionPath.value)
  //       .doc(tagId);
  //
  //   var tagData = await documentReference.get();
  //   if (tagData.exists) {
  //     return Tag.fromDocument(tagData);
  //   } else {
  //     return null;
  //   }
  // }

  ///取得所有標籤資訊
  Future<List<Tag>?> getAllTags(String activityId, String userId) async {
    if (!await _isManager(activityId, userId)) {
      log("you are not manager.");
      return null;
    }
    var tagQuery = db
        .collection(FirestoreConstants.activityCollectionPath.value)
        .doc(activityId)
        .collection(FirestoreConstants.tagCollectionPath.value)
        .where('activityId', isEqualTo: activityId);

    if ((await tagQuery.count().get()).count > 0) {
      var tagDocs = (await tagQuery.get()).docs;
      List<Tag> tagList = [];
      for (var tagDoc in tagDocs) {
        var tagData = await tagDoc.reference.get();
        tagList.add(Tag.fromDocument(tagData));
      }
      return tagList;
    } else {
      log('There are no tags in this activity.');
      return null;
    }
  }

  ///編輯標籤
  Future<void> editTag(
      String activityId, String tagId, String tagName, String userId) async {
    if (!await _isManager(activityId, userId)) {
      log("you are not manager.");
      return;
    }
    DocumentReference documentReference = db
        .collection(FirestoreConstants.activityCollectionPath.value)
        .doc(activityId)
        .collection(FirestoreConstants.tagCollectionPath.value)
        .doc(tagId);

    await documentReference.update({TagConstants.tagName.value: tagName});
  }

  ///刪除標籤
  //需合併DeleteTopic和DeleteQuestion
  Future<void> deleteTag(String activityId, String userId, String tagId) async {
    if (!await _isManager(activityId, userId)) {
      log("you are not manager.");
      return;
    }
    DocumentReference documentReference = db
        .collection(FirestoreConstants.activityCollectionPath.value)
        .doc(activityId)
        .collection(FirestoreConstants.tagCollectionPath.value)
        .doc(tagId);

    await documentReference.delete();

    var topicQuery = db
        .collection(FirestoreConstants.activityCollectionPath.value)
        .doc(activityId)
        .collection(FirestoreConstants.topicCollectionPath.value)
        .where('tagId', isEqualTo: tagId);

    if ((await topicQuery.count().get()).count > 0) {
      var topicDocs = (await topicQuery.get()).docs;
      for (var topicDoc in topicDocs) {
        await topicDoc.reference.delete();
      }
    }

    var questionQuery = db
        .collection(FirestoreConstants.activityCollectionPath.value)
        .doc(activityId)
        .collection(FirestoreConstants.questionCollectionPath.value)
        .where('tagId', isEqualTo: tagId);

    if ((await questionQuery.count().get()).count > 0) {
      var questionDocs = (await questionQuery.get()).docs;
      for (var questionDoc in questionDocs) {
        await questionDoc.reference.delete();
      }
    }
  }

  ///新增話題
  Future<String?> addNewTopic(
      String activityId, Topic topicData, String userId) async {
    if (!await _isManager(activityId, userId)) {
      log("You are not manager.");
      return null;
    }

    String topicId = generateUuid();
    DocumentReference topicDoc = db
        .collection(FirestoreConstants.activityCollectionPath.value)
        .doc(activityId)
        .collection(FirestoreConstants.topicCollectionPath.value)
        .doc(topicId);

    await topicDoc.set(topicData.toJson());
    await topicDoc.update({TopicConstants.topicId.value: topicId});
    return topicId;
  }



  ///取得話題
  Future<Topic?> gettopic(
      String activityId, String topicId, String userId) async {
    if (!await _isManager(activityId, userId)) {
      log("you are not manager.");
      return null;
    }
    DocumentReference documentReference = db
        .collection(FirestoreConstants.activityCollectionPath.value)
        .doc(activityId)
        .collection(FirestoreConstants.topicCollectionPath.value)
        .doc(topicId);

    var topicData = await documentReference.get();
    if (topicData.exists) {
      return Topic.fromDocument(topicData);
    } else {
      return null;
    }
  }

  ///編輯話題
  Future<void> editTopic(
      String activityId, String userId, String topicId, Topic topicData) async {
    if (!await _isManager(activityId, userId)) {
      log("You are not manager.");
      return;
    }

    DocumentReference topicDoc = db
        .collection(FirestoreConstants.activityCollectionPath.value)
        .doc(activityId)
        .collection(FirestoreConstants.topicCollectionPath.value)
        .doc(topicId);

    await topicDoc
        .update({TopicConstants.topicName.value: topicData.topicName});
  }

  ///新增問卷題目
  Future<String?> addNewQuestion(
      String activityId, Question questionData, String userId) async {
    if (!await _isManager(activityId, userId)) {
      log("You are not manager.");
      return null;
    }

    for (var i = 0; i < questionData.choices.length; i++) {
      for (var j = i + 1; j < questionData.choices.length; j++) {
        if (questionData.choices[i] == questionData.choices[j]) {
          log("There are two same choices");
          return null;
        }
      }
    }

    String questionId = generateUuid();

    DocumentReference questionDoc = db
        .collection(FirestoreConstants.activityCollectionPath.value)
        .doc(activityId)
        .collection(FirestoreConstants.questionCollectionPath.value)
        .doc(questionId);

    await questionDoc.set(questionData.toJson());
    await questionDoc.update({QuestionConstants.questionId.value: questionId});
    for (var i = 0; i < questionData.choices.length; i++) {
      Review review = Review(choice: questionData.choices[i], userList: []);
      var reviewDoc = questionDoc
          .collection(FirestoreConstants.reviewCollectionPath.value)
          .doc(questionData.choices[i]);
      await reviewDoc.set(review.toJson());
    }
    return questionId;
  }

  ///編輯問卷題目
  Future<void> editQuestion(String activityId, String userId, String questionId,
      Question questionData) async {
    if (!await _isManager(activityId, userId)) {
      log("You are not manager.");
      return;
    }

    DocumentReference questionDoc = db
        .collection(FirestoreConstants.activityCollectionPath.value)
        .doc(activityId)
        .collection(FirestoreConstants.questionCollectionPath.value)
        .doc(questionId);

    await questionDoc.update(
        {QuestionConstants.questionName.value: questionData.questionName});
  }

  ///取得問卷題目
  Future<Question?> getQuestion(
      String activityId, String topicId, String userId) async {
    if (!await _isManager(activityId, userId)) {
      log("you are not manager.");
      return null;
    }
    var questionQuery = db
        .collection(FirestoreConstants.activityCollectionPath.value)
        .doc(activityId)
        .collection(FirestoreConstants.questionCollectionPath.value)
        .where('topicId', isEqualTo: topicId);

    if ((await questionQuery.count().get()).count == 1) {
      var questionDocs = (await questionQuery.get()).docs;
      for (var questionDoc in questionDocs) {
        var questionRef = await questionDoc.reference.get();
        return Question.fromDocument(questionRef);
      }
    }
    return null;
  }

  ///刪除話題與問卷問題
  Future<void> deleteTopicAndQuestion(String activityId, String userId,
      String topicId, String questionId) async {
    if (!await _isManager(activityId, userId)) {
      log("You are not manager.");
      return;
    }

    DocumentReference topicDoc = db
        .collection(FirestoreConstants.activityCollectionPath.value)
        .doc(activityId)
        .collection(FirestoreConstants.topicCollectionPath.value)
        .doc(topicId);

    DocumentReference questionDoc = db
        .collection(FirestoreConstants.activityCollectionPath.value)
        .doc(activityId)
        .collection(FirestoreConstants.questionCollectionPath.value)
        .doc(questionId);

    await topicDoc.delete();
    await questionDoc.delete();
  }
}
