import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:resonance_chatroom/constants/constants.dart';

class Activity {
  final String ownerid;
  final String activityid;
  final String activityname;
  final String activityinfo;
  final String enddate;

  const Activity({
    required this.ownerid,
    required this.activityid,
    required this.activityname,
    required this.activityinfo,
    required this.enddate,
  });

  Map<String, dynamic> toJson() {
    return {
      FirestoreConstants.ownerid: ownerid,
      FirestoreConstants.activityid: activityid,
      FirestoreConstants.activityname: activityname,
      FirestoreConstants.activityinfo: activityinfo,
      FirestoreConstants.enddate: enddate,
    };
  }

  factory Activity.fromDocument(DocumentSnapshot doc) {
    String ownerid = doc.get(FirestoreConstants.ownerid);
    String activityid = doc.get(FirestoreConstants.activityid);
    String activityname = doc.get(FirestoreConstants.activityname);
    String activityinfo = doc.get(FirestoreConstants.activityinfo);
    String enddate = doc.get(FirestoreConstants.enddate);
    return Activity(
      ownerid: ownerid,
      activityid: activityid,
      activityname: activityname,
      activityinfo: activityinfo,
      enddate: enddate,
    );
  }
}

class Tag {
  final String activityid;
  final String tagname;
  final String tagid;

  const Tag({
    required this.activityid,
    required this.tagname,
    required this.tagid,
  });

  Map<String, dynamic> toJson() {
    return {
      FirestoreConstants.activityid: activityid,
      FirestoreConstants.tagname: tagname,
      FirestoreConstants.tagid: tagid,
    };
  }

  factory Tag.fromDocument(DocumentSnapshot doc) {
    String activityid = doc.get(FirestoreConstants.activityid);
    String tagname = doc.get(FirestoreConstants.tagname);
    String tagid = doc.get(FirestoreConstants.tagid);
    return Tag(
      activityid: activityid,
      tagname: tagname,
      tagid: tagid,
    );
  }
}

class Question {
  final String activityid;
  final String tagid;
  final String questionid;
  final String questionname;


  const Question({
    required this.activityid,
    required this.tagid,
    required this.questionid,
    required this.questionname,
  });

  Map<String, dynamic> toJson() {
    return {
      FirestoreConstants.activityid: activityid,
      FirestoreConstants.tagid: tagid,
      FirestoreConstants.questionid: questionid,
      FirestoreConstants.questionname: questionname,
    };
  }

  factory Question.fromDocument(DocumentSnapshot doc) {
    String activityid = doc.get(FirestoreConstants.activityid);
    String tagid = doc.get(FirestoreConstants.tagid);
    String questionid = doc.get(FirestoreConstants.questionid);
    String questionname = doc.get(FirestoreConstants.questionname);
    return Question(
      activityid: activityid,
      tagid: tagid,
      questionid: questionid,
      questionname: questionname,
    );
  }
}