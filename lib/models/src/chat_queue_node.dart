import 'package:cloud_firestore/cloud_firestore.dart';

import '../../constants/constants.dart';

class ChatQueueNode {
  final String userId;
  final List<String> tagIds;
  final String timestamp;

  const ChatQueueNode({
    required this.userId,
    required this.tagIds,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        QueueConstants.userId.value: userId,
        QueueConstants.tagIds.value: tagIds,
        QueueConstants.timestamp.value: timestamp,
      };

  factory ChatQueueNode.fromDocument(DocumentSnapshot doc) => ChatQueueNode(
        userId: doc.get(QueueConstants.userId.value),
        tagIds: List<String>.from(doc.get(QueueConstants.tagIds.value)),
        timestamp: doc.get(QueueConstants.timestamp.value),
      );

  @override
  String toString() =>
      'ChatQueueNode(userId: $userId, tagIds: $tagIds, timestamp: $timestamp)';
}
