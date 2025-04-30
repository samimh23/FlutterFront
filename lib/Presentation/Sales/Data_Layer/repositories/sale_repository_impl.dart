
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../../Domain_Layer/entities/sale.dart';
import '../../Domain_Layer/repositories/Sale_Repository.dart';
import '../datasources/Sale_Remote_DataSource.dart';


class SaleRepositoryImpl implements SaleRepository {
  final SaleRemoteDataSource remoteDataSource;

  SaleRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Sale>>> getAllSales() async {
    try {
      final sales = await remoteDataSource.getAllSales();
      return Right(sales);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Sale>> getSaleById(String id) async {
    try {
      final sale = await remoteDataSource.getSaleById(id);
      return Right(sale);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> addSale(Sale sale) async {
    try {
      await remoteDataSource.addSale(sale);
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateSale(Sale sale) async {
    try {
      await remoteDataSource.updateSale(sale);
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteSale(String id) async {
    try {
      await remoteDataSource.deleteSale(id);
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Sale>>> getSalesByCropId(String cropId) async {
    try {
      final sales = await remoteDataSource.getSalesByCropId(cropId);
      return Right(sales);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  
  @override
  Future<Either<Failure, List<Sale>>> getSalesByFarmMarket(String farmMarketId)async {
    try {
      final remoteSales = await remoteDataSource.getSalesByFarmMarket(farmMarketId);
      return Right(remoteSales);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }


}