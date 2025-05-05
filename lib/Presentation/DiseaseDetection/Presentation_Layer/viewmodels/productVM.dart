// lib/features/Disease_Detection/Presentation_Layer/viewmodels/disease_detection_viewmodel.dart

import 'package:flutter/material.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DiseaseDetectionViewModel extends ChangeNotifier {
  bool _isLoading = false;
  String _prediction = '';
  double _confidence = 0.0;
  bool? _isAccepted;
  String _errorMessage = '';
  
  // Getters
  bool get isLoading => _isLoading;
  String get prediction => _prediction; 
  double get confidence => _confidence;
  bool? get isAccepted => _isAccepted;
  String get errorMessage => _errorMessage;
  
  // TODO: Configure your Flask API endpoint here
  final String _apiUrl = 'http://127.0.0.1:8002/audit';
  
  // Reset state
  void resetState() {
    _prediction = '';
    _confidence = 0.0;
    _isAccepted = null;
    _errorMessage = '';
    notifyListeners();
  }
  
  // Analyze image method
  Future<void> analyzeImage(File imageFile) async {
    if (imageFile == null) {
      _errorMessage = 'No image selected';
      notifyListeners();
      return;
    }
    
    try {
      _isLoading = true;
      _errorMessage = '';
      notifyListeners();
      
      final uri = Uri.parse(_apiUrl);
      var request = http.MultipartRequest('POST', uri);
      
      // Add the image file to the request
      request.files.add(await http.MultipartFile.fromPath(
        'file',
        imageFile.path,
      ));
      
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        
        if (result['success'] == true) {
          String prediction = result['prediction'];
          double confidence = result['confidence'].toDouble();
          
          // Determine if the fruit is healthy or diseased
          bool isAccepted = !prediction.toLowerCase().contains('disease') && 
                           !prediction.toLowerCase().contains('rot') &&
                           !prediction.toLowerCase().contains('scab') &&
                           !prediction.toLowerCase().contains('blight');
          
          _prediction = prediction;
          _confidence = confidence;
          _isAccepted = isAccepted;
        } else {
          _errorMessage = 'Error: ${result['error']}';
        }
      } else {
        _errorMessage = 'Server error: ${response.statusCode}';
      }
    } catch (e) {
      _errorMessage = 'Connection error: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}