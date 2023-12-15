import 'package:cloud_firestore/cloud_firestore.dart';

import '../../constants/constants.dart';

enum MessageType {
  text,
  image;

  String get value {
    switch (this) {
      case MessageType.text:
        return "text";
      case MessageType.image:
        return "image";
      default:
        throw Exception("Not found value for MessageType");
    }
  }
}

class ChatMessage {
  final String fromId;
  final String toId;
  final String timestamp;
  final String content;
  final MessageType type;

  const ChatMessage({
    required this.fromId,
    required this.toId,
    required this.timestamp,
    required this.content,
    required this.type,
  });

  Map<String, dynamic> toJson() {
    return {
      MessageConstants.idFrom.value: fromId,
      MessageConstants.idTo.value: toId,
      MessageConstants.timestamp.value: timestamp,
      MessageConstants.content.value: content,
      MessageConstants.type.value: type.value,
    };
  }

  factory ChatMessage.fromDocument(DocumentSnapshot doc) {
    String idFrom = doc.get(MessageConstants.idFrom.value);
    String idTo = doc.get(MessageConstants.idTo.value);
    String timestamp = doc.get(MessageConstants.timestamp.value);
    String content = doc.get(MessageConstants.content.value);
    String typeString = doc.get(MessageConstants.type.value);
    MessageType type = typeString == MessageType.text.value
        ? MessageType.text
        : MessageType.image;
    return ChatMessage(
      fromId: idFrom,
      toId: idTo,
      timestamp: timestamp,
      content: content,
      type: type,
    );
  }
}

class ReportMessage {
  final String activityId;
  final String fromId;
  final String toId;
  final String type;
  final String content;

  const ReportMessage({
    required this.activityId,
    required this.fromId,
    required this.toId,
    required this.type,
    required this.content
  });

  Map<String, dynamic> toJson() {
    return {
      ReportConstants.activityid.value: activityId,
      ReportConstants.idFrom.value: fromId,
      ReportConstants.idTo.value: toId,
      ReportConstants.type.value: type,
      ReportConstants.content.value: content,

    };
  }

  factory ReportMessage.fromDocument(DocumentSnapshot doc) {
    String activityid = doc.get(ReportConstants.activityid.value);
    String idFrom = doc.get(ReportConstants.idFrom.value);
    String idTo = doc.get(ReportConstants.idTo.value);
    String type = doc.get(ReportConstants.type.value);
    String content = doc.get(ReportConstants.content.value);
    return ReportMessage(
      activityId: activityid,
      fromId: idFrom,
      toId: idTo,
      type: type,
      content: content
    );
  }
}
