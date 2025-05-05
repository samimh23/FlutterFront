import 'package:dartz/dartz.dart';
import '../../repositories/farm_crop_repository.dart';
import 'package:hanouty/core/errors/failure.dart';

class ConvertFarmCropToProduct {
  final FarmCropRepository repository;

  ConvertFarmCropToProduct(this.repository);

  Future<Either<Failure, Map<String, dynamic>>> call(String cropId) {
    return repository.convertFarmCropToProduct(cropId);
  }
}