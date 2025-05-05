import 'package:hanouty/Presentation/auction/domain/entity/auction.dart';
import 'package:hanouty/Presentation/auction/domain/repository/auction_repository.dart';

class GetAuctionsByBidderId {
  final AuctionRepository repository;

  GetAuctionsByBidderId(this.repository);

  Future<List<Auction>> call(String bidderId) async {
    return await repository.getAuctionsByBidderId(bidderId);
  }
}