import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../entities/farm_crop.dart';
import '../repositories/farm_crop_repository.dart';

class GetAllFarmCrops {
  final FarmCropRepository repository;

  GetAllFarmCrops(this.repository);

  Future<Either<Failure, List<FarmCrop>>> call() {
    return repository.getAllFarmCrops();
  }
}
