enum Activityconstants {
  activityname,
  ownerid,
  activityid,
  activityinfo,
  startdate,
  enddate,
  activitryphoto,
  managers,

  tagname,
  tagid,

  topicname,
  topicid,

  questionid,
  questionname,
  choices;

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
      case Activityconstants.tagname:
        return "tagname";
      case Activityconstants.tagid:
        return "tagid";
      case Activityconstants.topicname:
        return "topicname";
      case Activityconstants.topicid:
        return "topicid";
      case Activityconstants.questionid:
        return "questionid";
      case Activityconstants.questionname:
        return "questionname";
      case Activityconstants.choices:
        return "choices";
      default:
        throw Exception("Not found value for FirestoreConstants");
    }
  }
}