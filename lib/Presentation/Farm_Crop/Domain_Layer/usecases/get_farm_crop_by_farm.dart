
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../entities/farm_crop.dart';
import '../repositories/farm_crop_repository.dart';
class GetFarmCropsByFarmMarketId {
final FarmCropRepository repository;
GetFarmCropsByFarmMarketId(this.repository);
Future<Either<Failure, List<FarmCrop>>> call(String farmMarketId) async {
return await repository.getFarmCropsByFarmMarketId(farmMarketId);
}
}
