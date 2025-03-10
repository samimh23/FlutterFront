import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../entities/farm_crop.dart';
import '../repositories/farm_crop_repository.dart';

class GetFarmCropById {
  final FarmCropRepository repository;

  GetFarmCropById(this.repository);

  Future<Either<Failure, FarmCrop>> call(String id) {
    return repository.getFarmCropById(id);
  }
}
