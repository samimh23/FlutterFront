

import 'package:hanouty/Core/heritables/Markets.dart';
import 'package:hanouty/Presentation/normalmarket/Domain/repositories/normamarket_domain_repository.dart';

class GetNormalMarkets {
  final NormalMarketRepository repository;

  GetNormalMarkets(this.repository);

  Future<List<Markets>> call() async {
    return await repository.getNormalMarkets();
  }
}