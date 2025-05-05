import 'package:hanouty/Presentation/auction/domain/entity/auction.dart';
import 'package:hanouty/Presentation/auction/domain/repository/auction_repository.dart';

class UpdateAuctionStatus {
  final AuctionRepository repository;

  UpdateAuctionStatus(this.repository);

  Future<Auction> call(String auctionId, AuctionStatus status) async {
    return await repository.updateAuctionStatus(auctionId, status);
  }
}