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
      Tagconstants.activityid.value: activityid,
      Tagconstants.tagname.value: tagname,
      Tagconstants.tagid.value: tagid,
    };
  }

  factory Tag.fromDocument(DocumentSnapshot doc) {
    String activityid = doc.get(Tagconstants.activityid.value);
    String tagname = doc.get(Tagconstants.tagname.value);
    String tagid = doc.get(Tagconstants.tagid.value);
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

  const Topic({
    required this.activityid,
    required this.tagid,
    required this.topicname,
    required this.topicid,
  });

  Map<String, dynamic> toJson() {
    return {
      Topicconstants.activityid.value: activityid,
      Topicconstants.tagid.value: tagid,
      Topicconstants.topicname.value: topicname,
      Topicconstants.topicid.value: topicid,
    };
  }

  factory Topic.fromDocument(DocumentSnapshot doc) {
    String activityid = doc.get(Topicconstants.activityid.value);
    String tagid = doc.get(Topicconstants.tagid.value);
    String topicname = doc.get(Topicconstants.topicname.value);
    String topicid = doc.get(Topicconstants.topicid.value);
    return Topic(
      activityid: activityid,
      tagid: tagid,
      topicname: topicname,
      topicid: topicid,
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
      Questionconstants.activityid.value: activityid,
      Questionconstants.tagid.value: tagid,
      Questionconstants.topicid.value: topicid,
      Questionconstants.questionid.value: questionid,
      Questionconstants.questionname.value: questionname,
      Questionconstants.choices.value: choices
    };
  }

  factory Question.fromDocument(DocumentSnapshot doc) {
    String activityid = doc.get(Questionconstants.activityid.value);
    String tagid = doc.get(Questionconstants.tagid.value);
    String topicid = doc.get(Questionconstants.topicid.value);
    String questionid = doc.get(Questionconstants.questionid.value);
    String questionname = doc.get(Questionconstants.questionname.value);
    List<dynamic> choices = doc.get(Questionconstants.choices.value);
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