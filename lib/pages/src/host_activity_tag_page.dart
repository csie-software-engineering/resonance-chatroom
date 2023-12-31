import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:resonance_chatroom/providers/providers.dart';
import '../../models/models.dart';
import '../../widgets/src/my_app_bar.dart';
import '../routes.dart';

class HostActivityTagPageArguments {
  final String activityId;
  HostActivityTagPageArguments({required this.activityId});
}

class HostActivityTagPage extends StatefulWidget {
  const HostActivityTagPage({super.key});

  static const routeName = '/host_activity_tag_page';

  @override
  State<HostActivityTagPage> createState() => _HostActivityTagPageState();
}

class _HostActivityTagPageState extends State<HostActivityTagPage> {
  late final List<Tag> _originTag;
  late final args = ModalRoute.of(context)!.settings.arguments
      as HostActivityTagPageArguments;
  late final ActivityProvider tagProvider = context.read<ActivityProvider>();
  List<Widget> fields = [];
  Future<void> _initTagContent() async {
    var getTags;
    try {
      getTags = await tagProvider.getAllTags(args.activityId);
    }catch(e){
      Fluttertoast.showToast(msg: e.toString());
    }

    _originTag = getTags;
    for (int i = 0; i < _originTag.length; i++) {
      fields.add(NewTagField(
        onDelete: (i) {
          setState(() {
            fields.removeAt(i);
            for (int i = 0; i < fields.length; i++) {
              NewTagField tagField = fields[i] as NewTagField;
              tagField.index = i;
              fields[i] = tagField;
            }
          });
        },
        index: i,
        id: _originTag[i].uid,
        activityId: args.activityId,
        tagName: _originTag[i].tagName,
      ));
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 350), () {
      _initTagContent();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        leading: const BackButton(),
        title: '設定活動標籤',
        tail: null,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('活動標籤'),
                  const SizedBox(width: 16.0),
                  SizedBox(
                    width: 280,
                    child: ElevatedButton(
                      child: const Text(
                        '新增標籤',
                      ),
                      onPressed: () async {
                        try{
                          Tag tag = await tagProvider.addNewTag(
                            args.activityId,
                            '',
                          );
                          debugPrint('活動id${args.activityId}');
                          setState(() {
                            int ind = fields.length;
                            fields.add(NewTagField(
                              onDelete: (ind) {
                                setState(() {
                                  fields.removeAt(ind);
                                  for (int i = 0; i < fields.length; i++) {
                                    NewTagField tagField = fields[i] as NewTagField;
                                    tagField.index = i;
                                    fields[i] = tagField;
                                  }
                                });
                              },
                              id: tag.uid,
                              activityId: args.activityId,
                              tagName: '',
                              index: ind,
                            ));
                          });
                        }catch(e){
                          Fluttertoast.showToast(msg: e.toString());
                        }
                      },
                    ),
                  ),
                ],
              ),
              ...fields,
              SizedBox(
                width: 100,
                child: ElevatedButton(
                  onPressed: () {
                    debugPrint('跳至主畫面');
                    Navigator.of(context).pushNamed(
                      MainPage.routeName,
                      arguments: const MainPageArguments(isHost: true),
                    );
                  },
                  child: const Text('完成'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NewTagField extends StatefulWidget {
  final Function(int) onDelete;
  int index;
  final String id;
  final String activityId;
  String tagName;

  NewTagField({
    super.key,
    required this.onDelete,
    required this.id,
    required this.activityId,
    required this.tagName,
    required this.index,
  });

  @override
  State<NewTagField> createState() => _NewTagFieldState();
}

class _NewTagFieldState extends State<NewTagField> {
  bool isEditing = false;
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              child: isEditing
                  ? TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                    )
                  : Text(widget.tagName),
              onPressed: () async {
                try {
                  await context.read<ActivityProvider>().getTag(
                      widget.activityId,
                      widget.id);
                  debugPrint('跳至topic頁面');
                  Navigator.of(context).pushNamed(
                      HostActivityTopicPage.routeName,
                      arguments: HostActivityTopicPageArguments(
                        activityId: widget.activityId,
                        tagId: widget.id,
                      ));
                }catch(e){
                  Fluttertoast.showToast(msg: e.toString());
                }
              },
            ),
          ),
          IconButton(
            icon: isEditing ? const Icon(Icons.check) : const Icon(Icons.edit),
            onPressed: () async {
              isEditing = !isEditing;
              if (isEditing == true){
                setState(() {
                  _focusNode.requestFocus();
                });
              }
              else{
                try {
                  setState(() {
                    isEditing = !isEditing;
                    widget.tagName = _controller.text;
                  });
                  await context
                      .read<ActivityProvider>()
                      .editTag(
                      widget.activityId, widget.id, widget.tagName);
                } catch (e) {
                  setState(() {
                    _controller.clear();
                    widget.tagName = _controller.text;
                  });
                  Fluttertoast.showToast(msg: e.toString());
                }
              }
            },
          ),
          IconButton(
            icon: isEditing
                ? const Icon(Icons.close)
                : const Icon(Icons.delete_forever),
            onPressed: isEditing
                ? () {
                    setState(() {
                      isEditing = false;
                      _controller.text = widget.tagName;
                    });
                  }
                : () async {
                    try {
                      await context
                          .read<ActivityProvider>()
                          .deleteTag(widget.activityId, widget.id);
                      widget.onDelete!(widget.index);
                    }catch(e){
                      Fluttertoast.showToast(msg: e.toString());
                    }
                  },
          ),
        ],
      ),
    );
  }
}
