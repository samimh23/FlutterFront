import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;

// Import the platform helper
import 'package:hanouty/Core/Utils/platform_imports.dart';

class ImagePickerHelper {
  // Use the platform helper to pick images
  static Future<Map<String, dynamic>> pickImage() async {
    return PlatformHelper.pickImage();
  }
}