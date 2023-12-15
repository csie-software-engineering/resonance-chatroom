enum FirestoreConstants {
  activityCollectionPath,
  roomCollectionPath,
  messageCollectionPath,
  chatQueueNodeCollectionPath,
  tagCollectionPath,
  topicCollectionPath,
  questionCollectionPath,
  reviewCollectionPath,
  reportCollectionPath,

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
      case FirestoreConstants.tagCollectionPath:
        return "tags";
      case FirestoreConstants.topicCollectionPath:
        return "topics";
      case FirestoreConstants.questionCollectionPath:
        return "questions";
      case FirestoreConstants.reviewCollectionPath:
        return "reviews";
      case FirestoreConstants.reportCollectionPath:
        return "reports";
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
}
