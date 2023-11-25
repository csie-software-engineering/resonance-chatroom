import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:resonance_chatroom/constants/constants.dart';
import 'package:resonance_chatroom/models/models.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SetActivityProvider{
  final SharedPreferences pref;
  final FirebaseFirestore firebaseFirestore;
  final FirebaseStorage firebaseStorage;

  SetActivityProvider({
    required this.pref,
    required this.firebaseFirestore,
    required this.firebaseStorage,
  });
  ///設置新活動
  Future<void> SetNewActivity(String name, String UserId, String info, String startdate, String enddate, String photo) async {
    String activityid = DateTime.now().millisecondsSinceEpoch.toString(); //guid
    DocumentReference documentReference = firebaseFirestore
        .collection(FirestoreConstants.activityCollectionPath.value)
        .doc(activityid);

    Activity activity = Activity(
      ownerid: UserId,
      activityid: activityid,
      activityname: name,
      activityinfo: info,
      startdate: startdate,
      enddate: enddate,
      activitryphoto: photo,
    );

    await documentReference.set(activity.toJson());
  }

  void AddNewTag(String activityid, String name) {
    String tagid = DateTime.now().millisecondsSinceEpoch.toString();
    DocumentReference documentReference = firebaseFirestore
        .collection(FirestoreConstants.activityCollectionPath.value)
        .doc(activityid)
        .collection(FirestoreConstants.tagCollectionPath.value)
        .doc(tagid);

    Tag tag = Tag(
        activityid: activityid,
        tagname: name,
        tagid: tagid,
    );

    FirebaseFirestore.instance.runTransaction((transaction) async {
      transaction.set(
        documentReference,
        tag.toJson(),
      );
    });
  }
  void AddNewQusetion(String activityid, String tagid,String name) {
    String questionid = DateTime.now().millisecondsSinceEpoch.toString();
    DocumentReference documentReference = firebaseFirestore
        .collection(FirestoreConstants.activityCollectionPath.value)
        .doc(activityid)
        .collection(FirestoreConstants.tagCollectionPath.value)
        .doc(tagid)
        .collection(FirestoreConstants.questionCollectionPath.value)
        .doc(questionid);

    Question question = Question(
      activityid: activityid,
      tagid: tagid,
      questionid: questionid,
      questionname: name,
    );

    FirebaseFirestore.instance.runTransaction((transaction) async {
      transaction.set(
        documentReference,
        question.toJson(),
      );
    });
  }
}