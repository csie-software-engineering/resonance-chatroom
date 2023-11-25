import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

// 定義一個類別來儲存活動的所有內容
class Event {
  String name; // 活動名稱
  List<DateTime> dates; // 活動時間
  String info; // 活動資訊
  XFile? image; // 活動圖片

  Event(this.name, this.dates, this.info, this.image); // 建構子
}

class HostActivitySetPage extends StatefulWidget {
  @override
  _HostActivitySetPageState createState() => _HostActivitySetPageState();
}

class _HostActivitySetPageState extends State<HostActivitySetPage> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _infoController = TextEditingController();
  List<DateTime> _selectedDates = [];
  XFile? _selectedImage;
  Future<void> _pickImage() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    setState(() {
      _selectedImage = image;
    });
  }

  Future<void> _pickDates() async {
    // 使用showDateRangePicker函數來顯示一個日期範圍選擇器
    final dates = await showDateRangePicker(
        context: context,
        initialDateRange: DateTimeRange(
          start: DateTime.now(),
          end: DateTime.now().add(Duration(days: 7)),
        ),
        firstDate: DateTime(2023),
        lastDate: DateTime(2024));
    if (dates != null) {
      setState(() {
        // 將dates轉換為List<DateTime>類型
        _selectedDates = [dates.start, dates.end];
      });
    }
  }

  // 建立一個Event物件，並將使用者輸入的資料傳遞給它
  Event createEvent() {
    return Event(
      _nameController.text,
      _selectedDates,
      _infoController.text,
      _selectedImage,
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
                      decoration:
                          const InputDecoration(labelText: "活動名稱"),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.0),
              Row(
                children: [
                  const Text('活動時間'),
                  const SizedBox(width: 16.0),
                  Expanded(
                    child: InkWell(
                      onTap: _pickDates,
                      child: Container(
                        height: 48.0,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                        child: Center(
                          child: Text(_selectedDates.isEmpty
                              ? '選擇起訖時間'
                              : '${_selectedDates[0].toLocal()} - ${_selectedDates[1].toLocal()}'),
                        ),
                      ),
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
                height: 200.0,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4.0),
                ),
                child: _selectedImage == null
                    ? Center(child: Text('沒有選擇圖片'))
                    : Image.file(File(_selectedImage!.path)), // 下方展示圖片
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
