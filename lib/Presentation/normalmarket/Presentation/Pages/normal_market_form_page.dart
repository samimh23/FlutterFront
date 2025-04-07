import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hanouty/Core/network/apiconastant.dart';
import 'package:hanouty/Presentation/normalmarket/Data/models/normalmarket_model.dart';
import 'package:hanouty/Presentation/normalmarket/Domain/entities/normalmarket_entity.dart';
import 'package:hanouty/Presentation/normalmarket/Presentation/Provider/normal_market_provider.dart';
import 'package:provider/provider.dart';
import 'dart:io';

class NormalMarketFormPage extends StatefulWidget {
  final NormalMarket? normalMarket;

  const NormalMarketFormPage({
    Key? key,
    this.normalMarket,
  }) : super(key: key);

  @override
  State<NormalMarketFormPage> createState() => _NormalMarketFormPageState();
}

class _NormalMarketFormPageState extends State<NormalMarketFormPage> {
  final _formKey = GlobalKey<FormState>();
  late bool _isEditing;

  final _marketNameController = TextEditingController();
  final _marketLocationController = TextEditingController();
  final _marketPhoneController = TextEditingController();
  final _marketEmailController = TextEditingController();

  String? _fractionalNFTAddress;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.normalMarket != null;

    if (_isEditing) {
      _initFormWithMarketData();
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<NormalMarketProvider>().clearError();
      }
    });
  }

  void _initFormWithMarketData() {
    final market = widget.normalMarket!;

    _marketNameController.text = market.marketName;
    _marketLocationController.text = market.marketLocation;
    _marketPhoneController.text = market.marketPhone ?? '';
    _marketEmailController.text = market.marketEmail ?? '';
    _fractionalNFTAddress = market.fractionalNFTAddress;
  }

  @override
  void dispose() {
    _marketNameController.dispose();
    _marketLocationController.dispose();
    _marketPhoneController.dispose();
    _marketEmailController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final provider = context.read<NormalMarketProvider>();

      // Check if we have an image selected when creating a new market
      if (!_isEditing && !provider.hasSelectedImage) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.redAccent,
            content: Text('Please select an image for the market',
                style: TextStyle(color: Colors.white)),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      try {
        // Create a map with only the required fields
        final marketData = {
          'marketName': _marketNameController.text,
          'marketLocation': _marketLocationController.text,
        };

        // Add optional fields only if they have values
        if (_marketPhoneController.text.isNotEmpty) {
          marketData['marketPhone'] = _marketPhoneController.text;
        }

        if (_marketEmailController.text.isNotEmpty) {
          marketData['marketEmail'] = _marketEmailController.text;
        }

        bool success;
        if (_isEditing) {
          success = await provider.updateExistingMarketFromMap(
            widget.normalMarket!.id,
            marketData,
          );
        } else {
          success = await provider.addMarketFromMap(marketData);
        }

        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: const Color(0xFF4CAF50),
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white, size: 20),
                  const SizedBox(width: 10),
                  Text(
                    _isEditing
                        ? 'Market updated successfully'
                        : 'Market created successfully',
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
              behavior: SnackBarBehavior.floating,
            ),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.redAccent,
              content: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.white, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Error: ${e.toString()}',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NormalMarketProvider>();
    final screenWidth = MediaQuery.of(context).size.width;
    final formWidth = screenWidth > 800
        ? 700.0
        : screenWidth > 600
        ? screenWidth * 0.85
        : screenWidth - 40;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F7F3), // Light cream background
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.arrow_back,
              color: Color(0xFF4CAF50),
              size: 20,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _isEditing ? 'Edit Market' : 'Create Market',
          style: const TextStyle(
            color: Color(0xFF2E7D32),
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: TextButton.icon(
              onPressed: provider.isSubmitting ? null : _submitForm,
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _isEditing ? Icons.update : Icons.check_circle_outline,
                  color: const Color(0xFF4CAF50),
                  size: 20,
                ),
              ),
              label: Text(
                _isEditing ? 'Update' : 'Save',
                style: const TextStyle(
                  color: Color(0xFF4CAF50),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              style: TextButton.styleFrom(
                disabledForegroundColor: Colors.grey.shade400,
              ),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/fruits_pattern_light.png'),
            opacity: 0.05,
            repeat: ImageRepeat.repeat,
          ),
        ),
        child: Form(
          key: _formKey,
          child: provider.isSubmitting
              ? _buildLoadingView()
              : Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: Center(
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: formWidth,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Page Header
                      _buildPageHeader(),

                      const SizedBox(height: 24),

                      // Error message display
                      if (provider.errorMessage.isNotEmpty)
                        _buildErrorMessage(provider),

                      // Image upload section
                      _buildImageSection(provider),

                      const SizedBox(height: 24),

                      // Form Fields
                      _buildFormFields(),

                      const SizedBox(height: 24),

                      // Note about automatically managed fields
                      if (!_isEditing)
                        _buildInfoNote(),

                      const SizedBox(height: 30),

                      // Submit button
                      _buildSubmitButton(provider),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'icons/loading.gif',
            height: 120,
            width: 120,
          ),
          const SizedBox(height: 24),
          const Text(
            'Processing your market...',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: Color(0xFF4CAF50),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageHeader() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _isEditing ? Icons.edit_note : Icons.storefront_outlined,
                  color: const Color(0xFF4CAF50),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isEditing ? 'Edit Market' : 'Create New Market',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _isEditing
                          ? 'Update your market information'
                          : 'Fill in the details for your new market',
                      style: TextStyle(
                        fontSize: 14,
                        color: const Color(0xFF666666),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildErrorMessage(NormalMarketProvider provider) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        border: Border.all(color: Colors.red.shade200),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Icon(Icons.error_outline, color: Colors.red.shade700, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              provider.errorMessage,
              style: TextStyle(color: Colors.red.shade700, fontSize: 14),
            ),
          ),
          IconButton(
            icon: Icon(Icons.close, color: Colors.red.shade700, size: 20),
            onPressed: () => provider.clearError(),
          ),
        ],
      ),
    );
  }

  Widget _buildImageSection(NormalMarketProvider provider) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section heading
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.image,
                  color: Color(0xFF4CAF50),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Market Image',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF333333),
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Upload a clear image of your market',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF777777),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Image preview area
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFEEF7ED),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFD8EBD8)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: _buildImagePreview(provider),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Image upload button
          Center(
            child: ElevatedButton.icon(
              onPressed: () => _pickImage(provider),
              icon: const Icon(Icons.add_photo_alternate, size: 20),
              label: Text(
                _isEditing ? 'Change Image' : 'Upload Image',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePreview(NormalMarketProvider provider) {
    // For editing market with existing image
    if (_isEditing && widget.normalMarket?.marketImage != null && !provider.hasSelectedImage) {
      return _buildExistingImage(widget.normalMarket!.marketImage!);
    }

    // For web platform with selected image
    if (kIsWeb && provider.selectedImageBytes != null) {
      return Stack(
        fit: StackFit.expand,
        children: [
          Image.memory(
            provider.selectedImageBytes!,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return _buildImageErrorView();
            },
          ),
          _buildImageOverlay('New Image Selected', provider.selectedImageName),
        ],
      );
    }

    // For mobile/desktop with selected image
    if (!kIsWeb && provider.selectedImage != null) {
      return Stack(
        fit: StackFit.expand,
        children: [
          Image.file(
            provider.selectedImage!,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return _buildImageErrorView();
            },
          ),
          _buildImageOverlay('New Image Selected'),
        ],
      );
    }

    // No image selected
    return _buildNoImageView();
  }

  Widget _buildExistingImage(String imagePath) {
    return Stack(
      fit: StackFit.expand,
      children: [
        imagePath.isNotEmpty
            ? Image.network(
          ApiConstants.getFullImageUrl(imagePath),
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return _buildImageErrorView();
          },
        )
            : _buildNoImageView(),
        _buildImageOverlay('Current Image'),
      ],
    );
  }

  Widget _buildNoImageView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFD8EBD8), width: 2),
            ),
            child: const Icon(
              Icons.add_photo_alternate_outlined,
              size: 36,
              color: Color(0xFF4CAF50),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Add Market Image',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4CAF50),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Select an image to showcase your market',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF777777),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildImageErrorView() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.broken_image, size: 32, color: Colors.red.shade300),
          ),
          const SizedBox(height: 12),
          const Text(
            'Could not load image',
            style: TextStyle(
              color: Color(0xFF777777),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageOverlay(String text, [String? subtext]) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              Colors.black.withOpacity(0.6),
              Colors.transparent,
            ],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.check_circle,
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            if (subtext != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  "($subtext)",
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormFields() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
      // Section heading
      Row(
      children: [
      Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF2196F3).withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Icon(
        Icons.info_outline,
        color: Color(0xFF2196F3),
        size: 20,
      ),
    ),
    const SizedBox(width: 12),
    const Text(
    'Market Information',
    style: TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: Color(0xFF333333),
    ),
    ),
      ],
      ),

            const SizedBox(height: 24),

            // Market name field
            _buildFormField(
              controller: _marketNameController,
              label: 'Market Name',
              hintText: 'Enter market name',
              prefixIcon: Icons.store_outlined,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a market name';
                }
                return null;
              },
              required: true,
            ),

            const SizedBox(height: 16),

            // Market location field
            _buildFormField(
              controller: _marketLocationController,
              label: 'Location',
              hintText: 'Enter market location',
              prefixIcon: Icons.location_on_outlined,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a market location';
                }
                return null;
              },
              required: true,
            ),

            const SizedBox(height: 16),

            // Market phone field (optional)
            _buildFormField(
              controller: _marketPhoneController,
              label: 'Contact Phone (Optional)',
              hintText: 'Enter contact phone',
              prefixIcon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
            ),

            const SizedBox(height: 16),

            // Market email field (optional)
            _buildFormField(
              controller: _marketEmailController,
              label: 'Contact Email (Optional)',
              hintText: 'Enter contact email',
              prefixIcon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  // Simple email validation
                  final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                  if (!emailRegExp.hasMatch(value)) {
                    return 'Please enter a valid email address';
                  }
                }
                return null;
              },
            ),

            // Show NFT address if it exists (when editing)
            if (_isEditing && _fractionalNFTAddress != null && _fractionalNFTAddress!.isNotEmpty)
              _buildNftAddressField(),
          ],
      ),
    );
  }

  Widget _buildNftAddressField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        const Divider(),
        const SizedBox(height: 16),

        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFFF9800).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.token_outlined,
                color: Color(0xFFFF9800),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'NFT Information',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF333333),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'This market has been tokenized',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF777777),
                  ),
                ),
              ],
            ),
          ],
        ),

        const SizedBox(height: 16),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF8E1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFFFE082)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'NFT Address',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF333333),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.token,
                    color: Color(0xFFFF9800),
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _truncateKey(_fractionalNFTAddress!),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF333333),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  IconButton(
                    constraints: const BoxConstraints(
                      minWidth: 36,
                      minHeight: 36,
                    ),
                    padding: EdgeInsets.zero,
                    icon: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF9800).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(
                        Icons.copy,
                        color: Color(0xFFFF9800),
                        size: 16,
                      ),
                    ),
                    onPressed: () {
                      _copyToClipboard(_fractionalNFTAddress!);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Note: NFT address cannot be modified',
                style: TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: Color(0xFF777777),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoNote() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFBBDEFB)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFBBDEFB)),
            ),
            child: const Icon(
              Icons.info_outline,
              color: Color(0xFF2196F3),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Additional Information',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2196F3),
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'A public key will be automatically generated for your market. You can tokenize your market after creation.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF424242),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required IconData prefixIcon,
    FormFieldValidator<String>? validator,
    TextInputType keyboardType = TextInputType.text,
    bool required = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Color(0xFF555555),
              ),
            ),
            if (required)
              const Text(
                ' *',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              color: const Color(0xFF999999),
              fontSize: 15,
            ),
            prefixIcon: Icon(
              prefixIcon,
              color: const Color(0xFF4CAF50),
              size: 20,
            ),
            fillColor: const Color(0xFFF5F5F5),
            filled: true,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 16,
              horizontal: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFF4CAF50),
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Colors.red,
                width: 1.0,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Colors.red,
                width: 1.5,
              ),
            ),
          ),
          validator: validator,
          keyboardType: keyboardType,
          style: const TextStyle(
            fontSize: 16,
            color: Color(0xFF333333),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton(NormalMarketProvider provider) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: ElevatedButton(
        onPressed: provider.isSubmitting ? null : _submitForm,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4CAF50),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
          disabledBackgroundColor: Colors.grey.shade400,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _isEditing ? Icons.update : Icons.storefront,
              size: 22,
            ),
            const SizedBox(width: 12),
            Text(
              _isEditing ? 'Update Market' : 'Create Market',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(NormalMarketProvider provider) async {
    try {
      await provider.pickImage();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.redAccent,
            content: Text('Error selecting image: ${e.toString()}'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  String _truncateKey(String key) {
    if (key.length <= 12) return key;
    return '${key.substring(0, 6)}...${key.substring(key.length - 6)}';
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: Color(0xFF4CAF50),
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white, size: 18),
            SizedBox(width: 10),
            Text(
              'Copied to clipboard',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }
}