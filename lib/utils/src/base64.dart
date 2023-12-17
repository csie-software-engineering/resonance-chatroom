import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

Future<String?> imagePathToBase64(String imagePath) async {
  var imageFile = File(imagePath);
  return imageFileToBase64(imageFile);
}

Future<String?> imageFileToBase64(File imageFile) async {
  if (!imageFile.existsSync()) return null;
  var bytes = await imageFile.readAsBytes();
  return base64Encode(bytes);
}

String imageToBase64(Uint8List image) {
  return base64Encode(image);
}

Uint8List base64ToImage(String base64String) {
  return base64Decode(base64String);
}