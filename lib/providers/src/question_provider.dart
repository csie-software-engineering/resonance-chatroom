import 'package:cloud_firestore/cloud_firestore.dart';

import '../../constants/constants.dart';
import '../../models/models.dart';
import '../../providers/providers.dart';

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

    final email = (await AuthProvider().currentUser).email;

    var ansRef = db
        .collection(FirestoreConstants.activityCollectionPath.value)
        .doc(activityId)
        .collection(FirestoreConstants.questionCollectionPath.value)
        .doc(questionId)
        .collection(FirestoreConstants.replyCollectionPath.value)
        .doc(email);

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
