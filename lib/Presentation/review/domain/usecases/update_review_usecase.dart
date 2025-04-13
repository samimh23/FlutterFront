import 'package:hanouty/Presentation/review/domain/entity/review.dart';
import 'package:hanouty/Presentation/review/domain/repositories/review_repository.dart';

class UpdateReviewUsecase {
  final ReviewRepository repository;

  UpdateReviewUsecase(this.repository);

  Future<Review> call(String idReview,Review review) async {
    return await repository.updateReview(idReview,review);
  }
}