import 'package:dio/dio.dart';
import 'package:hanouty/Core/Utils/secure_storage.dart';
import 'package:hanouty/Presentation/normalmarket/Data/models/normalmarket_model.dart';
import 'package:hanouty/Presentation/normalmarket/Data/models/share_fractions_model.dart';

import 'package:http_parser/http_parser.dart';

abstract class NormalMarketRemoteDataSource {
  Future<List<NormalMarketModel>> getNormalMarkets();
  Future<NormalMarketModel> getNormalMarketById(String id);
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
  NormalMarketRemoteDataSourceImpl(this._secureStorageService, {required this.dio
  });


@override
Future<List<NormalMarketModel>> getNormalMarkets() async {

  try {
    print('DataSource: Sending API request to fetch markets');
    final response = await dio.get('');
    print('DataSource: API Response received: ${response.statusCode}');
    
    if (response.data == null) {
      throw Exception('API returned null data');
    }
    
    final List<dynamic> marketList = response.data;
    print('DataSource: Processing ${marketList.length} markets');
    
    final markets = <NormalMarketModel>[];
    
    for (var marketJson in marketList) {
      try {
        final market = NormalMarketModel.fromJson(marketJson);
        markets.add(market);
      } catch (e) {
        // Log error but continue processing other markets
        print('Error parsing market: $e');
        print('Problematic market data: $marketJson');
      }
    }
    
    print('DataSource: Successfully processed ${markets.length} markets');
    return markets;
  } on DioException catch (e) {
    print('DioException: ${e.type} - ${e.message}');
    if (e.response != null) {
      print('Response status: ${e.response?.statusCode}');
      print('Response data: ${e.response?.data}');
    }
    throw Exception('Network error: ${e.message}');
  } catch (e, stackTrace) {
    print('General error: $e');
    print('Stack trace: $stackTrace');
    
   
    
    throw Exception('Failed to fetch markets: ${e.toString()}');
  }
}


  @override
  Future<NormalMarketModel> getNormalMarketById(String id) async {
    try {
      final response = await dio.get('/$id');
      return NormalMarketModel.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioException(e, 'Failed to fetch market');
    } catch (e) {
      throw Exception('Failed to fetch market: ${e.toString()}');
    }
  }

  @override
  Future<NormalMarketModel> createNormalMarket(
      NormalMarketModel market, String imagePath) async {
    final token = await _secureStorageService.getAccessToken();
    print(token);
    try {
      // Create form data for multipart request
      FormData formData = FormData.fromMap({
        'owner':    '67ce1c9c76a9aab8d26df7dd',
        'products': market.products,
        'marketName': market.marketName,
        'marketType': 'normal',
        'marketLocation': market.marketLocation,
        'marketWalletPublicKey': market.marketWalletPublicKey,
        'marketWalletSecretKey': market.marketWalletSecretKey,
        'fractions': market.fractions,
      });

      // Add optional fields
      if (market.marketPhone != null)
        formData.fields.add(MapEntry('marketPhone', market.marketPhone!));
      if (market.marketEmail != null)
        formData.fields.add(MapEntry('marketEmail', market.marketEmail!));

      // Add image file
      formData.files.add(MapEntry(
        'marketImage',
        await MultipartFile.fromFile(
          imagePath,
          filename: 'market_image.jpg',
          contentType: MediaType('image', 'jpeg'),
        ),
      ));

      final response = await dio.post(
        '',
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
          headers: {

            'Accept': 'application/json',
          },
        ),
      );

      // Log the response data
      print('Market creation response: ${response.data}');
      print('Response status code: ${response.statusCode}');

      return NormalMarketModel.fromJson(response.data);
    } on DioException catch (e) {
      // Log error response if available
      if (e.response != null) {
        print('Error response: ${e.response?.data}');
        print('Error status code: ${e.response?.statusCode}');
      }
      throw _handleDioException(e, 'Failed to create market');
    } catch (e) {
      print('Unexpected error: $e');
      throw Exception('Failed to create market: ${e.toString()}');
    }
  }

  @override
  Future<NormalMarketModel> updateNormalMarket(

      String id, NormalMarketModel market, String? imagePath) async {
    final token = await _secureStorageService.getAccessToken();
    try {
      Map<String, dynamic> formMap = {
        'marketName': market.marketName,
        'marketLocation': market.marketLocation,
      };

      // Add optional fields
      if (market.marketPhone != null)
        formMap['marketPhone'] = market.marketPhone;
      if (market.marketEmail != null)
        formMap['marketEmail'] = market.marketEmail;

      // Only add image if provided
      FormData formData;
      if (imagePath != null) {
        formData = FormData.fromMap({
          ...formMap,
          'marketImage': await MultipartFile.fromFile(
            imagePath,
            filename: 'market_image.jpg',
            contentType: MediaType('image', 'jpeg'),
          ),
        });
      } else {
        formData = FormData.fromMap(formMap);
      }

      final response = await dio.patch(
        '/$id',
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );

      return NormalMarketModel.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioException(e, 'Failed to update market');
    } catch (e) {
      throw Exception('Failed to update market: ${e.toString()}');
    }
  }

  @override
  Future<NormalMarketModel> deleteNormalMarket(String id) async {
    try {
      final response = await dio.delete('/$id');
      return NormalMarketModel.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioException(e, 'Failed to delete market');
    } catch (e) {
      throw Exception('Failed to delete market: ${e.toString()}');
    }
  }

  @override
  Future<NormalMarketModel> createNFTForMarket(String id) async {
    try {
      final response = await dio.post('/$id/create-nft');
      return NormalMarketModel.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioException(e, 'Failed to create NFT');
    } catch (e) {
      throw Exception('Failed to create NFT: ${e.toString()}');
    }
  }

  @override
  Future<Map<String, dynamic>> shareFractionalNFT(
      String id, ShareFractionRequestModel requestModel) async {
    try {
      final response = await dio.post(
        '/$id/share',
        data: requestModel.toJson(),
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      return response.data;
    } on DioException catch (e) {
      throw _handleDioException(e, 'Failed to share fractional NFT');
    } catch (e) {
      throw Exception('Failed to share fractional NFT: ${e.toString()}');
    }
  }

  // Helper method to handle Dio exceptions with better error messages
  Exception _handleDioException(DioException e, String defaultMessage) {
    String errorMessage = defaultMessage;

    if (e.response != null) {
      // Try to extract error message from response
      try {
        final responseData = e.response?.data;
        if (responseData is Map<String, dynamic> &&
            responseData.containsKey('message')) {
          errorMessage = '$defaultMessage: ${responseData['message']}';
        } else if (responseData is String) {
          errorMessage = '$defaultMessage: $responseData';
        }
      } catch (_) {
        // If error extraction fails, use status code
        errorMessage = '$defaultMessage: Status ${e.response?.statusCode}';
      }
    } else if (e.type == DioExceptionType.connectionTimeout) {
      errorMessage = '$defaultMessage: Connection timeout';
    } else if (e.type == DioExceptionType.receiveTimeout) {
      errorMessage = '$defaultMessage: Server is taking too long to respond';
    } else if (e.type == DioExceptionType.connectionError) {
      errorMessage = '$defaultMessage: No internet connection';
    }

    return Exception(errorMessage);
  }
}
