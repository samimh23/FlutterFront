import 'package:equatable/equatable.dart';

enum ProductCategory {
    Vegetables,
    Drinks,
    Sweets,
    Fruits,
  }

class Product extends Equatable {
  final String id;
  final String name;
  final String description;
  final double price;
  final double originalPrice;
  final ProductCategory category;
  final int stock;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> images;
  final double ratings;
  final bool isDiscounted;
  final double discountValue;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.originalPrice,
    required this.category,
    required this.stock,
    required this.createdAt,
    required this.updatedAt,
    required this.images,
    required this.ratings,
    required this.isDiscounted,
    required this.discountValue,
  });

  @override
  List<Object> get props => [
        id,
        name,
        description,
        price,
        originalPrice,
        category,
        stock,
        createdAt,
        updatedAt,
        images,
        ratings,
        isDiscounted,
        discountValue,
      ];

}
