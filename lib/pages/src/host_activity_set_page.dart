import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:resonance_chatroom/models/models.dart';
import 'package:resonance_chatroom/providers/providers.dart';
import 'package:resonance_chatroom/utils/src/time.dart';

import '../routes.dart';

// 定義一個類別來儲存活動的所有內容

class HostActivitySetPage extends StatefulWidget {
  const HostActivitySetPage({Key? key}) : super(key: key);

  static const routeName = '/host_activity_set_page';

  @override
  _HostActivitySetPageState createState() => _HostActivitySetPageState();
}

class _HostActivitySetPageState extends State<HostActivitySetPage> {
  late final ActivityProvider setActivityProvider =
      context.read<ActivityProvider>();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _infoController = TextEditingController();
  final List<DateTime> _selectedDates = [DateTime.now(), DateTime.now()];
  File? _selectedImage;
  Uint8List? _checkselectedImage;

  List<Tag> tags = []; // 活動標籤的List
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

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Text('活動設定頁面'),
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
                      controller: _nameController,
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
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: _checkselectedImage == null
                    ? Center(child: Text('沒有選擇圖片'))
                    : SingleChildScrollView(
                        // 將Column放在SingleChildScrollView中
                        child: Column(
                          children: [
                            // 使用Image.file來顯示圖片
                            Image.memory(_checkselectedImage!),
                          ],
                        ),
                      ),
              ),


              SizedBox(height: 16.0),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      final data = await setActivityProvider.getActivity(
                          "8a815b73-8fde-4564-8c11-e3d738f547d8");
                      setState(() {
                        _checkselectedImage = base64Decode(data!.activityPhoto);
                      });
                      // 跳至預覽頁面的邏輯
                      // 傳遞createEvent()方法的回傳值給預覽頁面
                      Navigator.of(context)
                    .pushNamed(HostActivityTagPage.routeName);
                    },
                    child: Text('預覽'),
                  ),
                  SizedBox(width: 16.0),
                  ElevatedButton(
                    onPressed: () async {
                      print("測試");
                      Activity activitydata = Activity(
                          activityPhoto:
                              base64Encode(_selectedImage!.readAsBytesSync()),
                          activityInfo: _infoController.text,
                          activityName: _nameController.text,
                          startDate: _selectedDates[0].toEpochString(),
                          endDate: _selectedDates[1].toEpochString(),
                          );
                      Activity activity =  await setActivityProvider.setNewActivity(
                          activitydata);
                      // 跳至送出頁面的邏輯
                      // 傳遞createEvent()方法的回傳值給送出頁面
                        List<Tag> tags= await setActivityProvider.getAllTags("20231221-1345-8f43-9113-b1dd764c427f");
                      Navigator.of(context).pushNamed(HostActivityTagPage.routeName,
          arguments: HostActivityTagPage(activityId: activity.uid, tag: tags));
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
