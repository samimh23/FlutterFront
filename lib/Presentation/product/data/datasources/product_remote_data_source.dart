import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:hanouty/Core/errors/exceptions.dart';
import 'package:hanouty/Presentation/product/data/models/product_model.dart';
import 'package:http/http.dart' as http;

abstract class ProductRemoteDataSource {
  Future<List<ProductModel>> getAllProducts();

  Future<Unit> deleteProduct(int id);

  Future<Unit> updateProduct(ProductModel productModel);

  Future<Unit> addProduct(ProductModel productModel);
}

const BASE_URL = "http://127.0.0.1:3000/product";

class ProductRemoteDataSourceImpl extends ProductRemoteDataSource {
  final http.Client client;

  ProductRemoteDataSourceImpl({required this.client});

  @override
  Future<Unit> addProduct(ProductModel productModel) async {
    final body = {
      "name": productModel.name,
      "price": productModel.price,
      "stock": productModel.stock,
      "originalPrice": productModel.originalPrice,
      "images": productModel.images,
      "description": productModel.description,
      "category": productModel.category,
      "createdAt": productModel.createdAt,
      "updatedAt": productModel.updatedAt,
      "ratings": productModel.ratings,
      "isDiscounted": productModel.isDiscounted,
      "discountValue": productModel.discountValue,
    };
    final response = await client.post(Uri.parse(BASE_URL), body: body);
    if (response.statusCode == 201) {
      return Future.value(unit);
    } else {
      throw ServerException();
    }
  }

  @override
  Future<Unit> deleteProduct(int id) async {
    final response = await client.delete(
      Uri.parse(BASE_URL + "/${id.toString()}"),
      headers: {"Content-Type": "application/json"},
    );
    if (response.statusCode == 200) {
      return Future.value(unit);
    } else {
      throw ServerException();
    }
  }

  @override
  Future<List<ProductModel>> getAllProducts() async {
    
    final response = await client.get(
      Uri.parse(BASE_URL),
      headers: {"Content-Type": "application/json"},
    );
    
    if (response.statusCode == 200) {
      final List decodedJson = json.decode(response.body) as List;
      final List<ProductModel> productModels =
          decodedJson
              .map<ProductModel>(
                (jsonProductModel) => ProductModel.fromJson(jsonProductModel),
              )
              .toList();
      return productModels;
    } else {
      throw ServerException();
    }
  }

  @override
  Future<Unit> updateProduct(ProductModel productModel) async {
    final productId = productModel.id.toString;
    final body = {
      "name": productModel.name,
      "price": productModel.price,
      "stock": productModel.stock,
      "originalPrice": productModel.originalPrice,
      "images": productModel.images,
      "description": productModel.description,
      "category": productModel.category,
      "createdAt": productModel.createdAt,
      "updatedAt": productModel.updatedAt,
      "ratings": productModel.ratings,
      "isDiscounted": productModel.isDiscounted,
      "discountValue": productModel.discountValue,
    };

    final response = await client.patch(
      Uri.parse("$BASE_URL/$productId"),
      body: body,
    );
    if (response.statusCode == 200) {
      return Future.value(unit);
    } else {
      throw ServerException();
    }
  }

  
}
