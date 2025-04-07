import 'dart:html' as html;
import 'dart:async';

class ImagePickerHelper {
  static Future<Map<String, dynamic>> pickImage() async {
    final completer = Completer<Map<String, dynamic>>();

    final input = html.FileUploadInputElement()
      ..accept = 'image/*'
      ..click();

    input.onChange.listen((event) async {
      final files = input.files;
      if (files != null && files.isNotEmpty) {
        final file = files.first;
        final reader = html.FileReader();

        reader.onLoadEnd.listen((_) {
          completer.complete({
            'file': file,
            'path': 'File:${file.name}',
            'type': file.type,
          });
        });

        reader.onError.listen((error) {
          completer.completeError('Error reading file: $error');
        });

        reader.readAsArrayBuffer(file);
      } else {
        completer.completeError('No file selected');
      }
    });

    return completer.future;
  }
}