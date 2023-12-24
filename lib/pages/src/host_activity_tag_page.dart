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
  late final args = ModalRoute.of(context)!.settings.arguments
      as HostActivityTagPageArguments;

  late final ActivityProvider activityProvider =
      context.read<ActivityProvider>();
  List<Widget> fields = [];

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
                    width: 280, // 使用Container來設定按鈕的寬度
                    child: ElevatedButton(
                      child: const Text(
                        "新增標籤",
                      ),
                      onPressed: () async {
                        Tag tag = await activityProvider.addNewTag(
                          //"20231221-1345-8f43-9113-b1dd764c427f",
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
                          ));
                        });
                      },
                    ),
                  ),
                ],
              ),
              ...fields,
              Container(
                width: 100, // 使用Container來設定按鈕的寬度
                child: ElevatedButton(
                  onPressed: () {
                    // 跳至送出頁面的邏輯
                    // 傳遞createEvent()方法的回傳值給送出頁面
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
  });
  final VoidCallback? onDelete;
  String id;
  String activityid;
  @override
  _NewTagFieldState createState() => _NewTagFieldState();
}

class _NewTagFieldState extends State<NewTagField> {
  bool isEditing = false; // 定義一個bool變量來控制按鈕的狀態
  late String tag; // 定義一個String變量來儲存按鈕的文字
  final TextEditingController _controller =
      TextEditingController(); // 定義一個TextEditingController
  final FocusNode _focusNode = FocusNode(); // 定義一個FocusNode
  late final ActivityProvider activityProvider =
      context.read<ActivityProvider>();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              // 將TextFormField改成ElevatedButton
              child: isEditing
                  ? TextField(
                      // 如果isEditing為true，就顯示TextField
                      controller:
                          _controller, // 使用TextEditingController來控制欄位的輸入值
                      focusNode: _focusNode, // 使用FocusNode來控制欄位的焦點
                    )
                  : Text(_controller.text.isEmpty
                      ? "新標籤"
                      : _controller.text), // 如果isEditing為false，就顯示Text
              onPressed: () {
                // 跳至預覽頁面的邏輯
                // 傳遞createEvent()方法的回傳值給預覽頁面
                print("跳至topic頁面");
                Navigator.of(context).pushNamed(HostActivityTopicPage.routeName,
                    arguments: HostActivityTopicPageArguments(
                      activityId: //"20231221-1345-8f43-9113-b1dd764c427f",
                          widget.activityid,
                      tagId: //"20231221-1400-8418-8208-3535109ee14f",
                          widget.id,
                    ));
              },
            ),
          ),
          IconButton(
            icon: isEditing
                ? Icon(Icons.check)
                : Icon(Icons.edit), // 根據isEditing的值顯示不同的icon
            onPressed: () async {
              setState(() {
                isEditing = !isEditing; // 改變isEditing的值
                if (isEditing == false) {
                  // 如果isEditing為false，表示編輯完成
                  tag = _controller.text; // 將TextEditingController的文字賦值給tag變量
                } else {
                  // 如果isEditing為true，表示開始編輯
                  _focusNode.requestFocus(); // 將焦點賦值給TextField
                }
              });
              print("更改標籤");
              await activityProvider.editTag(
                widget.activityid,
                widget.id,
                tag,
              );
            },
          ),
          IconButton(
            icon: isEditing
                ? Icon(Icons.close)
                : Icon(Icons.delete_forever), // 根據isEditing的值顯示不同的icon
            onPressed: isEditing
                ? () {
                    setState(() {
                      isEditing = false; // 如果isEditing為true，表示取消編輯
                      _controller.text =
                          tag; // 將oldText的值賦值回TextEditingController
                    });
                  }
                : () {
                    widget
                        .onDelete!(); // 如果isEditing為false，表示刪除按鈕，並傳遞索引值給onDelete方法
                  },
          ),
        ],
      ),
    );
  }
}
