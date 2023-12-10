import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:resonance_chatroom/constants/constants.dart';
import 'package:resonance_chatroom/models/models.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../providers/providers.dart';

class QuestionProvider {
  final SharedPreferences pref;
  final FirebaseFirestore firebaseFirestore;

  QuestionProvider({
    required this.pref,
    required this.firebaseFirestore
  });

  Future<void> UserAnswer(
      String activityid,
      String questionid,
      String choice,
      String UserId)
  async{
    var reviewcollection = firebaseFirestore
        .collection(FirestoreConstants.activityCollectionPath.value)
        .doc(activityid)
        .collection(FirestoreConstants.questionCollectionPath.value)
        .doc(questionid)
        .collection(FirestoreConstants.reviewCollectionPath.value);

    var reviewquery = await reviewcollection.get();
    for(int i = 0; i < reviewquery.docs.length; i++){
      var reviewdoc = Review.fromDocument(reviewquery.docs[i]);
      for (int j = 0; j < reviewdoc.userlist.length; j++){
        if (reviewdoc.userlist[j] == UserId){
          reviewdoc.userlist.remove(UserId);
          break;
        }
      }
      if (reviewdoc.choice == choice) {
        reviewdoc.userlist.add(UserId);
      }
      await reviewcollection.doc(reviewdoc.choice).update({
        Questionconstants.userlist.value: reviewdoc.userlist
      });
    }
  }

  Future<List<int>>GetReview(
      String activityid,
      String questionid,
      String UserId
      )async{
    var reviewcollection = firebaseFirestore
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