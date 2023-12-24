import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:resonance_chatroom/providers/providers.dart';
import '../../models/models.dart';
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
  late final List<Tag> _origintag;
  late final args = ModalRoute.of(context)!.settings.arguments
      as HostActivityTagPageArguments;
  late final ActivityProvider tagProvider = context.read<ActivityProvider>();
  List<Widget> fields = [];
  Future<void> _initTagContent() async {
    var getTags = await tagProvider.getAllTags(args.activityId);
    if (getTags != null) {
      _origintag = getTags;
    }
    for (int i = 0; i < _origintag.length; i++) {
      fields.add(NewTagField(
        onDelete: () {
          setState(() {
            fields.removeAt(fields.length - 1);
          });
        },
        id: _origintag[i].uid,
        activityid: args.activityId,
        tagname: _origintag[i].tagName,
      ));
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 350), () {
      this._initTagContent();
   });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('標籤頁面'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('活動標籤'),
                  SizedBox(width: 16.0),
                  Container(
                    width: 280,
                    child: ElevatedButton(
                      child: const Text(
                        "新增標籤",
                      ),
                      onPressed: () async {
                        Tag tag = await tagProvider.addNewTag(
                          args.activityId,
                          "",
                        );
                        print("活動id" + args.activityId);
                        setState(() {
                          fields.add(NewTagField(
                            onDelete: () {
                              setState(() {
                                fields.removeAt(fields.length - 1);
                              });
                            },
                            id: tag.uid,
                            activityid: args.activityId,
                            tagname: "",
                          ));
                        });
                      },
                    ),
                  ),
                ],
              ),
              ...fields,
              Container(
                width: 100,
                child: ElevatedButton(
                  onPressed: () {
                    // 跳至送出頁面的邏輯
                    // 傳遞createEvent()方法的回傳值給送出頁面
                    print("跳至主畫面");
                    Navigator.of(context).pushNamed(
                      MainPage.routeName,
                      arguments: MainPageArguments(isHost: true),
                    );
                  },
                  child: Text('完成'),
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
  NewTagField({
    super.key,
    required this.onDelete,
    required this.id,
    required this.activityid,
    required this.tagname,
  });
  final VoidCallback? onDelete;
  String id;
  String activityid;
  String tagname;
  @override
  _NewTagFieldState createState() => _NewTagFieldState();
}

class _NewTagFieldState extends State<NewTagField> {
  bool isEditing = false;
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  late final ActivityProvider tagbuttonProvider =
      context.read<ActivityProvider>();
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
                  : Text(widget.tagname),
              onPressed: () {
                print("跳至topic頁面");
                Navigator.of(context).pushNamed(HostActivityTopicPage.routeName,
                    arguments: HostActivityTopicPageArguments(
                      activityId: widget.activityid,
                      tagId: widget.id,
                    ));
              },
            ),
          ),
          IconButton(
            icon: isEditing ? Icon(Icons.check) : Icon(Icons.edit),
            onPressed: () async {
              setState(() {
                isEditing = !isEditing;
                if (isEditing == false) {
                  widget.tagname = _controller.text;
                } else {
                  _focusNode.requestFocus();
                }
              });
              print("更改標籤");
              await tagbuttonProvider.editTag(
                widget.activityid,
                widget.id,
                widget.tagname,
              );
            },
          ),
          IconButton(
            icon: isEditing ? Icon(Icons.close) : Icon(Icons.delete_forever),
            onPressed: isEditing
                ? () {
                    setState(() {
                      isEditing = false;
                      _controller.text = widget.tagname;
                    });
                  }
                : () {
                    widget.onDelete!();
                  },
          ),
        ],
      ),
    );
  }
}
