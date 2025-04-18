import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;

class ApiConstants {
  static String get baseUrl {
    if (!kIsWeb && kDebugMode) {
      try {

        const bool runningOnEmulator = false;

        if (runningOnEmulator) {
        }
      } catch (e) {
      }
    }
    return 'http://192.168.57.4:3000';
  }

  static String getFullImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      return '';
    }

    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return imagePath;
    }

    final String normalizedPath = imagePath.replaceAll('\\', '/');

    if (normalizedPath.startsWith('/uploads/')) {
      return '$baseUrl$normalizedPath';
    } else if (normalizedPath.startsWith('uploads/')) {
      return '$baseUrl/$normalizedPath';
    }

    return '$baseUrl/uploads/$normalizedPath';
  }
  static String getImageUrlWithCacheBusting(String? imagePath) {
    final String url = getFullImageUrl(imagePath);
    if (url.isEmpty) return url;
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    if (url.contains('?')) {
      return '$url&_cb=$timestamp';
    } else {
      return '$url?_cb=$timestamp';
    }
  }
}