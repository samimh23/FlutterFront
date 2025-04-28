// Mobile-specific implementations
import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:image_picker/image_picker.dart';
// For mobile image processing
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;

class PlatformHelperImpl {
  // Not used on mobile, but needed for API compatibility
  static Future<MultipartFile> processBlobUrl(String url, String filename) async {
    throw UnsupportedError('Blob URL processing is not supported on mobile');
  }

  // Not used on mobile, but needed for API compatibility
  static Future<MultipartFile> processFileObject(String key) async {
    throw UnsupportedError('File object processing is not supported on mobile');
  }

  // Process a file path on mobile
  static Future<MultipartFile> processFilePath(String filepath) async {
    File file = File(filepath);
    String filename = path.basename(filepath);

    String extension = path.extension(filename).toLowerCase().replaceAll('.', '');
    if (extension.isEmpty) extension = 'jpg';

    return await MultipartFile.fromFile(
      file.path,
      filename: filename,
      contentType: MediaType('image', extension),
    );
  }

  // Not used on mobile, but needed for API compatibility
  static Future<Map<String, dynamic>> pickImageWeb() async {
    throw UnsupportedError('Web image picking is not supported on mobile');
  }

  // Mobile image picker implementation
  static Future<Map<String, dynamic>> pickImageMobile() async {
    try {
      // Use the image_picker package for mobile platforms
      final imagePicker = ImagePicker();
      final pickedFile = await imagePicker.pickImage(
        source: ImageSource.gallery,
        // Optimize image at source
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 70,
      );

      if (pickedFile != null) {
        final file = File(pickedFile.path);
        final fileName = path.basename(pickedFile.path);
        final bytes = await file.readAsBytes();

        // Create a data URL for preview
        final String base64 = base64Encode(bytes);
        final String mimeType = pickedFile.mimeType ?? 'image/jpeg';
        final dataUrl = 'data:$mimeType;base64,$base64';

        return {
          'path': pickedFile.path,
          'dataUrl': dataUrl,
          'name': fileName,
          'size': await file.length(),
          'type': mimeType,
        };
      } else {
        throw Exception('No image selected');
      }
    } catch (e) {
      throw Exception('Failed to pick image: $e');
    }
  }

  // Not used on mobile, but needed for API compatibility
  static Future<String> processImageForWeb(
      dynamic file, {double quality = 0.7, int maxWidth = 800, int maxHeight = 800}) async {
    throw UnsupportedError('Web image processing is not supported on mobile');
  }

  // Not used on mobile, but needed for API compatibility
  static Future<String> processWebFileToDataUrl(dynamic file) async {
    throw UnsupportedError('Web file processing is not supported on mobile');
  }

  // NEW: Process mobile file to data URL - simpler version without compression
  static Future<String> processMobileFileToDataUrl(String filepath) async {
    try {
      final file = File(filepath);
      if (!await file.exists()) {
        throw Exception('File does not exist: $filepath');
      }

      // Read file bytes
      final bytes = await file.readAsBytes();

      // Convert to base64
      final base64 = base64Encode(bytes);

      // Determine mime type from file extension
      final extension = path.extension(filepath).toLowerCase();
      String mimeType;

      if (extension == '.jpg' || extension == '.jpeg') {
        mimeType = 'image/jpeg';
      } else if (extension == '.png') {
        mimeType = 'image/png';
      } else if (extension == '.gif') {
        mimeType = 'image/gif';
      } else if (extension == '.webp') {
        mimeType = 'image/webp';
      } else {
        mimeType = 'image/jpeg'; // Default mime type
      }

      // Return data URL
      return 'data:$mimeType;base64,$base64';
    } catch (e) {
      print('Error processing mobile file to data URL: $e');
      throw Exception('Failed to process image: $e');
    }
  }
}