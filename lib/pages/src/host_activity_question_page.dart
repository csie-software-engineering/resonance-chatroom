import 'package:flutter/material.dart';
import '../../providers/providers.dart';
import '../routes.dart';

class HostActivityQuestionPage extends StatefulWidget {
  const HostActivityQuestionPage({Key? key}) : super(key: key);

  static const routeName = '/host_activity_question_page';

  @override
  State<HostActivityQuestionPage> createState() =>
      _HostActivityQuestionPageState();
}

class _HostActivityQuestionPageState extends State<HostActivityQuestionPage> {
  List<Widget> fields = [];
  TextEditingController _questionController = TextEditingController();
  @override
  Widget build(BuildContext context) {
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
              SizedBox(width: 16.0),
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
              ...fields,
              Container(
                width: 100, // 使用Container來設定按鈕的寬度
                child: ElevatedButton(
                  onPressed: () {
                    // 跳至送出頁面的邏輯
                    // 傳遞createEvent()方法的回傳值給送出頁面

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

class NewChoiceField extends StatelessWidget {
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
          /*OutlinedButton(
            onPressed: () {
              // 跳至預覽頁面的邏輯
              // 傳遞createEvent()方法的回傳值給預覽頁面
            },
            child: Text('確認'),
          ),*/
          IconButton(
            icon: const Icon(Icons.delete_forever),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}
