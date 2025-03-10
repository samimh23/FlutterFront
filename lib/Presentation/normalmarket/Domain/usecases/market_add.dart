


import 'package:hanouty/Core/heritables/Markets.dart';
import 'package:hanouty/Presentation/normalmarket/Domain/repositories/normamarket_domain_repository.dart';

class CreateNormalMarket {
  final NormalMarketRepository repository;

  CreateNormalMarket(this.repository);

  Future<Markets> call(Markets market, String imagePath) async {
    return await repository.createNormalMarket(market, imagePath);
  }
}