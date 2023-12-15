import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:resonance_chatroom/constants/constants.dart';
import 'package:resonance_chatroom/models/models.dart';

import '../../utils/src/uuid.dart';

class SetActivityProvider {
  final FirebaseFirestore db;

  static final SetActivityProvider _instance = SetActivityProvider._internal(
    FirebaseFirestore.instance,
  );

  SetActivityProvider._internal(this.db);
  factory SetActivityProvider() => _instance;

  ///設置新活動
  Future<Activity?> SetNewActivity(Activity activitydata, String UserId) async {
    String activityid = generateUuid();
    DocumentReference documentReference = db
        .collection(FirestoreConstants.activityCollectionPath.value)
        .doc(activityid);

    activitydata.managers.add(UserId);
    await documentReference.set(activitydata.toJson());

    await documentReference
        .update({Activityconstants.activityid.value: activityid});
    return Getactivity(activityid, UserId);
  }

  ///獲取自己主辦的活動
  Future<List<Activity>?> GetAllActivity(String UserId) async {
    var docquery = db
        .collection(FirestoreConstants.activityCollectionPath.value)
        .where('ownerid', isEqualTo: UserId)
        .where('IsEnabled', isEqualTo: true);

    if ((await docquery.count().get()).count > 0) {
      var activitydocs = (await docquery.get()).docs;
      List<Activity> activitylist = [];
      for (var activitydoc in activitydocs) {
        var activitydata = await activitydoc.reference.get();
        activitylist.add(Activity.fromDocument(activitydata));
      }
      return activitylist;
    } else {
      log("You don't own any activities.");
      return null;
    }
  }

  ///取得活動
  Future<Activity?> Getactivity(String activityid, String UserId) async {
    if (!await IsManager(activityid, UserId)) {
      log("you are not manager.");
      return null;
    }
    DocumentReference documentReference = db
        .collection(FirestoreConstants.activityCollectionPath.value)
        .doc(activityid);

    var activitydata = await documentReference.get();
    if (activitydata.exists) {
      return Activity.fromDocument(activitydata);
    } else {
      return null;
    }
  }

  ///編輯活動
  Future<void> EditActivity(
      String activityid, Activity activity, String UserId) async {
    if (!await IsManager(activityid, UserId)) {
      log("you are not manager.");
      return;
    }

    DocumentReference documentReference = db
        .collection(FirestoreConstants.activityCollectionPath.value)
        .doc(activityid);

    await documentReference.update({
      Activityconstants.activityname.value: activity.activityname,
      Activityconstants.activityinfo.value: activity.activityinfo,
      Activityconstants.startdate.value: activity.startdate,
      Activityconstants.enddate.value: activity.enddate,
      Activityconstants.activitryphoto.value: activity.activitryphoto
    });
  }

  ///刪除活動
  Future<void> DeleteActivity(String activityid, String UserId) async {
    DocumentReference documentReference = db
        .collection(FirestoreConstants.activityCollectionPath.value)
        .doc(activityid);

    var activitydata = Activity.fromDocument(await documentReference.get());
    if (activitydata.ownerid == UserId) {
      await documentReference
          .update({Activityconstants.IsEnabled.value: false});
    } else
      log("You are not owner. Can't not delete.");
  }

  ///查詢是否為管理者
  Future<bool> IsManager(String activityid, String UserId) async {
    DocumentReference documentReference = db
        .collection(FirestoreConstants.activityCollectionPath.value)
        .doc(activityid);

    var activitydata = Activity.fromDocument(await documentReference.get());
    for (var manager in activitydata.managers) {
      if (manager == UserId) return true;
    }
    return false;
  }

  ///增加管理者
  Future<void> AddManagers(
      String activityid, String nowuser, String Adduser) async {
    DocumentReference documentReference = db
        .collection(FirestoreConstants.activityCollectionPath.value)
        .doc(activityid);

    var activitydata = Activity.fromDocument(await documentReference.get());
    if (activitydata.ownerid == nowuser) {
      if (await IsManager(activityid, Adduser)) {
        log("This user is already manager.");
        return;
      }
      activitydata.managers.add(Adduser);
      await documentReference.set(activitydata.toJson());
    } else
      log("You are not Owner");
  }

  ///刪除管理者
  Future<void> DeleteManagers(
      String activityid, String nowuser, String Deleteuser) async {
    DocumentReference documentReference = db
        .collection(FirestoreConstants.activityCollectionPath.value)
        .doc(activityid);

    var activitydata = Activity.fromDocument(await documentReference.get());
    if (activitydata.ownerid == nowuser) {
      if (nowuser == Deleteuser) {
        log("Can't delete the owner.");
        return;
      }
      if (await IsManager(activityid, Deleteuser)) {
        activitydata.managers.remove(Deleteuser);
        await documentReference.set(activitydata.toJson());
        return;
      }
      log("Can't not find the user.");
    } else
      log("You are not Owner");
  }

  ///新增標籤
  Future<String> AddNewTag(
    String activityid,
    String tagname,
    String UserId,
  ) async {
    if (!await IsManager(activityid, UserId)) {
      log("you are not manager.");
      return "";
    }
    String tagid = generateUuid();
    var tagdata = Tag(activityid: activityid, tagname: tagname, tagid: tagid);
    DocumentReference documentReference = db
        .collection(FirestoreConstants.activityCollectionPath.value)
        .doc(activityid)
        .collection(FirestoreConstants.tagCollectionPath.value)
        .doc(tagid);

    await documentReference.set(tagdata.toJson());
    await documentReference.update({Tagconstants.tagid.value: tagid});
    return tagid;
  }

  ///取得標籤
  // Future<Tag?> Gettag(String activityid, String tagid, String UserId) async {
  //   if (!await IsManager(activityid, UserId)) {
  //     log("you are not manager.");
  //     return null;
  //   }
  //   DocumentReference documentReference = db
  //       .collection(FirestoreConstants.activityCollectionPath.value)
  //       .doc(activityid)
  //       .collection(FirestoreConstants.tagCollectionPath.value)
  //       .doc(tagid);
  //
  //   var tagdata = await documentReference.get();
  //   if (tagdata.exists) {
  //     return Tag.fromDocument(tagdata);
  //   } else {
  //     return null;
  //   }
  // }

  ///取得所有標籤資訊
  Future<List<Tag>?> GetAllTags(String activityid, String UserId) async {
    if (!await IsManager(activityid, UserId)) {
      log("you are not manager.");
      return null;
    }
    var tagquery = db
        .collection(FirestoreConstants.activityCollectionPath.value)
        .doc(activityid)
        .collection(FirestoreConstants.tagCollectionPath.value)
        .where('activityid', isEqualTo: activityid);

    if ((await tagquery.count().get()).count > 0) {
      var tagdocs = (await tagquery.get()).docs;
      List<Tag> taglist = [];
      for (var tagdoc in tagdocs) {
        var tagdata = await tagdoc.reference.get();
        taglist.add(Tag.fromDocument(tagdata));
      }
      return taglist;
    } else {
      log('There are no tags in this activity.');
      return null;
    }
  }

  ///編輯標籤
  Future<void> EditTag(
      String activityid, String tagid, String tagname, String UserId) async {
    if (!await IsManager(activityid, UserId)) {
      log("you are not manager.");
      return;
    }
    DocumentReference documentReference = db
        .collection(FirestoreConstants.activityCollectionPath.value)
        .doc(activityid)
        .collection(FirestoreConstants.tagCollectionPath.value)
        .doc(tagid);

    await documentReference.update({Tagconstants.tagname: tagname});
  }

  ///刪除標籤
  //需合併DeleteTopic和DeleteQuestion
  Future<void> DeleteTag(String activityid, String UserId, String tagid) async {
    if (!await IsManager(activityid, UserId)) {
      log("you are not manager.");
      return;
    }
    DocumentReference documentReference = db
        .collection(FirestoreConstants.activityCollectionPath.value)
        .doc(activityid)
        .collection(FirestoreConstants.tagCollectionPath.value)
        .doc(tagid);

    await documentReference.delete();

    var topicquery = db
        .collection(FirestoreConstants.activityCollectionPath.value)
        .doc(activityid)
        .collection(FirestoreConstants.topicCollectionPath.value)
        .where('tagid', isEqualTo: tagid);

    if ((await topicquery.count().get()).count > 0) {
      var topicdocs = (await topicquery.get()).docs;
      for (var topicdoc in topicdocs) {
        await topicdoc.reference.delete();
      }
    }

    var questionquery = db
        .collection(FirestoreConstants.activityCollectionPath.value)
        .doc(activityid)
        .collection(FirestoreConstants.questionCollectionPath.value)
        .where('tagid', isEqualTo: tagid);

    if ((await questionquery.count().get()).count > 0) {
      var questiondocs = (await questionquery.get()).docs;
      for (var questiondoc in questiondocs) {
        await questiondoc.reference.delete();
      }
    }
  }

  ///新增話題
  Future<String?> AddNewTopic(
      String activityid, Topic topicdata, String UserId) async {
    if (!await IsManager(activityid, UserId)) {
      log("You are not manager.");
      return null;
    }

    String topicid = generateUuid();
    DocumentReference topicdoc = db
        .collection(FirestoreConstants.activityCollectionPath.value)
        .doc(activityid)
        .collection(FirestoreConstants.topicCollectionPath.value)
        .doc(topicid);

    await topicdoc.set(topicdata.toJson());
    await topicdoc.update({Topicconstants.topicid.value: topicid});
    return topicid;
  }



  ///取得話題
  Future<Topic?> Gettopic(
      String activityid, String topicid, String UserId) async {
    if (!await IsManager(activityid, UserId)) {
      log("you are not manager.");
      return null;
    }
    DocumentReference documentReference = db
        .collection(FirestoreConstants.activityCollectionPath.value)
        .doc(activityid)
        .collection(FirestoreConstants.topicCollectionPath.value)
        .doc(topicid);

    var topicdata = await documentReference.get();
    if (topicdata.exists) {
      return Topic.fromDocument(topicdata);
    } else {
      return null;
    }
  }

  ///編輯話題
  Future<void> EditTopic(
      String activityid, String UserId, String topicid, Topic topicdata) async {
    if (!await IsManager(activityid, UserId)) {
      log("You are not manager.");
      return;
    }

    DocumentReference topicdoc = db
        .collection(FirestoreConstants.activityCollectionPath.value)
        .doc(activityid)
        .collection(FirestoreConstants.topicCollectionPath.value)
        .doc(topicid);

    await topicdoc
        .update({Topicconstants.topicname.value: topicdata.topicname});
  }

  ///新增問卷題目
  Future<String?> AddNewQuestion(
      String activityid, Question questiondata, String UserId) async {
    if (!await IsManager(activityid, UserId)) {
      log("You are not manager.");
      return null;
    }

    for (var i = 0; i < questiondata.choices.length; i++) {
      for (var j = i + 1; j < questiondata.choices.length; j++) {
        if (questiondata.choices[i] == questiondata.choices[j]) {
          log("There are two same choices");
          return null;
        }
      }
    }

    String questionid = generateUuid();

    DocumentReference questiondoc = db
        .collection(FirestoreConstants.activityCollectionPath.value)
        .doc(activityid)
        .collection(FirestoreConstants.questionCollectionPath.value)
        .doc(questionid);

    await questiondoc.set(questiondata.toJson());
    await questiondoc.update({Questionconstants.questionid.value: questionid});
    for (var i = 0; i < questiondata.choices.length; i++) {
      Review review = Review(choice: questiondata.choices[i], userlist: []);
      var reviewdoc = questiondoc
          .collection(FirestoreConstants.reviewCollectionPath.value)
          .doc(questiondata.choices[i]);
      await reviewdoc.set(review.toJson());
    }
    return questionid;
  }

  ///編輯問卷題目
  Future<void> EditQuestion(String activityid, String UserId, String questionid,
      Question questiondata) async {
    if (!await IsManager(activityid, UserId)) {
      log("You are not manager.");
      return;
    }

    DocumentReference questiondoc = db
        .collection(FirestoreConstants.activityCollectionPath.value)
        .doc(activityid)
        .collection(FirestoreConstants.questionCollectionPath.value)
        .doc(questionid);

    await questiondoc.update(
        {Questionconstants.questionname.value: questiondata.questionname});
  }

  ///取得問卷題目
  Future<Question?> Getquestion(
      String activityid, String topicid, String UserId) async {
    if (!await IsManager(activityid, UserId)) {
      log("you are not manager.");
      return null;
    }
    var questionquery = db
        .collection(FirestoreConstants.activityCollectionPath.value)
        .doc(activityid)
        .collection(FirestoreConstants.questionCollectionPath.value)
        .where('topicid', isEqualTo: topicid);

    if ((await questionquery.count().get()).count == 1) {
      var questiondocs = (await questionquery.get()).docs;
      for (var questiondoc in questiondocs) {
        var questionref = await questiondoc.reference.get();
        return Question.fromDocument(questionref);
      }
    }
    else {
      
      return null;
    }
  }

  ///刪除話題與問卷問題
  Future<void> DeleteTopicandQuestion(String activityid, String UserId,
      String topicid, String questionid) async {
    if (!await IsManager(activityid, UserId)) {
      log("You are not manager.");
      return;
    }

    DocumentReference topicdoc = db
        .collection(FirestoreConstants.activityCollectionPath.value)
        .doc(activityid)
        .collection(FirestoreConstants.topicCollectionPath.value)
        .doc(topicid);

    DocumentReference questiondoc = db
        .collection(FirestoreConstants.activityCollectionPath.value)
        .doc(activityid)
        .collection(FirestoreConstants.questionCollectionPath.value)
        .doc(questionid);

    await topicdoc.delete();
    await questiondoc.delete();
  }
}
