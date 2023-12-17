import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:resonance_chatroom/constants/constants.dart';
import 'package:resonance_chatroom/models/models.dart';

class QuestionProvider {
  final FirebaseFirestore db;

  static final QuestionProvider _instance = QuestionProvider._internal(
    FirebaseFirestore.instance,
  );

  QuestionProvider._internal(this.db);
  factory QuestionProvider() => _instance;

  Future<void> userAnswer(
      String activityId,
      String questionId,
      String choice,
      String userEmail)
  async{
    var reviewCollection = db
        .collection(FirestoreConstants.activityCollectionPath.value)
        .doc(activityId)
        .collection(FirestoreConstants.questionCollectionPath.value)
        .doc(questionId)
        .collection(FirestoreConstants.reviewCollectionPath.value);

    var reviewQuery = await reviewCollection.get();
    for(int i = 0; i < reviewQuery.docs.length; i++){
      var reviewDoc = Review.fromDocument(reviewQuery.docs[i]);
      for (int j = 0; j < reviewDoc.userList.length; j++){
        if (reviewDoc.userList[j] == userEmail){
          reviewDoc.userList.remove(userEmail);
          break;
        }
      }
      if (reviewDoc.choice == choice) {
        reviewDoc.userList.add(userEmail);
      }
      await reviewCollection.doc(reviewDoc.choice).update({
        QuestionConstants.userList.value: reviewDoc.userList
      });
    }
  }

  Future<List<int>>getReview(
      String activityId,
      String questionId,
      )async{
    var reviewCollection = db
        .collection(FirestoreConstants.activityCollectionPath.value)
        .doc(activityId)
        .collection(FirestoreConstants.questionCollectionPath.value)
        .doc(questionId)
        .collection(FirestoreConstants.reviewCollectionPath.value);

    var reviewQuery = await reviewCollection.get();
    List<int> reviewConclusion = [];
    for(int i = 0; i < reviewQuery.docs.length; i++){
      var reviewDoc = Review.fromDocument(reviewQuery.docs[i]);
      reviewConclusion.add(reviewDoc.userList.length);
    }
    return reviewConclusion;
  }
}