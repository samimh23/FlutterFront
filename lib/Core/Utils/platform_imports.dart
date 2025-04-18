import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'dart:typed_data';
import 'dart:convert';
import 'dart:async';

// Import conditionally based on platform
import 'web_platform_helper.dart' if (dart.library.io) 'mobile_platform_helper.dart' as platform;

// This class delegates to the appropriate platform-specific implementation
class PlatformHelper {
  // Process a blob URL on web or handle the appropriate equivalent on other platforms
  static Future<MultipartFile> processBlobUrl(String url, String filename) async {
    return platform.PlatformHelperImpl.processBlobUrl(url, filename);
  }

  // Process a File object on web or handle the appropriate equivalent on other platforms
  static Future<MultipartFile> processFileObject(String key) async {
    return platform.PlatformHelperImpl.processFileObject(key);
  }

  // Process a file path on mobile or handle the appropriate equivalent on web
  static Future<MultipartFile> processFilePath(String path) async {
    return platform.PlatformHelperImpl.processFilePath(path);
  }

  // Pick an image - works on both web and mobile
  static Future<Map<String, dynamic>> pickImage() async {
    if (kIsWeb) {
      return platform.PlatformHelperImpl.pickImageWeb();
    } else {
      return platform.PlatformHelperImpl.pickImageMobile();
    }
  }

  // NEW: Process image for web
  static Future<String> processImageForWeb(
      dynamic file, {double quality = 0.7, int maxWidth = 800, int maxHeight = 800}) async {
    return platform.PlatformHelperImpl.processImageForWeb(
        file, quality: quality, maxWidth: maxWidth, maxHeight: maxHeight);
  }

  // NEW: Convert web file to data URL
  static Future<String> processWebFileToDataUrl(dynamic file) async {
    return platform.PlatformHelperImpl.processWebFileToDataUrl(file);
  }

  // NEW: Convert mobile file to data URL
  static Future<String> processMobileFileToDataUrl(String path) async {
    return platform.PlatformHelperImpl.processMobileFileToDataUrl(path);
  }
}