enum Activityconstants {
  activityname,
  ownerid,
  activityid,
  activityinfo,
  startdate,
  enddate,
  activitryphoto,

  tagname,
  tagid,

  questionid,
  questionname;

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
        case Activityconstants.tagname:
            return "tagname";
        case Activityconstants.tagid:
            return "tagid";
        case Activityconstants.questionid:
            return "questionid";
        case Activityconstants.questionname:
            return "questionname";
        default:
            throw Exception("Not found value for FirestoreConstants");
    }
  }
}