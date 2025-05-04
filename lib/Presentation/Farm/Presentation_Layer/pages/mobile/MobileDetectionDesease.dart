// features/DiseaseDetection/Presentation_Layer/pages/disease_detection_mobile_screen.dart
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class DiseaseDetectionMobileScreen extends StatefulWidget {
  const DiseaseDetectionMobileScreen({Key? key}) : super(key: key);

  @override
  State<DiseaseDetectionMobileScreen> createState() => _DiseaseDetectionMobileScreenState();
}

class _DiseaseDetectionMobileScreenState extends State<DiseaseDetectionMobileScreen> {
  final ImagePicker _picker = ImagePicker();
  Uint8List? _imageBytes;
  XFile? _pickedFile;
  bool _isAnalyzing = false;
  DetectionResult? _result;
  String? _errorMessage;

  // Disease information map - could be expanded with more details and treatments
  final Map<String, String> _diseaseInfo = {
    'Tomato_healthy': 'Your tomato plant is healthy! Continue with regular care and maintenance.',
    'Tomato_Bacterial_spot': 'Bacterial spot causes small, dark lesions on leaves, stems, and fruits. Remove infected plants and avoid overhead watering.',
    'Tomato_Early_blight': 'Early blight causes dark spots with concentric rings. Remove infected leaves and apply fungicide if severe.',
    'Tomato_Late_blight': 'Late blight causes large dark blotches and white fungal growth. This is highly contagious - remove infected plants immediately.',
    'Tomato_Leaf_Mold': 'Leaf mold causes yellow spots on leaf surfaces and olive-green mold underneath. Improve air circulation and reduce humidity.',
    'Tomato_Septoria_leaf_spot': 'Septoria leaf spot causes many small circular spots with dark borders. Remove infected leaves and apply fungicide.',
    'Tomato_Spider_mites_Two_spotted_spider_mite': 'Spider mites cause stippling on leaves. Treat with insecticidal soap or neem oil.',
    'Tomato__Target_Spot': 'Target spot causes circular lesions with concentric rings. Remove infected leaves and apply fungicide.',
    'Tomato__Tomato_YellowLeaf__Curl_Virus': 'Yellow Leaf Curl Virus causes leaf curling and yellowing. Remove infected plants and control whitefly vectors.',
    'Tomato__Tomato_mosaic_virus': 'Mosaic virus causes mottled green/yellow leaves. No cure exists - remove and destroy infected plants.',
    'Potato___healthy': 'Your potato plant is healthy! Continue with regular care and maintenance.',
    'Potato___Early_blight': 'Early blight in potatoes causes dark spots with concentric rings. Remove infected leaves and apply fungicide if severe.',
    'Potato___Late_blight': 'Late blight in potatoes is a serious disease. Remove infected plants immediately and apply fungicide to protect others.',
    'Pepper__bell___healthy': 'Your bell pepper plant is healthy! Continue with regular care and maintenance.',
    'Pepper__bell___Bacterial_spot': 'Bacterial spot in peppers causes water-soaked spots on leaves and fruits. Remove infected plants and avoid overhead watering.'
  };

  void _showImageSourceModal() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Select Image Source',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _imageSourceOption(
                  icon: Icons.camera_alt,
                  label: 'Camera',
                  onTap: () {
                    Navigator.pop(context);
                    _getImage(ImageSource.camera);
                  },
                ),
                _imageSourceOption(
                  icon: Icons.photo_library,
                  label: 'Gallery',
                  onTap: () {
                    Navigator.pop(context);
                    _getImage(ImageSource.gallery);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _imageSourceOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 30,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _getImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 80,
      );

      if (image != null) {
        // Save the picked file reference
        _pickedFile = image;

        // Read image bytes
        final bytes = await image.readAsBytes();

        setState(() {
          _imageBytes = bytes;
          _result = null;
          _errorMessage = null;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error selecting image: $e';
      });
    }
  }

  Future<void> _analyzeImage() async {
    if (_pickedFile == null || _imageBytes == null) return;

    setState(() {
      _isAnalyzing = true;
      _result = null;
      _errorMessage = null;
    });

    try {
      // Create multipart request
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('http://localhost:8000/predict'),
      );

      // Add file to request using bytes
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          _imageBytes!,
          filename: 'image.jpg',
          contentType: MediaType('image', 'jpeg'),
        ),
      );

      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['success'] == true) {
          setState(() {
            _result = DetectionResult(
              className: data['prediction'],
              confidenceScore: data['confidence'].toDouble(),
            );
          });
        } else {
          setState(() {
            _errorMessage = data['error'] ?? 'Unknown error occurred';
          });
        }
      } else {
        setState(() {
          _errorMessage = 'Server error: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Connection error: $e';
      });
    } finally {
      setState(() {
        _isAnalyzing = false;
      });
    }
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence < 50) return Colors.red;
    if (confidence < 75) return Colors.orange;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plant Health Assistant'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Image selection area
                      GestureDetector(
                        onTap: _showImageSourceModal,
                        child: Container(
                          height: 200,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surfaceVariant,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
                            ),
                          ),
                          child: _imageBytes == null
                              ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add_photo_alternate,
                                  size: 48,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Tap to add a plant photo',
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          )
                              : ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.memory(
                              _imageBytes!,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Error message
                      if (_errorMessage != null)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red[300]!),
                          ),
                          child: Text(
                            _errorMessage!,
                            style: TextStyle(color: Colors.red[800]),
                          ),
                        ),

                      // Results card
                      if (_result != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 3,
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        backgroundColor: _result!.confidenceScore >= 75
                                            ? Colors.green
                                            : (_result!.confidenceScore >= 50 ? Colors.orange : Colors.red),
                                        child: Icon(
                                          _result!.confidenceScore >= 75
                                              ? Icons.check
                                              : Icons.info_outline,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              _formatClassName(_result!.className),
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Confidence: ${_result!.confidenceScore.toStringAsFixed(1)}%',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Theme.of(context).colorScheme.secondary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),

                                  // Confidence bar
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: LinearProgressIndicator(
                                      value: _result!.confidenceScore / 100,
                                      minHeight: 8,
                                      backgroundColor: Colors.grey[200],
                                      color: _getConfidenceColor(_result!.confidenceScore),
                                    ),
                                  ),

                                  const SizedBox(height: 16),

                                  // Disease information
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.green[50],
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: Colors.green[100]!),
                                    ),
                                    child: Text(
                                      _diseaseInfo[_result!.className] ??
                                          'No specific information available for this condition.',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        height: 1.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),

            // Bottom action button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _imageBytes == null
                      ? _showImageSourceModal
                      : (_isAnalyzing ? null : _analyzeImage),
                  style: ElevatedButton.styleFrom(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isAnalyzing
                      ? const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Analyzing...',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  )
                      : Text(
                    _imageBytes == null ? 'Select Image' : 'Analyze Plant',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatClassName(String className) {
    // Convert snake_case to readable text
    // Example: "Tomato_Early_blight" -> "Tomato Early Blight"
    return className
        .replaceAll('_', ' ')
        .replaceAll('  ', ' ')
        .split(' ')
        .map((word) => word.isNotEmpty
        ? word[0].toUpperCase() + word.substring(1)
        : '')
        .join(' ');
  }
}

class DetectionResult {
  final String className;
  final double confidenceScore;

  DetectionResult({
    required this.className,
    required this.confidenceScore,
  });
}