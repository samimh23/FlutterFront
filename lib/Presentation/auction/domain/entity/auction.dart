import 'package:equatable/equatable.dart';
import 'package:hanouty/Presentation/auction/domain/entity/bid.dart';

enum AuctionStatus {
  active,
  completed,
  cancelled,
}

class Auction extends Equatable {
  final String id;
  final String cropId;
  final String description;
  final String farmerId;
  final List<Bid> bids;
  final double startingPrice;
  final DateTime startTime;
  final DateTime endTime;
  AuctionStatus? status;

  Auction({
    required this.id,
    required this.cropId,
    required this.description,
    required this.farmerId,
    required this.bids,
    required this.startingPrice,
    required this.startTime,
    required this.endTime,
    required this.status,
  });

  @override
  List<Object?> get props => [
    id,
    cropId,
    description,
    farmerId,
    bids,
    startingPrice,
    startTime,
    endTime,
    status
  ];
}