import 'package:hanouty/Presentation/auction/domain/entity/auction.dart';
import 'package:hanouty/Presentation/auction/domain/repository/auction_repository.dart';

class GetAuctionById {
  final AuctionRepository repository;

  GetAuctionById(this.repository);

  Future<Auction> call(String id) async {
    return await repository.getAuctionById(id);
  }
}