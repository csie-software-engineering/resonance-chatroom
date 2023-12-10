import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/models.dart';
import '../../constants/constants.dart';
import '../../providers/providers.dart';

class ChatProvider {
  final FirebaseFirestore db;
  final SharedPreferences pref;

  ChatProvider({
    required this.db,
    required this.pref,
  });

  String? getPref(String key) {
    return pref.getString(key);
  }

  /// 取得聊天訊息串流
  Stream<QuerySnapshot> getChatStream(
    String activityId,
    List<String> userIds, {
    int limit = 20,
  }) =>
      db
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
    List<String> tagIds1,
    List<String> tagIds2, {
    bool random = true,
  }) {
    if (random) tagIds1.shuffle();
    for (final tagId in tagIds1) {
      if (tagIds2.contains(tagId)) {
        return tagId;
      }
    }
    return null;
  }

  /// 獲取聊天對象 ID，若沒有聊天對象則進行配對
  ///
  /// 會先查看是否有啟用的聊天室，若有則直接進入，若沒有則進入等待配對
  Future<String?> getChatToUserId(
    String userId,
    String activityId,
  ) async {
    final enableRoomUserId =
        await _getChatToUserIdInEnableRoom(userId, activityId);
    if (enableRoomUserId != null) return enableRoomUserId;

    return await _pairOrWait(userId, activityId);
  }

  /// 從啟用的聊天室中獲取聊天對象 ID
  ///
  /// 回傳 對方ID (回傳 null 表示沒有啟用的聊天室)
  Future<String?> _getChatToUserIdInEnableRoom(
    String userId,
    String activityId,
  ) async {
    final roomQuery = db
        .collection(FirestoreConstants.activityCollectionPath.value)
        .doc(activityId)
        .collection(FirestoreConstants.roomCollectionPath.value)
        .where(RoomConstants.isEnable.value, isEqualTo: true);

    final allRoomData = await roomQuery.get();

    final rooms = allRoomData.docs
        .map((e) => Room.fromDocument(e))
        .where((e) => e.users.any((e) => e.id == userId))
        .toList();

    if (rooms.isEmpty) return null;
    return rooms.first.users.firstWhere((e) => e.id != userId).id;
  }

  /// 配對成功或進入等待
  ///
  /// 回傳 對方ID (回傳 null 表示進入等待)
  Future<String?> _pairOrWait(
    String userId,
    String activityId,
  ) async {
    final activityRef = db
        .collection(FirestoreConstants.activityCollectionPath.value)
        .doc(activityId);

    assert((await activityRef.get()).exists, '活動不存在');

    final userActivity =
        await UserProvider(db: db).getUserActivity(userId, activityId);

    final waitingUserQuery = activityRef
        .collection(FirestoreConstants.chatQueueNodeCollectionPath.value)
        .where(QueueConstants.tagIds.value,
            arrayContainsAny: userActivity.tagIds)
        .orderBy(QueueConstants.timestamp.value)
        .limit(1);

    final room = await db.runTransaction((transaction) async {
      if ((await waitingUserQuery.count().get()).count > 0) {
        final waitingUserRef =
            (await waitingUserQuery.get()).docs.first.reference;
        final waitingUserData = await transaction.get(waitingUserRef);
        final waitingUser = ChatQueueNode.fromDocument(waitingUserData);

        await _createOrEnableRoom(
          activityId,
          [userId, waitingUser.userId],
          _findMutualTag(userActivity.tagIds, waitingUser.tagIds)!,
          transaction: transaction,
        );
        transaction.delete(waitingUserRef);

        return waitingUser.userId;
      } else {
        final queueNodeRef = activityRef
            .collection(FirestoreConstants.chatQueueNodeCollectionPath.value)
            .doc(userId);

        // 不能重複排隊
        assert(!(await transaction.get(queueNodeRef)).exists, '不能重複排隊');

        final curTime = DateTime.now().millisecondsSinceEpoch.toString();
        final chatQueueNode = ChatQueueNode(
          tagIds: userActivity.tagIds,
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
    String tag, {
    Transaction? transaction,
  }) async {
    final roomDataRef = db
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
  Future<void> leaveRoom(
    String activityId,
    List<String> userIds,
  ) async {
    final roomQuery = db
        .collection(FirestoreConstants.activityCollectionPath.value)
        .doc(activityId)
        .collection(FirestoreConstants.roomCollectionPath.value)
        .doc(_getRoomId(userIds));

    final roomData = await roomQuery.get();
    assert(roomData.exists, '房間不存在');
    assert(roomData.get(RoomConstants.isEnable.value), '房間已停用');

    await roomQuery.update({
      RoomConstants.isEnable.value: false,
    });
  }

  /// 取得房間資訊
  Future<Room> getRoom(
    String activityId,
    List<String> userIds,
  ) async {
    final roomQuery = db
        .collection(FirestoreConstants.activityCollectionPath.value)
        .doc(activityId)
        .collection(FirestoreConstants.roomCollectionPath.value)
        .doc(_getRoomId(userIds));

    final roomData = await roomQuery.get();
    assert(roomData.exists, '房間不存在');

    final room = Room.fromDocument(roomData);
    return room;
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
    assert(room.isEnable, '房間已關閉');

    final curTime = DateTime.now().millisecondsSinceEpoch.toString();
    final roomId = _getRoomId([fromId, toId]);
    ChatMessage messageData = ChatMessage(
      fromId: fromId,
      toId: toId,
      timestamp: curTime,
      content: content,
      type: type,
    );

    await db
        .collection(FirestoreConstants.activityCollectionPath.value)
        .doc(activityId)
        .collection(FirestoreConstants.roomCollectionPath.value)
        .doc(roomId)
        .collection(FirestoreConstants.messageCollectionPath.value)
        .doc(curTime)
        .set(messageData.toJson());
  }

  /// 取得使用者在某活動的聊天室列表
  Future<List<Room>> getUserRooms(
    String userId,
    String activityId,
  ) async {
    final roomQuery = db
        .collection(FirestoreConstants.activityCollectionPath.value)
        .doc(activityId)
        .collection(FirestoreConstants.roomCollectionPath.value);

    final allRoomData = await roomQuery.get();
    final rooms = allRoomData.docs
        .map((e) => Room.fromDocument(e))
        .where((e) => e.users.any((e) => e.id == userId))
        .toList();

    return rooms;
  }
}
