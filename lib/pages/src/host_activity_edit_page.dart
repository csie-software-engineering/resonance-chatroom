import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/models.dart';
import '../../providers/providers.dart';
import '../../utils/utils.dart';
import '../../widgets/widgets.dart';
import '../routes.dart';

class HostActivityEditPageArguments {
  final String activityId;

  HostActivityEditPageArguments({required this.activityId});
}

class HostActivityEditPage extends StatefulWidget {
  const HostActivityEditPage({Key? key}) : super(key: key);

  static const routeName = '/host_activity_edit_page';

  @override
  State<HostActivityEditPage> createState() => _HostActivityEditPageState();
}

class _HostActivityEditPageState extends State<HostActivityEditPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _infoController = TextEditingController();
  final List<DateTime?> _selectedDates = [null, null];
  String? _selectedImage;
  late final ActivityProvider activityProvider =
      context.read<ActivityProvider>();
  late final args = ModalRoute.of(context)!.settings.arguments
      as HostActivityEditPageArguments;
  late final Activity _originActivity;
  void _initActivityEditContent() {
    debugPrint("初始活動編輯頁面");
    activityProvider.getActivity(args.activityId).then((value) {
      _originActivity = value;
      _nameController.text = _originActivity.activityName;
      _infoController.text = _originActivity.activityInfo;
      //_selectedDates[0] = _originActivity.startDate;
      //_selectedDates[1] = _originActivity.endDate;
      _selectedImage = _originActivity.activityPhoto;
      setState(() {});
    });
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 350), () {
      _initActivityEditContent();
    });
  }

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
      appBar: myAppBar(
        context,
        title: const Text('活動設定頁面'),
        leading: const BackButton(),
      ),
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
        onPressed: () {
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

          debugPrint("活動送出");
          final activityData = Activity(
            activityName: _nameController.text,
            activityInfo: _infoController.text,
            startDate: _selectedDates[0]!.toEpochString(),
            endDate: _selectedDates[1]!.toEpochString(),
            activityPhoto: _selectedImage!,
          );
          context.read<ActivityProvider>().setNewActivity(activityData).then(
                (activity) => Navigator.of(context).pushNamed(
                  HostActivityTagPage.routeName,
                  arguments: HostActivityTagPageArguments(
                    activityId: activity.uid,
                  ),
                ),
              );
        },
        label: const Row(children: [Icon(Icons.send), Text("新增活動")]),
      ),
      floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
    );
  }
}
