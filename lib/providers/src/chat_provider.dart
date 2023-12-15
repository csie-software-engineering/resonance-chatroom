import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/models.dart';
import '../../constants/constants.dart';

class ChatProvider {
  final SharedPreferences pref;
  final FirebaseFirestore firebaseFirestore;

  ChatProvider({
    required this.firebaseFirestore,
    required this.pref,
  });

  String? getPref(String key) {
    return pref.getString(key);
  }

  /// 取得聊天訊息串流
  Stream<QuerySnapshot> getChatStream(
    String activityId,
    List<String> userIds, [
    int limit = 20,
  ]) =>
      firebaseFirestore
          .collection(FirestoreConstants.activityCollectionPath.value)
          .doc(activityId)
          .collection(FirestoreConstants.roomCollectionPath.value)
          .doc(_getRoomId(userIds))
          .collection(FirestoreConstants.messageCollectionPath.value)
          .orderBy(MessageConstants.timestamp.value, descending: true)
          .limit(limit)
          .snapshots();

  /// 生成房間 ID
  static String _getRoomId(List<String> userIds) {
    assert(userIds.length == 2, '人數須為 2 人');
    assert(userIds.first != userIds.last, '不能跟自己配對');
    return userIds[0].compareTo(userIds[1]) < 0
        ? '${userIds[0]}-${userIds[1]}'
        : '${userIds[1]}-${userIds[0]}';
  }

  /// 取得共同標籤
  static String? _findMutualTag(
    List<String> tags1,
    List<String> tags2, [
    bool random = true,
  ]) {
    if (random) tags1.shuffle();
    for (final tag in tags1) {
      if (tags2.contains(tag)) {
        return tag;
      }
    }
    return null;
  }

  /// 配對成功或進入等待
  ///
  /// 回傳 對方ID 表示配對成功，回傳 null 表示進入等待
  Future<String?> pairOrWait(
    String activityId,
    String userId,
    List<String> tagIds,
  ) async {
    final activityRef = firebaseFirestore
        .collection(FirestoreConstants.activityCollectionPath.value)
        .doc(activityId);

    final waitingUserQuery = activityRef
        .collection(FirestoreConstants.chatQueueNodeCollectionPath.value)
        .where(QueueConstants.tagIds.value, arrayContainsAny: tagIds)
        .orderBy(QueueConstants.timestamp.value)
        .limit(1);

    var room = await firebaseFirestore.runTransaction((transaction) async {
      if ((await waitingUserQuery.count().get()).count > 0) {
        final waitingUserRef =
            (await waitingUserQuery.get()).docs.first.reference;
        final waitingUserData = await transaction.get(waitingUserRef);
        final waitingUser = ChatQueueNode.fromDocument(waitingUserData);

        await _createOrEnableRoom(
          activityId,
          [userId, waitingUser.userId],
          _findMutualTag(tagIds, waitingUser.tags)!,
          transaction,
        );
        transaction.delete(waitingUserRef);
        return waitingUser.userId;
      } else {
        final queueNodeRef = activityRef
            .collection(FirestoreConstants.chatQueueNodeCollectionPath.value)
            .doc(userId);

        // 不能重複排隊
        final queueNodeData = await transaction.get(queueNodeRef);
        assert(!queueNodeData.exists, '不能重複排隊');

        final curTime = DateTime.now().millisecondsSinceEpoch.toString();
        final chatQueueNode = ChatQueueNode(
          tags: tagIds,
          userId: userId,
          timestamp: curTime,
        );
        transaction.set(
          queueNodeRef,
          chatQueueNode.toJson(),
        );
        return null;
      }
    });

    return room;
  }

  /// 創建或啟用(更新)房間
  Future<Room?> _createOrEnableRoom(
    String activityId,
    List<String> userIds,
    String tag, [
    Transaction? transaction,
  ]) async {
    final roomDataRef = firebaseFirestore
        .collection(FirestoreConstants.activityCollectionPath.value)
        .doc(activityId)
        .collection(FirestoreConstants.roomCollectionPath.value)
        .doc(_getRoomId(userIds));

    final roomData = transaction == null
        ? await roomDataRef.get()
        : await transaction.get(roomDataRef);

    if (roomData.exists) {
      transaction == null
          ? roomDataRef.update({
              RoomConstants.isEnable.value: true,
              RoomConstants.tag.value: tag,
            })
          : transaction.update(roomDataRef, {
              RoomConstants.isEnable.value: true,
              RoomConstants.tag.value: tag,
            });
    } else {
      final room = Room(
        tag: tag,
        isEnable: true,
        users: [
          RoomUser(
            id: userIds.first,
            shareSocialMedia: false,
          ),
          RoomUser(
            id: userIds.last,
            shareSocialMedia: false,
          ),
        ],
      );

      transaction == null
          ? roomDataRef.set(room.toJson())
          : transaction.set(roomDataRef, room.toJson());
    }

    return transaction == null
        ? Room.fromDocument(await roomDataRef.get())
        : null;
  }

  /// 離開房間
  Future<bool> leaveRoom(
    String activityId,
    List<String> userIds,
  ) async {
    final roomId = _getRoomId(userIds);
    final roomQuery = firebaseFirestore
        .collection(FirestoreConstants.activityCollectionPath.value)
        .doc(activityId)
        .collection(FirestoreConstants.roomCollectionPath.value)
        .doc(roomId);

    final roomData = await roomQuery.get();
    if (roomData.exists && roomData.get(RoomConstants.isEnable.value)) {
      await roomQuery.update({
        RoomConstants.isEnable.value: false,
      });
      return true;
    } else {
      return false;
    }
  }

  /// 取得房間資訊
  Future<Room?> getRoom(
    String activityId,
    List<String> userIds,
  ) async {
    final roomId = _getRoomId(userIds);
    final roomQuery = firebaseFirestore
        .collection(FirestoreConstants.activityCollectionPath.value)
        .doc(activityId)
        .collection(FirestoreConstants.roomCollectionPath.value)
        .doc(roomId);

    final roomData = await roomQuery.get();
    if (roomData.exists) {
      final room = Room.fromDocument(roomData);
      return room;
    } else {
      return null;
    }
  }

  /// 傳遞訊息
  Future<void> sendMessage(
    String activityId,
    String fromId,
    String toId,
    String content,
    MessageType type,
  ) async {
    final room = await getRoom(activityId, [fromId, toId]);
    assert(room != null, '房間不存在');
    assert(room!.isEnable, '房間已關閉');

    final curTime = DateTime.now().millisecondsSinceEpoch.toString();
    final roomId = _getRoomId([fromId, toId]);
    ChatMessage messageData = ChatMessage(
      fromId: fromId,
      toId: toId,
      timestamp: curTime,
      content: content,
      type: type,
    );

    await firebaseFirestore
        .collection(FirestoreConstants.activityCollectionPath.value)
        .doc(activityId)
        .collection(FirestoreConstants.roomCollectionPath.value)
        .doc(roomId)
        .collection(FirestoreConstants.messageCollectionPath.value)
        .doc(curTime)
        .set(messageData.toJson());
  }
}
