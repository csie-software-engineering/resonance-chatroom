import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:resonance_chatroom/pages/routes.dart';
import 'package:resonance_chatroom/widgets/src/my_app_bar.dart';

import '../../models/models.dart';
import '../../providers/providers.dart';

class HistoricalChatRoomPageArguments {
  final String activityId;

  const HistoricalChatRoomPageArguments({required this.activityId});
}

class HistoricalChatRoomPage extends StatelessWidget {
  const HistoricalChatRoomPage({Key? key}) : super(key: key);

  static String routeName = '/historical_chat_room';

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments
        as HistoricalChatRoomPageArguments;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      // appBar: myAppBar(
      //   context,
      //   title: const Text('過去的聊天室'),
      //   leading: const BackButton(),
      // ),
      appBar: CustomAppBar(
        leading: const BackButton(),
        title: '過去的聊天室',
        tail: null,
      ),
      body: FutureBuilder<List<Room>>(
        future: context.read<ChatProvider>().getUserRooms(args.activityId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final rooms = snapshot.requireData;
          debugPrint("rooms.length:${rooms.length}");
          return rooms.isNotEmpty
              ? ListView.separated(
                  itemCount: rooms.length,
                  itemBuilder: (context, index) {
                    return FutureBuilder<User>(
                      future: _getUser(context, rooms[index]),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        final user = snapshot.requireData;
                        return ListTile(
                          leading: const Icon(Icons.chat),
                          title: Text(user.displayName),
                          subtitle: FutureBuilder<Tag>(
                            future:
                                _getTag(context, args.activityId, rooms[index]),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              }

                              final tag = snapshot.requireData;
                              return Text('標籤 : ${tag.tagName}');
                            },
                          ),
                          onTap: () {
                            Navigator.of(context).pushNamed(
                              ChatPage.routeName,
                              arguments: ChatPageArguments(
                                activityId: args.activityId,
                                peerId: user.uid,
                                isHistorical: true,
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                  separatorBuilder: (context, index) {
                    return const Divider();
                  },
                )
              : Center(
                  child: Text(
                    '沒有過去的聊天室',
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                );
        },
      ),
    );
  }

  Future<User> _getUser(BuildContext context, Room room) async {
    final userId = room.users
        .firstWhere(
          (element) => element.id != context.read<AuthProvider>().currentUserId,
        )
        .id;

    return await context.read<UserProvider>().getUser(userId: userId);
  }

  Future<Tag> _getTag(
      BuildContext context, String activityId, Room room) async {
    return await context
        .read<ActivityProvider>()
        .getTag(activityId, room.tagId);
  }
}
