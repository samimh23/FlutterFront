import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../repositories/farm_repository.dart';

class UploadFarmImage {
  final FarmMarketRepository repository;

  UploadFarmImage(this.repository);

  Future<Either<Failure, String>> call(String farmId, String imagePath) async {
    return await repository.uploadFarmImage(farmId, imagePath);
  }
}