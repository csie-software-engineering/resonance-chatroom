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

  List<Tag> tags = []; // 活動標籤的List
  Future<void> _pickImage() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    setState(() {
      _selectedImage = File(image!.path);
    });
  }

  Future<void> _pickStartDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2024),
    );
    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (time != null) {
        final start = DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
        );
        setState(() {
          _selectedDates[0] = start;
        });
      }
    }
  }

  Future<void> _pickEndDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2024),
    );
    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (time != null) {
        final end = DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
        );
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
                    MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: height * 0.05,
                  ),
                  Expanded(
                    flex: 2,
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
                      onPressed: _pickStartDate,
                      child: Text(_selectedDates[0] == null
                          ? '選擇日期和時間'
                          : '${_selectedDates[0]}'),
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
                      onPressed: _pickEndDate,
                      child: Text(_selectedDates[1] == null
                          ? '選擇日期和時間'
                          : '${_selectedDates[1]}'),
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
              Row(
                children: [
                  Text('活動圖片'),
                  SizedBox(width: 16.0),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _pickImage,
                      child: Text('選擇圖片'),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.0),
              Container(
                height: null,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: _selectedImage == null
                    ? Center(child: Text('沒有選擇圖片'))
                    : SingleChildScrollView(
                        child: Column(
                          children: [
                            Image.file(_selectedImage!),
                          ],
                        ),
                      ),
              ),

              SizedBox(height: 16.0),
              Row(
                children: [
                  /*ElevatedButton(
                    onPressed: () async {
                      final data = await setActivityProvider
                          .getActivity("8a815b73-8fde-4564-8c11-e3d738f547d8");
                      setState(() {
                        _checkselectedImage = base64Decode(data!.activityPhoto);
                      });
                      // 跳至預覽頁面的邏輯
                      // 傳遞createEvent()方法的回傳值給預覽頁面
                      Navigator.of(context)
                          .pushNamed(HostActivityTagPage.routeName);
                    },
                    child: Text('預覽'),
                  ),*/
                  ElevatedButton(
                    onPressed: () async {
                      print("活動送出");
                      Activity activitydata = Activity(
                        activityPhoto:
                            base64Encode(_selectedImage!.readAsBytesSync()),
                        activityInfo: _infoController.text,
                        activityName: _nameController.text,
                        startDate: _selectedDates[0].toEpochString(),
                        endDate: _selectedDates[1].toEpochString(),
                      );
                      Activity activity = await setActivityProvider
                          .setNewActivity(activitydata);
                      Navigator.of(context).pushNamed(
                          HostActivityTagPage.routeName,
                          arguments: HostActivityTagPageArguments(
                              activityId: activity.uid));
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
