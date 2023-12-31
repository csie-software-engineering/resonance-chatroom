import 'package:cloud_firestore/cloud_firestore.dart';

import '../../constants/constants.dart';
import '../../models/models.dart';
import '../../providers/providers.dart';
import '../../utils/utils.dart';

class ActivityProvider {
  final FirebaseFirestore db;

  static final ActivityProvider _instance = ActivityProvider._internal(
    FirebaseFirestore.instance,
  );

  ActivityProvider._internal(this.db);
  factory ActivityProvider() => _instance;

  /// 設置新活動
  Future<Activity> setNewActivity(Activity activityData) async {
    if (activityData.endDate
        .toEpochTime()
        .isBefore(activityData.startDate.toEpochTime())) {
      throw const FormatException('活動結束時間需要在開始之間之後');
    }

    activityData.uid = generateUuid();
    final documentReference = db
        .collection(FirestoreConstants.activityCollectionPath.value)
        .doc(activityData.uid);

    activityData.isEnabled = true;
    final curUserId = AuthProvider().currentUserId;
    activityData.ownerId = curUserId;
    activityData.managers = [curUserId];
    UserProvider()
        .addUserActivity(UserActivity(uid: activityData.uid, isManager: true));

    await documentReference.set(activityData.toJson());

    return await getActivity(activityData.uid);
  }

  /// 取得活動
  Future<Activity> getActivity(String activityId) async {
    if (!await _checkActivityAlive(activityId)) {
      throw const FormatException("活動不存在");
    }

    final documentReference = db
        .collection(FirestoreConstants.activityCollectionPath.value)
        .doc(activityId);

    final activityData = await documentReference.get();
    final activity = Activity.fromDocument(activityData);

    // 如果不是管理者，清空管理者列表
    if (!await _isManager(activityId)) {
      activity.managers.clear();
    }

    return activity;
  }

  /// 取得所有活動
  Future<List<Activity>> getAllActivities() async {
    final activityQuery = db
        .collection(FirestoreConstants.activityCollectionPath.value)
        .where(ActivityConstants.isEnabled.value, isEqualTo: true);

    final activityDocs = (await activityQuery.get()).docs;
    return activityDocs.map((e) => Activity.fromDocument(e)).toList();
  }

  /// 編輯活動
  Future<Activity> editActivity(Activity activityData) async {
    if (!await _checkActivityAlive(activityData.uid)) {
      throw const FormatException("活動不存在");
    }
    if (!await _isManager(activityData.uid)) {
      throw const FormatException("你不是管理者");
    }

    final documentReference = db
        .collection(FirestoreConstants.activityCollectionPath.value)
        .doc(activityData.uid);

    if (activityData.endDate
        .toEpochTime()
        .isBefore(activityData.startDate.toEpochTime())) {
      throw const FormatException("活動結束時間需要在開始時間之後");
    }

    await documentReference.update({
      ActivityConstants.activityName.value: activityData.activityName,
      ActivityConstants.activityInfo.value: activityData.activityInfo,
      ActivityConstants.startDate.value: activityData.startDate,
      ActivityConstants.endDate.value: activityData.endDate,
      ActivityConstants.activityPhoto.value: activityData.activityPhoto
    });

    return await getActivity(activityData.uid);
  }

  /// 刪除活動
  Future<void> deleteActivity(String activityId) async {
    if (!await _checkActivityAlive(activityId)) {
      throw const FormatException("活動不存在");
    }
    if (!await _isHost(activityId)) {
      throw const FormatException("你不是主辦方");
    }

    final documentReference = db
        .collection(FirestoreConstants.activityCollectionPath.value)
        .doc(activityId);

    await documentReference.update({ActivityConstants.isEnabled.value: false});
  }

  /// 啟用活動
  Future<void> enableActivity(String activityId) async {
    if (!await _checkActivityAlive(activityId)) {
      throw const FormatException("活動不存在");
    }
    if (!await _isHost(activityId)) {
      throw const FormatException("你不是主辦方");
    }

    final documentReference = db
        .collection(FirestoreConstants.activityCollectionPath.value)
        .doc(activityId);

    await documentReference.update({ActivityConstants.isEnabled.value: true});
  }

  Future<bool> _checkActivityAlive(String activityId) async {
    final documentReference = db
        .collection(FirestoreConstants.activityCollectionPath.value)
        .doc(activityId);

    final activityData = await documentReference.get();
    if (!activityData.exists) {
      return false;
    }

    return true;
  }

  Future<bool> _checkTagAlive(String activityId, String tagId) async {
    final documentReference = db
        .collection(FirestoreConstants.activityCollectionPath.value)
        .doc(activityId)
        .collection(FirestoreConstants.tagCollectionPath.value)
        .doc(tagId);

    final tagData = await documentReference.get();
    if (!tagData.exists) {
      return false;
    }
    return true;
  }

  Future<bool> _checkTopicAlive(String activityId, String topicId) async {
    final documentReference = db
        .collection(FirestoreConstants.activityCollectionPath.value)
        .doc(activityId)
        .collection(FirestoreConstants.topicCollectionPath.value)
        .doc(topicId);

    final topicData = await documentReference.get();
    if (!topicData.exists) {
      return false;
    }
    return true;
  }

  /// 查詢是否為主辦方
  Future<bool> _isHost(String activityId, {String? userId}) async {
    userId ??= AuthProvider().currentUserId;
    final documentReference = db
        .collection(FirestoreConstants.activityCollectionPath.value)
        .doc(activityId);

    final activityData = Activity.fromDocument(await documentReference.get());
    return activityData.ownerId == userId;
  }

  /// 查詢是否為管理者
  Future<bool> _isManager(String activityId, {String? userId}) async {
    userId ??= AuthProvider().currentUserId;
    final documentReference = db
        .collection(FirestoreConstants.activityCollectionPath.value)
        .doc(activityId);

    final activityData = Activity.fromDocument(await documentReference.get());
    for (final manager in activityData.managers) {
      if (manager == userId) return true;
    }
    return false;
  }

  Future<List<String>> getAllManagers(String activityId) async {
    if (!await _checkActivityAlive(activityId)) {
      throw const FormatException("活動不存在");
    }
    if (!await _isManager(activityId)) {
      throw const FormatException("你不是管理者");
    }

    final documentReference = db
        .collection(FirestoreConstants.activityCollectionPath.value)
        .doc(activityId);

    final activityData = Activity.fromDocument(await documentReference.get());

    return activityData.managers;
  }

  /// 增加管理者
  Future<void> addManagers(String activityId, String addUserId) async {
    if (!await _checkActivityAlive(activityId)) {
      throw const FormatException("活動不存在");
    }
    if (!await _isHost(activityId)) {
      throw const FormatException("你不是主辦方");
    }
    if (await _isManager(activityId, userId: addUserId)) {
      throw const FormatException("該用戶已經是管理者");
    }

    final documentReference = db
        .collection(FirestoreConstants.activityCollectionPath.value)
        .doc(activityId);

    final activityData = Activity.fromDocument(await documentReference.get());

    activityData.managers.add(addUserId);
    await UserProvider().addUserActivity(
        UserActivity(uid: activityData.uid, isManager: true),
        userId: addUserId);
    await documentReference.set(activityData.toJson());
  }

  /// 刪除管理者
  Future<void> deleteManagers(String activityId, String deleteUserId) async {
    if (!await _checkActivityAlive(activityId)) {
      throw const FormatException("活動不存在");
    }
    if (!await _isHost(activityId)) {
      throw const FormatException("你不是主辦方");
    }

    final documentReference = db
        .collection(FirestoreConstants.activityCollectionPath.value)
        .doc(activityId);

    final activityData = Activity.fromDocument(await documentReference.get());

    if (activityData.ownerId == deleteUserId) {
      throw const FormatException("不能刪除主辦者");
    }
    if (!activityData.managers.remove(deleteUserId)) {
      throw const FormatException("該用戶不是管理者");
    }
    await UserProvider()
        .removeUserActivity(activityId, userId: deleteUserId, isManager: true);
    await documentReference.set(activityData.toJson());
  }

  /// 新增標籤
  Future<Tag> addNewTag(
    String activityId,
    String tagName,
  ) async {
    if (!await _checkActivityAlive(activityId)) {
      throw const FormatException("活動不存在");
    }
    if (!await _isManager(activityId)) {
      throw const FormatException("你不是管理者");
    }

    final tagData = Tag(activityId: activityId, tagName: tagName);
    tagData.uid = generateUuid();

    final documentReference = db
        .collection(FirestoreConstants.activityCollectionPath.value)
        .doc(activityId)
        .collection(FirestoreConstants.tagCollectionPath.value)
        .doc(tagData.uid);

    await documentReference.set(tagData.toJson());
    return await getTag(activityId, tagData.uid);
  }

  /// 取得標籤
  Future<Tag> getTag(String activityId, String tagId) async {
    if (!await _checkActivityAlive(activityId)) {
      throw const FormatException("活動不存在");
    }
    if (!await _checkTagAlive(activityId, tagId)) {
      throw const FormatException("標籤不存在");
    }
    final documentReference = db
        .collection(FirestoreConstants.activityCollectionPath.value)
        .doc(activityId)
        .collection(FirestoreConstants.tagCollectionPath.value)
        .doc(tagId);

    final tagData = await documentReference.get();

    return Tag.fromDocument(tagData);
  }

  /// 取得所有標籤資訊
  Future<List<Tag>> getAllTags(String activityId) async {
    if (!await _checkActivityAlive(activityId)) {
      throw const FormatException("活動不存在");
    }
    final tagQuery = db
        .collection(FirestoreConstants.activityCollectionPath.value)
        .doc(activityId)
        .collection(FirestoreConstants.tagCollectionPath.value)
        .where(TagConstants.activityId.value, isEqualTo: activityId);

    final tagDocs = (await tagQuery.get()).docs;
    return tagDocs.map((e) => Tag.fromDocument(e)).toList();
  }

  /// 編輯標籤
  Future<void> editTag(String activityId, String tagId, String tagName) async {
    if (!await _checkActivityAlive(activityId)) {
      throw const FormatException("活動不存在");
    }
    if (!await _checkTagAlive(activityId, tagId)) {
      throw const FormatException("標籤不存在");
    }
    if (!await _isManager(activityId)) {
      throw const FormatException("你不是管理者");
    }

    final documentReference = db
        .collection(FirestoreConstants.activityCollectionPath.value)
        .doc(activityId)
        .collection(FirestoreConstants.tagCollectionPath.value)
        .doc(tagId);

    await documentReference.update({TagConstants.tagName.value: tagName});
  }

  /// 刪除標籤
  ///
  /// 需合併DeleteTopic和DeleteQuestion
  Future<void> deleteTag(String activityId, String tagId) async {
    if (!await _checkActivityAlive(activityId)) {
      throw const FormatException("活動不存在");
    }
    if (!await _checkTagAlive(activityId, tagId)) {
      throw const FormatException("標籤不存在");
    }
    if (!await _isManager(activityId)) {
      throw const FormatException("你不是管理者");
    }

    final documentReference = db
        .collection(FirestoreConstants.activityCollectionPath.value)
        .doc(activityId)
        .collection(FirestoreConstants.tagCollectionPath.value)
        .doc(tagId);

    await documentReference.delete();

    final topicQuery = db
        .collection(FirestoreConstants.activityCollectionPath.value)
        .doc(activityId)
        .collection(FirestoreConstants.topicCollectionPath.value)
        .where(TopicConstants.tagId.value, isEqualTo: tagId);

    final topics = (await topicQuery.get()).docs;
    for (final topic in topics) {
      await topic.reference.delete();
    }

    final questionQuery = db
        .collection(FirestoreConstants.activityCollectionPath.value)
        .doc(activityId)
        .collection(FirestoreConstants.questionCollectionPath.value)
        .where(TopicConstants.tagId.value, isEqualTo: tagId);

    final questions = (await questionQuery.get()).docs;
    for (final question in questions) {
      await question.reference.delete();
    }
  }

  /// 新增話題
  Future<Topic> addNewTopic(String activityId, Topic topicData) async {
    if (!await _checkActivityAlive(activityId)) {
      throw const FormatException("活動不存在");
    }
    if (!await _checkTagAlive(activityId, topicData.tagId)) {
      throw const FormatException("標籤不存在");
    }
    if (!await _isManager(activityId)) {
      throw const FormatException("你不是管理者");
    }

    topicData.uid = generateUuid();
    DocumentReference topicDoc = db
        .collection(FirestoreConstants.activityCollectionPath.value)
        .doc(activityId)
        .collection(FirestoreConstants.topicCollectionPath.value)
        .doc(topicData.uid);

    await topicDoc.set(topicData.toJson());
    return await getTopic(activityId, topicData.uid);
  }

  /// 取得話題
  Future<Topic> getTopic(String activityId, String topicId) async {
    if (!await _checkActivityAlive(activityId)) {
      throw const FormatException("活動不存在");
    }
    if (!await _checkTopicAlive(activityId, topicId)) {
      throw const FormatException("話題不存在");
    }
    final documentReference = db
        .collection(FirestoreConstants.activityCollectionPath.value)
        .doc(activityId)
        .collection(FirestoreConstants.topicCollectionPath.value)
        .doc(topicId);

    final topicData = await documentReference.get();
    return Topic.fromDocument(topicData);
  }

  /// 用標籤取得話題
  Future<List<Topic>> getTopicsByTag(String activityId, String tagId) async {
    if (!await _checkActivityAlive(activityId)) {
      throw const FormatException("活動不存在");
    }
    if (!await _checkTagAlive(activityId, tagId)) {
      throw const FormatException("標籤不存在");
    }
    final topicQuery = db
        .collection(FirestoreConstants.activityCollectionPath.value)
        .doc(activityId)
        .collection(FirestoreConstants.topicCollectionPath.value)
        .where(TopicConstants.tagId.value, isEqualTo: tagId);

    final topicDocs = (await topicQuery.get()).docs;
    return topicDocs.map((e) => Topic.fromDocument(e)).toList();
  }

  /// 編輯話題
  Future<void> editTopic(
    String activityId,
    String topicId,
    String topicName,
  ) async {
    if (!await _checkActivityAlive(activityId)) {
      throw const FormatException("活動不存在");
    }
    if (!await _checkTopicAlive(activityId, topicId)) {
      throw const FormatException("話題不存在");
    }
    if (!await _isManager(activityId)) {
      throw const FormatException("你不是管理者");
    }

    final topicDoc = db
        .collection(FirestoreConstants.activityCollectionPath.value)
        .doc(activityId)
        .collection(FirestoreConstants.topicCollectionPath.value)
        .doc(topicId);

    await topicDoc.update({TopicConstants.topicName.value: topicName});
  }

  /// 新增問卷題目
  Future<Question> addNewQuestion(
    String activityId,
    Question questionData,
  ) async {
    if (!await _checkActivityAlive(activityId)) {
      throw const FormatException("活動不存在");
    }
    if (!await _checkTagAlive(activityId, questionData.tagId)) {
      throw const FormatException("標籤不存在");
    }
    if (!await _checkTopicAlive(activityId, questionData.topicId)) {
      throw const FormatException("話題不存在");
    }
    if (!await _isManager(activityId)) {
      throw const FormatException("你不是管理者");
    }
    questionData.choices = List.filled(5, '');

    questionData.uid = generateUuid();
    final questionDoc = db
        .collection(FirestoreConstants.activityCollectionPath.value)
        .doc(activityId)
        .collection(FirestoreConstants.questionCollectionPath.value)
        .doc(questionData.uid);

    await questionDoc.set(questionData.toJson());

    return await getQuestion(activityId, questionData.uid);
  }

  /// 修改問卷題目(若活動已經開始，則不可修改)
  Future<Question> editQuestion(
    String activityId,
    String questionId,
    Question questionData,
  ) async {
    if (!await _checkActivityAlive(activityId)) {
      throw const FormatException("活動不存在");
    }
    if (!await _checkTagAlive(activityId, questionData.tagId)) {
      throw const FormatException("標籤不存在");
    }
    if (!await _checkTopicAlive(activityId, questionData.topicId)) {
      throw const FormatException("話題不存在");
    }
    if (!await _isManager(activityId)) {
      throw const FormatException("你不是管理者");
    }

    if (questionData.choices.toSet().length != questionData.choices.length) {
      throw const FormatException("選項重複");
    }

    DocumentReference questionDoc = db
        .collection(FirestoreConstants.activityCollectionPath.value)
        .doc(activityId)
        .collection(FirestoreConstants.questionCollectionPath.value)
        .doc(questionId);

    if (!((await questionDoc.get()).exists)) {
      throw const FormatException("問卷不存在");
    }
    // final activityData = await getActivity(activityId);
    // if(
    //     activityData.startDate.toEpochTime().isAfter(DateTime.now()), '活動已經開始');

    // while (questionData.choices.remove("")) {}

    await questionDoc.update({
      QuestionConstants.questionName.value: questionData.questionName,
      QuestionConstants.choices.value: questionData.choices
    });
    db
        .collection(FirestoreConstants.activityCollectionPath.value)
        .doc(activityId)
        .collection(FirestoreConstants.questionCollectionPath.value)
        .doc(questionId)
        .collection(FirestoreConstants.replyCollectionPath.value)
        .get()
        .then((snapshot) {
      for (DocumentSnapshot ds in snapshot.docs) {
        ds.reference.delete();
      }
    });

    return await getQuestion(activityId, questionId);
  }

  /// 取得問卷
  Future<Question> getQuestion(String activityId, String questionId) async {
    if (!await _checkActivityAlive(activityId)) {
      throw const FormatException("活動不存在");
    }

    final questionRef = db
        .collection(FirestoreConstants.activityCollectionPath.value)
        .doc(activityId)
        .collection(FirestoreConstants.questionCollectionPath.value)
        .doc(questionId);

    final questionData = await questionRef.get();
    if (!questionData.exists) {
      throw const FormatException("問卷不存在");
    }

    return Question.fromDocument(questionData);
  }

  /// 用話題取得問卷
  Future<Question> getQuestionByTopic(String activityId, String topicId) async {
    if (!await _checkActivityAlive(activityId)) {
      throw const FormatException("活動不存在");
    }
    if (!await _checkTopicAlive(activityId, topicId)) {
      throw const FormatException("話題不存在");
    }

    final questionQuery = db
        .collection(FirestoreConstants.activityCollectionPath.value)
        .doc(activityId)
        .collection(FirestoreConstants.questionCollectionPath.value)
        .where(QuestionConstants.topicId.value, isEqualTo: topicId);

    final questionDocs = (await questionQuery.get()).docs;
    if (questionDocs.isEmpty) {
      throw const FormatException("該話題沒有問卷");
    }
    return Question.fromDocument(questionDocs.first);
  }

  /// 取得所有問卷
  Future<List<Question>> getAllQuestions(String activityId) async {
    final questionQuery = db
        .collection(FirestoreConstants.activityCollectionPath.value)
        .doc(activityId)
        .collection(FirestoreConstants.questionCollectionPath.value);

    final questionDocs = (await questionQuery.get()).docs;
    return questionDocs.map((e) => Question.fromDocument(e)).toList();
  }

  /// 刪除話題與問卷問題
  Future<void> deleteTopicAndQuestion(
    String activityId,
    String topicId,
  ) async {
    if (!await _checkActivityAlive(activityId)) {
      throw const FormatException("活動不存在");
    }
    if (!await _isManager(activityId)) {
      throw const FormatException("你不是管理者");
    }

    final topicDoc = db
        .collection(FirestoreConstants.activityCollectionPath.value)
        .doc(activityId)
        .collection(FirestoreConstants.topicCollectionPath.value)
        .doc(topicId);

    final questionDoc = db
        .collection(FirestoreConstants.activityCollectionPath.value)
        .doc(activityId)
        .collection(FirestoreConstants.questionCollectionPath.value)
        .where(QuestionConstants.topicId.value, isEqualTo: topicId);

    await db.runTransaction((transaction) async {
      if (!((await topicDoc.get()).exists)) {
        throw const FormatException("該話題不存在");
      }
      transaction.delete(topicDoc);
      final questions = (await questionDoc.get()).docs;
      if (questions.isEmpty) {
        throw const FormatException("該話題沒有問卷");
      }
      transaction.delete(questions.first.reference);
    });
  }
}
