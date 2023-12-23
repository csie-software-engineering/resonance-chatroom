import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:resonance_chatroom/pages/routes.dart';
import 'package:resonance_chatroom/providers/providers.dart';

import '../../models/models.dart';

class ManagerArguments {
  final String activityId;

  ManagerArguments({
    required this.activityId,
  });
}

class ManagerPage extends StatefulWidget {
  const ManagerPage({super.key});

  static const routeName = '/manager';

  @override
  State<ManagerPage> createState() => _ManagerPageState();
}

class _ManagerPageState extends State<ManagerPage> {
  late List<String> managers;
  final TextEditingController _textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as ManagerArguments;

    return FutureBuilder<List<String>>(
      future: context.read<ActivityProvider>().getAllManagers(args.activityId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        managers = snapshot.data!;

        return Scaffold(
          appBar: AppBar(
            title: const Text('管理者名單'),
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _textEditingController,
                  decoration: InputDecoration(
                    hintText: '輸入新的管理者',
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  final newManagerId = _textEditingController.text;
                  if (newManagerId.isNotEmpty) {
                    _addNewManager(args.activityId, newManagerId);
                  }
                },
                child: Text('新增管理者'),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: managers.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(managers[index]),
                      trailing: IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          assert(index > 0, "不能刪除主辦者");
                          final deleteUserId = managers[index];
                          _deleteItem(args.activityId, deleteUserId);
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _deleteItem(String activityId, String deleteUserId) async {
    await ActivityProvider().deleteManagers(activityId, deleteUserId);
    managers = await ActivityProvider().getAllManagers(activityId);
    setState(() {});
  }

  Future<void> _addNewManager(String activityId, String newManagerId) async {
    await ActivityProvider().addManagers(activityId, newManagerId);
    managers = await ActivityProvider().getAllManagers(activityId);
    _textEditingController.clear();
    setState(() {});
  }
}
