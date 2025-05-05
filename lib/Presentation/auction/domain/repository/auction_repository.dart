

import 'package:hanouty/Presentation/auction/domain/entity/auction.dart';
import 'package:hanouty/Presentation/auction/domain/entity/bid.dart';

abstract class AuctionRepository {
  /// Create a new auction
  Future<Auction> createAuction(Auction auction);

  /// Get all active auctions
  Future<List<Auction>> getActiveAuctions();

  /// Get auction by its ID
  Future<Auction> getAuctionById(String id);

  /// Place a bid on an auction by auctionId
  Future<Auction> placeBid(String auctionId, Bid bid);

  /// Update auction status (active, completed, cancelled)
  Future<Auction> updateAuctionStatus(String auctionId, AuctionStatus status);

  /// Get all auctions where the user (bidder) has placed a bid
  Future<List<Auction>> getAuctionsByBidderId(String bidderId);

  /// Get all unique bidder IDs for an auction
  Future<List<Bid>> getBiddersByAuctionId(String auctionId);

  Future<List<Auction>> getAuctionsByFarmerId(String farmerId);
}