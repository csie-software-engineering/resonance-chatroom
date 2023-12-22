import 'package:cloud_firestore/cloud_firestore.dart';

import '../../constants/constants.dart';
import '../../models/models.dart';
import '../../providers/providers.dart';
import '../../utils/utils.dart';

class QuestionProvider {
  final FirebaseFirestore db;

  static final QuestionProvider _instance = QuestionProvider._internal(
    FirebaseFirestore.instance,
  );

  QuestionProvider._internal(this.db);
  factory QuestionProvider() => _instance;

  /// 回答問題
  ///
  /// 匿名無法回答
  Future<void> userAnswer(
    String activityId,
    String questionId,
    String choice,
  ) async {
    assert(AuthProvider().getFBAUser!.isAnonymous == false, '匿名無法回答問題');

    final email = (await AuthProvider().currentUser).email;
    assert(email != null, 'email 不可為空');

    var ansRef = db
        .collection(FirestoreConstants.activityCollectionPath.value)
        .doc(activityId)
        .collection(FirestoreConstants.questionCollectionPath.value)
        .doc(questionId)
        .collection(FirestoreConstants.replyCollectionPath.value)
        .doc(email);

    final activityData = await ActivityProvider().getActivity(activityId);
    assert(
      activityData.startDate.toEpochTime().isBefore(DateTime.now()),
      '活動尚未開始',
    );
    assert(
      activityData.endDate.toEpochTime().isAfter(DateTime.now()),
      '活動已經結束',
    );

    ansRef.set({
      ReplyConstants.email.value: email,
      ReplyConstants.choice.value: choice,
    });
    await UserProvider().addUserActivityPoint(activityId);
  }

  Future<List<int>> getReplyResult(
    String activityId,
    String questionId,
  ) async {
    final repliesData = await db
        .collection(FirestoreConstants.activityCollectionPath.value)
        .doc(activityId)
        .collection(FirestoreConstants.questionCollectionPath.value)
        .doc(questionId)
        .collection(FirestoreConstants.replyCollectionPath.value)
        .get();

    final replies = repliesData.docs.map((e) => Reply.fromDocument(e)).toList();
    final question =
        await ActivityProvider().getQuestion(activityId, questionId);

    final result = List<int>.filled(question.choices.length, 0);
    for (var reply in replies) {
      final index = question.choices.indexOf(reply.choice);
      result[index]++;
    }

    return result;
  }
}
