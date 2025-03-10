



import 'package:hanouty/Core/heritables/Markets.dart';
import 'package:hanouty/Presentation/normalmarket/Domain/repositories/normamarket_domain_repository.dart';

class CreateFractionalNFT {
  final NormalMarketRepository repository;

  CreateFractionalNFT(this.repository);

  Future<Markets> call(String marketId) async {
    return await repository.createNFTForMarket(marketId);
  }
}