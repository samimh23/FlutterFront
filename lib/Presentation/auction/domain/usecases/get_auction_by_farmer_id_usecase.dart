import 'package:hanouty/Presentation/auction/domain/entity/auction.dart';
import 'package:hanouty/Presentation/auction/domain/repository/auction_repository.dart';

class GetAuctionsByFarmerId {
  final AuctionRepository repository;

  GetAuctionsByFarmerId(this.repository);

  Future<List<Auction>> call(String farmerId) async {
    return await repository.getAuctionsByFarmerId(farmerId);
  }
}