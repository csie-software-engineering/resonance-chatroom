import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/models.dart';
import '../../providers/providers.dart';
import '../../widgets/widgets.dart';

class SocialMediaPage extends StatefulWidget {
  const SocialMediaPage({Key? key}) : super(key: key);

  static const routeName = '/social-media';

  @override
  State<SocialMediaPage> createState() => _SocialMediaPageState();
}

class _SocialMediaPageState extends State<SocialMediaPage> {
  late Future<List<UserSocialMedia>> _futureGetUserSocialMedium;

  final _nameController = TextEditingController();
  final _linkController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _futureGetUserSocialMedium =
        context.read<UserProvider>().getUserSocialMedium();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: CustomAppBar(
        leading: const BackButton(),
        title: '社群媒體',
        tail: null,
      ),
      // myAppBar(
      //   context,
      //   title: const Text('社群媒體'),
      //   leading: const BackButton(),
      // ),
      body: SizedBox(
        height: MediaQuery.of(context).size.height -
            MediaQuery.of(context).viewInsets.bottom,
        child: Column(
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.05),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              height: MediaQuery.of(context).size.height * 0.1,
              child: TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  hintText: '輸入社群媒體名稱',
                ),
              ),
            ),
            SizedBox(width: MediaQuery.of(context).size.width * 0.1),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              height: MediaQuery.of(context).size.height * 0.1,
              child: TextField(
                controller: _linkController,
                decoration: const InputDecoration(
                  hintText: '輸入社群媒體連結',
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final name = _nameController.text;
                final link = _linkController.text;
                if (name.isNotEmpty && link.isNotEmpty) {
                  context
                      .read<UserProvider>()
                      .addUserSocialMedia(
                          UserSocialMedia(displayName: name, linkUrl: link))
                      .then((_) => setState(() {
                            _nameController.clear();
                            _linkController.clear();
                            _futureGetUserSocialMedium = context
                                .read<UserProvider>()
                                .getUserSocialMedium();
                          }));
                } else {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(const SnackBar(content: Text('請輸入完整資訊')));
                }
              },
              child: const Text('新增社群媒體'),
            ),
            Divider(height: MediaQuery.of(context).size.height * 0.05),
            Expanded(
              child: FutureBuilder<List<UserSocialMedia>>(
                future: _futureGetUserSocialMedium,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final socialMedium = snapshot.requireData;
                  return ListView.builder(
                    itemCount: socialMedium.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(socialMedium[index].displayName),
                        subtitle: Text(socialMedium[index].linkUrl),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: const Text('確認刪除'),
                                content: const Text('確定要刪除嗎？'),
                                actions: confirmButtons(
                                  context,
                                  action: () => context
                                      .read<UserProvider>()
                                      .removeUserSocialMedia(
                                          socialMedium[index].displayName)
                                      .then(
                                        (_) => setState(
                                          () {
                                            _futureGetUserSocialMedium = context
                                                .read<UserProvider>()
                                                .getUserSocialMedium();
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                      ),
                                  cancel: () => Navigator.of(context).pop(),
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
