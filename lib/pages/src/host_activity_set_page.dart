import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';

// 定義一個類別來儲存活動的所有內容
class Event {
  String name; // 活動名稱
  late int startTime; // 活動起始時間
  late int endTime; // 活動結束時間
  String info; // 活動資訊

  String? image; // 活動圖片的base64字串

  // 新增一個Tag的陣列
  List<Tag> tags; // 活動的標籤

  Event(this.name, DateTime start, DateTime end, this.info, File? image,
      this.tags) {
    // 改為File? image
    // 將DateTime物件轉換為millisecondsSinceEpoch
    startTime = start.millisecondsSinceEpoch;
    endTime = end.millisecondsSinceEpoch;

    // 將File物件轉換為base64字串
    if (image != null) {
      image = base64Encode(image.readAsBytesSync()) as File?;
    }
  }

  // 將Event物件轉換為字串
  @override
  String toString() {
    return 'Event(name: $name, startTime: $startTime, endTime: $endTime, info: $info, image: $image, tags: $tags)';
  }
}

class Tag {
  String tagdata;
  List<Topic> topics;
  Tag(this.tagdata, this.topics) {}
}

class Topic {
  String topicdata;
  String questiondata;
  List<String> choices;
  Topic(this.topicdata, this.questiondata, this.choices) {}
}

class HostActivitySetPage extends StatefulWidget {
  @override
  _HostActivitySetPageState createState() => _HostActivitySetPageState();
}

class _HostActivitySetPageState extends State<HostActivitySetPage> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _infoController = TextEditingController();
  final List<DateTime> _selectedDates = [DateTime.now(), DateTime.now()];
  File? _selectedImage;
  List<Tag> tags = []; // 活動標籤的List
  final List<Widget> fields = [];
  EdgeInsets columnPadding = EdgeInsets.all(20); // 定義Column的間距
  double fieldHeight = 50; // 定義欄位的高度
  double buttonWidth = 100; // 定義按鈕的寬度
  Future<void> _pickImage() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    setState(() {
      _selectedImage = File(image!.path); // 直接使用image.path來建立File物件
      // 使用print函數來印出base64字串
      print('圖片base64: ${base64Encode(_selectedImage!.readAsBytesSync())}');
    });
  }

  Future<void> _pickStartDate() async {
    // 使用showDatePicker函數來選擇日期
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2024),
    );
    // 如果日期不為空，則繼續選擇時間
    if (date != null) {
      // 使用showTimePicker函數來選擇時間
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      // 如果時間不為空，則將日期和時間組合成一個DateTime物件
      if (time != null) {
        final start = DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
        );
        // 將DateTime物件傳遞給_selectedDates陣列的第一個元素
        setState(() {
          _selectedDates[0] = start;
        });
      }
    }
  }

  Future<void> _pickEndDate() async {
    // 使用showDatePicker函數來選擇日期
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2024),
    );
    // 如果日期不為空，則繼續選擇時間
    if (date != null) {
      // 使用showTimePicker函數來選擇時間
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      // 如果時間不為空，則將日期和時間組合成一個DateTime物件
      if (time != null) {
        final end = DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
        );
        // 將DateTime物件傳遞給_selectedDates陣列的第一個元素
        setState(() {
          _selectedDates[1] = end;
        });
      }
    }
  }

  // 建立一個Event物件，並將使用者輸入的資料傳遞給它
  Event createEvent() {
    return Event(
      _nameController.text,
      _selectedDates[0], // 活動起始時間
      _selectedDates[1], // 活動結束時間
      _infoController.text,
      _selectedImage,
      tags,
    );
  }

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Text('活動頁面'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceEvenly, // 調整子元件的水平對齊方式
                crossAxisAlignment: CrossAxisAlignment.center, // 調整子元件的垂直對齊方式
                children: [
                  SizedBox(
                    height: height * 0.05,
                  ),
                  Expanded(
                    // 使用Expanded Widget來包裹TextFormField
                    flex: 2, // 指定flex因數為2
                    child: TextFormField(
                      decoration: const InputDecoration(labelText: "活動名稱"),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Text('活動開始時間'),
                  SizedBox(width: 16.0),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _pickStartDate, // 按下按鈕可以選擇開始時間
                      child: Text(_selectedDates[0] == null
                          ? '選擇日期和時間'
                          : '${_selectedDates[0]}'), // 顯示選擇的日期和時間
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Text('活動結束時間'),
                  SizedBox(width: 16.0),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _pickEndDate, // 按下按鈕可以選擇結束時間
                      child: Text(_selectedDates[1] == null
                          ? '選擇日期和時間'
                          : '${_selectedDates[1]}'), // 顯示選擇的日期和時間
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16.0),
              Row(
                children: [
                  const Text('活動資訊'),
                  const SizedBox(width: 16.0),
                  Expanded(
                    child: TextField(
                      controller: _infoController,
                      maxLines: 5,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.0),
              // 修改後的活動圖片部分
              Row(
                children: [
                  Text('活動圖片'),
                  SizedBox(width: 16.0),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _pickImage, // 按下按鈕可以選圖片
                      child: Text('選擇圖片'),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 16.0),
              Container(
                height: null, // 將高度改為null
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4.0),
                ),
                child: _selectedImage == null
                    ? Center(child: Text('沒有選擇圖片'))
                    : SingleChildScrollView(
                        // 將Column放在SingleChildScrollView中
                        child: Column(
                          children: [
                            // 使用Image.file來顯示圖片
                            Image.file(_selectedImage!),
                            Text('圖片路徑: ${_selectedImage!.path}'),
                          ],
                        ),
                      ),
              ),

              const SizedBox(height: 20),
              Padding(
                padding: columnPadding, // 使用Padding來設定Column的間距
                child: TextFormField(
                  decoration: const InputDecoration(
                    label: Text('標籤名稱'),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center, // 將按鈕置中
                children: [
                  Container(
                    width: buttonWidth, // 使用Container來設定按鈕的寬度
                    child: MaterialButton(
                      color: Theme.of(context).colorScheme.secondary,
                      child: const Text(
                        "Add tag",
                        style: TextStyle(
                          color: Colors.white),
                      ),
                      onPressed: () {
                        setState(() {
                          fields.add(NewTextField(
                            name: 'name_${fields.length}',
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

              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceEvenly, // 調整子元件的水平對齊方式
                crossAxisAlignment: CrossAxisAlignment.center, // 調整子元件的垂直對齊方式
                children: [
                  SizedBox(
                    height: height * 0.05,
                  ),
                  Container(
                    height: fieldHeight, // 使用Container來設定欄位的高度
                    child: TextFormField(
                      decoration: const InputDecoration(labelText: "活動標籤"),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.0),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      // 跳至預覽頁面的邏輯
                      // 傳遞createEvent()方法的回傳值給預覽頁面
                    },
                    child: Text('預覽'),
                  ),
                  SizedBox(width: 16.0),
                  ElevatedButton(
                    onPressed: () {
                      // 跳至送出頁面的邏輯
                      // 傳遞createEvent()方法的回傳值給送出頁面
                    },
                    child: Text('送出'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NewTextField extends StatelessWidget {
  const NewTextField({
    super.key,
    required this.name,
    this.onDelete,
  });
  final String name;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              decoration: const InputDecoration(
                label: Text('New field'),
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
