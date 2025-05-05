import 'package:dartz/dartz.dart';
import 'package:hanouty/core/errors/failure.dart';
import '../entities/farm_crop.dart';
import '../repositories/farm_crop_repository.dart';

class AddFarmCrop {
  final FarmCropRepository repository;

  AddFarmCrop(this.repository);

  Future<Either<Failure, void>> call(FarmCrop farmCrop) {
    return repository.addFarmCrop(farmCrop);
  }
}