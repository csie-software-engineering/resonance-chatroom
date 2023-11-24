import 'package:cloud_firestore/cloud_firestore.dart';

import '../../constants/constants.dart';

class RoomDetail {
  final String tag;
  final bool isEnable;
  final bool isShowSocialMedia;

  const RoomDetail({
    required this.tag,
    required this.isEnable,
    required this.isShowSocialMedia,
  });

  Map<String, dynamic> toJson() {
    return {
      RoomDetailConstants.tag.value: tag,
      RoomDetailConstants.isEnable.value: isEnable,
      RoomDetailConstants.isShowSocialMedia.value: isShowSocialMedia
    };
  }

  factory RoomDetail.fromDocument(DocumentSnapshot doc) {
    String tag = doc.get(RoomDetailConstants.tag.value);
    bool isEnable = doc.get(RoomDetailConstants.isEnable.value);
    bool isShowSocialMedia =
        doc.get(RoomDetailConstants.isShowSocialMedia.value);
    return RoomDetail(
      tag: tag,
      isEnable: isEnable,
      isShowSocialMedia: isShowSocialMedia,
    );
  }
}
