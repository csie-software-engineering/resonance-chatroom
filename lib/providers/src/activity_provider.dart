import 'package:cloud_firestore/cloud_firestore.dart';

import '../../constants/constants.dart';
import '../../models/models.dart';
import '../../providers/providers.dart';
import '../../utils/utils.dart';

// todo
// final activityData = await getActivity(activityId);
// assert(activityData.startDate.toEpochTime().isAfter(DateTime.now()), '活動已經開始');

class ActivityProvider {
  final FirebaseFirestore db;

  static final ActivityProvider _instance = ActivityProvider._internal(
    FirebaseFirestore.instance,
  );

  ActivityProvider._internal(this.db);
  factory ActivityProvider() => _instance;

  /// 設置新活動
  Future<Activity> setNewActivity(Activity activityData) async {
    assert(activityData.startDate.toEpochTime().isAfter(DateTime.now()),
    '活動開始時間需要在現在之後');
    assert(activityData.endDate.toEpochTime().isAfter(activityData.startDate.toEpochTime()),
    '活動結束時間需要在開始之間之後');

    activityData.uid = generateUuid();
    final documentReference = db
        .collection(FirestoreConstants.activityCollectionPath.value)
        .doc(activityData.uid);

    activityData.isEnabled = true;
    final curUserId = AuthProvider().currentUserId;
    activityData.ownerId = curUserId;
    activityData.managers = [curUserId];
    UserProvider().addUserActivity(UserActivity(uid: activityData.uid, isManager: true));

    await documentReference.set(activityData.toJson());

    return await getActivity(activityData.uid);
  }

  /// 取得活動
  Future<Activity> getActivity(String activityId) async {
    final documentReference = db
        .collection(FirestoreConstants.activityCollectionPath.value)
        .doc(activityId);

    final activityData = await documentReference.get();
    assert(activityData.exists, '活動不存在');

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
  Future<Activity> editActivity(Activity activity) async {
    assert(await _isManager(activity.uid), '你不是管理者');

    final documentReference = db
        .collection(FirestoreConstants.activityCollectionPath.value)
        .doc(activity.uid);

    var activityData = await documentReference.get();
    assert(activityData.exists, '活動不存在');
    assert(Activity.fromDocument(activityData).isEnabled, '活動已經被刪除');
    await documentReference.update({
      ActivityConstants.activityName.value: activity.activityName,
      ActivityConstants.activityInfo.value: activity.activityInfo,
      ActivityConstants.startDate.value: activity.startDate,
      ActivityConstants.endDate.value: activity.endDate,
      ActivityConstants.activityPhoto.value: activity.activityPhoto
    });

    return await getActivity(activity.uid);
  }

  ///刪除活動
  Future<void> deleteActivity(String activityId) async {
    assert(await _isHost(activityId), '你不是主辦方');

    final documentReference = db
        .collection(FirestoreConstants.activityCollectionPath.value)
        .doc(activityId);

    final activityData = await documentReference.get();
    assert(activityData.exists, '活動已經被刪除');
    assert(Activity.fromDocument(activityData).isEnabled, '活動已經被刪除');

    await documentReference.update({ActivityConstants.isEnabled.value: false});
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

  /// 增加管理者
  Future<void> addManagers(String activityId, String addUserId) async {
    assert(await _isHost(activityId), '你不是主辦方');
    assert(!await _isManager(activityId, userId: addUserId), '該用戶已經是管理者');

    final documentReference = db
        .collection(FirestoreConstants.activityCollectionPath.value)
        .doc(activityId);

    final activityData = Activity.fromDocument(await documentReference.get());
    assert(activityData.isEnabled, '活動已經被刪除');

    activityData.managers.add(addUserId);
    UserProvider().addUserActivity(UserActivity(uid: activityData.uid, isManager: true));
    await documentReference.set(activityData.toJson());
  }

  /// 刪除管理者
  Future<void> deleteManagers(String activityId, String deleteUserId) async {
    assert(await _isHost(activityId), '你不是主辦方');

    final documentReference = db
        .collection(FirestoreConstants.activityCollectionPath.value)
        .doc(activityId);

    final activityData = Activity.fromDocument(await documentReference.get());
    assert(activityData.isEnabled, '活動已經被刪除');
    assert(activityData.ownerId != deleteUserId, '不能刪除主辦方');

    assert(activityData.managers.remove(deleteUserId), '該用戶不是管理者');
    UserProvider().removeUserActivity(activityId);
    await documentReference.set(activityData.toJson());
  }

  /// 新增標籤
  Future<Tag> addNewTag(
      String activityId,
      String tagName,
      ) async {
    assert(await _isManager(activityId), '你不是管理者');

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
    final documentReference = db
        .collection(FirestoreConstants.activityCollectionPath.value)
        .doc(activityId)
        .collection(FirestoreConstants.tagCollectionPath.value)
        .doc(tagId);

    final tagData = await documentReference.get();
    assert(tagData.exists, '標籤不存在');

    return Tag.fromDocument(tagData);
  }

  /// 取得所有標籤資訊
  Future<List<Tag>> getAllTags(String activityId) async {
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
    assert(await _isManager(activityId), '你不是管理者');

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
  Future<void> deleteTag(String activityId, String userId, String tagId) async {
    assert(await _isManager(activityId, userId: userId), '你不是管理者');

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
    assert(await _isManager(activityId), '你不是管理者');

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
    final documentReference = db
        .collection(FirestoreConstants.activityCollectionPath.value)
        .doc(activityId)
        .collection(FirestoreConstants.topicCollectionPath.value)
        .doc(topicId);

    final topicData = await documentReference.get();
    assert(topicData.exists, '話題不存在');

    return Topic.fromDocument(topicData);
  }

  /// 用標籤取得話題
  Future<List<Topic>> getTopicsByTag(String activityId, String tagId) async {
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
    assert(await _isManager(activityId), '你不是管理者');

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
    assert(await _isManager(activityId), '你不是管理者');
    assert(
    questionData.choices.toSet().length == questionData.choices.length,
    'There are two same choices',
    );

    final existQuestion = db
        .collection(FirestoreConstants.activityCollectionPath.value)
        .doc(activityId)
        .collection(FirestoreConstants.questionCollectionPath.value)
        .where(QuestionConstants.topicId.value,
        isEqualTo: questionData.topicId);

    assert((await existQuestion.count().get()).count == 0, '該話題已經有問卷');

    questionData.uid = generateUuid();
    final questionDoc = db
        .collection(FirestoreConstants.activityCollectionPath.value)
        .doc(activityId)
        .collection(FirestoreConstants.questionCollectionPath.value)
        .doc(questionData.uid);

    questionDoc.set(questionData.toJson());

    return await getQuestion(activityId, questionData.uid);
  }

  /// 修改問卷選項(若活動已經開始，則不可修改)
  Future<void> editQuestionChoices(
      String activityId,
      String questionId,
      List<String> choices,
      ) async {
    assert(await _isManager(activityId), '你不是管理者');

    final questionDoc = db
        .collection(FirestoreConstants.activityCollectionPath.value)
        .doc(activityId)
        .collection(FirestoreConstants.questionCollectionPath.value)
        .doc(questionId);

    final questionData = await questionDoc.get();
    assert(questionData.exists, '問卷不存在');

    final activityData = await getActivity(activityId);
    assert(
    activityData.startDate.toEpochTime().isAfter(DateTime.now()), '活動已經開始');

    await db.runTransaction((transaction) async {
      transaction
          .update(questionDoc, {QuestionConstants.choices.value: choices});

      final reviewQuery = questionDoc
          .collection(FirestoreConstants.replyCollectionPath.value)
          .where(QuestionConstants.choices.value, whereIn: choices);

      final reviewDocs = (await reviewQuery.get()).docs;
      for (final reviewDoc in reviewDocs) {
        transaction.delete(reviewDoc.reference);
      }
    });
  }

  /// 修改問卷題目(若活動已經開始，則不可修改)
  Future<Question> editQuestion(
      String activityId,
      String questionId,
      Question questionData,
      ) async {
    assert(await _isManager(activityId), '你不是管理者');

    DocumentReference questionDoc = db
        .collection(FirestoreConstants.activityCollectionPath.value)
        .doc(activityId)
        .collection(FirestoreConstants.questionCollectionPath.value)
        .doc(questionId);

    assert((await questionDoc.get()).exists, '問卷不存在');
    final activityData = await getActivity(activityId);
    assert(
    activityData.startDate.toEpochTime().isAfter(DateTime.now()), '活動已經開始');

    await questionDoc.update(
        {QuestionConstants.questionName.value: questionData.questionName});

    return await getQuestion(activityId, questionId);
  }

  /// 取得問卷
  Future<Question> getQuestion(String activityId, String topicId) async {
    final questionQuery = db
        .collection(FirestoreConstants.activityCollectionPath.value)
        .doc(activityId)
        .collection(FirestoreConstants.questionCollectionPath.value)
        .where(QuestionConstants.topicId.value, isEqualTo: topicId);

    final questionDocs = (await questionQuery.get()).docs;
    assert(questionDocs.isNotEmpty, '該話題沒有問卷');
    return Question.fromDocument(questionDocs.first);
  }

  /// 刪除話題與問卷問題
  Future<void> deleteTopicAndQuestion(
      String activityId,
      String topicId,
      ) async {
    assert(await _isManager(activityId), '你不是管理者');

    final activityData = await getActivity(activityId);
    assert(
    activityData.startDate.toEpochTime().isAfter(DateTime.now()), '活動已經開始');

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
      assert((await topicDoc.get()).exists, '該話題不存在');
      transaction.delete(topicDoc);
      final questions = (await questionDoc.get()).docs;
      assert(questions.isNotEmpty, '該話題沒有問卷');
      transaction.delete(questions.first.reference);
    });
  }
}
