import 'package:flutter/material.dart';
import 'package:dartz/dartz.dart';
import 'package:hanouty/Core/errors/exceptions.dart';
import 'package:hanouty/Core/errors/failuresconection.dart';
import 'package:hanouty/Presentation/review/domain/entity/review.dart';
import 'package:hanouty/Presentation/review/domain/usecases/create_review_usecase.dart';
import 'package:hanouty/Presentation/review/domain/usecases/get_reviews_by_user_id_usecase.dart';
import 'package:hanouty/Presentation/review/domain/usecases/update_review_usecase.dart';

class ReviewProvider extends ChangeNotifier {
  final CreateReviewUsecase createReviewUsecase;
  final UpdateReviewUsecase updateReviewUsecase;
  final GetReviewsByUserId getReviewsByUserId;

  ReviewProvider({
    required this.createReviewUsecase,
    required this.updateReviewUsecase,
    required this.getReviewsByUserId,
  });

  bool _isLoading = false;
  String _errorMessage = '';
  List<Review> _userReviews = [];

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  List<Review> get userReviews => _userReviews;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  /// Create a new review and update state.
  Future<bool> createNewReview(Review review, String idProduct) async {
    if (_isLoading) return false;
    _setLoading(true);

    bool success = false;
    try {
      await createReviewUsecase(review, idProduct);
      success = true;
      if (success) {
        print('Review created successfully for product: $idProduct');
      }
    } catch (e) {
      _errorMessage = e.toString();
    }

    _setLoading(false);
    return success;
  }

  /// Update an existing review by its ID.
  Future<bool> updateExistingReview(String idReview, Review review) async {
    if (_isLoading) return false;
    _setLoading(true);
    _errorMessage = '';

    bool success = false;
    try {
      await updateReviewUsecase(idReview, review);
      success = true;
      print('Review updated successfully for product: ${review.product}');
    } catch (e) {
      _errorMessage = e.toString();
    }
    _setLoading(false);
    return success;
  }

  /// Fetch reviews by user ID, updates local state and notifies listeners.
  Future<List<Review>> fetchReviewsByUserId(String userId) async {
    _setLoading(true);
    try {
      final reviews = await getReviewsByUserId(userId);
      _userReviews = reviews;
      _setLoading(false);
      print('Fetched user reviews successfully');
      return reviews;
    } catch (e) {
      _errorMessage = e.toString();
      _userReviews = [];
      _setLoading(false);
      print('Failed to fetch user reviews');
      return [];
    }
  }

  /// Helper: get user's review for a particular product (if exists)
  Review? getUserReviewForProduct(String productId) {
    try {
      return _userReviews.firstWhere((review) => review.product == productId);
    } catch (_) {
      return null;
    }
  }

  String _mapFailureToMessage(Failure failure) {
    if (failure is ServerFailure) {
      return 'Server Error';
    } else if (failure is ServerException) {
      return 'Network Error: Check your internet connection.';
    } else {
      return 'Failed to create review. Please try again.';
    }
  }

  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }
}