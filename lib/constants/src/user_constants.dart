enum UserConstants {
  id,
  displayName,
  photoUrl,
  email,

  activities;

  String get value {
    switch (this) {
      case UserConstants.id:
        return "id";
      case UserConstants.displayName:
        return "displayName";
      case UserConstants.photoUrl:
        return "photoUrl";
      case UserConstants.email:
        return "email";

      case UserConstants.activities:
        return "activities";
      default:
        throw Exception("Not found value for UserConstants");
    }
  }
}

enum UserActivityConstants {
  id,
  displayName,
  tags;

  String get value {
    switch (this) {
      case UserActivityConstants.id:
        return "id";
      case UserActivityConstants.displayName:
        return "displayName";
      case UserActivityConstants.tags:
        return "tags";
      default:
        throw Exception("Not found value for UserActivityConstants");
    }
  }
}

enum UserTagConstants {
  id,
  displayName;

  String get value {
    switch (this) {
      case UserTagConstants.id:
        return "id";
      case UserTagConstants.displayName:
        return "displayName";
      default:
        throw Exception("Not found value for UserTagConstants");
    }
  }
}
