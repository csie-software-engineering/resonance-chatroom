import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:resonance_chatroom/providers/providers.dart';
import '../../models/models.dart';
import '../../widgets/src/my_app_bar.dart';
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
  late final List<Topic> _originTopic;
  List<Widget> fields = [];
  late final args = ModalRoute.of(context)!.settings.arguments
      as HostActivityTopicPageArguments;
  late final ActivityProvider activityProvider =
      context.read<ActivityProvider>();

  void _initTopicContent() {
    debugPrint("初始話題頁面");
    try {
      activityProvider.getTopicsByTag(args.activityId, args.tagId).then((
          value) {
        _originTopic = value;
        for (int i = 0; i < _originTopic.length; i++) {
          activityProvider
              .getQuestionByTopic(args.activityId, _originTopic[i].uid)
              .then((questionTmp) {
            fields.add(NewTopicField(
              onDelete: (i) {
                setState(() {
                  fields.removeAt(i);
                  for (int i = 0; i < fields.length; i++) {
                    NewTopicField topicField = fields[i] as NewTopicField;
                    topicField.index = i;
                    fields[i] = topicField;
                  }
                });
              },
              index: i,
              id: _originTopic[i].uid,
              questionId: questionTmp.uid,
              tagId: args.tagId,
              activityId: args.activityId,
              topicName: _originTopic[i].topicName,
            ));
            setState(() {});
            print("fields.length長度");
            print(fields.length);
          }).onError((error, stackTrace) {
            debugPrint("getQuestionByTopicError: $error");
          });
        }
      });
    }catch(e){
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 350), () {
      _initTopicContent();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        leading: const BackButton(),
        title: '設定活動話題',
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
                  const Text('標籤話題'),
                  const SizedBox(width: 16.0),
                  SizedBox(
                    width: 280,
                    child: ElevatedButton(
                      child: const Text(
                        "新增話題",
                      ),
                      onPressed: () async {
                        debugPrint("新增話題");
                        Topic topic = Topic(
                            activityId: args.activityId,
                            tagId: args.tagId,
                            topicName: "");
                        try {
                          Topic tmp = await activityProvider.addNewTopic(
                            args.activityId,
                            topic,
                          );
                          Question questionTmp = Question(
                            activityId: args.activityId,
                            tagId: args.tagId,
                            topicId: tmp.uid,
                            questionName: "",
                          );
                          Question question = await activityProvider
                              .addNewQuestion(args.activityId, questionTmp);
                          int i = fields.length;
                          setState(() {
                            fields.add(NewTopicField(
                              onDelete: (i) {
                                setState(() {
                                  fields.removeAt(i);
                                  for (int i = 0; i < fields.length; i++) {
                                    NewTopicField topicField = fields[i] as NewTopicField;
                                    topicField.index = i;
                                    fields[i] = topicField;
                                  }
                                });
                              },
                              index: i,
                              id: tmp.uid,
                              questionId: question.uid,
                              activityId: args.activityId,
                              tagId: args.tagId,
                              topicName: "",
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
                    // 跳至送出頁面的邏輯
                    // 傳遞createEvent()方法的回傳值給送出頁面
                    debugPrint("topic跳至主畫面");
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

class NewTopicField extends StatefulWidget {
  final Function(int) onDelete;
  int index;
  String questionId;
  String id;
  String activityId;
  String tagId;
  String topicName;

  NewTopicField({
    super.key,
    required this.onDelete,
    required this.index,
    required this.id,
    required this.questionId,
    required this.activityId,
    required this.tagId,
    required this.topicName,
  });

  @override
  State<NewTopicField> createState() => _NewTopicFieldState();
}

class _NewTopicFieldState extends State<NewTopicField> {
  bool isEditing = false;
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
                  : Text(widget.topicName),
              onPressed: () async {
                debugPrint("跳至問卷頁面");
                debugPrint(widget.questionId);
                try {
                  await activityProvider.getTopic(
                      widget.activityId,
                      widget.id);
                  Navigator.of(context)
                      .pushNamed(HostActivityQuestionPage.routeName,
                      arguments: HostActivityQuestionPageArguments(
                        activityId: widget.activityId,
                        tagId: widget.tagId,
                        topicId: widget.id,
                        questionId: widget.questionId,
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
                    widget.topicName = _controller.text;
                  });
                  await activityProvider.editTopic(
                      widget.activityId, widget.id, widget.topicName);
                } catch (e) {
                  setState(() {
                    _controller.clear();
                    widget.topicName = _controller.text;
                  });
                  Fluttertoast.showToast(msg: e.toString());
                }
              }
            }
          ),
          IconButton(
            icon: isEditing
                ? const Icon(Icons.close)
                : const Icon(Icons.delete_forever),
            onPressed: isEditing
                ? () {
                    setState(() {
                      isEditing = false;
                    });
                  }
                : () async {
                    try {
                      await activityProvider.deleteTopicAndQuestion(widget.activityId, widget.id);
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
