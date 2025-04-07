import 'package:equatable/equatable.dart';

class Review extends Equatable {
  final String id;
  final int rating;
  final String user;
  final String product;
  final DateTime createdAt;
  final DateTime updatedAt;

  Review({
    required this.id,
    required this.rating,
    required this.user,
    required this.product,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object> get props => [
        id,
        rating,
        user,
        product,
        createdAt,
        updatedAt,
      ];
}