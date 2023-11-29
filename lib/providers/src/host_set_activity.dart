import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:resonance_chatroom/constants/constants.dart';
import 'package:resonance_chatroom/models/models.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_guid/flutter_guid.dart';

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
  Future<void> SetNewActivity(
      String name,
      String UserId,
      String info,
      String startdate,
      String enddate,
      String photo)
  async {
    String activityid = Guid.newGuid.toString();
    List<String> managers = [UserId];
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
        managers: managers
    );

    await documentReference.set(activity.toJson());
  }

  ///編輯活動
  Future<void> EditActivity(
      String activityid,
      String name,
      String UserId,
      String info,
      String startdate,
      String enddate,
      String photo)
  async {
    DocumentReference documentReference = firebaseFirestore
        .collection(FirestoreConstants.activityCollectionPath.value)
        .doc(activityid);

    final activitydata = Activity.fromDocument(await documentReference.get());
    bool InManagersList = false;
    for (final manager in activitydata.managers){
      if (manager == UserId){
        InManagersList = true;
        break;
      }
    }
    if (!InManagersList) {
      log("You are not manager. Can't not edit.");
      return;
    }
    Activity activity = Activity(
        ownerid: activitydata.ownerid,
        activityid: activityid,
        activityname: name,
        activityinfo: info,
        startdate: startdate,
        enddate: enddate,
        activitryphoto: photo,
        managers: activitydata.managers
    );

    await documentReference.set(activity.toJson());

  }

  ///刪除活動
  Future<void> DeleteActivity(String activityid, String nowuser) async {
    DocumentReference documentReference = firebaseFirestore
        .collection(FirestoreConstants.activityCollectionPath.value)
        .doc(activityid);

    final activitydata = Activity.fromDocument(await documentReference.get());
    if (activitydata.ownerid == nowuser) {
      await documentReference.delete();
    }
    else
      log("You are not owner. Can't not delete.");
  }

  ///增加管理者
  Future<void> AddManagers(String activityid, String nowuser, String Adduser) async {
    DocumentReference documentReference = firebaseFirestore
        .collection(FirestoreConstants.activityCollectionPath.value)
        .doc(activityid);

    final activitydata = Activity.fromDocument(await documentReference.get());
    if (activitydata.ownerid == nowuser){
      for(final manager in activitydata.managers){
        if (manager == Adduser){
          log("This user is already manager.");
          return;
        }
      }
      activitydata.managers.add(Adduser);
      await documentReference.set(activitydata.toJson());
    }
    else
      log("You are not Owner");
  }

  ///刪除管理者
  Future<void> DeleteManagers(String activityid, String nowuser, String Deleteuser) async {
    DocumentReference documentReference = firebaseFirestore
        .collection(FirestoreConstants.activityCollectionPath.value)
        .doc(activityid);

    final activitydata = Activity.fromDocument(await documentReference.get());
    if (activitydata.ownerid == nowuser){
      if (nowuser == Deleteuser){
        log("Can't delete the owner.");
        return;
      }
      for(final manager in activitydata.managers){
        if (manager == Deleteuser){
          activitydata.managers.remove(Deleteuser);
          await documentReference.set(activitydata.toJson());
          return;
        }
      }
      log("Can't not find the user.");
    }
    else
      log("You are not Owner");
  }



  ///標籤資訊送到firebase
  Future<void> tagtofirebase(
      String activityid,
      String name,
      String tagid)
  async{
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

    await documentReference.set(tag.toJson());
  }

  ///新增標籤
  Future<void> AddNewTag(
      String activityid,
      String name)
  async {
    String tagid = Guid.newGuid.toString();
    await tagtofirebase(activityid, name, tagid);
  }

  ///編輯標籤
  Future<void> EditTag(
      String activityid,
      String name,
      String tagid)
  async {
    await tagtofirebase(activityid, name, tagid);
  }

  ///新增話題與問卷問題
  Future<void> AddNewTopicandQuestion(
      String activityid,
      String tagid,
      String topicid,
      String name)
  async {
    String questionid = Guid.newGuid.toString();
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
      topicid: topicid,
      questionid: questionid,
      questionname: name,
    );

    await documentReference.set(question.toJson());
  }
}