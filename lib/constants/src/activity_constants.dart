enum Activityconstants {
  activityname,
  ownerid,
  activityid,
  activityinfo,
  startdate,
  enddate,
  activitryphoto,
  managers;

  String get value {
    switch (this) {
      case Activityconstants.activityname:
        return "activityname";
      case Activityconstants.ownerid:
        return "ownerid";
      case Activityconstants.activityid:
        return "activityid";
      case Activityconstants.activityinfo:
        return "activityinfo";
      case Activityconstants.startdate:
        return "startdate";
      case Activityconstants.enddate:
        return "enddate";
      case Activityconstants.activitryphoto:
        return "activitryphoto";
      case Activityconstants.managers:
        return "managers";
      default:
        throw Exception("Not found value for FirestoreConstants");
    }
  }
}

enum Tagconstants{
  activityid,
  tagid,
  tagname;

  String get value {
    switch (this) {
      case Tagconstants.activityid:
        return "activityid";
      case Tagconstants.tagid:
        return "tagid";
      case Tagconstants.tagname:
        return "tagname";
      default:
        throw Exception("Not found value for FirestoreConstants");
    }
  }
}

enum Topicconstants{
  activityid,
  tagid,
  topicname,
  topicid;

  String get value {
    switch (this) {
      case Topicconstants.activityid:
        return "activityid";
      case Topicconstants.tagid:
        return "tagid";
      case Topicconstants.topicid:
        return "topicid";
      case Topicconstants.topicname:
        return "topicname";
      default:
        throw Exception("Not found value for FirestoreConstants");
    }
  }
}

enum Questionconstants{
  activityid,
  tagid,
  topicid,
  questionid,
  questionname,
  choices;

  String get value {
    switch (this) {
      case Questionconstants.activityid:
        return "activityid";
      case Questionconstants.tagid:
        return "tagid";
      case Questionconstants.topicid:
        return "topicid";
      case Questionconstants.questionid:
        return "questionid";
      case Questionconstants.questionname:
        return "questionname";
      case Questionconstants.choices:
        return "choices";
      default:
        throw Exception("Not found value for FirestoreConstants");
    }
  }
}