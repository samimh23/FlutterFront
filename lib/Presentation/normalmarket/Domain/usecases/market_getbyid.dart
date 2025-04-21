


import 'package:hanouty/Core/heritables/Markets.dart';
import 'package:hanouty/Presentation/normalmarket/Domain/entities/normalmarket_entity.dart';
import 'package:hanouty/Presentation/normalmarket/Domain/repositories/normamarket_domain_repository.dart';

class GetNormalMarketById {
  final NormalMarketRepository repository;

  GetNormalMarketById(this.repository);

  Future<NormalMarket> call(String id) async {
    return await repository.getNormalMarketById(id);
  }
}