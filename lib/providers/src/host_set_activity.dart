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
      String nowuser,
      String info,
      String startdate,
      String enddate,
      String photo)
  async {
    if (!await IsManager(activityid, nowuser)) {
      log("you are not manager.");
      return;
    }

    DocumentReference documentReference = firebaseFirestore
        .collection(FirestoreConstants.activityCollectionPath.value)
        .doc(activityid);

    final activitydata = Activity.fromDocument(await documentReference.get());
      Activity activity = Activity(
          ownerid: activitydata.ownerid,
          activityid: activitydata.activityid,
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

  ///查詢是否為管理者
  Future<bool> IsManager(String activityid, String UserId) async {
    DocumentReference documentReference = firebaseFirestore
        .collection(FirestoreConstants.activityCollectionPath.value)
        .doc(activityid);

    final activitydata = Activity.fromDocument(await documentReference.get());
    for(final manager in activitydata.managers){
      if (manager == UserId)
        return true;
    }
    return false;
  }

  ///增加管理者
  Future<void> AddManagers(String activityid, String nowuser, String Adduser) async {
    DocumentReference documentReference = firebaseFirestore
        .collection(FirestoreConstants.activityCollectionPath.value)
        .doc(activityid);

    final activitydata = Activity.fromDocument(await documentReference.get());
    if (activitydata.ownerid == nowuser){
      if (await IsManager(activityid, Adduser)){
        log("This user is already manager.");
        return;
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
      if (await IsManager(activityid, Deleteuser)){
        activitydata.managers.remove(Deleteuser);
        await documentReference.set(activitydata.toJson());
        return;
      }
      log("Can't not find the user.");
    }
    else
      log("You are not Owner");
  }

  ///新增標籤
  Future<void> AddNewTag(
      String activityid,
      String nowuser,
      String name)
  async {
    if (!await IsManager(activityid, nowuser)) {
      log("you are not manager.");
      return;
    }
    String tagid = Guid.newGuid.toString();
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

  ///編輯標籤
  Future<void> EditTag(
      String activityid,
      String name,
      String tagid)
  async {
    DocumentReference documentReference = firebaseFirestore
        .collection(FirestoreConstants.activityCollectionPath.value)
        .doc(activityid)
        .collection(FirestoreConstants.tagCollectionPath.value)
        .doc(tagid);

    final tagdata = Tag.fromDocument(await documentReference.get());
    Tag tag = Tag(
      activityid: tagdata.activityid,
      tagname: name,
      tagid: tagdata.tagid,
    );

    await documentReference.set(tag.toJson());
  }

  ///刪除標籤
  Future<void> DeleteTag(
      String activityid,
      String name,
      String tagid)
  async {
    DocumentReference documentReference = firebaseFirestore
        .collection(FirestoreConstants.activityCollectionPath.value)
        .doc(activityid)
        .collection(FirestoreConstants.tagCollectionPath.value)
        .doc(tagid);

    await documentReference.delete();

    final topicquery = firebaseFirestore
        .collection(FirestoreConstants.activityCollectionPath.value)
        .doc(activityid)
        .collection(FirestoreConstants.tagCollectionPath.value)
        .where('tagid', isEqualTo: tagid);
    if ((await topicquery.count().get()).count > 0){
      (await topicquery.get()).docs.clear();
    }
  }

  ///新增話題與問卷問題
  Future<void> AddNewTopicandQuestion(
      String activityid,
      String UserId,
      String tagid,
      String topicname,
      String questionname,
      List<String> choices)
  async {
    if (!await IsManager(activityid, UserId)){
      log("You are not manager.");
      return;
    }
    for (var i = 0; i < choices.length; i++){
      for (var j = i + 1; j < choices.length; j++){
        if(choices[i] == choices[j]){
          log("There are two same choices");
          return;
        }
      }
    }

    String topicid = Guid.newGuid.toString();
    String questionid = Guid.newGuid.toString();
    DocumentReference topicdoc = firebaseFirestore
        .collection(FirestoreConstants.activityCollectionPath.value)
        .doc(activityid)
        .collection(FirestoreConstants.topicCollectionPath.value)
        .doc(topicid);

    Topic topic = Topic(
      activityid: activityid,
      tagid: tagid,
      topicid: topicid,
      questionid: questionid,
      topicname: topicname,
    );

    await topicdoc.set(topic.toJson());

    DocumentReference questiondoc = firebaseFirestore
        .collection(FirestoreConstants.activityCollectionPath.value)
        .doc(activityid)
        .collection(FirestoreConstants.questionCollectionPath.value)
        .doc(questionid);

    Question question = Question(
      activityid: activityid,
      tagid: tagid,
      topicid: topicid,
      questionid: questionid,
      questionname: questionname,
      choices: choices
    );

    await questiondoc.set(question.toJson());
  }

  ///編輯話題與問卷題目
  Future<void> EditTopicandQuestion(
      String activityid,
      String UserId,
      String topicid,
      String topicname,
      String questionname,
      List<String> choices)
  async {
    if (!await IsManager(activityid, UserId)){
      log("You are not manager.");
      return;
    }
    for (var i = 0; i < choices.length; i++){
      for (var j = i + 1; j < choices.length; j++){
        if(choices[i] == choices[j]){
          log("There are two same choices");
          return;
        }
      }
    }

    DocumentReference topicdoc = firebaseFirestore
        .collection(FirestoreConstants.activityCollectionPath.value)
        .doc(activityid)
        .collection(FirestoreConstants.topicCollectionPath.value)
        .doc(topicid);

    final topicdata = Topic.fromDocument(await topicdoc.get());
    Topic topic = Topic(
      activityid: topicdata.activityid,
      tagid: topicdata.tagid,
      topicid: topicdata.topicid,
      questionid: topicdata.questionid,
      topicname: topicname,
    );

    await topicdoc.set(topic.toJson());

    DocumentReference questiondoc = firebaseFirestore
        .collection(FirestoreConstants.activityCollectionPath.value)
        .doc(activityid)
        .collection(FirestoreConstants.questionCollectionPath.value)
        .doc(topicdata.questionid);

    final questiondata = Question.fromDocument(await questiondoc.get());
    Question question = Question(
      activityid: questiondata.activityid,
      tagid: questiondata.tagid,
      topicid: questiondata.topicid,
      questionid: questiondata.questionid,
      questionname: questionname,
      choices: choices
    );

    await questiondoc.set(question.toJson());
  }

  ///刪除話題與問卷問題
  Future<void> DeleteTopicandQuestion(
      String activityid,
      String UserId,
      String topicid)
  async{
    if (!await IsManager(activityid, UserId)){
      log("You are not manager.");
      return;
    }

    DocumentReference topicdoc = firebaseFirestore
        .collection(FirestoreConstants.activityCollectionPath.value)
        .doc(activityid)
        .collection(FirestoreConstants.topicCollectionPath.value)
        .doc(topicid);

    final topicdata = Topic.fromDocument(await topicdoc.get());

    DocumentReference questiondoc = firebaseFirestore
        .collection(FirestoreConstants.activityCollectionPath.value)
        .doc(activityid)
        .collection(FirestoreConstants.questionCollectionPath.value)
        .doc(topicdata.questionid);

    await topicdoc.delete();
    await questiondoc.delete();
  }
}