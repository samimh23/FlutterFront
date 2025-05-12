import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../repositories/farm_crop_repository.dart';

class UploadCropImage {
  final FarmCropRepository repository;

  UploadCropImage(this.repository);

  Future<Either<Failure, Map<String, dynamic>>> call(String cropId, File imageFile) async {
    return await repository.uploadCropImage(cropId, imageFile);
  }
}