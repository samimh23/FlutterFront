
import 'package:hanouty/Presentation/product/domain/entities/product.dart';

class ProductModel extends Product {
  ProductModel({
    required super.id,
    required super.name,
    required super.description,
    required super.price,
    required super.originalPrice,
    required super.category,
    required super.stock,
    required super.createdAt,
    required super.updatedAt,
    super.image,
    super.ratingsAverage,
    super.ratingsQuantity,
    required super.isDiscounted,
    required super.discountValue,
    required super.shop
  });

  static ProductCategory productCategoryFromString(String value) =>
    ProductCategory.values.firstWhere(
      (e) => e.toString().split('.').last.toLowerCase() == value.toLowerCase(),
      orElse: () => ProductCategory.Vegetables, 
    );

  static String productCategoryToString(ProductCategory category) =>
    category.toString().split('.').last;

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['_id'] is Map ? json['_id']['\$oid'] : json['_id'].toString(),
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      originalPrice: (json['originalPrice'] ?? 0).toDouble(),
      category: productCategoryFromString(json['category'] ?? ''),
      stock: (json['stock'] ?? 0).toInt(),
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? '') ?? DateTime.now(),
      image: json['image'] as String?, // Keep using the singular "image" field
      ratingsQuantity: (json['ratingsQuantity']?? 0).toInt(),
      ratingsAverage: (json['ratingsAverage'] ?? 0).toInt(),
      isDiscounted: json['isDiscounted'] ?? false,
      discountValue: (json['DiscountValue'] ?? 0).toDouble(),
      shop: json['shop']?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'description': description,
      'price': price,
      'originalPrice': originalPrice,
      'category': productCategoryToString(category),
      'stock': stock,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'image': image, // Keep using the singular "image" field
      'ratingsAverage': ratingsAverage,
      'ratingsQuantity': ratingsQuantity,
      'isDiscounted': isDiscounted,
      'DiscountValue': discountValue,
      'shop': shop,
    };
  }
  
}
