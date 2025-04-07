import 'package:dartz/dartz.dart';
import 'package:hanouty/Presentation/review/domain/entity/review.dart';
import 'package:hanouty/Presentation/review/domain/repositories/review_repository.dart';

class CreateReviewUsecase {
  final ReviewRepository repository;

   CreateReviewUsecase(this.repository);
  
  Future<Unit> call(Review review,String idProduct) async {
    return await repository.createReview(review,idProduct);
  }
}