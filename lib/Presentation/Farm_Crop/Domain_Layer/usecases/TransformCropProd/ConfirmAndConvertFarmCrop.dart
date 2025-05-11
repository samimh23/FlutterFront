import 'package:dartz/dartz.dart';
import '../../repositories/farm_crop_repository.dart';
import 'package:hanouty/core/errors/failure.dart';

class ConfirmAndConvertFarmCrop {
  final FarmCropRepository repository;

  ConfirmAndConvertFarmCrop(this.repository);

  Future<Either<Failure, Map<String, dynamic>>> call(String cropId, String auditReport) {
    return repository.confirmAndConvertFarmCrop(cropId, auditReport);
  }
}