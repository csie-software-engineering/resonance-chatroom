import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:resonance_chatroom/models/models.dart';
import '../../providers/providers.dart';
import '../routes.dart';

class HostActivityQuestionPageArguments {
  final String activityId;
  final String questionId;

  HostActivityQuestionPageArguments(
      {required this.activityId, required this.questionId});
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
  List<Widget> fields = [];
  late final args = ModalRoute.of(context)!.settings.arguments
      as HostActivityQuestionPageArguments;
  TextEditingController _questionController = TextEditingController();
  TextEditingController _choice1Controller = TextEditingController();
  TextEditingController _choice2Controller = TextEditingController();
  TextEditingController _choice3Controller = TextEditingController();
  TextEditingController _choice4Controller = TextEditingController();
  TextEditingController _choice5Controller = TextEditingController();
  late final ActivityProvider setActivityProvider =
      context.read<ActivityProvider>();
  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Text('問卷頁面'),
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
              Container(
                width: 100,
                child: ElevatedButton(
                  onPressed: () async {
                    print("問卷修改");
                    // 跳至送出頁面的邏輯
                    // 傳遞createEvent()方法的回傳值給送出頁面
                    Question question = await setActivityProvider.getQuestion(
                      args.activityId,
                      args.questionId,
                    );
                    print(question.choices);
                    question.questionName = _questionController.text;
                    print("===========");
                    print(choice);
                    choice[0] = _choice1Controller.text;
                    choice[1] = _choice2Controller.text;
                    choice[2] = _choice3Controller.text;
                    choice[3] = _choice4Controller.text;
                    choice[4] = _choice5Controller.text;
                    question.choices = choice;
                    await setActivityProvider.editQuestion(
                        args.activityId, args.questionId, question);
                  },
                  child: Text('送出'),
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