import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../entities/farm_crop.dart';
import '../repositories/farm_crop_repository.dart';

class UpdateFarmCrop {
  final FarmCropRepository repository;

  UpdateFarmCrop(this.repository);

  Future<Either<Failure, void>> call(FarmCrop farmCrop) {
    return repository.updateFarmCrop(farmCrop);
  }
}
