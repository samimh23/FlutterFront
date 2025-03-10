
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hanouty/Core/heritables/Markets.dart';
import 'package:hanouty/Presentation/normalmarket/Data/models/normalmarket_model.dart';
import 'package:hanouty/Presentation/normalmarket/Domain/entities/share_fraction.dart';
import 'package:hanouty/Presentation/normalmarket/Domain/usecases/create_fractional_nft.dart';
import 'package:hanouty/Presentation/normalmarket/Domain/usecases/give_shares.dart';
import 'package:hanouty/Presentation/normalmarket/Domain/usecases/market_add.dart';
import 'package:hanouty/Presentation/normalmarket/Domain/usecases/market_delete.dart';
import 'package:hanouty/Presentation/normalmarket/Domain/usecases/market_getall.dart';
import 'package:hanouty/Presentation/normalmarket/Domain/usecases/market_getbyid.dart';
import 'package:hanouty/Presentation/normalmarket/Domain/usecases/market_update.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:typed_data';

class NormalMarketProvider extends ChangeNotifier {
  final GetNormalMarkets getNormalMarkets;
  final GetNormalMarketById getNormalMarketById;
  final CreateNormalMarket createNormalMarket;
  final UpdateNormalMarket updateNormalMarket;
  final DeleteNormalMarket deleteNormalMarket;
  final ShareFractionalNFT shareFractionalNFT;
  final CreateFractionalNFT createFractionalNFT;

  NormalMarketProvider({
    required this.getNormalMarkets,
    required this.getNormalMarketById,
    required this.createNormalMarket,
    required this.updateNormalMarket,
    required this.deleteNormalMarket,
    required this.shareFractionalNFT,
    required this.createFractionalNFT,
  }) {
    // Initialize by loading markets
    loadMarkets();
  }

  // State variables
  List<Markets> _markets = [];
  Markets? _selectedMarket;
  bool _isLoading = false;
  String _errorMessage = '';
  File? _selectedImageFile; // For mobile/desktop
  Uint8List? _selectedImageBytes; // For web
  XFile? _selectedImageXFile; // Original XFile from picker
  bool _isSubmitting = false;

  // Getters
  List<Markets> get markets => _markets;
  Markets? get selectedMarket => _selectedMarket;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  File? get selectedImage => _selectedImageFile;
  Uint8List? get selectedImageBytes => _selectedImageBytes;
  String? get selectedImageName => _selectedImageXFile?.name;
  bool get isSubmitting => _isSubmitting;
  bool get hasSelectedImage =>
      _selectedImageFile != null || _selectedImageBytes != null;

  // Methods
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

  Future<bool> addMarket(NormalMarketModel market) async {
    if (!hasSelectedImage) {
      _setError('Please select a market image');
      return false;
    }

    _setSubmitting(true);
    _clearError();

    try {
      final newMarket = await createNormalMarket(
          market,
          _selectedImageFile!.path);

      _markets.add(newMarket);
      _clearSelectedImage();
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to create market: ${e.toString()}');
      return false;
    } finally {
      _setSubmitting(false);
    }
  }

  Future<bool> updateExistingMarket(String id, NormalMarketModel market) async {
    _setSubmitting(true);
    _clearError();

    try {
      final updatedMarket = await updateNormalMarket(
          id,
          market,
          _selectedImageFile?.path);

      // Update local state
      final index = _markets.indexWhere((m) => m.id == id);
      if (index != -1) {
        _markets[index] = updatedMarket;
      }

      if (_selectedMarket?.id == id) {
        _selectedMarket = updatedMarket;
      }

      _clearSelectedImage();
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to update market: ${e.toString()}');
      return false;
    } finally {
      _setSubmitting(false);
    }
  }

  Future<bool> removeMarket(String id) async {
    _setLoading(true);
    _clearError();

    try {
      await deleteNormalMarket(id);
      _markets.removeWhere((market) => market.id == id);

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

  Future<bool> createNFT(String marketId) async {
    _setLoading(true);
    _clearError();

    try {
      final updatedMarket = await createFractionalNFT(marketId);

      // Update local state
      final index = _markets.indexWhere((m) => m.id == marketId);
      if (index != -1) {
        _markets[index] = updatedMarket;
      }

      if (_selectedMarket?.id == marketId) {
        _selectedMarket = updatedMarket;
      }

      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to create NFT: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> shareNFT(
      String marketId, String recipientAddress, int percentage) async {
    _setLoading(true);
    _clearError();

    try {
      final request = ShareFractionRequest(
        recipientAddress: recipientAddress,
        percentage: percentage,
      );

      final result = await shareFractionalNFT(marketId, request);

      // Reload the market to get updated fractions
      await loadMarketById(marketId);

      return result['success'] ?? false;
    } catch (e) {
      _setError('Failed to share NFT: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> pickImage() async {
    try {
      final ImagePicker _picker = ImagePicker();
      final XFile? pickedImage = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (pickedImage != null) {
        print('Image picked: ${pickedImage.name}');
        _selectedImageXFile = pickedImage;

        // Handle differently based on platform
        if (kIsWeb) {
          // For web, read as bytes
          _selectedImageBytes = await pickedImage.readAsBytes();
          _selectedImageFile = null;
          print(
              'Web image loaded: ${_selectedImageBytes!.lengthInBytes} bytes');
        } else {
          // For mobile/desktop, use File
          _selectedImageFile = File(pickedImage.path);
          _selectedImageBytes = null;
          print(
              'File image loaded: ${await _selectedImageFile!.length()} bytes');
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
}
