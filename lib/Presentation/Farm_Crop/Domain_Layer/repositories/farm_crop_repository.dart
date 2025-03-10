// In Domain_Layer/repositories/farm_crop_repository.dart
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../entities/farm_crop.dart';

abstract class FarmCropRepository {
  Future<Either<Failure, List<FarmCrop>>> getAllFarmCrops();
  Future<Either<Failure, FarmCrop>> getFarmCropById(String id);
  Future<Either<Failure, void>> addFarmCrop(FarmCrop farmCrop);
  Future<Either<Failure, void>> updateFarmCrop(FarmCrop farmCrop);
  Future<Either<Failure, void>> deleteFarmCrop(String id);
}
