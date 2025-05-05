import 'package:hanouty/Presentation/auction/data/datasource/auction_remote_datasource.dart';
import 'package:hanouty/Presentation/auction/data/models/auction_model.dart';
import 'package:hanouty/Presentation/auction/data/models/bid_model.dart';
import 'package:hanouty/Presentation/auction/domain/entity/auction.dart';
import 'package:hanouty/Presentation/auction/domain/entity/bid.dart';
import 'package:hanouty/Presentation/auction/domain/repository/auction_repository.dart';

class AuctionRepositoryImpl implements AuctionRepository {
  final AuctionRemoteDataSource remoteDataSource;

  AuctionRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Auction> createAuction(Auction auction) async {
    final auctionModel = AuctionModel(
      id: auction.id,
      cropId: auction.cropId,
      description: auction.description,
      farmerId: auction.farmerId,
      bids: auction.bids,
      startingPrice: auction.startingPrice,
      startTime: auction.startTime,
      endTime: auction.endTime,
      status: auction.status,
    );
    return await remoteDataSource.createAuction(auctionModel);
  }

  @override
  Future<List<Auction>> getActiveAuctions() async {
    return await remoteDataSource.getActiveAuctions();
  }

  @override
  Future<Auction> getAuctionById(String id) async {
    return await remoteDataSource.getAuctionById(id);
  }

  @override
  Future<Auction> placeBid(String auctionId, Bid bid) async {
    final bidModel = BidModel(
      bidderId: bid.bidderId,
      bidAmount: bid.bidAmount,
      bidTime: bid.bidTime,
    );
    return await remoteDataSource.placeBid(auctionId, bidModel);
  }

  @override
  Future<Auction> updateAuctionStatus(String auctionId, AuctionStatus status) async {
    return await remoteDataSource.updateAuctionStatus(auctionId, status);
  }

  @override
  Future<List<Auction>> getAuctionsByBidderId(String bidderId) async {
    return await remoteDataSource.getAuctionsByBidderId(bidderId);
  }

  @override
  Future<List<BidModel>> getBiddersByAuctionId(String auctionId) async {
    return await remoteDataSource.getBiddersByAuctionId(auctionId);
  }

  @override
  Future<List<Auction>> getAuctionsByFarmerId(String farmerId) async{
    return await remoteDataSource.getAuctionsByFarmerId(farmerId);
  }
}