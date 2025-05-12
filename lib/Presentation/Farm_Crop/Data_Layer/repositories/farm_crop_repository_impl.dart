import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../../Domain_Layer/entities/farm_crop.dart';
import '../../Domain_Layer/repositories/farm_crop_repository.dart';
import '../datasources/farm_crop_remote_data_source.dart';

class FarmCropRepositoryImpl implements FarmCropRepository {
  final FarmCropRemoteDataSource remoteDataSource;

  FarmCropRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<FarmCrop>>> getAllFarmCrops() async {
    try {
      final crops = await remoteDataSource.getAllCrops();
      return Right(crops);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, FarmCrop>> getFarmCropById(String id) async {
    try {
      final crop = await remoteDataSource.getCropById(id);
      return Right(crop);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<FarmCrop>>> getFarmCropsByFarmMarketId(String farmMarketId) async {
    try {
      final crops = await remoteDataSource.getCropsByFarmMarketId(farmMarketId);
      return Right(crops);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addFarmCrop(FarmCrop farmCrop) async {
    try {
      await remoteDataSource.addCrop(farmCrop);
      return const Right(null);
    } catch (e) {
      print("Repository Error: $e");
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateFarmCrop(FarmCrop farmCrop) async {
    try {
      await remoteDataSource.updateCrop(farmCrop);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteFarmCrop(String id) async {
    try {
      await remoteDataSource.deleteCrop(id);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  //farm-crop convert

  @override
  Future<Either<Failure, Map<String, dynamic>>> convertFarmCropToProduct(String cropId) async {
    try {
      final result = await remoteDataSource.convertToProduct(cropId);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> confirmAndConvertFarmCrop(String cropId, String auditReport) async {
    try {
      final result = await remoteDataSource.confirmAndConvert(cropId, auditReport);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> processAllConfirmedFarmCrops() async {
    try {
      final result = await remoteDataSource.processAllConfirmed();
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  // New method implementation for uploading crop images
  @override
  Future<Either<Failure, Map<String, dynamic>>> uploadCropImage(String cropId, File imageFile) async {
    try {
      final result = await remoteDataSource.uploadCropImage(cropId, imageFile);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  // Helper to get full image URL
  @override
  String getCropImageUrl(String? imagePath) {
    return remoteDataSource.getCropImageUrl(imagePath);
  }
}