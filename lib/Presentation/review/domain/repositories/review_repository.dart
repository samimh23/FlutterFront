import 'package:dartz/dartz.dart';
import 'package:hanouty/Presentation/review/data/models/review_model.dart';
import 'package:hanouty/Presentation/review/domain/entity/review.dart';

abstract class ReviewRepository {
  /// Get review by ID
  Future<Review> getReviewById(String id);

  /// Create new review
  Future<Unit> createReview(Review review, String idProduct);

  /// Update existing review
  Future<Review> updateReview(String idReview,Review review);

  /// Delete review
  Future<void> deleteReview(String id);

  /// Get reviews by product ID
  Future<List<Review>> getReviewsByProductId(String productId);

  /// Get reviews by user ID
  Future<List<Review>> getReviewsByUserId(String userId);
}
