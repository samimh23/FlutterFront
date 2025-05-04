import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hanouty/Core/heritables/Markets.dart';
import 'package:hanouty/Presentation/normalmarket/Data/models/normalmarket_model.dart';
import 'package:hanouty/Presentation/normalmarket/Domain/entities/normalmarket_entity.dart';
import 'package:hanouty/Presentation/normalmarket/Domain/entities/share_fraction.dart';
import 'package:hanouty/Presentation/normalmarket/Domain/usecases/create_fractional_nft.dart';
import 'package:hanouty/Presentation/normalmarket/Domain/usecases/get_my_market.dart';
import 'package:hanouty/Presentation/normalmarket/Domain/usecases/give_shares.dart';
import 'package:hanouty/Presentation/normalmarket/Domain/usecases/market_add.dart';
import 'package:hanouty/Presentation/normalmarket/Domain/usecases/market_delete.dart';
import 'package:hanouty/Presentation/normalmarket/Domain/usecases/market_getall.dart';
import 'package:hanouty/Presentation/normalmarket/Domain/usecases/market_getbyid.dart';
import 'package:hanouty/Presentation/normalmarket/Domain/usecases/market_update.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:typed_data';

import '../../../../Core/Utils/secure_storage.dart';
import '../../../../hedera_api_service.dart';

class NormalMarketProvider extends ChangeNotifier {


  final GetNormalMarkets getNormalMarkets;
  final GetMyNormalMarkets getMyNormalMarkets;
  final GetNormalMarketById getNormalMarketById;
  final CreateNormalMarket createNormalMarket;
  final UpdateNormalMarket updateNormalMarket;
  final DeleteNormalMarket deleteNormalMarket;
  final ShareFractionalNFT shareFractionalNFT;
  final CreateFractionalNFT createFractionalNFT;
  final SecureStorageService secureStorageService;

  NormalMarketProvider({
    required this.getNormalMarkets,
    required this.getMyNormalMarkets,
    required this.getNormalMarketById,
    required this.createNormalMarket,
    required this.updateNormalMarket,
    required this.deleteNormalMarket,
    required this.shareFractionalNFT,
    required this.createFractionalNFT,
    required this.secureStorageService,
  }) {
    // Initialize by loading markets
    loadMarkets();
  }

  // State variables
  List<Markets> _markets = [];
  List<Markets> _myMarkets = []; // State variable for user's markets
  Markets? _selectedMarket;
  bool _isLoading = false;
  bool _isLoadingMyMarkets = false; // Add loading state for my markets
  String _errorMessage = '';
  File? _selectedImageFile; // For mobile/desktop
  Uint8List? _selectedImageBytes; // For web
  XFile? _selectedImageXFile; // Original XFile from picker
  bool _isSubmitting = false;

  // Getters
  List<Markets> get markets => _markets;
  List<Markets> get myMarkets => _myMarkets; // Getter for my markets
  Markets? get selectedMarket => _selectedMarket;
  bool get isLoading => _isLoading;
  bool get isLoadingMyMarkets => _isLoadingMyMarkets;
  String get errorMessage => _errorMessage;
  File? get selectedImage => _selectedImageFile;
  Uint8List? get selectedImageBytes => _selectedImageBytes;
  String? get selectedImageName => _selectedImageXFile?.name;
  bool get isSubmitting => _isSubmitting;
  bool get hasSelectedImage =>
      _selectedImageFile != null || _selectedImageBytes != null;

  // Methods for markets
  Future<void> loadMarkets() async {
    _setLoading(true);
    _clearError();

    try {
      _markets = await getNormalMarkets();
      notifyListeners();
    } catch (e) {
      _setError('Failed to load markets: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadMarketById(String id) async {
    _setLoading(true);
    _clearError();

    try {
      _selectedMarket = await getNormalMarketById(id);
      notifyListeners();
    } catch (e) {
      _setError('Failed to load market details: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }






  // Method to load authenticated user's markets
  Future<void> loadMyMarkets() async {
    _isLoadingMyMarkets = true;
    _clearError();

    try {
      print('📊 Provider: Loading markets owned by current user');
      _myMarkets = await getMyNormalMarkets();
      print('✅ Provider: Loaded ${_myMarkets.length} markets for current user');
      notifyListeners();
    } catch (e) {
      print('❌ Provider: Error loading user\'s markets: $e');
      _setError('Failed to load your markets: ${e.toString()}');
    } finally {
      _isLoadingMyMarkets = false;
      notifyListeners();
    }
  }

  // Market creation methods
  Future<bool> addMarketFromMap(Map<String, dynamic> marketData) async {
    try {
      _setSubmitting(true);
      _clearError();

      print('Creating market from data: $marketData');

      // Create a minimal market object with only required fields
      final market = NormalMarket(
        id: '', // Leave empty for backend to generate
        marketName: marketData['marketName'],
        marketLocation: marketData['marketLocation'],
        marketPhone: marketData['marketPhone'],
        marketEmail: marketData['marketEmail'],
        products: [], // Empty products list for new market
        marketWalletPublicKey: '',
        marketWalletSecretKey: '',
      );

      if (!hasSelectedImage) {
        _setError('No image selected');
        return false;
      }

      String imagePath;
      try {
        if (kIsWeb && _selectedImageBytes != null) {
          imagePath = await _saveWebImage();
          print('Using web image data URL');
        } else if (!kIsWeb && _selectedImageFile != null) {
          imagePath = _selectedImageFile!.path;
          print('Using file image path: $imagePath');
        } else {
          _setError('Invalid image data');
          return false;
        }
      } catch (e) {
        print('Error processing image: $e');
        _setError('Failed to process image: $e');
        return false;
      }

      final result = await createNormalMarket(market, imagePath);
      print('Market created successfully with ID: ${result.id}');

      _markets.add(result);
      _myMarkets.add(result); // Add to my markets too since user created it
      _clearSelectedImage();
      notifyListeners();
      return true;
    } catch (e, stackTrace) {
      print('Error creating market: $e');
      print('Stack trace: $stackTrace');
      _setError('Failed to create market: ${e.toString()}');
      return false;
    } finally {
      _setSubmitting(false);
    }
  }

  // Market update method
  Future<bool> updateExistingMarketFromMap(
      String id, Map<String, dynamic> marketData) async {
    try {
      _setSubmitting(true);
      _clearError();

      print('Updating market with ID: $id');
      print('Data: $marketData');

      // Find existing market
      final existingMarket = _markets.firstWhere(
            (market) => market.id == id,
        orElse: () => throw Exception('Market not found'),
      );

      if (!(existingMarket is NormalMarket)) {
        throw Exception('Market with ID $id is not a NormalMarket');
      }

      // Create an updated market entity with merged data
      final updatedMarket = NormalMarket(
        id: id,
        marketName: marketData['marketName'] ?? existingMarket.marketName,
        marketLocation: marketData['marketLocation'] ?? existingMarket.marketLocation,
        marketPhone: marketData['marketPhone'] ?? existingMarket.marketPhone,
        marketEmail: marketData['marketEmail'] ?? existingMarket.marketEmail,
        products: existingMarket.products,
        marketWalletPublicKey: existingMarket.marketWalletPublicKey,
        marketWalletSecretKey: existingMarket.marketWalletSecretKey,
        marketImage: existingMarket.marketImage,
        fractionalNFTAddress: existingMarket.fractionalNFTAddress,
      );

      // Determine whether we have a new image to update
      String? imagePath;
      if (hasSelectedImage) {
        if (kIsWeb && _selectedImageBytes != null) {
          imagePath = await _saveWebImage();
          print('Using new web image path: $imagePath');
        } else if (!kIsWeb && _selectedImageFile != null) {
          imagePath = _selectedImageFile!.path;
          print('Using new file image path: $imagePath');
        }
      }

      // Call the update usecase
      final updatedMarketFromRepo = await updateNormalMarket(id, updatedMarket, imagePath);
      print('Market updated successfully');

      // Update local state in both market lists
      _updateMarketInLists(updatedMarketFromRepo);

      _clearSelectedImage();
      notifyListeners();
      return true;
    } catch (e, stackTrace) {
      print('Error updating market: $e');
      print('Stack trace: $stackTrace');
      _setError('Failed to update market: ${e.toString()}');
      return false;
    } finally {
      _setSubmitting(false);
    }
  }

  // Helper to update a market in both lists
  void _updateMarketInLists(Markets updatedMarket) {
    // Update in the main markets list
    final mainIndex = _markets.indexWhere((market) => market.id == updatedMarket.id);
    if (mainIndex != -1) {
      _markets[mainIndex] = updatedMarket;
    }

    // Update in my markets list
    final myIndex = _myMarkets.indexWhere((market) => market.id == updatedMarket.id);
    if (myIndex != -1) {
      _myMarkets[myIndex] = updatedMarket;
    }

    // Update selected market if it's the one that got updated
    if (_selectedMarket?.id == updatedMarket.id) {
      _selectedMarket = updatedMarket;
    }
  }

  // Web image handling helper
  Future<String> _saveWebImage() async {
    if (_selectedImageBytes == null || _selectedImageXFile == null) {
      throw Exception('No web image data available');
    }

    try {
      // Get file extension from original filename
      final String extension = _selectedImageXFile!.name.split('.').last.toLowerCase();
      final String mimeType = extension == 'png' ? 'image/png' : 'image/jpeg';

      // Convert bytes to base64
      final base64String = base64Encode(_selectedImageBytes!);

      // Create proper data URL without adding file extension
      return 'data:$mimeType;base64,$base64String';
    } catch (e) {
      print('Error processing web image: $e');
      throw Exception('Failed to process web image: $e');
    }
  }

  // Legacy method - maintain for compatibility
  Future<bool> addMarket(NormalMarketModel market) async {
    _setSubmitting(true);
    _clearError();

    try {
      print('Legacy addMarket called with model: ${market.marketName}');

      final marketEntity = NormalMarket(
        id: '',
        marketName: market.marketName,
        marketLocation: market.marketLocation,
        marketPhone: market.marketPhone,
        marketEmail: market.marketEmail,
        products: [],
        marketWalletPublicKey: '',
        marketWalletSecretKey: '',
        marketImage: market.marketImage,
      );

      // Check for image
      if (!hasSelectedImage) {
        _setError('No image selected');
        return false;
      }

      String imagePath;
      if (kIsWeb && _selectedImageBytes != null) {
        imagePath = await _saveWebImage();
      } else if (!kIsWeb && _selectedImageFile != null) {
        imagePath = _selectedImageFile!.path;
      } else {
        _setError('Invalid image data');
        return false;
      }

      final result = await createNormalMarket(marketEntity, imagePath);
      _markets.add(result);
      _myMarkets.add(result); // Add to my markets too since user created it
      _clearSelectedImage();
      notifyListeners();
      return true;
    } catch (e, stackTrace) {
      print('Error in legacy addMarket: $e');
      print('Stack trace: $stackTrace');
      _setError('Failed to create market: ${e.toString()}');
      return false;
    } finally {
      _setSubmitting(false);
    }
  }

  // Legacy method - maintain for compatibility
  Future<bool> updateExistingMarket(String id, NormalMarketModel market) async {
    _setSubmitting(true);
    _clearError();

    try {
      print('Legacy updateExistingMarket called with ID: $id');

      final marketEntity = NormalMarket(
        id: id,
        marketName: market.marketName,
        marketLocation: market.marketLocation,
        marketPhone: market.marketPhone,
        marketEmail: market.marketEmail,
        products: market.products,
        marketWalletPublicKey: market.marketWalletPublicKey,
        marketWalletSecretKey: market.marketWalletSecretKey,
        fractionalNFTAddress: market.fractionalNFTAddress,
        marketImage: market.marketImage,
      );

      // Determine image path
      String? imagePath;
      if (_selectedImageFile != null) {
        imagePath = _selectedImageFile!.path;
      } else if (_selectedImageBytes != null) {
        imagePath = await _saveWebImage();
      }

      final updatedMarket = await updateNormalMarket(id, marketEntity, imagePath);

      // Update market in both lists
      _updateMarketInLists(updatedMarket);

      _clearSelectedImage();
      notifyListeners();
      return true;
    } catch (e, stackTrace) {
      print('Error in legacy updateExistingMarket: $e');
      print('Stack trace: $stackTrace');
      _setError('Failed to update market: ${e.toString()}');
      return false;
    } finally {
      _setSubmitting(false);
    }
  }

  // Market deletion method
  Future<bool> removeMarket(String id) async {
    _setLoading(true);
    _clearError();

    try {
      await deleteNormalMarket(id);

      // Remove from both lists
      _markets.removeWhere((market) => market.id == id);
      _myMarkets.removeWhere((market) => market.id == id);

      if (_selectedMarket?.id == id) {
        _selectedMarket = null;
      }

      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to delete market: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // NFT Creation method
  Future<bool> createNFT(String marketId) async {
    _setLoading(true);
    _clearError();

    try {
      final updatedMarket = await createFractionalNFT(marketId);

      // Update market in both lists
      _updateMarketInLists(updatedMarket);

      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to create NFT: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // NFT Sharing method
  Future<Map<String, dynamic>> shareNFT(
      String marketId, String recipientAddress, int percentage, {String? recipientType}) async {
    _setLoading(true);
    _clearError();

    try {
      // Validate input
      if (percentage <= 0 || percentage > 100) {
        _setError('Percentage must be between 1 and 100');
        return {'success': false, 'message': 'Invalid percentage value'};
      }

      if (recipientAddress.isEmpty) {
        _setError('Recipient address cannot be empty');
        return {'success': false, 'message': 'Invalid recipient address'};
      }

      // Check if the recipient is a Hedera account ID (0.0.xxxxx format) or an ObjectId
      bool isHederaAccount = RegExp(r'^0\.0\.\d+$').hasMatch(recipientAddress);

      // Create the share request
      final request = ShareFractionRequest(
        recipientAddress: recipientAddress,
        percentage: percentage,
        recipientType: recipientType,
      );

      print('Sharing ${percentage}% of market ${marketId} with recipient: ${recipientAddress}');
      if (recipientType != null) {
        print('Recipient type specified as: $recipientType');
      }

      // Call the API
      final result = await shareFractionalNFT(marketId, request);

      // Log the response
      print('Share NFT response: $result');

      // Reload the market to get updated fractions
      if (result['success'] == true) {
        await loadMarketById(marketId);
      }

      return result;
    } catch (e) {
      print('Error sharing NFT: $e');
      _setError('Failed to share NFT: ${e.toString()}');
      return {'success': false, 'message': e.toString()};
    } finally {
      _setLoading(false);
    }
  }

  // Image picking method
  Future<void> pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedImage = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (pickedImage != null) {
        // Check file extension
        final String extension = pickedImage.name.split('.').last.toLowerCase();
        if (!['jpg', 'jpeg', 'png'].contains(extension)) {
          _setError('Please select a PNG or JPEG image');
          return;
        }

        print('Image picked: ${pickedImage.name}');
        _selectedImageXFile = pickedImage;

        if (kIsWeb) {
          _selectedImageBytes = await pickedImage.readAsBytes();
          _selectedImageFile = null;
          print('Web image loaded: ${_selectedImageBytes!.lengthInBytes} bytes');
        } else {
          _selectedImageFile = File(pickedImage.path);
          _selectedImageBytes = null;
          print('File image loaded: ${await _selectedImageFile!.length()} bytes');
        }

        notifyListeners();
      } else {
        print('No image selected by user');
      }
    } catch (e) {
      print('Error picking image: $e');
      _setError('Failed to pick image: ${e.toString()}');
    }
  }

  // Helper methods
  void clearSelectedMarket() {
    _selectedMarket = null;
    notifyListeners();
  }

  void _clearSelectedImage() {
    _selectedImageFile = null;
    _selectedImageBytes = null;
    _selectedImageXFile = null;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setSubmitting(bool submitting) {
    _isSubmitting = submitting;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = '';
    notifyListeners();
  }

  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }

  void setSubmitting(bool value) {
    _isSubmitting = value;
    notifyListeners();
  }
}