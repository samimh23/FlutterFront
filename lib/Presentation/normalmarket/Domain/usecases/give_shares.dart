
import 'package:hanouty/Presentation/normalmarket/Domain/entities/share_fraction.dart';
import 'package:hanouty/Presentation/normalmarket/Domain/repositories/normamarket_domain_repository.dart';

class ShareFractionalNFT {
  final NormalMarketRepository repository;

  ShareFractionalNFT(this.repository);

  Future<Map<String, dynamic>> call(
      String marketId, ShareFractionRequest request) async {
    return await repository.shareFractionalNFT(marketId, request);
  }
}
