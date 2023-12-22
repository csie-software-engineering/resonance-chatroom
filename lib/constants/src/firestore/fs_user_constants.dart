enum FireStoreUserConstants {
  userCollectionPath,
  userSocialMediaCollectionPath,
  userHostedActivityCollectionPath,
  userJoinedActivityCollectionPath;

  String get value {
    switch (this) {
      case FireStoreUserConstants.userCollectionPath:
        return "users";
      case FireStoreUserConstants.userSocialMediaCollectionPath:
        return "userSocialMedias";
      case FireStoreUserConstants.userHostedActivityCollectionPath:
        return "userHostedActivities";
      case FireStoreUserConstants.userJoinedActivityCollectionPath:
        return "userJoinedActivities";
      default:
        throw Exception("Not found value for FireStoreUserConstants");
    }
  }
}

enum FSUserConstants {
  uid,
  displayName,
  photoUrl,
  email,
  isEnabled;

  String get value {
    switch (this) {
      case FSUserConstants.uid:
        return "id";
      case FSUserConstants.displayName:
        return "displayName";
      case FSUserConstants.photoUrl:
        return "photoUrl";
      case FSUserConstants.email:
        return "email";
      case FSUserConstants.isEnabled:
        return "isEnabled";
      default:
        throw Exception("Not found value for FSUserConstants");
    }
  }
}

enum FSUserSocialMediaConstants {
  displayName,
  linkUrl;

  String get value {
    switch (this) {
      case FSUserSocialMediaConstants.displayName:
        return "displayName";
      case FSUserSocialMediaConstants.linkUrl:
        return "linkUrl";
      default:
        throw Exception("Not found value for FSUserSocialMediaConstants");
    }
  }
}

enum FSUserActivityConstants {
  uid,
  point,
  isManager,
  tagIds;

  String get value {
    switch (this) {
      case FSUserActivityConstants.uid:
        return "uid";
      case FSUserActivityConstants.point:
        return "point";
      case FSUserActivityConstants.isManager:
        return "isManager";
      case FSUserActivityConstants.tagIds:
        return "tags";
      default:
        throw Exception("Not found value for FSUserActivityConstants");
    }
  }
}