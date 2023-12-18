import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';

Future<String?> pickImageToBase64() async {
  final xFile = (await ImagePicker().pickImage(source: ImageSource.gallery));
  if (xFile == null) return null;
  return imagePathToBase64(xFile.path);
}

Future<String?> imagePathToBase64(String imagePath) async {
  var imageFile = File(imagePath);
  return imageFileToBase64(imageFile);
}

Future<String?> imageFileToBase64(File imageFile) async {
  if (!await imageFile.exists()) return null;
  var bytes = await imageFile.readAsBytes();
  return imageToBase64(bytes);
}

String imageToBase64(Uint8List image) {
  return base64Encode(image);
}

Uint8List base64ToImage(String base64String) {
  return base64Decode(base64String);
}
