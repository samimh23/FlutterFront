
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:dartz/dartz.dart';
import 'package:hanouty/Core/Utils/secure_storage.dart';
import 'package:hanouty/Core/errors/exceptions.dart';
import 'package:hanouty/Core/errors/failuresconection.dart';
import 'package:hanouty/Core/network/apiconastant.dart';
import 'package:hanouty/Presentation/product/data/models/product_model.dart';
import 'package:hanouty/Presentation/product/domain/entities/product.dart';
import 'package:hanouty/Presentation/product/domain/usecases/add_product.dart';
import 'package:hanouty/Presentation/product/domain/usecases/get_all_product.dart';
import 'package:hanouty/Presentation/product/domain/usecases/get_product_by_id.dart';
import 'package:hanouty/Presentation/product/domain/usecases/update_product.dart';
import 'package:universal_html/html.dart' as html;
import 'package:dio/dio.dart';
import 'dart:math' as math;

class ProductProvider extends ChangeNotifier {
  final GetAllProductUseCase getAllProductUseCase;
  final GetProductById getProductById;
  final AddProductUseCase? addProductUseCase;
  final UpdateProductUseCase? updateProductUseCase;
  final SecureStorageService _secureStorage;
  ProductProvider(this._secureStorage, {
    required this.getAllProductUseCase,
    required this.getProductById,
    required this.addProductUseCase,
    required this.updateProductUseCase,
  }) {
    print('[ProductProvider] Initialized');
  }
final String apiUrl = ApiConstants.baseUrl;
  List<Product> _products = [];
  bool _isLoading = false;
  String _errorMessage = '';

  bool _isSubmitting = false;
  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
bool get isSubmitting => _isSubmitting;
List<Product> _filteredProducts = [];

  List<Product> get filteredProducts => _filteredProducts;
Future<String?> getToken() async {
    try {
      print('[ProductProvider] getToken: Retrieving token from secure storage');
      final token = await _secureStorage.getAccessToken();
      if (token == null || token.isEmpty) {
        print('[ProductProvider] getToken: No token found in secure storage');
        return null;
      }
      print('[ProductProvider] getToken: Token retrieved successfully: ${token.toString()}');
      return token;
    } catch (e) {
      print('[ProductProvider] ERROR: Failed to get token: $e');
      return null;
    }
  }

  /// Search products by name.
  void searchProducts(String query) {
    if (query.isEmpty) {
      _filteredProducts = _products;
    } else {
      _filteredProducts = _products.where((product) {
        return product.name.toLowerCase().contains(query.toLowerCase());
      }).toList();
    }
    notifyListeners();
  }
Future<bool> deleteProduct(String productId) async {
    print('[ProductProvider] Deleting product with ID: $productId');
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final token = await getToken();
      if (token == null) {
        throw Exception("Authentication token not available");
      }

      final dio = Dio();
      dio.options.headers['Authorization'] = 'Bearer $token';

      final response = await dio.delete('$apiUrl/product/$productId');

      if (response.statusCode == 200) {
        print('[ProductProvider] Product deleted successfully');
        // Remove from local list
        _products.removeWhere((product) => product.id == productId);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        throw Exception('Failed to delete product: ${response.statusCode}');
      }
    } catch (e) {
      print('[ProductProvider] ERROR deleting product: $e');
      if (e is DioException && e.response != null) {
        _errorMessage = 'Server error: ${e.response?.statusCode}';
      } else {
        _errorMessage = 'Failed to delete product: ${e.toString()}';
      }
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  Map<String, dynamic> createProductDto(ProductModel product) {
    print('[ProductProvider] createProductDto: Creating DTO for product: ${product.name}');
    try {
      final dto = {
        'name': product.name,
        'description': product.description,
        'originalPrice': product.originalPrice,
        'category': ProductModel.productCategoryToString(product.category),
        'stock': product.stock,
        'image': product.image,
        'shop': product.shop,
      };
      print('[ProductProvider] createProductDto: Successfully created DTO with fields: ${dto.keys.join(", ")}');
      return dto;
    } catch (e) {
      print('[ProductProvider] ERROR: Failed to create product DTO: $e');
      rethrow;
    }
  }
  /// Fetches products and updates state.
  Future<void> fetchProducts() async {
    // Prevent concurrent requests
    if (_isLoading) return;

    _isLoading = true;
    _errorMessage = ''; // Clear previous errors
    notifyListeners();

    final Either<Failure, List<Product>> result = await getAllProductUseCase();

    result.fold(
      (failure) {
        _errorMessage = _mapFailureToMessage(failure);
        // Optionally keep old data: comment next line to preserve previous products
        _products = [];
      },
      (products) {
        _products = products;
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  Future<Product?> fetchProductById(String id) async {
    _isLoading = true;
    _errorMessage = ''; // Clear previous errors
    notifyListeners();

    final Either<Failure, Product> result = await getProductById(id);

    Product? product;
    result.fold(
      (failure) {
        _errorMessage = _mapFailureToMessage(failure);
        product = null;
      },
      (fetchedProduct) {
        product = fetchedProduct;
      },
    );

    _isLoading = false;
    notifyListeners();
    return product;
  }
  Future<String> _processImageFile(html.File file, {double quality = 0.7, int maxWidth = 800, int maxHeight = 800}) async {
    try {
      print('[ProductProvider] Processing image file: ${file.name} (${file.size ~/ 1024} KB)');

      // Create a Blob URL for the file
      final objectUrl = html.Url.createObjectUrl(file);

      // Load the image to get its dimensions
      final img = html.ImageElement(src: objectUrl);
      await img.onLoad.first;

      // Calculate new dimensions while maintaining aspect ratio
      int targetWidth = img.width ?? 800;
      int targetHeight = img.height ?? 800;

      if (targetWidth > maxWidth || targetHeight > maxHeight) {
        if (targetWidth > targetHeight) {
          targetHeight = (maxWidth * targetHeight / targetWidth).round();
          targetWidth = maxWidth;
        } else {
          targetWidth = (maxHeight * targetWidth / targetHeight).round();
          targetHeight = maxHeight;
        }
      }

      // Create canvas and draw resized image
      final canvas = html.CanvasElement(width: targetWidth, height: targetHeight);
      final ctx = canvas.context2D;
      ctx.drawImageScaled(img, 0, 0, targetWidth, targetHeight);

      // Convert to compressed JPEG data URL
      final mimeType = 'image/jpeg';
      final dataUrl = canvas.toDataUrl(mimeType, quality);

      // Clean up
      html.Url.revokeObjectUrl(objectUrl);

      // Calculate size reduction
      final base64String = dataUrl.split(',')[1];
      final compressedSize = base64String.length * 0.75 ~/ 1024;
      print('[ProductProvider] Image processed: ${targetWidth}x${targetHeight}, ~$compressedSize KB');

      return dataUrl;
    } catch (e) {
      print('[ProductProvider] ERROR processing image: $e');
      throw Exception('Failed to process image: $e');
    }
  }

  /// Creates a new product with image using direct JSON upload with base64 image
  Future<bool> addProductWithImageData(Map<String, dynamic> productData, Map<String, dynamic>? imageData) async {
    print('\n[ProductProvider] ===== ADD PRODUCT WITH IMAGE DATA OPERATION STARTED =====');
    print('[ProductProvider] addProductWithImageData: Attempting to add product:');
    print('[ProductProvider] - Name: ${productData['name']}');
    print('[ProductProvider] - Has new image: ${imageData != null}');

    _isSubmitting = true;
    _errorMessage = '';
    notifyListeners();

    try {
      // Get authentication token
      final token = await getToken();
      if (token == null) {
        throw Exception("Authentication token not available");
      }

      // Create API client
      final dio = Dio();
      dio.options.headers['Authorization'] = 'Bearer $token';
      dio.options.headers['Content-Type'] = 'application/json';

      // Prepare product data with correct types
      final Map<String, dynamic> productJson = {
        'name': productData['name'],
        'description': productData['description'],
        'originalPrice': double.parse(productData['originalPrice'].toString()),
        'category': productData['category'],
        'stock': int.parse(productData['stock'].toString()),
        'shop': productData['shop'],
      };

      // Process image if provided
      if (imageData != null) {
        print('[ProductProvider] Processing image for upload');

        try {
          final htmlFile = imageData['file'] as html.File;

          // Process and optimize the image
          final dataUrl = await _processImageFile(
              htmlFile,
              quality: 0.7,  // 70% quality for good balance of size/quality
              maxWidth: 800,
              maxHeight: 800
          );

          // Add the image data to the product JSON
          productJson['image'] = dataUrl;

          print('[ProductProvider] Image processed and added to request data');
        } catch (e) {
          print('[ProductProvider] ERROR processing image: $e');
          throw Exception('Failed to process image: $e');
        }
      } else {
        print('[ProductProvider] WARNING: No image data provided');
        throw Exception('Image is required for creating a product');
      }

      // Send request with product data
      print('[ProductProvider] Sending product data to API at $apiUrl/product');
      final response = await dio.post(
        '$apiUrl/product',
        data: productJson,
      );

      print('[ProductProvider] API Response: ${response.statusCode}');

      // Check response
      if (response.statusCode == 200 || response.statusCode == 201) {
        print('[ProductProvider] Product created successfully!');
        fetchProducts(); // Refresh product list
        _isSubmitting = false;
        notifyListeners();
        return true;
      } else {
        throw Exception('Unexpected response status: ${response.statusCode}');
      }
    } catch (e) {
      print('[ProductProvider] ERROR adding product: $e');

      // Handle DioException specifically
      if (e is DioException) {
        if (e.response != null) {
          print('[ProductProvider] Server response: ${e.response?.statusCode} - ${e.response?.data}');

          // Extract error message
          if (e.response?.data is Map && e.response?.data['message'] != null) {
            _errorMessage = e.response?.data['message'];
            if (_errorMessage is List) {
              _errorMessage = (_errorMessage as List).join(', ');
            }
          } else {
            _errorMessage = 'Server error: ${e.response?.statusCode}';
          }
        } else {
          _errorMessage = 'Network error: ${e.message}';
        }
      } else {
        _errorMessage = 'Error: ${e.toString()}';
      }

      _isSubmitting = false;
      notifyListeners();
      print('[ProductProvider] ===== ADD PRODUCT WITH IMAGE DATA OPERATION FAILED =====');
      return false;
    }
  }

  /// Updates an existing product with image
  /// Updates an existing product with image
  Future<bool> updateProductWithImageData(String productId, Map<String, dynamic> productData, Map<String, dynamic>? imageData, String? existingImageUrl) async {
    print('\n[ProductProvider] ===== UPDATE PRODUCT WITH IMAGE DATA OPERATION STARTED =====');
    print('[ProductProvider] updateProductWithImageData for ID: $productId');

    _isSubmitting = true;
    _errorMessage = '';
    notifyListeners();

    try {
      // Get authentication token
      final authToken = await getToken();
      if (authToken == null) {
        throw Exception("Authentication token not available");
      }

      // Create API client
      final dio = Dio();
      dio.options.headers['Authorization'] = 'Bearer $authToken';
      dio.options.headers['Content-Type'] = 'application/json';

      // Create a map with the product data
      final Map<String, dynamic> updateData = {};

      // Copy all fields from productData that have values
      ['name', 'description', 'originalPrice', 'category', 'stock', 'shop', 'isDiscounted', 'DiscountValue'].forEach((field) {
        if (productData.containsKey(field) && productData[field] != null) {
          updateData[field] = productData[field];
        }
      });

      // Process image if provided
      if (imageData != null && imageData['file'] != null) {
        try {
          final htmlFile = imageData['file'] as html.File;

          // Convert the file to base64 using FileReader instead of arrayBuffer
          final completer = Completer<String>();
          final reader = html.FileReader();

          reader.onLoad.listen((_) {
            final result = reader.result as String;
            completer.complete(result);
          });

          reader.onError.listen((error) {
            completer.completeError('Error reading file: $error');
          });

          // Read as data URL (this automatically gives us a base64 image)
          reader.readAsDataUrl(htmlFile);

          // Wait for the file to be read
          final dataUrl = await completer.future;

          // Add the image data to the update data
          updateData['image'] = dataUrl;
          print('[ProductProvider] Image processed and added to update data');
        } catch (e) {
          print('[ProductProvider] ERROR processing image: $e');
          throw Exception('Failed to process image: $e');
        }
      } else if (existingImageUrl != null && existingImageUrl.isNotEmpty) {
        // Use network image if no new image but has existing image
        if (existingImageUrl.startsWith('http')) {
          updateData['networkImage'] = existingImageUrl;
          print('[ProductProvider] Using networkImage: $existingImageUrl');
        } else {
          updateData['image'] = existingImageUrl;
          print('[ProductProvider] Using existing image path: $existingImageUrl');
        }
      }

      // Ensure we're not sending an empty object
      if (updateData.isEmpty) {
        print('[ProductProvider] WARNING: No data to update, adding a dummy field to avoid empty object');
        updateData['_timestamp'] = DateTime.now().millisecondsSinceEpoch.toString();
      }

      print('[ProductProvider] Sending JSON update with fields:');
      updateData.forEach((key, value) {
        print('  $key: $value');
      });

      // Send the JSON request
      final response = await dio.patch(
        '$apiUrl/product/$productId',
        data: updateData,
      );

      print('[ProductProvider] Update successful! Response status: ${response.statusCode}');

      // Refresh products list and update UI
      fetchProducts();
      _isSubmitting = false;
      notifyListeners();
      return true;
    } catch (e) {
      print('[ProductProvider] ERROR updating product: $e');

      // Handle DioException specifically
      if (e is DioException) {
        if (e.response != null) {
          print('[ProductProvider] Server response: ${e.response?.statusCode} - ${e.response?.data}');

          if (e.response?.data is Map) {
            final Map<String, dynamic> errorData = e.response?.data as Map<String, dynamic>;
            if (errorData.containsKey('message')) {
              final errorMessage = errorData['message'];
              if (errorMessage is List) {
                _errorMessage = errorMessage.join(', ');
              } else {
                _errorMessage = errorMessage.toString();
              }
            } else {
              _errorMessage = 'Server error: ${e.response?.statusCode}';
            }
          } else {
            _errorMessage = 'Server error: ${e.response?.statusCode}';
          }
        } else {
          _errorMessage = 'Network error: ${e.message}';
        }
      } else {
        _errorMessage = 'Error: ${e.toString()}';
      }

      _isSubmitting = false;
      notifyListeners();
      print('[ProductProvider] ===== UPDATE PRODUCT WITH IMAGE DATA OPERATION FAILED =====');
      return false;
    }
  }

  /// Maps specific failure types to error messages.
  String _mapFailureToMessage(Failure failure) {
    if (failure is ServerFailure) {
      return 'Server Error';
    } else if (failure is ServerException) {
      return 'Network Error: Check your internet connection.';
    } else if (failure is EmptyCachedFailure) {
      return 'Cache Error: Failed to load local data.';
    } else {
      return 'Failed to fetch products. Please try again.';
    }
  }
 



 
  /// Clears the current error message.
  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }
}