enum FirestoreConstants {
  activityCollectionPath,
  roomCollectionPath,
  messageCollectionPath,
  chatQueueNodeCollectionPath,

  nickname,
  aboutMe,
  photoUrl,
  id,
  chattingWith;

  String get value {
    switch (this) {
      case FirestoreConstants.activityCollectionPath:
        return "activities";
      case FirestoreConstants.roomCollectionPath:
        return "rooms";
      case FirestoreConstants.messageCollectionPath:
        return "messages";
      case FirestoreConstants.chatQueueNodeCollectionPath:
        return "chatQueueNodes";
      case FirestoreConstants.nickname:
        return "nickname";
      case FirestoreConstants.aboutMe:
        return "aboutMe";
      case FirestoreConstants.photoUrl:
        return "photoUrl";
      case FirestoreConstants.id:
        return "id";
      case FirestoreConstants.chattingWith:
        return "chattingWith";
      default:
        throw Exception("Not found value for FirestoreConstants");
    }
  }

  //activity set
  static const pathActivityCollection = "activities";
  static const activityname = "activityname";
  static const ownerid = "ownerid";
  static const activityid = "activityid";
  static const activityinfo = "activityinfo";
  static const enddate = "enddate";

  static const pathTagCollection = "tags";
  static const tagname = "tagname";
  static const tagid = "tagid";
  static const pathQuestionCollection = "questions";
  static const questionid = "questionid";
  static const questionname = "questionname";
}
