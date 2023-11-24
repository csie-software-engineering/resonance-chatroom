import 'package:cloud_firestore/cloud_firestore.dart';

import '../../constants/constants.dart';

class ChatQueueNode {
  final List<String> tags;
  final String userId;
  final String timestamp;

  const ChatQueueNode({
    required this.tags,
    required this.userId,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      QueueConstants.tag.value: tags,
      QueueConstants.userId.value: userId,
      QueueConstants.timestamp.value: timestamp,
    };
  }

  factory ChatQueueNode.fromDocument(DocumentSnapshot doc) {
    List<dynamic> tag = doc.get(QueueConstants.tag.value);
    String userId = doc.get(QueueConstants.userId.value);
    String timestamp = doc.get(QueueConstants.timestamp.value);
    return ChatQueueNode(
      tags: tag.cast<String>(),
      userId: userId,
      timestamp: timestamp,
    );
  }
}
