


import 'package:hanouty/Core/heritables/Markets.dart';
import 'package:hanouty/Presentation/normalmarket/Domain/repositories/normamarket_domain_repository.dart';

class GetNormalMarketById {
  final NormalMarketRepository repository;

  GetNormalMarketById(this.repository);

  Future<Markets> call(String id) async {
    return await repository.getNormalMarketById(id);
  }
}