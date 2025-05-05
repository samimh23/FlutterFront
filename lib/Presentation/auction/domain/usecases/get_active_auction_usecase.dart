import 'package:hanouty/Presentation/auction/domain/entity/auction.dart';
import 'package:hanouty/Presentation/auction/domain/repository/auction_repository.dart';

class GetActiveAuctions {
  final AuctionRepository repository;

  GetActiveAuctions(this.repository);

  Future<List<Auction>> call() async {
    return await repository.getActiveAuctions();
  }
}