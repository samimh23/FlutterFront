
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
    required super.images,
    required super.ratings,
    required super.isDiscounted,
    required super.discountValue,
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
      images: List<String>.from(json['images'] ?? []),
      ratings: (json['ratings'] ?? 0).toDouble(),
      isDiscounted: json['isDiscounted'] ?? false,
      discountValue: (json['DiscountValue'] ?? 0).toDouble(),
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
      'images': images,
      'ratings': ratings,
      'isDiscounted': isDiscounted,
      'DiscountValue': discountValue,
    };
  }
  
}
