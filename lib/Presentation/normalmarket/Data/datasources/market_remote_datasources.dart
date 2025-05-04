import 'dart:convert';
import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:hanouty/Core/Utils/secure_storage.dart';
import 'package:hanouty/Presentation/normalmarket/Data/models/normalmarket_model.dart';
import 'package:hanouty/Presentation/normalmarket/Data/models/share_fractions_model.dart';
import 'package:http_parser/http_parser.dart';
import 'dart:typed_data';

// We need to use different import strategies for web vs mobile
// For conditional imports, we'll use different prefixes
import 'package:hanouty/Core/Utils/platform_imports.dart';

abstract class NormalMarketRemoteDataSource {
  Future<List<NormalMarketModel>> getNormalMarkets();
  Future<NormalMarketModel> getNormalMarketById(String id);
  Future<List<NormalMarketModel>> getMyNormalMarkets();
  Future<NormalMarketModel> createNormalMarket(
      NormalMarketModel market, String imagePath);
  Future<NormalMarketModel> updateNormalMarket(
      String id, NormalMarketModel market, String? imagePath);
  Future<NormalMarketModel> deleteNormalMarket(String id);
  Future<NormalMarketModel> createNFTForMarket(String id);
  Future<Map<String, dynamic>> shareFractionalNFT(
      String id, ShareFractionRequestModel requestModel);
}

class NormalMarketRemoteDataSourceImpl implements NormalMarketRemoteDataSource {
  final Dio dio;
  final SecureStorageService _secureStorageService;

  NormalMarketRemoteDataSourceImpl(this._secureStorageService, {required this.dio});

  // Helper method to get auth headers
  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await _secureStorageService.getAccessToken();
    return {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    };
  }

  // Platform-agnostic image processing method
  Future<MultipartFile> _processImage(String imagePath) async {
    try {
      print('📸 Processing image path: $imagePath');

      // Handle Data URLs (works on both platforms)
      if (imagePath.startsWith('data:')) {
        // Extract the base64 data from the Data URL
        final String base64Data = imagePath.split(',')[1];
        final List<int> bytes = base64Decode(base64Data);

        return MultipartFile.fromBytes(
          bytes,
          filename: 'market_image_${DateTime.now().millisecondsSinceEpoch}.jpg',
          contentType: MediaType('image', 'jpeg'),
        );
      }

      // Platform-specific handling
      if (kIsWeb) {
        return _processWebImage(imagePath);
      } else {
        return _processMobileImage(imagePath);
      }
    } catch (e) {
      print('❌ Error processing image: $e');
      throw Exception('Failed to process image: $e');
    }
  }

  // Web-specific image processing
  Future<MultipartFile> _processWebImage(String imagePath) async {
    // Handle Blob URLs
    if (imagePath.startsWith('blob:')) {
      try {
        return PlatformHelper.processBlobUrl(
          imagePath,
          'market_image_${DateTime.now().millisecondsSinceEpoch}.jpg',
        );
      } catch (e) {
        throw Exception('Error processing blob URL: $e');
      }
    }
    // Handle File objects (for web file input)
    else if (imagePath.startsWith('File:')) {
      try {
        return PlatformHelper.processFileObject(imagePath);
      } catch (e) {
        throw Exception('Error processing File object: $e');
      }
    }
    else {
      throw Exception('Unsupported image path format for web. Path must start with "data:", "blob:", or "File:"');
    }
  }

  // Mobile-specific image processing
  Future<MultipartFile> _processMobileImage(String imagePath) async {
    // Handle file paths
    if (imagePath.startsWith('/') || imagePath.contains('://')) {
      try {
        return PlatformHelper.processFilePath(imagePath);
      } catch (e) {
        throw Exception('Error processing local file path: $e');
      }
    }
    else {
      throw Exception('Unsupported image path format for mobile: $imagePath');
    }
  }

  // The rest of your implementation remains the same
  @override
  Future<NormalMarketModel> createNormalMarket(
      NormalMarketModel market, String imagePath) async {
    try {
      print('📸 Image path: $imagePath');

      // Create form data for multipart request
      FormData formData = FormData.fromMap({
        'products': market.products,
        'marketName': market.marketName,
        'marketType': 'normal',
        'marketLocation': market.marketLocation,
        if (market.marketWalletPublicKey?.isNotEmpty == true)
          'marketWalletPublicKey': market.marketWalletPublicKey,
        if (market.marketWalletSecretKey?.isNotEmpty == true)
          'marketWalletSecretKey': market.marketWalletSecretKey,
        if (market.marketPhone != null && market.marketPhone!.isNotEmpty)
          'marketPhone': market.marketPhone,
        if (market.marketEmail != null && market.marketEmail!.isNotEmpty)
          'marketEmail': market.marketEmail,
      });

      // Process and add image using platform-agnostic method
      final imageFile = await _processImage(imagePath);
      formData.files.add(MapEntry('marketImage', imageFile));

      // Get auth headers
      final headers = await _getAuthHeaders();
      print('🔐 Adding auth headers: ${headers.toString()}');

      final response = await dio.post(
        '',
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
          headers: headers,
          responseType: ResponseType.json,
          // Add longer timeout for market creation
          sendTimeout: const Duration(minutes: 2),
          receiveTimeout: const Duration(minutes: 2),
        ),
      );

      print('✅ Market creation response status: ${response.statusCode}');
      print('📄 Response data: ${response.data}');

      if (response.data == null) {
        throw Exception('Server returned null response after market creation');
      }

      return NormalMarketModel.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioException(e, 'Failed to create market');
    } catch (e) {
      print('❌ Error creating market: $e');
      throw Exception('Failed to create market: $e');
    }
  }

  @override
  Future<NormalMarketModel> updateNormalMarket(
      String id, NormalMarketModel market, String? imagePath) async {
    try {
      print('🔄 Updating market with ID: $id');

      // Create form data for multipart request with only the updatable fields
      Map<String, dynamic> formDataMap = {
        'marketName': market.marketName,
        'marketLocation': market.marketLocation,
      };

      if (market.marketPhone != null && market.marketPhone!.isNotEmpty) {
        formDataMap['marketPhone'] = market.marketPhone;
      }
      if (market.marketEmail != null && market.marketEmail!.isNotEmpty) {
        formDataMap['marketEmail'] = market.marketEmail;
      }

      // Create FormData object
      FormData formData = FormData.fromMap(formDataMap);

      // Add image if provided
      if (imagePath != null) {
        final imageFile = await _processImage(imagePath);
        formData.files.add(MapEntry('marketImage', imageFile));
      }

      final headers = await _getAuthHeaders();
      final response = await dio.patch(
        '/$id',
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
          headers: headers,
        ),
      );

      if (response.data == null) {
        throw Exception('Server returned null response after market update');
      }

      return NormalMarketModel.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioException(e, 'Failed to update market');
    } catch (e) {
      print('❌ Error updating market: $e');
      throw Exception('Failed to update market: $e');
    }
  }

  // Rest of your methods remain unchanged
  // ...

  @override
  Future<List<NormalMarketModel>> getNormalMarkets() async {
    try {
      print('🔍 DataSource: Fetching all markets');
      final response = await dio.get('');
      print('✅ DataSource: API Response received: ${response.statusCode}');

      if (response.data == null) {
        print('❌ DataSource: API returned null data');
        return [];
      }

      final List<dynamic> marketList = response.data;
      print('📊 DataSource: Processing ${marketList.length} markets');

      final markets = <NormalMarketModel>[];

      for (var marketJson in marketList) {
        try {
          final market = NormalMarketModel.fromJson(marketJson);
          markets.add(market);
        } catch (e) {
          print('❌ Error parsing market: $e');
          print('🧩 Problematic market data: $marketJson');
        }
      }

      print('✅ DataSource: Successfully processed ${markets.length} markets');
      return markets;
    } on DioException catch (e) {
      _logDioError('getNormalMarkets', e);
      throw Exception('Network error: ${e.message}');
    } catch (e, stackTrace) {
      print('❌ General error: $e');
      print('📚 Stack trace: $stackTrace');
      throw Exception('Failed to fetch markets: ${e.toString()}');
    }
  }

  @override
  Future<NormalMarketModel> getNormalMarketById(String id) async {
    try {
      print('🔍 DataSource: Fetching market with ID: $id');
      final headers = await _getAuthHeaders();

      final response = await dio.get(
        '/$id',
        options: Options(headers: headers),
      );

      print('✅ DataSource: Market fetched successfully');

      if (response.data == null) {
        throw Exception('Server returned null response');
      }

      return NormalMarketModel.fromJson(response.data);
    } on DioException catch (e) {
      _logDioError('getNormalMarketById', e);
      throw _handleDioException(e, 'Failed to fetch market');
    } catch (e) {
      print('❌ Error fetching market by ID: $e');
      throw Exception('Failed to fetch market: ${e.toString()}');
    }
  }

  @override
  Future<NormalMarketModel> deleteNormalMarket(String id) async {
    try {
      print('🗑️ Deleting market with ID: $id');
      final headers = await _getAuthHeaders();

      final response = await dio.delete(
        '/$id',
        options: Options(headers: headers),
      );

      print('✅ Market deletion successful');
      print('📊 Response data: ${response.data}');

      if (response.data == null) {
        throw Exception('Server returned null response after market deletion');
      }

      return NormalMarketModel.fromJson(response.data);
    } on DioException catch (e) {
      _logDioError('deleteNormalMarket', e);
      throw _handleDioException(e, 'Failed to delete market');
    } catch (e) {
      print('❌ Error deleting market: $e');
      throw Exception('Failed to delete market: ${e.toString()}');
    }
  }

  @override
  Future<NormalMarketModel> createNFTForMarket(String id) async {
    try {
      print('🖼️ Creating NFT for market with ID: $id');
      final headers = await _getAuthHeaders();

      final response = await dio.post(
        '/$id/create-nft',
        options: Options(headers: headers),
      );

      print('✅ NFT creation successful');
      print('📊 Response data: ${response.data}');

      if (response.data == null) {
        throw Exception('Server returned null response after NFT creation');
      }

      return NormalMarketModel.fromJson(response.data);
    } on DioException catch (e) {
      _logDioError('createNFTForMarket', e);
      throw _handleDioException(e, 'Failed to create NFT');
    } catch (e) {
      print('❌ Error creating NFT: $e');
      throw Exception('Failed to create NFT: ${e.toString()}');
    }
  }

  @override
  Future<List<NormalMarketModel>> getMyNormalMarkets() async {
    try {
      print('🔍 DataSource: Fetching markets for authenticated user');
      final headers = await _getAuthHeaders();

      final response = await dio.get(
        '/my-markets', // Endpoint for user's own markets
        options: Options(headers: headers),
      );

      print('✅ DataSource: API Response received: ${response.statusCode}');

      if (response.data == null) {
        print('❌ DataSource: API returned null data');
        return [];
      }

      final List<dynamic> marketList = response.data;
      print('📊 DataSource: Processing ${marketList.length} markets owned by user');

      final markets = <NormalMarketModel>[];

      for (var marketJson in marketList) {
        try {
          final market = NormalMarketModel.fromJson(marketJson);
          markets.add(market);
        } catch (e) {
          print('❌ Error parsing market: $e');
          print('🧩 Problematic market data: $marketJson');
        }
      }

      print('✅ DataSource: Successfully processed ${markets.length} markets owned by user');
      return markets;
    } on DioException catch (e) {
      _logDioError('getMyNormalMarkets', e);
      throw _handleDioException(e, 'Failed to fetch your markets');
    } catch (e, stackTrace) {
      print('❌ General error in getMyNormalMarkets: $e');
      print('📚 Stack trace: $stackTrace');
      throw Exception('Failed to fetch your markets: ${e.toString()}');
    }
  }

  @override
  Future<Map<String, dynamic>> shareFractionalNFT(
      String id, ShareFractionRequestModel requestModel) async {
    try {
      print('🔄 Sharing fractional NFT for market with ID: $id');
      print('📦 Share data: ${requestModel.toJson()}');

      final headers = await _getAuthHeaders();
      headers['Content-Type'] = 'application/json';

      final response = await dio.post(
        '/$id/share',
        data: requestModel.toJson(),
        options: Options(headers: headers,
          sendTimeout: const Duration(minutes: 2),
          receiveTimeout: const Duration(minutes: 2),

        ),


      );

      print('✅ NFT sharing API call completed');
      print('📊 Response data: ${response.data}');

      if (response.data == null) {
        throw Exception('Server returned null response after sharing NFT');
      }

      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      _logDioError('shareFractionalNFT', e);

      if (e.response?.data != null) {
        var responseData = e.response!.data;

        if (responseData is String && responseData.isNotEmpty) {
          try {
            responseData = jsonDecode(responseData);
          } catch (_) {
          }
        }

        if (responseData is Map<String, dynamic>) {
          return {
            'success': false,
            'message': responseData['message'] ?? 'An error occurred',
            'error': responseData['error'],
            'data': responseData['data'],
          };
        }
      }

      throw _handleDioException(e, 'Failed to share fractional NFT');
    } catch (e) {
      print('❌ Error sharing fractional NFT: $e');
      throw Exception('Failed to share fractional NFT: ${e.toString()}');
    }
  }

  // Helper method to handle Dio exceptions with better error messages
  Exception _handleDioException(DioException e, String defaultMessage) {
    String errorMessage = defaultMessage;

    if (e.response != null) {
      // Handle specific status codes
      switch (e.response?.statusCode) {
        case 401:
          return Exception('$defaultMessage: Authentication failed. Please log in again.');
        case 403:
          return Exception('$defaultMessage: You do not have permission to perform this action.');
        case 404:
          return Exception('$defaultMessage: The requested resource was not found.');
        case 422:
          return Exception('$defaultMessage: Validation failed. Please check your data.');
      }

      // Try to extract error message from response
      try {
        final responseData = e.response?.data;
        if (responseData is Map<String, dynamic>) {
          if (responseData.containsKey('message')) {
            errorMessage = '$defaultMessage: ${responseData['message']}';
          } else if (responseData.containsKey('error')) {
            errorMessage = '$defaultMessage: ${responseData['error']}';
          }
        } else if (responseData is String) {
          errorMessage = '$defaultMessage: $responseData';
        }
      } catch (_) {
        errorMessage = '$defaultMessage: Status code ${e.response?.statusCode}';
      }
    } else {
      // Handle different error types
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
          errorMessage = '$defaultMessage: Connection timeout. Check your internet connection.';
          break;
        case DioExceptionType.receiveTimeout:
          errorMessage = '$defaultMessage: Server is taking too long to respond. Please try again later.';
          break;
        case DioExceptionType.sendTimeout:
          errorMessage = '$defaultMessage: Sending request timeout. Check your internet connection.';
          break;
        case DioExceptionType.connectionError:
          errorMessage = '$defaultMessage: No internet connection. Please check your network.';
          break;
        case DioExceptionType.badCertificate:
          errorMessage = '$defaultMessage: SSL certificate validation failed.';
          break;
        case DioExceptionType.badResponse:
          errorMessage = '$defaultMessage: Server returned invalid response.';
          break;
        case DioExceptionType.cancel:
          errorMessage = '$defaultMessage: Request was canceled.';
          break;
        case DioExceptionType.unknown:
        default:
          errorMessage = '$defaultMessage: An unknown error occurred.';
          break;
      }
    }

    print('🚫 Error: $errorMessage');
    return Exception(errorMessage);
  }

  // Helper method to log Dio errors in a structured way
  void _logDioError(String method, DioException e) {
    print('❌ DIO ERROR in $method:');
    print('  Type: ${e.type}');
    print('  Message: ${e.message}');

    if (e.response != null) {
      print('  Status: ${e.response?.statusCode}');
      print('  Response data: ${e.response?.data}');
      print('  Headers: ${e.response?.headers}');
    }

    if (e.requestOptions != null) {
      print('  Request path: ${e.requestOptions.path}');
      print('  Request method: ${e.requestOptions.method}');
      print('  Request headers: ${e.requestOptions.headers}');
      print('  Request data: ${e.requestOptions.data}');
    }

    // Log stack trace if available
    if (e.stackTrace != null) {
      print('  Stack trace: ${e.stackTrace}');
    }
  }
}