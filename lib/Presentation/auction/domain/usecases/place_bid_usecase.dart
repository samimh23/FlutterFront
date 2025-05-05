import 'package:hanouty/Presentation/auction/domain/entity/auction.dart';
import 'package:hanouty/Presentation/auction/domain/entity/bid.dart';
import 'package:hanouty/Presentation/auction/domain/repository/auction_repository.dart';

class PlaceBid {
  final AuctionRepository repository;

  PlaceBid(this.repository);

  Future<Auction> call(String auctionId, Bid bid) async {
    return await repository.placeBid(auctionId, bid);
  }
}