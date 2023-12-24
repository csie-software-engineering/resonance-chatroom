import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:resonance_chatroom/providers/providers.dart';
import '../../models/models.dart';
import '../routes.dart';

class HostActivityTopicPageArguments {
  final String activityId;
  final String tagId;

  HostActivityTopicPageArguments(
      {required this.activityId, required this.tagId});
}

class HostActivityTopicPage extends StatefulWidget {
  const HostActivityTopicPage({super.key});

  static const routeName = '/host_activity_topic_page';

  @override
  State<HostActivityTopicPage> createState() => _HostActivityTopicPageState();
}

class _HostActivityTopicPageState extends State<HostActivityTopicPage> {
  late final args = ModalRoute.of(context)!.settings.arguments
      as HostActivityTopicPageArguments;
  late final ActivityProvider topicProvider = context.read<ActivityProvider>();
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
                    width: 280,
                    child: ElevatedButton(
                      child: const Text(
                        "新增話題",
                      ),
                      onPressed: () async {
                        print("新增話題");
                        Topic topic = Topic(
                            activityId: args.activityId,
                            tagId: args.tagId,
                            topicName: "");
                        Topic tmp = await topicProvider.addNewTopic(
                          args.activityId,
                          topic,
                        );
                        Question questiontmp = Question(
                          activityId: args.activityId,
                          tagId: args.tagId,
                          topicId: tmp.uid,
                          questionName: "",
                        );
                        Question question = await topicProvider.addNewQuestion(
                            args.activityId, questiontmp);
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
                width: 100,
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
    required this.activityid,
  });
  final VoidCallback? onDelete;
  String questionid;
  String id;
  String activityid;
  @override
  _NewTopicFieldState createState() => _NewTopicFieldState();
}

class _NewTopicFieldState extends State<NewTopicField> {
  bool isEditing = false;
  late String topic;
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
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
              child: isEditing
                  ? TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                    )
                  : Text(_controller.text.isEmpty ? "新話題" : _controller.text),
              onPressed: () async {
                print("跳至問卷頁面");
                print(widget.questionid);
                Navigator.of(context)
                    .pushNamed(HostActivityQuestionPage.routeName,
                        arguments: HostActivityQuestionPageArguments(
                          activityId: widget.activityid,
                          questionId: widget.questionid,
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
                  topic = _controller.text;
                } else {
                  _focusNode.requestFocus();
                }
              });
              await activityProvider.editTopic(
                  widget.activityid, widget.id, topic);
            },
          ),
          IconButton(
            icon: isEditing ? Icon(Icons.close) : Icon(Icons.delete_forever),
            onPressed: isEditing
                ? () {
                    setState(() {
                      isEditing = false;
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
