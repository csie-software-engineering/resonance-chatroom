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
  final List<String> managers;

  const Activity({
    required this.ownerid,
    required this.activityid,
    required this.activityname,
    required this.activityinfo,
    required this.startdate,
    required this.enddate,
    required this.activitryphoto,
    required this.managers
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
      Activityconstants.managers.value: managers
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
    List<dynamic> managers = doc.get(Activityconstants.managers.value);
    return Activity(
      ownerid: ownerid,
      activityid: activityid,
      activityname: activityname,
      activityinfo: activityinfo,
      startdate: startdate,
      enddate: enddate,
      activitryphoto: activitryphoto,
      managers: managers.cast<String>()
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

class Topic {
  final String activityid;
  final String tagid;
  final String topicname;
  final String topicid;
  final String questionid;

  const Topic({
    required this.activityid,
    required this.tagid,
    required this.topicname,
    required this.topicid,
    required this.questionid,
  });

  Map<String, dynamic> toJson() {
    return {
      Activityconstants.activityid.value: activityid,
      Activityconstants.tagid.value: tagid,
      Activityconstants.topicname.value: topicname,
      Activityconstants.topicid.value: topicid,
      Activityconstants.questionid.value: questionid,
    };
  }

  factory Topic.fromDocument(DocumentSnapshot doc) {
    String activityid = doc.get(Activityconstants.activityid.value);
    String tagid = doc.get(Activityconstants.tagid.value);
    String topicname = doc.get(Activityconstants.topicname.value);
    String topicid = doc.get(Activityconstants.topicid.value);
    String questionid = doc.get(Activityconstants.questionid.value);
    return Topic(
      activityid: activityid,
      tagid: tagid,
      topicname: topicname,
      topicid: topicid,
      questionid: questionid,
    );
  }
}

class Question {
  final String activityid;
  final String tagid;
  final String topicid;
  final String questionid;
  final String questionname;
  final List<String> choices;


  const Question({
    required this.activityid,
    required this.tagid,
    required this.topicid,
    required this.questionid,
    required this.questionname,
    required this.choices
  });

  Map<String, dynamic> toJson() {
    return {
      Activityconstants.activityid.value: activityid,
      Activityconstants.tagid.value: tagid,
      Activityconstants.topicid.value: topicid,
      Activityconstants.questionid.value: questionid,
      Activityconstants.questionname.value: questionname,
      Activityconstants.choices.value: choices
    };
  }

  factory Question.fromDocument(DocumentSnapshot doc) {
    String activityid = doc.get(Activityconstants.activityid.value);
    String tagid = doc.get(Activityconstants.tagid.value);
    String topicid = doc.get(Activityconstants.topicid.value);
    String questionid = doc.get(Activityconstants.questionid.value);
    String questionname = doc.get(Activityconstants.questionname.value);
    List<dynamic> choices = doc.get(Activityconstants.choices.value);
    return Question(
      activityid: activityid,
      tagid: tagid,
      topicid: topicid,
      questionid: questionid,
      questionname: questionname,
        choices: choices.cast<String>()
    );
  }
}