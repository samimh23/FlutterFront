import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../repositories/farm_crop_repository.dart';

class DeleteFarmCrop {
  final FarmCropRepository repository;

  DeleteFarmCrop(this.repository);

  Future<Either<Failure, void>> call(String id) {
    return repository.deleteFarmCrop(id);
  }
}
