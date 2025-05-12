import '../repositories/farm_crop_repository.dart';

class GetCropImageUrl {
  final FarmCropRepository repository;

  GetCropImageUrl(this.repository);

  String call(String? imagePath) {
    return repository.getCropImageUrl(imagePath);
  }
}