import 'package:dartz/dartz.dart';
import 'package:hanouty/Presentation/review/domain/entity/review.dart';
import 'package:hanouty/Presentation/review/domain/repositories/review_repository.dart';
import 'package:hanouty/Core/errors/failuresconection.dart';

class GetReviewsByUserId {
  final ReviewRepository repository;

  GetReviewsByUserId(this.repository);

  Future<List<Review>> call(String userId) async {
    return await repository.getReviewsByUserId(userId);
  }
}