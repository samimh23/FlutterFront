import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:hanouty/Core/errors/exceptions.dart';
import 'package:hanouty/Presentation/product/data/models/product_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class ProductLocalDataSource {
  Future<List<ProductModel>> getCachedProducts();

  Future<Unit> chacheProducts(List<ProductModel> productModels);
}
const CACHED_PRODUCTS = "CACHED_PRODUCTS";
class ProductLocalDataSourceImpl implements ProductLocalDataSource {
  final SharedPreferences sharedPreferences;

  ProductLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<Unit> chacheProducts(List<ProductModel> productModels) {
    List productModelToJson =
        productModels
            .map<Map<String, dynamic>>((productModel) => productModel.toJson())
            .toList();
    sharedPreferences.setString(
      CACHED_PRODUCTS,
      json.encode(productModelToJson),
    );
    return Future.value(unit);
  }

  @override
  Future<List<ProductModel>> getCachedProducts() {
    final jsonString = sharedPreferences.getString(CACHED_PRODUCTS);

    if (jsonString != null) {
      List decodeJsonData = json.decode(jsonString);
      List<ProductModel> jsonToProductModels =
          decodeJsonData
              .map<ProductModel>(
                (jsonProductModel) => ProductModel.fromJson(jsonProductModel),
              )
              .toList();
      return Future.value(jsonToProductModels);
    } else {
      throw EmptyCacheException();
    }
  }
}
