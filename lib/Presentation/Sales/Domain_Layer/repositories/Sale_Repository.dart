// In Domain_Layer/repositories/sale_repository.dart

import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../entities/sale.dart';

abstract class SaleRepository {
  Future<Either<Failure, List<Sale>>> getAllSales();
  Future<Either<Failure, Sale>> getSaleById(String id);
  Future<Either<Failure, Unit>> addSale(Sale sale);
  Future<Either<Failure, Unit>> updateSale(Sale sale);
  Future<Either<Failure, Unit>> deleteSale(String id);
  Future<Either<Failure, List<Sale>>> getSalesByCropId(String cropId);
  Future<Either<Failure, List<Sale>>> getSalesByFarmMarket(String farmMarketId);
}