// lib/features/Disease_Detection/Presentation_Layer/pages/mobile_product_detect_disease.dart

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:typed_data';
import 'package:provider/provider.dart';
import '../../../../DiseaseDetection/Presentation_Layer/viewmodels/productVM.dart';

class MobileProductDetectDisease extends StatefulWidget {
  const MobileProductDetectDisease({Key? key}) : super(key: key);

  @override
  State<MobileProductDetectDisease> createState() => _MobileProductDetectDiseaseState();
}

class _MobileProductDetectDiseaseState extends State<MobileProductDetectDisease> with SingleTickerProviderStateMixin {
  File? _imageFile;
  Uint8List? _webImage;
  XFile? _pickedFile;
  late AnimationController _animationController;
  late Animation<double> _animation;
  late Animation<double> _slideAnimation;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    );
    _slideAnimation = Tween<double>(begin: 100, end: 0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _getImage(ImageSource source) async {
    final viewModel = Provider.of<DiseaseDetectionViewModel>(context, listen: false);
    viewModel.resetState();

    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
      source: source,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 90,
    );

    if (pickedFile != null) {
      _pickedFile = pickedFile;

      if (kIsWeb) {
        _webImage = await pickedFile.readAsBytes();
        _imageFile = null;
      } else {
        _imageFile = File(pickedFile.path);
        _webImage = null;
      }

      setState(() {});

      // Automatically move to analysis page after selecting an image
      _pageController.animateToPage(
        1,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _analyzeImage() async {
    if (_pickedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an image first'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final viewModel = Provider.of<DiseaseDetectionViewModel>(context, listen: false);

    // For mobile platforms
    if (!kIsWeb && _imageFile != null) {
      await viewModel.analyzeImage(_imageFile!);
    } else {
      // For web (or if there's an issue with the file)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error processing image'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Move to results page after analysis is complete
    _pageController.animateToPage(
      2,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  // Helper method to render the appropriate image widget
  Widget _buildImageWidget() {
    if (_pickedFile == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
                Icons.add_photo_alternate_outlined,
                size: 60,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey.shade500
                    : Colors.grey.shade400
            ),
            const SizedBox(height: 12),
            Text(
              'No image selected',
              style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey.shade400
                      : Colors.grey.shade600,
                  fontSize: 16
              ),
            ),
          ],
        ),
      );
    } else if (kIsWeb && _webImage != null) {
      return Image.memory(
        _webImage!,
        fit: BoxFit.cover,
        width: double.infinity,
      );
    } else if (!kIsWeb && _imageFile != null) {
      return Image.file(
        _imageFile!,
        fit: BoxFit.cover,
        width: double.infinity,
      );
    } else {
      return const Center(child: Text('Error loading image'));
    }
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  Widget _buildCaptureScreen() {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final cardColor = isDarkMode ? Colors.grey.shade800 : Colors.grey.shade50;
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final secondaryTextColor = isDarkMode ? Colors.grey.shade300 : Colors.grey.shade700;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ScaleTransition(
            scale: _animation,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: isDarkMode ? Colors.black26 : Colors.grey.shade200,
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.eco_rounded,
                      size: 56,
                      color: theme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Crop Health Scanner',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Take a photo of your fruit or vegetable to instantly check for diseases',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: secondaryTextColor,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const Spacer(),

          AnimatedBuilder(
            animation: _slideAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, _slideAnimation.value),
                child: child,
              );
            },
            child: Column(
              children: [
                Container(
                  height: 180,
                  width: 180,
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      Icons.camera_alt_rounded,
                      size: 80,
                      color: theme.primaryColor.withOpacity(0.5),
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                Text(
                  'Choose an option to get started',
                  style: TextStyle(
                    fontSize: 16,
                    color: secondaryTextColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: _buildActionButton(
                        icon: Icons.camera_alt_rounded,
                        label: 'Camera',
                        onTap: () => _getImage(ImageSource.camera),
                        color: theme.primaryColor,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildActionButton(
                        icon: Icons.photo_library_rounded,
                        label: 'Gallery',
                        onTap: () => _getImage(ImageSource.gallery),
                        color: theme.colorScheme.secondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color color,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.4),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isDarkMode ? Colors.white : Colors.white,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalysisScreen() {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final viewModel = Provider.of<DiseaseDetectionViewModel>(context);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Preview & Analysis',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
          ),

          const SizedBox(height: 16),

          Text(
            'Confirm your image is clear and well-lit',
            style: TextStyle(
              fontSize: 16,
              color: isDarkMode ? Colors.grey.shade300 : Colors.grey.shade700,
            ),
          ),

          const SizedBox(height: 24),

          Expanded(
            child: Hero(
              tag: 'selectedImage',
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: isDarkMode ? Colors.black38 : Colors.grey.shade300,
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: _buildImageWidget(),
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Analysis buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    _pageController.animateToPage(
                      0,
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                    );
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('New Image'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
                    foregroundColor: isDarkMode ? Colors.white : Colors.black87,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 16),

              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: viewModel.isLoading ? null : _analyzeImage,
                  icon: viewModel.isLoading
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                      : const Icon(Icons.search),
                  label: Text(
                    viewModel.isLoading ? 'Analyzing...' : 'Analyze Crop',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: theme.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 5,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResultsScreen() {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final viewModel = Provider.of<DiseaseDetectionViewModel>(context);
    final isAccepted = viewModel.isAccepted;

    Color resultColor = theme.primaryColor;
    if (isAccepted != null) {
      resultColor = isAccepted
          ? (isDarkMode ? Colors.green.shade400 : Colors.green)
          : (isDarkMode ? Colors.red.shade400 : Colors.red);
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Results header with animation
          ScaleTransition(
            scale: _animation,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: resultColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: resultColor.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isAccepted == null
                          ? Icons.info_outline
                          : isAccepted
                          ? Icons.check_circle_outline
                          : Icons.warning_amber_rounded,
                      size: 40,
                      color: resultColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isAccepted == null
                        ? 'Analysis Result'
                        : isAccepted
                        ? 'Healthy Crop'
                        : 'Disease Detected',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: resultColor,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // The image thumbnail
                  Row(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: isDarkMode ? Colors.black26 : Colors.grey.shade300,
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: _buildImageWidget(),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              viewModel.prediction,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isDarkMode ? Colors.white : Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Confidence: ${viewModel.confidence.toStringAsFixed(1)}%',
                              style: TextStyle(
                                fontSize: 14,
                                color: isDarkMode ? Colors.grey.shade300 : Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Confidence bar
                  Text(
                    'Analysis Confidence',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Container(
                    height: 24,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
                    ),
                    child: Stack(
                      children: [
                        // Animated confidence bar
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 1500),
                          curve: Curves.easeOutCubic,
                          width: MediaQuery.of(context).size.width * (viewModel.confidence / 100),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: resultColor,
                            gradient: LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [
                                resultColor.withOpacity(0.7),
                                resultColor,
                              ],
                            ),
                          ),
                        ),
                        // Percentage label
                        Center(
                          child: Text(
                            '${viewModel.confidence.toStringAsFixed(1)}%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Detailed results
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isAccepted == null
                          ? (isDarkMode ? Colors.grey.shade800 : Colors.grey.shade100)
                          : isAccepted
                          ? (isDarkMode ? Colors.green.shade900.withOpacity(0.3) : Colors.green.shade50)
                          : (isDarkMode ? Colors.red.shade900.withOpacity(0.3) : Colors.red.shade50),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isAccepted == null
                            ? (isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300)
                            : isAccepted
                            ? (isDarkMode ? Colors.green.shade700 : Colors.green.shade300)
                            : (isDarkMode ? Colors.red.shade700 : Colors.red.shade300),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              isAccepted == null
                                  ? Icons.help_outline
                                  : isAccepted
                                  ? Icons.check_circle_outline
                                  : Icons.warning_amber_rounded,
                              color: isAccepted == null
                                  ? (isDarkMode ? Colors.grey.shade300 : Colors.grey.shade600)
                                  : isAccepted
                                  ? (isDarkMode ? Colors.green.shade300 : Colors.green.shade600)
                                  : (isDarkMode ? Colors.red.shade300 : Colors.red.shade600),
                              size: 24,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Status Summary',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isDarkMode ? Colors.white : Colors.black87,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        Text(
                          isAccepted == null
                              ? 'Analysis completed. Please check the results.'
                              : isAccepted
                              ? 'This crop appears to be healthy and suitable for cultivation or sale.'
                              : 'Disease detected. This crop may require treatment or may not be suitable for sale.',
                          style: TextStyle(
                            fontSize: 16,
                            color: isDarkMode ? Colors.white : Colors.black87,
                          ),
                        ),

                        if (isAccepted == false) ...[
                          const SizedBox(height: 16),
                          const Divider(),
                          const SizedBox(height: 16),
                          Text(
                            'Recommendations',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isDarkMode ? Colors.white : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.spa_outlined,
                                size: 20,
                                color: isDarkMode ? Colors.orange.shade300 : Colors.orange.shade800,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Consider treatment options appropriate for this disease',
                                  style: TextStyle(
                                    color: isDarkMode ? Colors.orange.shade300 : Colors.orange.shade800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.health_and_safety_outlined,
                                size: 20,
                                color: isDarkMode ? Colors.orange.shade300 : Colors.orange.shade800,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Remove affected crops to prevent spread to healthy plants',
                                  style: TextStyle(
                                    color: isDarkMode ? Colors.orange.shade300 : Colors.orange.shade800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Bottom action buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    _pageController.animateToPage(
                      0,
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                    );
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('New Scan'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
                    foregroundColor: isDarkMode ? Colors.white : Colors.black87,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // This would be connected to a share function
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Share functionality would be implemented here'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  icon: const Icon(Icons.share),
                  label: const Text('Share Results'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: theme.colorScheme.secondary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: isDarkMode ? Colors.black : Colors.grey.shade100,
      appBar: AppBar(
        title: Text(
          _currentPage == 0 ? 'Crop Scanner' :
          _currentPage == 1 ? 'Image Analysis' : 'Analysis Results',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        centerTitle: true,
        actions: [
          if (_currentPage > 0)
            IconButton(
              icon: const Icon(Icons.home),
              onPressed: () {
                _pageController.animateToPage(
                  0,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                );
              },
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (_currentPage > 0) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: _currentPage >= 0
                              ? theme.primaryColor
                              : (isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: _currentPage >= 1
                              ? theme.primaryColor
                              : (isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: _currentPage >= 2
                              ? theme.primaryColor
                              : (isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: _onPageChanged,
                children: [
                  _buildCaptureScreen(),
                  _buildAnalysisScreen(),
                  _buildResultsScreen(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}