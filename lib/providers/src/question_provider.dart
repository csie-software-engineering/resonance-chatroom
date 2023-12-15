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

  Future<void> UserAnswer(
      String activityid,
      String questionid,
      String choice,
      String UserEmail)
  async{
    var reviewcollection = db
        .collection(FirestoreConstants.activityCollectionPath.value)
        .doc(activityid)
        .collection(FirestoreConstants.questionCollectionPath.value)
        .doc(questionid)
        .collection(FirestoreConstants.reviewCollectionPath.value);

    var reviewquery = await reviewcollection.get();
    for(int i = 0; i < reviewquery.docs.length; i++){
      var reviewdoc = Review.fromDocument(reviewquery.docs[i]);
      for (int j = 0; j < reviewdoc.userlist.length; j++){
        if (reviewdoc.userlist[j] == UserEmail){
          reviewdoc.userlist.remove(UserEmail);
          break;
        }
      }
      if (reviewdoc.choice == choice) {
        reviewdoc.userlist.add(UserEmail);
      }
      await reviewcollection.doc(reviewdoc.choice).update({
        Questionconstants.userlist.value: reviewdoc.userlist
      });
    }
  }

  Future<List<int>>GetReview(
      String activityid,
      String questionid,
      )async{
    var reviewcollection = db
        .collection(FirestoreConstants.activityCollectionPath.value)
        .doc(activityid)
        .collection(FirestoreConstants.questionCollectionPath.value)
        .doc(questionid)
        .collection(FirestoreConstants.reviewCollectionPath.value);

    var reviewquery = await reviewcollection.get();
    List<int> reviewconclusion = [];
    for(int i = 0; i < reviewquery.docs.length; i++){
      var reviewdoc = Review.fromDocument(reviewquery.docs[i]);
      reviewconclusion.add(reviewdoc.userlist.length);
    }
    return reviewconclusion;
  }
}