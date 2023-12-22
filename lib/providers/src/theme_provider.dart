import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferenceProvider extends ChangeNotifier {
  final Future<SharedPreferences> pref;

  static final SharedPreferenceProvider _instance = SharedPreferenceProvider._internal(
    SharedPreferences.getInstance(),
  );

  SharedPreferenceProvider._internal(this.pref);
  factory SharedPreferenceProvider() => _instance;

  Future<void> setIsHost(bool isHost) async {
    final instance = await pref;
    await instance.setBool('isHost', isHost);
    notifyListeners();
  }
}
