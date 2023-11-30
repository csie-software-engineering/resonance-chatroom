import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/models.dart';
import '../../constants/constants.dart';

class ChatProvider {
  final SharedPreferences pref;
  final FirebaseFirestore firebaseFirestore;
  final FirebaseStorage firebaseStorage;

  ChatProvider({
    required this.firebaseFirestore,
    required this.pref,
    required this.firebaseStorage,
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
  Future<RoomDetail?> pairOrWait(
    String activityId,
    List<String> tags,
    String userId,
  ) async {
    final activityRef = firebaseFirestore
        .collection(FirestoreConstants.activityCollectionPath.value)
        .doc(activityId);

    final waitingUserQuery = activityRef
        .collection(FirestoreConstants.chatQueueNodeCollectionPath.value)
        .where(QueueConstants.tag.value, arrayContainsAny: tags)
        .orderBy(QueueConstants.timestamp.value)
        .limit(1);

    var room = await firebaseFirestore.runTransaction((transaction) async {
      if ((await waitingUserQuery.count().get()).count > 0) {
        final waitingUserRef =
            (await waitingUserQuery.get()).docs.first.reference;
        final waitingUserData = await transaction.get(waitingUserRef);
        final waitingUser = ChatQueueNode.fromDocument(waitingUserData);

        final roomId = _getRoomId([userId, waitingUser.userId]);
        final roomDetail = await _createOrEnableRoom(
          activityId,
          roomId,
          _findMutualTag(tags, waitingUser.tags)!,
          transaction,
        );
        transaction.delete(waitingUserRef);
        return roomDetail;
      } else {
        final queueNodeRef = activityRef
            .collection(FirestoreConstants.chatQueueNodeCollectionPath.value)
            .doc(userId);

        // 不能重複排隊
        final queueNodeData = await transaction.get(queueNodeRef);
        assert(!queueNodeData.exists, '不能重複排隊');

        final curTime = DateTime.now().millisecondsSinceEpoch.toString();
        final chatQueueNode = ChatQueueNode(
          tags: tags,
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
  Future<RoomDetail?> _createOrEnableRoom(
    String activityId,
    String roomId,
    String tag, [
    Transaction? transaction,
  ]) async {
    final roomDataRef = firebaseFirestore
        .collection(FirestoreConstants.activityCollectionPath.value)
        .doc(activityId)
        .collection(FirestoreConstants.roomCollectionPath.value)
        .doc(roomId);

    final roomData = transaction == null
        ? await roomDataRef.get()
        : await transaction.get(roomDataRef);

    if (roomData.exists) {
      transaction == null
          ? roomDataRef.update({
              RoomDetailConstants.isEnable.value: true,
              RoomDetailConstants.tag.value: tag,
            })
          : transaction.update(roomDataRef, {
              RoomDetailConstants.isEnable.value: true,
              RoomDetailConstants.tag.value: tag,
            });
    } else {
      final roomDetail = RoomDetail(
        tag: tag,
        isEnable: true,
        isShowSocialMedia: false,
      );

      transaction == null
          ? roomDataRef.set(roomDetail.toJson())
          : transaction.set(roomDataRef, roomDetail.toJson());
    }

    return transaction == null
        ? RoomDetail.fromDocument(await roomDataRef.get())
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
    if (roomData.exists && roomData.get(RoomDetailConstants.isEnable.value)) {
      await roomQuery.update({
        RoomDetailConstants.isEnable.value: false,
      });
      return true;
    } else {
      return false;
    }
  }

  /// 取得房間資訊
  Future<RoomDetail?> getRoomDetail(
    String activityId,
    List<String> userIds,
  ) async {
    final roomId = _getRoomId(userIds);
    final roomQuery = firebaseFirestore
        .collection(FirestoreConstants.activityCollectionPath.value)
        .doc(activityId)
        .collection(FirestoreConstants.roomCollectionPath.value)
        .doc(roomId);

    final roomDetailData = await roomQuery.get();
    if (roomDetailData.exists) {
      final roomDetail = RoomDetail.fromDocument(roomDetailData);
      return roomDetail;
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
    final roomDetail = await getRoomDetail(activityId, [fromId, toId]);
    assert(roomDetail != null && roomDetail.isEnable, '房間不存在或已關閉');

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
