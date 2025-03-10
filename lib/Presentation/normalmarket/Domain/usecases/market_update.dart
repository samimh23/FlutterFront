

import 'package:hanouty/Core/heritables/Markets.dart';
import 'package:hanouty/Presentation/normalmarket/Domain/repositories/normamarket_domain_repository.dart';

class UpdateNormalMarket {
  final NormalMarketRepository repository;

  UpdateNormalMarket(this.repository);

  Future<Markets> call(String id, Markets market, String? imagePath) async {
    return await repository.updateNormalMarket(id, market, imagePath);
  }
}