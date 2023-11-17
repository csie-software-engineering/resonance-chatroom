import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:resonance_chatroom/constants/constants.dart';

enum MessageType { text, image }

class MessageChat {
  final String idFrom;
  final String idTo;
  final String timestamp;
  final String content;
  final MessageType type;

  const MessageChat({
    required this.idFrom,
    required this.idTo,
    required this.timestamp,
    required this.content,
    required this.type,
  });

  Map<String, dynamic> toJson() {
    return {
      FirestoreConstants.idFrom: idFrom,
      FirestoreConstants.idTo: idTo,
      FirestoreConstants.timestamp: timestamp,
      FirestoreConstants.content: content,
      FirestoreConstants.type: type.toString(),
    };
  }

  factory MessageChat.fromDocument(DocumentSnapshot doc) {
    String idFrom = doc.get(FirestoreConstants.idFrom);
    String idTo = doc.get(FirestoreConstants.idTo);
    String timestamp = doc.get(FirestoreConstants.timestamp);
    String content = doc.get(FirestoreConstants.content);
    String typeString = doc.get(FirestoreConstants.type);
    MessageType type =
        typeString == "text" ? MessageType.text : MessageType.image;
    return MessageChat(
      idFrom: idFrom,
      idTo: idTo,
      timestamp: timestamp,
      content: content,
      type: type,
    );
  }
}
