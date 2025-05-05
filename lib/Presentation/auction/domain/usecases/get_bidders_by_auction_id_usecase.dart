import 'package:hanouty/Presentation/auction/domain/entity/bid.dart';
import 'package:hanouty/Presentation/auction/domain/repository/auction_repository.dart';

class GetBiddersByAuctionId {
  final AuctionRepository repository;

  GetBiddersByAuctionId(this.repository);

  Future<List<Bid>> call(String auctionId) async {
    return await repository.getBiddersByAuctionId(auctionId);
  }
}