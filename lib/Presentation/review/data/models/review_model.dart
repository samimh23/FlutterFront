import 'package:hanouty/Presentation/review/domain/entity/review.dart';

class ReviewModel extends Review {
  ReviewModel({
    String? id, // Make id optional
    required int rating,
    String? user,
    required String product,
    DateTime? createdAt, // Make createdAt optional
    DateTime? updatedAt, // Make updatedAt optional
  }) : super(
          id: id ?? '', // Provide a default value if needed
          rating: rating,
          user: user ?? '', // Provide a default value
          product: product,
          createdAt: createdAt ?? DateTime.now(), // Default to current time
          updatedAt: updatedAt ?? DateTime.now(), // Default to current time
        );

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['_id'] is Map ? json['_id']['\$oid'] : json['_id'].toString(),
      rating: (json['rating'] ?? 0).toInt(),
      user: json['user'] ?? '',
      product: json['product'] ?? '',
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rating': rating,
      'product': product,
    };
  }
}