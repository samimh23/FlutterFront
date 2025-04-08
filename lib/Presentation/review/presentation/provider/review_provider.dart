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
  final GetReviewsByUserId getReviewsByUserId; // Add this line
  ReviewProvider(
      {required this.createReviewUsecase,
      required this.updateReviewUsecase,
      required this.getReviewsByUserId});

  bool _isLoading = false;
  String _errorMessage = '';

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  /// Create a new review and update state.
  Future<bool> createNewReview(Review review, String idProduct) async {
    if (_isLoading) return false; // Return false if already loading
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
      // Optionally, you can notify the UI or show a snackbar via your widget.
    }

    _setLoading(false);
    return success;
  }

  Future<bool> updateExistingReview(String idReview, Review review) async {
    if (_isLoading) return false;
    _setLoading(true);

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

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  /// Maps specific failure types to error messages.
  String _mapFailureToMessage(Failure failure) {
    if (failure is ServerFailure) {
      return 'Server Error';
    } else if (failure is ServerException) {
      return 'Network Error: Check your internet connection.';
    } else {
      return 'Failed to create review. Please try again.';
    }
  }

  /// Clears the current error message.
  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }

  Future<List<Review>> fetchReviewsByUserId(String userId) async {
    _setLoading(true);
    try {
      final reviews = await getReviewsByUserId(userId);
      _setLoading(false);
      print('yessssssssssss');
      return reviews;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      print('nooooooooooooooooo');

      return [];
    }
  }
}
