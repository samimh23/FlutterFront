import 'package:hanouty/Presentation/auction/domain/entity/auction.dart';
import 'package:hanouty/Presentation/auction/domain/repository/auction_repository.dart';

class CreateAuction {
  final AuctionRepository repository;

  CreateAuction(this.repository);

  Future<Auction> call(Auction auction) async {
    return await repository.createAuction(auction);
  }
}