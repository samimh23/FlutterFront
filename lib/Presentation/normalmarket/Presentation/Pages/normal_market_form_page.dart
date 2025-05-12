import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hanouty/Core/network/apiconastant.dart';
import 'package:hanouty/Presentation/normalmarket/Data/models/normalmarket_model.dart';
import 'package:hanouty/Presentation/normalmarket/Domain/entities/normalmarket_entity.dart';
import 'package:hanouty/Presentation/normalmarket/Presentation/Provider/normal_market_provider.dart';
import 'package:provider/provider.dart';
import 'dart:io';

// Input Validator class for form validation
class InputValidator {
  static String? validateMarketName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a market name';
    }
    if (value.trim().length < 3) {
      return 'Market name must be at least 3 characters';
    }
    return null;
  }

  static String? validateLocation(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a market location';
    }
    if (value.trim().length < 5) {
      return 'Location must be at least 5 characters';
    }
    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) return null;
    final cleanedNumber = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    if (!RegExp(r'^[0-9]+$').hasMatch(cleanedNumber)) {
      return 'Phone number should contain only digits';
    }
    if (cleanedNumber.length < 8 || cleanedNumber.length > 15) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) return null;
    final emailRegExp = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegExp.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }
}

class NormalMarketFormPage extends StatefulWidget {
  final NormalMarket? normalMarket;

  const NormalMarketFormPage({Key? key, this.normalMarket}) : super(key: key);

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
  final ScrollController _scrollController = ScrollController();

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
    _scrollController.dispose();
    super.dispose();
  }
  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Theme.of(context).colorScheme.error,
          content: Text(
            'Please fix the errors in the form',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.onError,
            ),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    final provider = context.read<NormalMarketProvider>();
    if (!_isEditing && !provider.hasSelectedImage) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Theme.of(context).colorScheme.error,
          content: Text(
            'Please select an image for the market',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.onError,
            ),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    try {
      final marketData = {
        'marketName': _marketNameController.text.trim(),
        'marketLocation': _marketLocationController.text.trim(),
      };
      final phoneText = _marketPhoneController.text.trim();
      if (phoneText.isNotEmpty) marketData['marketPhone'] = phoneText;
      final emailText = _marketEmailController.text.trim();
      if (emailText.isNotEmpty) marketData['marketEmail'] = emailText;

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
            backgroundColor: Theme.of(context).colorScheme.secondary,
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Theme.of(context).colorScheme.onSecondary, size: 20),
                const SizedBox(width: 10),
                Text(
                  _isEditing ? 'Market updated successfully' : 'Market created successfully',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSecondary,
                  ),
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
            backgroundColor: Theme.of(context).colorScheme.error,
            content: Row(
              children: [
                Icon(Icons.error_outline, color: Theme.of(context).colorScheme.onError, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Error: ${e.toString()}',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onError,
                    ),
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

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NormalMarketProvider>();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDarkMode = colorScheme.brightness == Brightness.dark;
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 360;
    final horizontalPadding = isSmallScreen ? 12.0 : 20.0;
    final contentPadding = isSmallScreen ? 16.0 : 20.0;
    final formWidth = screenSize.width > 800
        ? 700.0
        : screenSize.width > 600
        ? screenSize.width * 0.85
        : screenSize.width - (isSmallScreen ? 24 : 40);

    final backgroundColor = colorScheme.background;
    final cardColor = colorScheme.surface;
    final textColor = colorScheme.onSurface;
    final subtitleColor = colorScheme.onSurface.withOpacity(0.7);
    final accentColor = colorScheme.secondary;
    final headerIconBgColor = accentColor.withOpacity(isDarkMode ? 0.2 : 0.1);
    final inputBgColor = isDarkMode ? Colors.grey.shade900 : const Color(0xFFF5F5F5);
    final inputBorderColor = isDarkMode ? Colors.grey.shade800 : Colors.transparent;
    final hintColor = theme.hintColor;
    final infoBoxBgColor = isDarkMode ? const Color(0xFF0D2E42) : const Color(0xFFE3F2FD);
    final infoBoxBorderColor = isDarkMode ? Colors.blue.shade900 : const Color(0xFFBBDEFB);
    final infoBoxIconColor = isDarkMode ? Colors.blue.shade200! : const Color(0xFF2196F3);
    final infoBoxTextColor = isDarkMode ? Colors.blue.shade200 : const Color(0xFF2196F3);
    final infoBoxContentColor = isDarkMode ? Colors.grey[300] : const Color(0xFF424242);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          backgroundColor: cardColor,
          elevation: 0,
          leading: IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: headerIconBgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.arrow_back,
                color: accentColor,
                size: 20,
              ),
            ),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            _isEditing ? 'Edit Market' : 'Create Market',
            style: theme.textTheme.titleLarge?.copyWith(
              color: accentColor,
              fontWeight: FontWeight.bold,
              fontSize: isSmallScreen ? 18 : 22,
            ),
          ),
        ),
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: const AssetImage('assets/icons/fruits_pattern_light.png'),
              opacity: isDarkMode ? 0.03 : 0.05,
              repeat: ImageRepeat.repeat,
            ),
          ),
          child: Form(
            key: _formKey,
            child: provider.isSubmitting
                ? _buildLoadingView(isDarkMode, isSmallScreen)
                : Center(
              child: Scrollbar(
                controller: _scrollController,
                thumbVisibility: true,
                child: SingleChildScrollView(
                  controller: _scrollController,
                  padding: EdgeInsets.symmetric(
                    vertical: 20.0,
                    horizontal: 0,
                  ),
                  child: Center(
                    child: Container(
                      constraints: BoxConstraints(
                        maxWidth: formWidth,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildPageHeader(isSmallScreen, horizontalPadding, isDarkMode, textColor, headerIconBgColor, accentColor, subtitleColor),
                          SizedBox(height: isSmallScreen ? 16 : 24),
                          if (provider.errorMessage.isNotEmpty)
                            _buildErrorMessage(provider, horizontalPadding, isDarkMode),
                          _buildImageSection(provider, horizontalPadding, contentPadding, isSmallScreen, isDarkMode, cardColor, textColor, subtitleColor, accentColor),
                          SizedBox(height: isSmallScreen ? 16 : 24),
                          _buildFormFields(horizontalPadding, contentPadding, isSmallScreen, isDarkMode, cardColor, textColor, subtitleColor, accentColor, inputBgColor, inputBorderColor, hintColor),
                          SizedBox(height: isSmallScreen ? 16 : 24),
                          if (!_isEditing)
                            _buildInfoNote(horizontalPadding, isSmallScreen, isDarkMode, infoBoxBgColor, infoBoxBorderColor, infoBoxIconColor, infoBoxTextColor, infoBoxContentColor),
                          SizedBox(height: isSmallScreen ? 24 : 30),
                          _buildSubmitButton(provider, horizontalPadding, isSmallScreen, isDarkMode, accentColor),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        floatingActionButton: isSmallScreen && !provider.isSubmitting
            ? FloatingActionButton(
          onPressed: _submitForm,
          backgroundColor: accentColor,
          child: Icon(
            _isEditing ? Icons.update : Icons.check,
            color: Theme.of(context).colorScheme.onSecondary,
          ),
        )
            : null,
      ),
    );
  }
  // PART 3: SUBWIDGETS (LOADING, HEADERS, ERROR, IMAGE, FORM FIELDS, SUBMIT BUTTON, ETC.)

  Widget _buildLoadingView(bool isDarkMode, bool isSmallScreen) {
    final accentColor = Theme.of(context).colorScheme.secondary;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'icons/loading.gif',
            height: isSmallScreen ? 80 : 120,
            width: isSmallScreen ? 80 : 120,
            color: isDarkMode ? Colors.white.withOpacity(0.7) : null,
          ),
          SizedBox(height: isSmallScreen ? 16 : 24),
          Text(
            'Processing your market...',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: accentColor,
              fontSize: isSmallScreen ? 16 : 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageHeader(
      bool isSmallScreen,
      double horizontalPadding,
      bool isDarkMode,
      Color textColor,
      Color headerIconBgColor,
      Color accentColor,
      Color? subtitleColor) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(isSmallScreen ? 8 : 12),
                decoration: BoxDecoration(
                  color: headerIconBgColor,
                  borderRadius: BorderRadius.circular(isSmallScreen ? 8 : 12),
                ),
                child: Icon(
                  _isEditing ? Icons.edit_note : Icons.storefront_outlined,
                  color: accentColor,
                  size: isSmallScreen ? 20 : 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isEditing ? 'Edit Market' : 'Create New Market',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontSize: isSmallScreen ? 20 : 24,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    SizedBox(height: isSmallScreen ? 2 : 4),
                    Text(
                      _isEditing
                          ? 'Update your market information'
                          : 'Fill in the details for your new market',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        fontSize: isSmallScreen ? 12 : 14,
                        color: subtitleColor,
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

  Widget _buildErrorMessage(NormalMarketProvider provider, double horizontalPadding, bool isDarkMode) {
    final errorBgColor = isDarkMode ? Colors.red.shade900.withOpacity(0.2) : Colors.red.shade50;
    final errorBorderColor = isDarkMode ? Colors.red.shade800.withOpacity(0.4) : Colors.red.shade200;
    final errorTextColor = isDarkMode ? Colors.red.shade300 : Colors.red.shade700;
    final errorIconBgColor = isDarkMode ? Colors.red.shade900 : Colors.white;

    return Container(
      margin: EdgeInsets.fromLTRB(horizontalPadding, 0, horizontalPadding, 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: errorBgColor,
        border: Border.all(color: errorBorderColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: errorIconBgColor,
              shape: BoxShape.circle,
              border: Border.all(color: errorBorderColor),
            ),
            child: Icon(Icons.error_outline, color: errorTextColor, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              provider.errorMessage,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: errorTextColor, fontSize: 14),
            ),
          ),
          IconButton(
            icon: Icon(Icons.close, color: errorTextColor, size: 20),
            onPressed: () => provider.clearError(),
            constraints: const BoxConstraints(
              minWidth: 40,
              minHeight: 40,
            ),
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  Widget _buildImageSection(
      NormalMarketProvider provider,
      double horizontalPadding,
      double contentPadding,
      bool isSmallScreen,
      bool isDarkMode,
      Color cardColor,
      Color textColor,
      Color? subtitleColor,
      Color accentColor,
      ) {
    final headerIconBgColor = accentColor.withOpacity(isDarkMode ? 0.2 : 0.1);
    final imageAreaBgColor = isDarkMode ? Colors.grey.shade900 : const Color(0xFFEEF7ED);
    final imageAreaBorderColor = isDarkMode ? Colors.grey.shade800 : const Color(0xFFD8EBD8);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: horizontalPadding),
      padding: EdgeInsets.all(contentPadding),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDarkMode ? 0.2 : 0.05),
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
                padding: EdgeInsets.all(isSmallScreen ? 8 : 10),
                decoration: BoxDecoration(
                  color: headerIconBgColor,
                  borderRadius: BorderRadius.circular(isSmallScreen ? 8 : 10),
                ),
                child: Icon(
                  Icons.image,
                  color: accentColor,
                  size: isSmallScreen ? 16 : 20,
                ),
              ),
              SizedBox(width: isSmallScreen ? 8 : 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Market Image',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: isSmallScreen ? 16 : 18,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                    SizedBox(height: isSmallScreen ? 0 : 2),
                    Text(
                      'Upload a clear image of your market',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        fontSize: isSmallScreen ? 11 : 13,
                        color: subtitleColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: isSmallScreen ? 16 : 20),
          AspectRatio(
            aspectRatio: isSmallScreen ? 4 / 3 : 16 / 9,
            child: Container(
              decoration: BoxDecoration(
                color: imageAreaBgColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: imageAreaBorderColor),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: _buildImagePreview(provider, isDarkMode, isSmallScreen),
              ),
            ),
          ),
          SizedBox(height: isSmallScreen ? 16 : 20),
          Center(
            child: ElevatedButton.icon(
              onPressed: () => _pickImage(provider),
              icon: Icon(Icons.add_photo_alternate, size: isSmallScreen ? 16 : 20),
              label: Text(
                _isEditing ? 'Change Image' : 'Upload Image',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: isSmallScreen ? 13 : 15,
                  color: Theme.of(context).colorScheme.onSecondary,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor,
                foregroundColor: Theme.of(context).colorScheme.onSecondary,
                padding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 16 : 20,
                    vertical: isSmallScreen ? 10 : 12),
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
  // ==== PART 4: IMAGE PREVIEW, NO IMAGE, ERROR VIEW, OVERLAY ====

  Widget _buildImagePreview(NormalMarketProvider provider, bool isDarkMode, bool isSmallScreen) {
    // For editing market with existing image
    if (_isEditing && widget.normalMarket?.marketImage != null && !provider.hasSelectedImage) {
      return _buildExistingImage(widget.normalMarket!.marketImage!, isDarkMode, isSmallScreen);
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
              return _buildImageErrorView(isSmallScreen, isDarkMode);
            },
          ),
          _buildImageOverlay('New Image Selected', provider.selectedImageName, isSmallScreen),
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
              return _buildImageErrorView(isSmallScreen, isDarkMode);
            },
          ),
          _buildImageOverlay('New Image Selected', null, isSmallScreen),
        ],
      );
    }
    // No image selected
    return _buildNoImageView(isSmallScreen, isDarkMode);
  }

  Widget _buildExistingImage(String imagePath, bool isDarkMode, bool isSmallScreen) {
    final accentColor = Theme.of(context).colorScheme.secondary;
    return Stack(
      fit: StackFit.expand,
      children: [
        imagePath.isNotEmpty
            ? Image.network(
          ApiConstants.getFullImageUrl(imagePath),
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return _buildImageErrorView(isSmallScreen, isDarkMode);
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                    loadingProgress.expectedTotalBytes!
                    : null,
                color: accentColor,
              ),
            );
          },
        )
            : _buildNoImageView(isSmallScreen, isDarkMode),
        _buildImageOverlay('Current Image', null, isSmallScreen),
      ],
    );
  }

  Widget _buildNoImageView(bool isSmallScreen, bool isDarkMode) {
    final accentColor = Theme.of(context).colorScheme.secondary;
    final textColor = Theme.of(context).colorScheme.onSurface;
    final subtitleColor = Theme.of(context).colorScheme.onSurface.withOpacity(0.7);
    final iconBgColor = isDarkMode ? Colors.grey.shade800 : Colors.white;
    final iconBorderColor = isDarkMode ? Colors.grey.shade700 : const Color(0xFFD8EBD8);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
              border: Border.all(color: iconBorderColor, width: 2),
            ),
            child: Icon(
              Icons.add_photo_alternate_outlined,
              size: isSmallScreen ? 28 : 36,
              color: accentColor,
            ),
          ),
          SizedBox(height: isSmallScreen ? 12 : 16),
          Text(
            'Add Market Image',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: accentColor,
              fontSize: isSmallScreen ? 14 : 16,
            ),
          ),
          SizedBox(height: isSmallScreen ? 6 : 8),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 20 : 0),
            child: Text(
              'Select an image to showcase your market',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: subtitleColor,
                fontSize: isSmallScreen ? 12 : 14,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageErrorView(bool isSmallScreen, bool isDarkMode) {
    final errorColor = isDarkMode ? Colors.red.shade300 : Colors.red.shade300;
    final errorBgColor = isDarkMode ? Colors.red.shade900.withOpacity(0.3) : Colors.red.shade50;
    final textColor = Theme.of(context).colorScheme.onSurface.withOpacity(0.7);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(isSmallScreen ? 10 : 12),
            decoration: BoxDecoration(
              color: errorBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.broken_image,
              size: isSmallScreen ? 24 : 32,
              color: errorColor,
            ),
          ),
          SizedBox(height: isSmallScreen ? 8 : 12),
          Text(
            'Could not load image',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w500,
              fontSize: isSmallScreen ? 12 : 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageOverlay(String text, [String? subtext, bool isSmallScreen = false]) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: isSmallScreen ? 8 : 12,
          horizontal: isSmallScreen ? 12 : 16,
        ),
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
                Icon(
                  Icons.check_circle,
                  color: Colors.white,
                  size: isSmallScreen ? 14 : 16,
                ),
                SizedBox(width: isSmallScreen ? 6 : 8),
                Text(
                  text,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: isSmallScreen ? 12 : 14,
                  ),
                ),
              ],
            ),
            if (subtext != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  "($subtext)",
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Colors.white70,
                    fontSize: isSmallScreen ? 10 : 12,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ==== PART 5: FORM FIELDS, NFT INFO, INFO NOTE, SUBMIT BUTTON, IMAGE PICKER, UTILS, END OF CLASS ====

  Widget _buildFormFields(
      double horizontalPadding,
      double contentPadding,
      bool isSmallScreen,
      bool isDarkMode,
      Color cardColor,
      Color textColor,
      Color? subtitleColor,
      Color accentColor,
      Color inputBgColor,
      Color inputBorderColor,
      Color hintColor,
      ) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: horizontalPadding),
      padding: EdgeInsets.all(contentPadding),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDarkMode ? 0.2 : 0.05),
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
                padding: EdgeInsets.all(isSmallScreen ? 8 : 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF2196F3).withOpacity(isDarkMode ? 0.2 : 0.1),
                  borderRadius: BorderRadius.circular(isSmallScreen ? 8 : 10),
                ),
                child: Icon(
                  Icons.info_outline,
                  color: isDarkMode ? Colors.blue.shade300 : const Color(0xFF2196F3),
                  size: isSmallScreen ? 16 : 20,
                ),
              ),
              SizedBox(width: isSmallScreen ? 8 : 12),
              Text(
                'Market Information',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontSize: isSmallScreen ? 16 : 18,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ],
          ),
          SizedBox(height: isSmallScreen ? 16 : 24),

          // Market name field
          _buildFormField(
            controller: _marketNameController,
            label: 'Market Name',
            hintText: 'Enter market name (min. 3 characters)',
            prefixIcon: Icons.store_outlined,
            validator: InputValidator.validateMarketName,
            required: true,
            isSmallScreen: isSmallScreen,
            isDarkMode: isDarkMode,
            textColor: textColor,
            subtitleColor: subtitleColor,
            accentColor: accentColor,
            inputBgColor: inputBgColor,
            inputBorderColor: inputBorderColor,
            hintColor: hintColor,
          ),
          SizedBox(height: isSmallScreen ? 12 : 16),

          // Market location field
          _buildFormField(
            controller: _marketLocationController,
            label: 'Location',
            hintText: 'Enter market location (min. 5 characters)',
            prefixIcon: Icons.location_on_outlined,
            validator: InputValidator.validateLocation,
            required: true,
            isSmallScreen: isSmallScreen,
            isDarkMode: isDarkMode,
            textColor: textColor,
            subtitleColor: subtitleColor,
            accentColor: accentColor,
            inputBgColor: inputBgColor,
            inputBorderColor: inputBorderColor,
            hintColor: hintColor,
          ),
          SizedBox(height: isSmallScreen ? 12 : 16),

          // Market phone field
          _buildFormField(
            controller: _marketPhoneController,
            label: 'Contact Phone (Optional)',
            hintText: 'Enter digits only',
            prefixIcon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            validator: InputValidator.validatePhone,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9\s\-\(\)]')),
            ],
            isSmallScreen: isSmallScreen,
            isDarkMode: isDarkMode,
            textColor: textColor,
            subtitleColor: subtitleColor,
            accentColor: accentColor,
            inputBgColor: inputBgColor,
            inputBorderColor: inputBorderColor,
            hintColor: hintColor,
          ),
          SizedBox(height: isSmallScreen ? 12 : 16),

          // Market email field
          _buildFormField(
            controller: _marketEmailController,
            label: 'Contact Email (Optional)',
            hintText: 'Enter contact email',
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: InputValidator.validateEmail,
            isSmallScreen: isSmallScreen,
            isDarkMode: isDarkMode,
            textColor: textColor,
            subtitleColor: subtitleColor,
            accentColor: accentColor,
            inputBgColor: inputBgColor,
            inputBorderColor: inputBorderColor,
            hintColor: hintColor,
          ),

          // NFT Address (editing only)
          if (_isEditing && _fractionalNFTAddress != null && _fractionalNFTAddress!.isNotEmpty)
            _buildNftAddressField(isSmallScreen, isDarkMode, textColor, subtitleColor),
        ],
      ),
    );
  }

  Widget _buildNftAddressField(bool isSmallScreen, bool isDarkMode, Color textColor, Color? subtitleColor) {
    final nftHeaderColor = isDarkMode ? Colors.amber.shade300 : const Color(0xFFFF9800);
    final nftHeaderBgColor = nftHeaderColor.withOpacity(isDarkMode ? 0.2 : 0.1);
    final nftBoxColor = isDarkMode ? const Color(0xFF332200) : const Color(0xFFFFF8E1);
    final nftBoxBorderColor = isDarkMode ? Colors.amber.shade900 : const Color(0xFFFFE082);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: isSmallScreen ? 16 : 24),
        Divider(color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200),
        SizedBox(height: isSmallScreen ? 12 : 16),
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(isSmallScreen ? 8 : 10),
              decoration: BoxDecoration(
                color: nftHeaderBgColor,
                borderRadius: BorderRadius.circular(isSmallScreen ? 8 : 10),
              ),
              child: Icon(
                Icons.token_outlined,
                color: nftHeaderColor,
                size: isSmallScreen ? 16 : 20,
              ),
            ),
            SizedBox(width: isSmallScreen ? 8 : 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'NFT Information',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontSize: isSmallScreen ? 14 : 16,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                SizedBox(height: isSmallScreen ? 2 : 4),
                Text(
                  'This market has been tokenized',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontSize: isSmallScreen ? 11 : 13,
                    color: subtitleColor,
                  ),
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: isSmallScreen ? 12 : 16),
        Container(
          padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
          decoration: BoxDecoration(
            color: nftBoxColor,
            borderRadius: BorderRadius.circular(isSmallScreen ? 10 : 12),
            border: Border.all(color: nftBoxBorderColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'NFT Address',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontSize: isSmallScreen ? 12 : 14,
                  fontWeight: FontWeight.w500,
                  color: textColor,
                ),
              ),
              SizedBox(height: isSmallScreen ? 6 : 8),
              Row(
                children: [
                  Icon(
                    Icons.token,
                    color: nftHeaderColor,
                    size: isSmallScreen ? 16 : 18,
                  ),
                  SizedBox(width: isSmallScreen ? 6 : 8),
                  Expanded(
                    child: Text(
                      _truncateKey(_fractionalNFTAddress!),
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: textColor,
                        letterSpacing: 0.5,
                        fontSize: isSmallScreen ? 12 : 14,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    constraints: BoxConstraints(
                      minWidth: isSmallScreen ? 32 : 36,
                      minHeight: isSmallScreen ? 32 : 36,
                    ),
                    padding: EdgeInsets.zero,
                    icon: Container(
                      padding: EdgeInsets.all(isSmallScreen ? 4 : 6),
                      decoration: BoxDecoration(
                        color: nftHeaderBgColor,
                        borderRadius: BorderRadius.circular(isSmallScreen ? 4 : 6),
                      ),
                      child: Icon(
                        Icons.copy,
                        color: nftHeaderColor,
                        size: isSmallScreen ? 14 : 16,
                      ),
                    ),
                    onPressed: () {
                      _copyToClipboard(_fractionalNFTAddress!);
                    },
                  ),
                ],
              ),
              SizedBox(height: isSmallScreen ? 6 : 8),
              Text(
                'Note: NFT address cannot be modified',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontSize: isSmallScreen ? 10 : 12,
                  fontStyle: FontStyle.italic,
                  color: subtitleColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoNote(
      double horizontalPadding,
      bool isSmallScreen,
      bool isDarkMode,
      Color infoBoxBgColor,
      Color infoBoxBorderColor,
      Color? infoBoxIconColor,
      Color? infoBoxTextColor,
      Color? infoBoxContentColor,
      ) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: horizontalPadding),
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
      decoration: BoxDecoration(
        color: infoBoxBgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: infoBoxBorderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(top: isSmallScreen ? 0 : 4),
            padding: EdgeInsets.all(isSmallScreen ? 8 : 10),
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey.shade800 : Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: infoBoxBorderColor),
            ),
            child: Icon(
              Icons.info_outline,
              color: infoBoxIconColor,
              size: isSmallScreen ? 20 : 24,
            ),
          ),
          SizedBox(width: isSmallScreen ? 12 : 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Additional Information',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: infoBoxTextColor,
                    fontSize: isSmallScreen ? 14 : 16,
                  ),
                ),
                SizedBox(height: isSmallScreen ? 6 : 8),
                Text(
                  'A public key will be automatically generated for your market. You can tokenize your market after creation.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: infoBoxContentColor,
                    height: 1.4,
                    fontSize: isSmallScreen ? 12 : 14,
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
    List<TextInputFormatter>? inputFormatters,
    required bool isSmallScreen,
    required bool isDarkMode,
    required Color textColor,
    required Color? subtitleColor,
    required Color accentColor,
    required Color inputBgColor,
    required Color inputBorderColor,
    required Color hintColor,
  }) {
    final errorColor = isDarkMode ? Colors.red.shade300 : Colors.red;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontSize: isSmallScreen ? 13 : 15,
                fontWeight: FontWeight.w500,
                color: subtitleColor,
              ),
            ),
            if (required)
              Text(
                ' *',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: errorColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
        SizedBox(height: isSmallScreen ? 6 : 8),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: hintColor,
              fontSize: isSmallScreen ? 13 : 15,
            ),
            prefixIcon: Icon(
              prefixIcon,
              color: accentColor,
              size: isSmallScreen ? 18 : 20,
            ),
            fillColor: inputBgColor,
            filled: true,
            contentPadding: EdgeInsets.symmetric(
              vertical: isSmallScreen ? 12 : 16,
              horizontal: isSmallScreen ? 12 : 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(isSmallScreen ? 10 : 12),
              borderSide: BorderSide(color: inputBorderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(isSmallScreen ? 10 : 12),
              borderSide: BorderSide(color: inputBorderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(isSmallScreen ? 10 : 12),
              borderSide: BorderSide(color: accentColor, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(isSmallScreen ? 10 : 12),
              borderSide: BorderSide(color: errorColor, width: 1.0),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(isSmallScreen ? 10 : 12),
              borderSide: BorderSide(color: errorColor, width: 1.5),
            ),
            errorStyle: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontSize: isSmallScreen ? 11 : 12,
              height: isSmallScreen ? 0.8 : 1.0,
              color: errorColor,
            ),
          ),
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontSize: isSmallScreen ? 14 : 16,
            color: textColor,
          ),
          validator: validator,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          textInputAction: TextInputAction.next,
        ),
      ],
    );
  }

  Widget _buildSubmitButton(
      NormalMarketProvider provider,
      double horizontalPadding,
      bool isSmallScreen,
      bool isDarkMode,
      Color accentColor,
      ) {
    if (isSmallScreen) {
      return const SizedBox.shrink();
    }
    return Container(
      margin: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: ElevatedButton(
        onPressed: provider.isSubmitting ? null : _submitForm,
        style: ElevatedButton.styleFrom(
          backgroundColor: accentColor,
          foregroundColor: Theme.of(context).colorScheme.onSecondary,
          padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 14 : 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(isSmallScreen ? 10 : 12),
          ),
          elevation: 2,
          disabledBackgroundColor: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade400,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _isEditing ? Icons.update : Icons.storefront,
              size: isSmallScreen ? 18 : 22,
            ),
            SizedBox(width: isSmallScreen ? 8 : 12),
            Text(
              _isEditing ? 'Update Market' : 'Create Market',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: isSmallScreen ? 16 : 18,
                color: Theme.of(context).colorScheme.onSecondary,
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
            backgroundColor: Theme.of(context).colorScheme.error,
            content: Text(
              'Error selecting image: ${e.toString()}',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: Theme.of(context).colorScheme.onError,
                fontSize: 14,
              ),
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  String _truncateKey(String key) {
    final isSmallScreen = MediaQuery.of(context).size.width < 360;
    if (key.length <= (isSmallScreen ? 10 : 12)) return key;
    return isSmallScreen
        ? '${key.substring(0, 4)}...${key.substring(key.length - 4)}'
        : '${key.substring(0, 6)}...${key.substring(key.length - 6)}';
  }

  void _copyToClipboard(String text) {
    final accentColor = Theme.of(context).colorScheme.secondary;
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: accentColor,
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Theme.of(context).colorScheme.onSecondary, size: 18),
            const SizedBox(width: 10),
            Text(
              'Copied to clipboard',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSecondary,
              ),
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
