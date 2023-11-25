import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:resonance_chatroom/constants/constants.dart';

class Activity {
  final String ownerid;
  final String activityid;
  final String activityname;
  final String activityinfo;
  final String startdate;
  final String enddate;
  final String activitryphoto;

  const Activity({
    required this.ownerid,
    required this.activityid,
    required this.activityname,
    required this.activityinfo,
    required this.startdate,
    required this.enddate,
    required this.activitryphoto,
  });

  Map<String, dynamic> toJson() {
    return {
      Activityconstants.ownerid.value: ownerid,
      Activityconstants.activityid.value: activityid,
      Activityconstants.activityname.value: activityname,
      Activityconstants.activityinfo.value: activityinfo,
      Activityconstants.startdate.value: startdate,
      Activityconstants.enddate.value: enddate,
      Activityconstants.activitryphoto.value: activitryphoto,
    };
  }

  factory Activity.fromDocument(DocumentSnapshot doc) {
    String ownerid = doc.get(Activityconstants.ownerid.value);
    String activityid = doc.get(Activityconstants.activityid.value);
    String activityname = doc.get(Activityconstants.activityname.value);
    String activityinfo = doc.get(Activityconstants.activityinfo.value);
    String startdate = doc.get(Activityconstants.startdate.value);
    String enddate = doc.get(Activityconstants.enddate.value);
    String activitryphoto = doc.get(Activityconstants.activitryphoto.value);
    return Activity(
      ownerid: ownerid,
      activityid: activityid,
      activityname: activityname,
      activityinfo: activityinfo,
      startdate: startdate,
      enddate: enddate,
      activitryphoto: activitryphoto,
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
      Activityconstants.activityid.value: activityid,
      Activityconstants.tagname.value: tagname,
      Activityconstants.tagid.value: tagid,
    };
  }

  factory Tag.fromDocument(DocumentSnapshot doc) {
    String activityid = doc.get(Activityconstants.activityid.value);
    String tagname = doc.get(Activityconstants.tagname.value);
    String tagid = doc.get(Activityconstants.tagid.value);
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
      Activityconstants.activityid.value: activityid,
      Activityconstants.tagid.value: tagid,
      Activityconstants.questionid.value: questionid,
      Activityconstants.questionname.value: questionname,
    };
  }

  factory Question.fromDocument(DocumentSnapshot doc) {
    String activityid = doc.get(Activityconstants.activityid.value);
    String tagid = doc.get(Activityconstants.tagid.value);
    String questionid = doc.get(Activityconstants.questionid.value);
    String questionname = doc.get(Activityconstants.questionname.value);
    return Question(
      activityid: activityid,
      tagid: tagid,
      questionid: questionid,
      questionname: questionname,
    );
  }
}