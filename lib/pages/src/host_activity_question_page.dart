import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/models.dart';
import '../../providers/providers.dart';
import '../../widgets/src/my_app_bar.dart';
import '../routes.dart';

class HostActivityQuestionPageArguments {
  final String activityId;
  final String tagId;
  final String topicId;
  final String questionId;

  HostActivityQuestionPageArguments({
    required this.activityId,
    required this.tagId,
    required this.topicId,
    required this.questionId,
  });
}

class HostActivityQuestionPage extends StatefulWidget {
  const HostActivityQuestionPage({super.key});

  static const routeName = '/host_activity_question_page';

  @override
  State<HostActivityQuestionPage> createState() =>
      _HostActivityQuestionPageState();
}

class _HostActivityQuestionPageState extends State<HostActivityQuestionPage> {
  List<String> choice = ["", "", "", "", ""];
  late final Question _originQuestion;
  List<Widget> fields = [];
  late final args = ModalRoute.of(context)!.settings.arguments
      as HostActivityQuestionPageArguments;
  final TextEditingController _questionController = TextEditingController();
  final TextEditingController _choice1Controller = TextEditingController();
  final TextEditingController _choice2Controller = TextEditingController();
  final TextEditingController _choice3Controller = TextEditingController();
  final TextEditingController _choice4Controller = TextEditingController();
  final TextEditingController _choice5Controller = TextEditingController();
  late final ActivityProvider questionProvider =
      context.read<ActivityProvider>();

  void _initQuestionContent() async {
    debugPrint("初始問卷頁面");
    var getQuestion =
        await questionProvider.getQuestion(args.activityId, args.questionId);

    _originQuestion = getQuestion;
    _questionController.text = _originQuestion.questionName;
    // 創建一個列表來存儲所有的_choiceiController
    List<TextEditingController> choiceControllers = [
      _choice1Controller,
      _choice2Controller,
      _choice3Controller,
      _choice4Controller,
      _choice5Controller
    ];
    // 使用for循環來遍歷_originQuestion.choices
    for (int i = 0; i < _originQuestion.choices.length; i++) {
      // 將每個元素賦值給對應的_choiceiController.text
      choiceControllers[i].text = _originQuestion.choices[i];
    }
    // 如果_originQuestion.choices的長度小於5
    if (_originQuestion.choices.length < 5) {
      // 將剩下的_choiceiController.text賦值為空字符串
      for (int i = _originQuestion.choices.length; i < 5; i++) {
        choiceControllers[i].text = "";
      }
    }
    debugPrint(_questionController.text);
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 350), () {
      _initQuestionContent();
    });
  }

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: CustomAppBar(
        leading: const BackButton(),
        title: '設定活動問卷',
        tail: null,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 16.0),
              Row(
                children: [
                  const Text('問卷題目'),
                  const SizedBox(width: 16.0),
                  Expanded(
                    child: TextField(
                      controller: _questionController,
                      maxLines: 5,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: height * 0.05,
                  ),
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _choice1Controller,
                      decoration: const InputDecoration(labelText: "選項一"),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: height * 0.05,
                  ),
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _choice2Controller,
                      decoration: const InputDecoration(labelText: "選項二"),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: height * 0.05,
                  ),
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _choice3Controller,
                      decoration: const InputDecoration(labelText: "選項三"),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: height * 0.05,
                  ),
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _choice4Controller,
                      decoration: const InputDecoration(labelText: "選項四"),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: height * 0.05,
                  ),
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _choice5Controller,
                      decoration: const InputDecoration(labelText: "選項五"),
                    ),
                  ),
                ],
              ),
/*              SizedBox(width: 16.0),
              Container(
                width: 280, // 使用Container來設定按鈕的寬度
                child: ElevatedButton(
                  child: const Text(
                    "新增選項",
                  ),
                  onPressed: () {
                    setState(() {
                      fields.add(NewChoiceField(
                        onDelete: () {
                          setState(() {
                            fields.removeAt(fields.length - 1);
                          });
                        },
                      ));
                    });
                  },
                ),
              ),
              ...fields,*/
              SizedBox(
                width: 100,
                child: ElevatedButton(
                  onPressed: () {
                    debugPrint("問卷修改");
                    // 跳至送出頁面的邏輯
                    // 傳遞createEvent()方法的回傳值給送出頁面
                    questionProvider
                        .getQuestion(
                      args.activityId,
                      args.questionId,
                    )
                        .then((question) {
                      debugPrint(question.choices.toString());
                      question.questionName = _questionController.text;
                      debugPrint("===========");
                      debugPrint(choice.toString());
                      choice[0] = _choice1Controller.text;
                      choice[1] = _choice2Controller.text;
                      choice[2] = _choice3Controller.text;
                      choice[3] = _choice4Controller.text;
                      choice[4] = _choice5Controller.text;
                      question.choices = choice;
                      questionProvider
                          .editQuestion(
                              args.activityId, args.questionId, question)
                          .then((_) => Navigator.of(context).pushNamed(
                                HostActivityTopicPage.routeName,
                                arguments: HostActivityTopicPageArguments(
                                  activityId: args.activityId,
                                  tagId: args.tagId,
                                ),
                              ));
                    });
                  },
                  child: const Text('送出'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
/*class NewChoiceField extends StatelessWidget {
  NewChoiceField({
    super.key,
    required this.onDelete,
  });
  final VoidCallback? onDelete;
  final TextEditingController _controller =
      TextEditingController(); // 定義一個TextEditingController
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: _controller, // 使用TextEditingController來控制欄位的輸入值
              decoration: const InputDecoration(
                label: Text('新選項'),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_forever),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}
*/