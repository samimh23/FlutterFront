import 'package:hanouty/Core/heritables/Markets.dart';
import 'package:hanouty/Presentation/normalmarket/Domain/repositories/normamarket_domain_repository.dart';

class GetMyNormalMarkets {
  final NormalMarketRepository repository;

  GetMyNormalMarkets(this.repository);

  Future<List<Markets>> call() async {
    return await repository.getMyNormalMarkets();
  }
}