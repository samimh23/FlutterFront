import 'dart:async';
import 'dart:html' as html;
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';

class PlatformHelperImpl {
  // Static variable to hold file reference
  static html.File? _tempFile;

  // Process a blob URL on web
  static Future<MultipartFile> processBlobUrl(String url, String filename) async {
    final completer = Completer<List<int>>();

    // Create an HTML anchor element
    final anchor = html.AnchorElement(href: url);

    // Create an XHR request to get the blob
    final request = html.HttpRequest();
    request.open('GET', anchor.href!, async: true);
    request.responseType = 'blob';

    request.onLoad.listen((event) {
      if (request.status == 200) {
        final blob = request.response as html.Blob;
        final reader = html.FileReader();
        reader.readAsArrayBuffer(blob);

        reader.onLoad.listen((event) {
          completer.complete((reader.result as Uint8List).toList());
        });

        reader.onError.listen((event) {
          completer.completeError('Error reading blob: ${reader.error}');
        });
      } else {
        completer.completeError('Failed to load image: Status ${request.status}');
      }
    });

    request.onError.listen((event) {
      completer.completeError('XHR Error: ${request.statusText}');
    });

    request.send();

    // Wait for the data
    final bytes = await completer.future;

    return MultipartFile.fromBytes(
      bytes,
      filename: filename,
      contentType: MediaType('image', 'jpeg'),
    );
  }

  // Process a File object on web
  static Future<MultipartFile> processFileObject(String key) async {
    final completer = Completer<MultipartFile>();

    try {
      // Use the stored file reference instead of trying to get it from sessionStorage
      final file = _tempFile;
      if (file == null) {
        throw Exception('No file available');
      }

      final reader = html.FileReader();
      reader.readAsArrayBuffer(file);

      reader.onLoad.listen((event) {
        final bytes = (reader.result as Uint8List).toList();
        final mimeType = file.type.split('/');
        final String type = mimeType.length > 1 ? mimeType[1] : 'jpeg';

        completer.complete(MultipartFile.fromBytes(
          bytes,
          filename: file.name,
          contentType: MediaType('image', type),
        ));
      });

      reader.onError.listen((event) {
        completer.completeError('Error reading file: ${reader.error}');
      });
    } catch (e) {
      completer.completeError('Error processing file object: $e');
    }

    return completer.future;
  }

  // Not used on web, but needed for API compatibility
  static Future<MultipartFile> processFilePath(String path) async {
    throw UnsupportedError('File path processing is not supported on web');
  }

  // Web image picker implementation
  static Future<Map<String, dynamic>> pickImageWeb() async {
    final completer = Completer<Map<String, dynamic>>();

    final input = html.FileUploadInputElement()
      ..accept = 'image/*'
      ..click();

    input.onChange.listen((event) async {
      final files = input.files;
      if (files != null && files.isNotEmpty) {
        final file = files.first;

        // Store the file reference in our static variable
        _tempFile = file;

        final reader = html.FileReader();

        reader.onLoadEnd.listen((_) {
          final dataUrl = reader.result as String;

          completer.complete({
            'file': file,
            'path': 'File:${file.name}',
            'type': file.type,
            'dataUrl': dataUrl,
            'name': file.name,
            'size': file.size,
          });
        });

        reader.onError.listen((error) {
          completer.completeError('Error reading file: $error');
        });

        // Read as data URL for preview
        reader.readAsDataUrl(file);
      } else {
        completer.completeError('No file selected');
      }
    });

    return completer.future;
  }

  // Not used on web, but needed for API compatibility
  static Future<Map<String, dynamic>> pickImageMobile() async {
    throw UnsupportedError('Mobile image picking is not supported on web');
  }

  // NEW: Process image for web
  static Future<String> processImageForWeb(
      dynamic file, {double quality = 0.7, int maxWidth = 800, int maxHeight = 800}) async {
    final html.File htmlFile = file as html.File;
    print('Processing image file: ${htmlFile.name} (${htmlFile.size ~/ 1024} KB)');

    // Create a Blob URL for the file
    final objectUrl = html.Url.createObjectUrl(htmlFile);

    try {
      // Load the image to get its dimensions
      final img = html.ImageElement(src: objectUrl);
      await img.onLoad.first;

      // Calculate new dimensions while maintaining aspect ratio
      int targetWidth = img.width ?? 800;
      int targetHeight = img.height ?? 800;

      if (targetWidth > maxWidth || targetHeight > maxHeight) {
        if (targetWidth > targetHeight) {
          targetHeight = (maxWidth * targetHeight / targetWidth).round();
          targetWidth = maxWidth;
        } else {
          targetWidth = (maxHeight * targetWidth / targetHeight).round();
          targetHeight = maxHeight;
        }
      }

      // Create canvas and draw resized image
      final canvas = html.CanvasElement(width: targetWidth, height: targetHeight);
      final ctx = canvas.context2D;
      ctx.drawImageScaled(img, 0, 0, targetWidth, targetHeight);

      // Convert to compressed JPEG data URL
      final mimeType = 'image/jpeg';
      final dataUrl = canvas.toDataUrl(mimeType, quality);

      // Calculate size reduction
      final base64String = dataUrl.split(',')[1];
      final compressedSize = base64String.length * 0.75 ~/ 1024;
      print('Image processed: ${targetWidth}x${targetHeight}, ~$compressedSize KB');

      return dataUrl;
    } finally {
      // Clean up
      html.Url.revokeObjectUrl(objectUrl);
    }
  }

  // NEW: Process web file to data URL
  static Future<String> processWebFileToDataUrl(dynamic file) async {
    final html.File htmlFile = file as html.File;
    final completer = Completer<String>();

    final reader = html.FileReader();
    reader.onLoad.listen((_) {
      final dataUrl = reader.result as String;
      completer.complete(dataUrl);
    });

    reader.onError.listen((error) {
      completer.completeError('Error reading file: $error');
    });

    reader.readAsDataUrl(htmlFile);

    return completer.future;
  }

  // Not used on web, but needed for API compatibility
  static Future<String> processMobileFileToDataUrl(String path) async {
    throw UnsupportedError('Mobile file processing is not supported on web');
  }
}