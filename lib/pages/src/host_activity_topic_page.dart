import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:resonance_chatroom/providers/providers.dart';
import '../../models/models.dart';
import '../routes.dart';

class HostActivityTopicPageArguments {
  // todo
  // final ;
  final String activityId;
  final String tagId;

  HostActivityTopicPageArguments(
      {required this.activityId, required this.tagId});
}

class HostActivityTopicPage extends StatefulWidget {
  const HostActivityTopicPage(
      {Key? key, required String activityId, required String tagId})
      : super(key: key);

  static const routeName = '/host_activity_topic_page';

  @override
  State<HostActivityTopicPage> createState() => _HostActivityTopicPageState();
}

class _HostActivityTopicPageState extends State<HostActivityTopicPage> {
  late final args = ModalRoute.of(context)!.settings.arguments
      as HostActivityTopicPageArguments;
  late final ActivityProvider activityProvider =
      context.read<ActivityProvider>();
  List<Widget> fields = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('話題頁面'),
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
                  Text('標籤話題'),
                  SizedBox(width: 16.0),
                  Container(
                    width: 280, // 使用Container來設定按鈕的寬度
                    child: ElevatedButton(
                      child: const Text(
                        "新增話題",
                      ),
                      onPressed: () async {
                        Topic topic = Topic(
                            activityId: "20231221-1345-8f43-9113-b1dd764c427f",
                            //args.activityId,
                            tagId: "20231221-1400-8418-8208-3535109ee14f",
                            //args.tagId,
                            topicName: "");
                        Topic tmp = await activityProvider.addNewTopic(
                          "20231221-1345-8f43-9113-b1dd764c427f",
                          //  args.activityId,
                          topic,
                        );
                        print("topic測試");
                        Question questiontmp = Question(
                            activityId: "20231221-1345-8f43-9113-b1dd764c427f",
                            tagId: "20231221-1400-8418-8208-3535109ee14f",
                            topicId: tmp.uid,
                            questionName: "questionName",
                            choices: []);
                        Question question =
                            await activityProvider.addNewQuestion(
                                "20231221-1345-8f43-9113-b1dd764c427f",
                                questiontmp);
                                print("question測試");
                        setState(() {
                          fields.add(NewTopicField(
                            onDelete: () {
                              setState(() {
                                fields.removeAt(fields.length - 1);
                              });
                            },
                            id: tmp.uid,
                            questionid: question.uid,
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

class NewTopicField extends StatefulWidget {
  NewTopicField({
    super.key,
    required this.onDelete,
    required this.id,
    required this.questionid,
  });
  final VoidCallback? onDelete;
  String questionid;
  String id;
  @override
  _NewTopicFieldState createState() => _NewTopicFieldState();
}

class _NewTopicFieldState extends State<NewTopicField> {
  late final args = ModalRoute.of(context)!.settings.arguments
      as HostActivityTopicPageArguments;
  bool isEditing = false; // 定義一個bool變量來控制按鈕的狀態
  late String topic; // 定義一個String變量來儲存按鈕的文字
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
                      ? "新話題"
                      : _controller.text), // 如果isEditing為false，就顯示Text
              onPressed: () async {
                // 跳至預覽頁面的邏輯
                // 傳遞createEvent()方法的回傳值給預覽頁面
                Navigator.of(context)
                    .pushNamed(HostActivityQuestionPage.routeName,
                        arguments: HostActivityQuestionPage(
                          activityId: "20231221-1345-8f43-9113-b1dd764c427f",
                          //args.activityId,
                          questionId: widget.questionid,
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
                  topic = _controller.text; // 將TextEditingController的文字賦值給tag變量
                } else {
                  // 如果isEditing為true，表示開始編輯
                  _focusNode.requestFocus(); // 將焦點賦值給TextField
                }
              });
              await activityProvider.editTopic(
                  "20231221-1345-8f43-9113-b1dd764c427f",
                  //args.activityId,
                  widget.id,
                  topic);
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
