import 'package:dartz/dartz.dart';
import 'package:hanouty/Core/errors/exceptions.dart';
import 'package:hanouty/Core/errors/failuresconection.dart';
import 'package:hanouty/Core/network/network_info.dart';
import 'package:hanouty/Presentation/review/data/datasources/review_remote_data_source.dart';
import 'package:hanouty/Presentation/review/data/models/review_model.dart';
import 'package:hanouty/Presentation/review/domain/entity/review.dart';
import 'package:hanouty/Presentation/review/domain/repositories/review_repository.dart';



class ReviewRepositoryImpl implements ReviewRepository {
  final ReviewRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  ReviewRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Review> getReviewById(String id) async {
    if (await networkInfo.isConnected) {
      try {
        final review = await remoteDataSource.getReviewById(id);
        return review;
      } on ServerException {
        throw ServerFailure();
      }
    } else {
      throw OfflineFailure();
    }
  }

  @override
  Future<Unit> createReview(Review review, String idProduct) async {
    final ReviewModel reviewModel = ReviewModel(
      rating: review.rating,
      product: review.product,
    );

    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.createReview(reviewModel, idProduct);
        return unit;
      } on ServerException {
        throw ServerFailure();
      }
    } else {
      throw OfflineFailure();
    }
  }
  
  @override
  Future<void> deleteReview(String id) {
    // TODO: implement deleteReview
    throw UnimplementedError();
  }
  
  @override
  Future<List<Review>> getReviewsByProductId(String productId) {
    // TODO: implement getReviewsByProductId
    throw UnimplementedError();
  }
  
  @override
  Future<List<ReviewModel>> getReviewsByUserId(String userId) async {
    if (await networkInfo.isConnected) {
      try {
        final reviewModels = await remoteDataSource.getReviewsByUserId(userId);
        return reviewModels.map((model) => ReviewModel(
          id: model.id,
          rating: model.rating,
          user: model.user,
          product: model.product,
          createdAt: model.createdAt,
          updatedAt: model.updatedAt,
        )).toList();
      } on ServerException {
        throw ServerFailure();
      }
    } else {
      throw OfflineFailure();
    }
  }
  
  @override
  Future<ReviewModel> updateReview(String reviewId,Review review) async{
     final ReviewModel reviewModel = ReviewModel(
      rating: review.rating,
      product: review.product,
    );
if (await networkInfo.isConnected) {
  try {
    final updatedReview = await remoteDataSource.updateReview(reviewId,reviewModel);
    return updatedReview;
  } on ServerException {
    throw ServerFailure();
  }
} else {
  throw OfflineFailure();
}
    throw UnimplementedError();
  }

  
}


