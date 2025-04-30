// In Domain_Layer/usecases/get_all_sales.dart
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../entities/sale.dart';
import '../repositories/Sale_Repository.dart';

class GetAllSales {
  final SaleRepository repository;

  GetAllSales(this.repository);

  Future<Either<Failure, List<Sale>>> call() async {
    return await repository.getAllSales();
  }
}