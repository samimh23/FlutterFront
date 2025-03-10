


import 'package:hanouty/Core/heritables/Markets.dart';
import 'package:hanouty/Presentation/normalmarket/Domain/repositories/normamarket_domain_repository.dart';

class DeleteNormalMarket {
  final NormalMarketRepository repository;

  DeleteNormalMarket(this.repository);

  Future<Markets> call(String id) async {
    return await repository.deleteNormalMarket(id);
  }
}