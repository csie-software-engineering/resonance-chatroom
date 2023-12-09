enum FireStoreUserConstants {
  userCollectionPath,
  userSocialMediaCollectionPath,
  userActivityCollectionPath;

  String get value {
    switch (this) {
      case FireStoreUserConstants.userCollectionPath:
        return "users";
      case FireStoreUserConstants.userSocialMediaCollectionPath:
        return "userSocialMedias";
      case FireStoreUserConstants.userActivityCollectionPath:
        return "userActivities";
      default:
        throw Exception("Not found value for FireStoreUserConstants");
    }
  }
}

enum FSUserConstants {
  id,
  displayName,
  photoUrl,
  email,
  isEnabled;

  String get value {
    switch (this) {
      case FSUserConstants.id:
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
  id,
  tagIds;

  String get value {
    switch (this) {
      case FSUserActivityConstants.id:
        return "id";
      case FSUserActivityConstants.tagIds:
        return "tags";
      default:
        throw Exception("Not found value for FSUserActivityConstants");
    }
  }
}