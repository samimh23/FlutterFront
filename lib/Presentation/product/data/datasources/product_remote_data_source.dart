import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:hanouty/Core/Utils/secure_storage.dart';
import 'package:hanouty/Core/errors/exceptions.dart';
import 'package:hanouty/Presentation/product/data/models/product_model.dart';
import 'package:http/http.dart' as http;
import 'dart:math' as Math;

abstract class ProductRemoteDataSource {
  Future<List<ProductModel>> getAllProducts();
  Future<Unit> deleteProduct(int id);
  Future<Unit> updateProduct(ProductModel productModel);
  Future<Unit> addProduct(ProductModel productModel);
  Future<ProductModel> getProductById(String id);
}

const BASE_URL = "http://192.168.0.223:3000/product";

class ProductRemoteDataSourceImpl extends ProductRemoteDataSource {
  final http.Client client;
  final SecureStorageService authService;

  ProductRemoteDataSourceImpl({
    required this.client,
    required this.authService,
  });

  // Helper method to get authentication headers
  Future<Map<String, String>> _getHeaders() async {
    try {
      final token = await authService.getAccessToken();
      print("🔑 ProductRemoteDataSource: Access token retrieved");
      if (token == null || token.isEmpty) {
        print("⚠️ ProductRemoteDataSource: No access token found!");
      } else {
        print("✅ ProductRemoteDataSource: Token found [${token.substring(0, Math.min(10, token.length))}...]");
      }

      final headers = {
        "Content-Type": "application/json",
        if (token != null && token.isNotEmpty) "Authorization": "Bearer $token",
      };

      print("🔍 ProductRemoteDataSource: Headers: ${headers.toString()}");
      return headers;
    } catch (e, stackTrace) {
      print("⚠️ ERROR in _getHeaders: ${e.toString()}");
      print(stackTrace);
      return {"Content-Type": "application/json"};
    }
  }

  @override
  Future<Unit> addProduct(ProductModel productModel) async {
    try {
      print("\n====== ADDING PRODUCT - START ======");
      print("📦 ProductRemoteDataSource: Adding product: ${productModel.name}");
      print("🏪 Shop/Market ID: ${productModel.shop ?? 'NULL'}");

      // Log full product details
      print("📋 PRODUCT DETAILS:");
      print("   - ID: ${productModel.id ?? 'NULL'}");
      print("   - Name: ${productModel.name}");
      print("   - Price: ${productModel.price}");
      print("   - Stock: ${productModel.stock}");
      print("   - Original Price: ${productModel.originalPrice}");
      print("   - Image: ${productModel.image != null ? 'Present' : 'NULL'}");
      print("   - Description: ${productModel.description != null ? (productModel.description!.length > 30 ? productModel.description!.substring(0, 30) + '...' : productModel.description) : 'NULL'}");
      print("   - Category: ${productModel.category != null ? ProductModel.productCategoryToString(productModel.category!) : 'NULL'}");
      print("   - Created At: ${productModel.createdAt?.toIso8601String() ?? 'NULL'}");
      print("   - Updated At: ${productModel.updatedAt?.toIso8601String() ?? 'NULL'}");
      print("   - Ratings: ${productModel.ratingsAverage ?? 'NULL'}");
      print("   - Is Discounted: ${productModel.isDiscounted}");
      print("   - Discount Value: ${productModel.discountValue}");
      print("   - Shop: ${productModel.shop ?? 'NULL'}");

      // Get token directly first for verification
      final rawToken = await authService.getAccessToken();
      print("🔐 Token verification - Raw token: ${rawToken != null ? 'Present' : 'NULL'}");
      if (rawToken != null) {
        print("🔐 Token first chars: ${rawToken.substring(0, Math.min(10, rawToken.length))}...");
      }

      // Get the headers with token
      final headers = await _getHeaders();

      // Verify Authorization header is present
      if (!headers.containsKey("Authorization")) {
        print("⛔ CRITICAL ERROR: Authorization header is missing in request!");
      } else {
        print("✅ Authorization header is present: ${headers['Authorization']?.substring(0, Math.min(20, headers['Authorization']!.length))}...");
      }

      // Create request body map first to validate
      final Map<String, dynamic> bodyMap = {
        "name": productModel.name,
        "price": productModel.price,
        "stock": productModel.stock,
        "originalPrice": productModel.originalPrice,
      };

      // Add optional fields carefully to avoid null serialization issues
      if (productModel.image != null) bodyMap["image"] = productModel.image; // FIXED: Changed from "images" to "image"
      if (productModel.description != null) bodyMap["description"] = productModel.description;
      if (productModel.category != null) {
        bodyMap["category"] = ProductModel.productCategoryToString(productModel.category!);
      }
      if (productModel.createdAt != null) bodyMap["createdAt"] = productModel.createdAt!.toIso8601String();
      if (productModel.updatedAt != null) bodyMap["updatedAt"] = productModel.updatedAt!.toIso8601String();
      if (productModel.ratingsAverage != null) bodyMap["ratings"] = productModel.ratingsAverage;

      bodyMap["isDiscounted"] = productModel.isDiscounted;
      bodyMap["DiscountValue"] = productModel.discountValue; // FIXED: Changed from "discountValue" to "DiscountValue"

      // Ensure shop ID is included if available
      if (productModel.shop != null && productModel.shop!.isNotEmpty) {
        bodyMap["shop"] = productModel.shop;
      } else {
        print("⚠️ WARNING: Shop ID is missing or empty!");
      }

      // Try to encode the body and check for any encoding issues
      String body;
      try {
        body = jsonEncode(bodyMap);
        print("✅ JSON encoding successful");
      } catch (e) {
        print("⛔ JSON ENCODING ERROR: ${e.toString()}");
        print("⚠️ Problematic fields might be:");
        bodyMap.forEach((key, value) {
          try {
            jsonEncode({key: value});
          } catch (e) {
            print("   - $key: ${value.toString()} - ERROR: ${e.toString()}");
          }
        });
        throw Exception("JSON encoding failed: ${e.toString()}");
      }

      print("📡 ProductRemoteDataSource: Sending POST request to $BASE_URL");
      print("📤 Request headers: $headers");
      print("📦 Request body sample: ${body.length > 100 ? body.substring(0, 100) + '...' : body}");

      // Make the HTTP request with try-catch for network errors
      http.Response response;
      try {
        response = await client.post(
          Uri.parse(BASE_URL),
          headers: headers,
          body: body,
        );
      } catch (e) {
        print("🌐 NETWORK ERROR: ${e.toString()}");
        throw ServerException(message: "Network error: ${e.toString()}");
      }

      // Log the complete response
      print("📢 RESPONSE STATUS: ${response.statusCode}");
      print("📢 RESPONSE HEADERS: ${response.headers}");
      print("📢 RESPONSE BODY: ${response.body}");

      // Check for authentication issues
      if (response.statusCode == 401) {
        print("🚨 UNAUTHORIZED: Server rejected the authentication token");
        throw ServerException(message: "Authentication failed: ${response.body}");
      }

      // Check for validation errors
      if (response.statusCode == 400) {
        print("⚠️ BAD REQUEST: Server validation failed");
        print("🔍 Validation errors: ${response.body}");
        throw ServerException(message: "Validation error: ${response.body}");
      }

      // Check for success response
      if (response.statusCode == 201 || response.statusCode == 200) {
        print("✅ PRODUCT ADDED SUCCESSFULLY");
        print("====== ADDING PRODUCT - SUCCESS ======\n");
        return Future.value(unit);
      } else {
        print("❌ FAILED TO ADD PRODUCT. STATUS: ${response.statusCode}");
        print("====== ADDING PRODUCT - FAILED ======\n");
        throw ServerException(message: "Server error: ${response.statusCode} - ${response.body}");
      }
    } catch (e, stackTrace) {
      print("🔥 CRITICAL ERROR ADDING PRODUCT: ${e.toString()}");
      print("STACK TRACE:");
      print(stackTrace);
      print("====== ADDING PRODUCT - ERROR ======\n");
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<Unit> deleteProduct(int id) async {
    try {
      print("🗑️ ProductRemoteDataSource: Deleting product ID: $id");
      final headers = await _getHeaders();

      print("📡 ProductRemoteDataSource: Sending DELETE request to $BASE_URL/$id");
      final response = await client.delete(
        Uri.parse("$BASE_URL/${id.toString()}"),
        headers: headers,
      );

      print("📢 ProductRemoteDataSource: Response status: ${response.statusCode}");

      if (response.statusCode == 200) {
        print("✅ ProductRemoteDataSource: Product deleted successfully");
        return Future.value(unit);
      } else {
        print("❌ ProductRemoteDataSource: Failed to delete product. Status: ${response.statusCode}");
        throw ServerException();
      }
    } catch (e) {
      print("🔥 ProductRemoteDataSource: Error deleting product: $e");
      throw ServerException();
    }
  }

  @override
  Future<List<ProductModel>> getAllProducts() async {
    try {
      print("📋 ProductRemoteDataSource: Getting all products");
      final headers = await _getHeaders();

      print("📡 ProductRemoteDataSource: Sending GET request to $BASE_URL");
      final response = await client.get(
        Uri.parse(BASE_URL),
        headers: headers,
      );

      print("📢 ProductRemoteDataSource: Response status: ${response.statusCode}");

      if (response.statusCode == 200) {
        final List decodedJson = json.decode(response.body) as List;
        print("✅ ProductRemoteDataSource: Retrieved ${decodedJson.length} products");

        final List<ProductModel> productModels =
        decodedJson
            .map<ProductModel>(
              (jsonProductModel) => ProductModel.fromJson(jsonProductModel),
        )
            .toList();
        return productModels;
      } else {
        print("❌ ProductRemoteDataSource: Failed to get products. Status: ${response.statusCode}");
        throw ServerException();
      }
    } catch (e) {
      print("🔥 ProductRemoteDataSource: Error getting products: $e");
      throw ServerException();
    }
  }

  @override
  Future<Unit> updateProduct(ProductModel productModel) async {
    try {
      print("🔄 ProductRemoteDataSource: Updating product: ${productModel.name}");
      final headers = await _getHeaders();
      final productId = productModel.id;

      final Map<String, dynamic> bodyMap = {
        "name": productModel.name,
        "price": productModel.price,
        "stock": productModel.stock,
        "originalPrice": productModel.originalPrice,
        "description": productModel.description,
        "category": ProductModel.productCategoryToString(productModel.category),
        "updatedAt": productModel.updatedAt.toIso8601String(),
        "isDiscounted": productModel.isDiscounted,
        "DiscountValue": productModel.discountValue, // FIXED: Changed from "discountValue" to "DiscountValue"
      };

      // Add image if present
      if (productModel.image != null) {
        bodyMap["image"] = productModel.image; // FIXED: Changed from "images" to "image"
      }

      final body = jsonEncode(bodyMap);

      print("📡 ProductRemoteDataSource: Sending PATCH request to $BASE_URL/$productId");
      final response = await client.patch(
        Uri.parse("$BASE_URL/$productId"),
        headers: headers,
        body: body,
      );

      print("📢 ProductRemoteDataSource: Response status: ${response.statusCode}");
      print("📢 ProductRemoteDataSource: Response body: ${response.body}");

      if (response.statusCode == 200) {
        print("✅ ProductRemoteDataSource: Product updated successfully");
        return Future.value(unit);
      } else {
        print("❌ ProductRemoteDataSource: Failed to update product. Status: ${response.statusCode}");
        throw ServerException();
      }
    } catch (e) {
      print("🔥 ProductRemoteDataSource: Error updating product: $e");
      throw ServerException();
    }
  }

  @override
  Future<ProductModel> getProductById(String id) async {
    try {
      print("🔍 ProductRemoteDataSource: Getting product ID: $id");
      final headers = await _getHeaders();

      print("📡 ProductRemoteDataSource: Sending GET request to $BASE_URL/$id");
      final response = await client.get(
        Uri.parse('$BASE_URL/$id'),
        headers: headers,
      );

      print("📢 ProductRemoteDataSource: Response status: ${response.statusCode}");

      if (response.statusCode == 200) {
        final decodedJson = json.decode(response.body);
        print("✅ ProductRemoteDataSource: Product found");
        final ProductModel productModel = ProductModel.fromJson(decodedJson);
        return productModel;
      } else {
        print("❌ ProductRemoteDataSource: Failed to get product. Status: ${response.statusCode}");
        throw ServerException();
      }
    } catch (e) {
      print("🔥 ProductRemoteDataSource: Error getting product: $e");
      throw ServerException();
    }
  }
}