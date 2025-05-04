import 'package:dartz/dartz.dart';
import '../../repositories/farm_crop_repository.dart';
import 'package:hanouty/core/errors/failure.dart';


class ProcessAllConfirmedFarmCrops {
  final FarmCropRepository repository;

  ProcessAllConfirmedFarmCrops(this.repository);

  Future<Either<Failure, Map<String, dynamic>>> call() {
    return repository.processAllConfirmedFarmCrops();
  }
}