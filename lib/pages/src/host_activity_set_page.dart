import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

import '../../models/models.dart';
import '../../providers/providers.dart';
import '../../utils/utils.dart';
import '../../widgets/widgets.dart';
import '../routes.dart';

class HostActivitySetPage extends StatefulWidget {
  const HostActivitySetPage({Key? key}) : super(key: key);

  static const routeName = '/host_activity_set_page';

  @override
  State<HostActivitySetPage> createState() => _HostActivitySetPageState();
}

class _HostActivitySetPageState extends State<HostActivitySetPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _infoController = TextEditingController();
  final List<DateTime?> _selectedDates = [null, null];
  String? _selectedImage;

  void _pickStartDate() {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2048),
    ).then((date) {
      if (date != null) {
        showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
        ).then((time) {
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
        });
      }
    });
  }

  void _pickEndDate(DateTime? start) {
    if (start == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('請先選擇開始時間'),
        ),
      );
      return;
    }

    showDatePicker(
      context: context,
      initialDate: start,
      firstDate: start,
      lastDate: DateTime(2048),
    ).then((date) {
      if (date != null) {
        showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
        ).then((time) {
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
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: CustomAppBar(
        leading: const BackButton(),
        title: '設定活動',
        tail: null,
      ),
      // appBar: myAppBar(
      //   context,
      //   title: const Text('活動設定頁面'),
      //   leading: const BackButton(),
      // ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.25,
                    child: const Text(
                      '活動名稱',
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    child: TextFormField(
                      controller: _nameController,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.25,
                    child: const Text(
                      '活動開始時間',
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _pickStartDate,
                      child: Text(_selectedDates[0] == null
                          ? '選擇日期和時間'
                          : _selectedDates[0].toString()),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.25,
                    child: const Text(
                      '活動結束時間',
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _pickEndDate(_selectedDates[0]),
                      child: Text(_selectedDates[1] == null
                          ? '選擇日期和時間'
                          : _selectedDates[1].toString()),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.25,
                    child: const Text(
                      '活動資訊',
                      textAlign: TextAlign.center,
                    ),
                  ),
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
              const SizedBox(height: 16.0),
              Row(
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.25,
                    child: const Text(
                      '活動圖片',
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => pickImageToBase64().then((value) {
                        setState(() {
                          _selectedImage = value;
                        });
                      }).catchError((e){
                        debugPrint("pickImageToBase64Error: $e");
                        ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(content: Text('圖片太大無法使用')));
                      }),
                      child: const Text('選擇圖片'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              Container(
                height: null,
                decoration: BoxDecoration(
                  color: Colors.grey,
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: _selectedImage == null
                    ? SizedBox(
                        width: MediaQuery.of(context).size.width * 0.9,
                        height: MediaQuery.of(context).size.width * 0.2,
                        child: const Center(
                          child: Text(
                            '尚未選擇圖片',
                            style: TextStyle(
                              fontSize: 20,
                            ),
                          ),
                        ),
                      )
                    : Image.memory(base64ToImage(_selectedImage!)),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          if (_nameController.text.isEmpty) {
            ScaffoldMessenger.of(context)
                .showSnackBar(const SnackBar(content: Text('請填寫活動名稱')));
            return;
          }

          if (_infoController.text.isEmpty) {
            ScaffoldMessenger.of(context)
                .showSnackBar(const SnackBar(content: Text('請填寫活動資訊')));
            return;
          }

          if (_selectedDates[0] == null || _selectedDates[1] == null) {
            ScaffoldMessenger.of(context)
                .showSnackBar(const SnackBar(content: Text('請填寫活動時間')));
            return;
          }

          if (_selectedImage == null) {
            ScaffoldMessenger.of(context)
                .showSnackBar(const SnackBar(content: Text('請選擇活動圖片')));
            return;
          }

          debugPrint("活動送出 base64 length: ${_selectedImage!.length}");
          final activityData = Activity(
            activityName: _nameController.text,
            activityInfo: _infoController.text,
            startDate: _selectedDates[0]!.toEpochString(),
            endDate: _selectedDates[1]!.toEpochString(),
            activityPhoto: _selectedImage!,
          );
          try {
            await context.read<ActivityProvider>().setNewActivity(activityData).then(
                  (activity) =>
                  Navigator.of(context).pushNamed(
                    HostActivityTagPage.routeName,
                    arguments: HostActivityTagPageArguments(
                      activityId: activity.uid,
                    ),
                  ),
            );
          }catch(e){
            Fluttertoast.showToast(msg: e.toString());
          }
        },
        label: const Row(children: [Icon(Icons.send), Text("新增活動")]),
      ),
      floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
    );
  }
}
