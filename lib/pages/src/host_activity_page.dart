import 'package:flutter/material.dart';
import '../../providers/providers.dart';
import '../routes.dart';

class HostActivityPage extends StatefulWidget {
  @override
  State<HostActivityPage> createState() => _HostActivityPageState();
}

class _HostActivityPageState extends State<HostActivityPage> {
  List<Widget> fields = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('活動頁面'),
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
                      onPressed: () {
                        setState(() {
                          fields.add(NewTagField(
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
                ],
              ),
              ...fields,
            ],
          ),
        ),
      ),
    );
  }
}

class NewTagField extends StatelessWidget {
  NewTagField({
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
                label: Text('新標籤'),
              ),
            ),
          ),
          OutlinedButton(
            onPressed: () {
              // 跳至預覽頁面的邏輯
              // 傳遞createEvent()方法的回傳值給預覽頁面
            },
            child: Text('確認'),
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
